part of australiasim;

/**
 * Handles View operations of the game.
 */
class GameView extends DOMView {

  /**
   * Scale to use when converting cm to pixel.
   */
  double _pixelScale = 0.5;

  /**
   * Whether to use Gyro Sensor as Input.
   */
  bool _useGyrosensor = false;

  /**
   * Gamemode reference.
   */
  GameMode _gameMode;

  /**
   * LevelManger reference.
   */
  LevelManager _levelManager;

  // Static DOM Elements
  static final _mainElement  = querySelector("#main");
  static final _menuLayer    = querySelector("#menuLayer");
  static final _gameLayer    = querySelector("#gameLayer");
  static final _inputLayer   = querySelector("#inputLayer");
  static final _inputKnob    = querySelector("#inputKnob");

  /**
   * Passes Streams of input positions.
   */
  Stream<Stream<Vector2>> onInput;
  StreamController<Stream<Vector2>> _inputEvent = new StreamController();
  
  Stream<Level> onSelectLevel;
  StreamController<Level> _selectLevelEvent = new StreamController();

  /**
   * If the game is currently running.
   */
  get running => this._gameMode.running;

  set useGyrosensor(bool val) {
    window.localStorage["useGyrosensor"] = val ? "1" : "0";
    _useGyrosensor = val;
    if (val) {
      activate(get("useGyrosensor"));
    } else {
      deactivate(get("useGyrosensor"));
    }
  }

  bool get useGyrosensor => _useGyrosensor;

  /**
   * GameView constructor.
   */
  GameView(GameMode this._gameMode, LevelManager this._levelManager) {
    onInput = _inputEvent.stream.asBroadcastStream(); // Create Broadcast stream of inputEvent
    onSelectLevel = _selectLevelEvent.stream.asBroadcastStream(); // Create Broadcast stream of inputEvent
    _mainElement.classes.add("loaded"); // Indicate that the game program has loaded
    //useGyrosensor = window.localStorage["useGyrosensor"] == "1";
    get("startGame").onClick.listen((e) => _selectLevelEvent.add(_levelManager.get(_levelManager.current)));
  }
  
  /**
   * Closes the game view and shows the menu.
   */
  closeGameView(bool failed) async {
    // Reset Game
    _gameLayer.setInnerHtml("");

    get("startGame").setInnerHtml(failed ? "RETRY!" : _levelManager.current > 0 ? "CONTINUE!" : "ENTER!");

    if (_levelManager.unlocked > 0) {
        show(get("selectLevel"));
        final levelSelection = get("levelSelection");

        for (var i = 0; i < _levelManager.unlocked; i++) {
            final level = _levelManager.get(i);
            if (get("level-${i}") == null) {
                levelSelection.appendHtml("<button class='btn' id='level-${i}'>Level ${i + 1}</button>");
                get("level-${i}").onClick.listen((e) => _selectLevelEvent.add(level));
            }
        }
    }

    clearCache();

    // Toggle States
    hide(_gameLayer);
    show(_menuLayer);
    activate(_menuLayer);
    deactivate(_gameLayer);
    deactivate(_inputLayer);

    await nextFrame(); // Waiting for the next frame, otherwise the css activation animations wouldn't play.

    deactivate(_mainElement);
  }

  /**
   * Creates a new game view and hides the menu.
   */
  openGameView() async {
    // Setup Elements
    var worldElement = get("world");

    if (get("bigLabel") == null)                create(_gameLayer, "bigLabel");
    if (worldElement    == null) worldElement = create(_gameLayer, "world");

    final statsElement = create(_gameLayer, "stats");
    final enemyCountElement = create(statsElement, "enemyCount");
    _gameMode.onEnemyCountChange.listen((count) => enemyCountElement.setInnerHtml("Enemies left: ${count}"));

    // Setup World Dimensions
    setDimensions(worldElement, _gameMode.world.size * _pixelScale);
    
    // Setup Listeners
    _gameMode.world.onActorSpawned.listen(createActor);
    _gameMode.world.onActorRemoved.listen(removeActor);
    for (var actor in _gameMode.world.actors) createActor(actor);

    // Toggle States
    show(_gameLayer);
    hide(_menuLayer);
    activate(_mainElement);
    activate(_inputLayer);

    await nextFrame();

    deactivate(_menuLayer);
    activate(_gameLayer);
  }

  hintBig(String text, Duration duration) async {

    // Setup Label
    final bigLabel = get("bigLabel");
    bigLabel.setInnerHtml(text);

    // Show Label for duration
    await timeout(duration, before: () => activate(bigLabel), after:  () => deactivate(bigLabel));
  }

  /**
   * Creates a new Actor in the view based on the model.
   */
  createActor(Actor actor) {
    // Check if running
    if (!running) return;

    // Check if Actor already exists.
    var el = get(actor.name);
    if (el != null) return;

    // Handle Character seperately.
    if (actor is Character) { 
      createCharacter(actor);
      return;
    }

    // Create Actor Element
    el = create(get("world"), actor.name);

    // Mark Element as Actor
    el.classes.add("actor");

    // Make Actor circular if necessary
    if (actor.isCircleCollider) el.classes.add("circle");

    // Actor update listener
    updateActorPos(Vector2 vec) => move(el, vec * _pixelScale);
    updateActorRot(Vector2 vec) => rotate(el, vec);
    updateActorScale(Vector2 vec) => scale(el, vec / 100.0);

    // Register listeners
    if (actor is Pawn) {

      actor.onMove.listen((vec) => updateActorPos(vec));
      actor.onRotate.listen((vec) => updateActorRot(vec));
      actor.onScale.listen((vec) => updateActorScale(vec));
      updateActorPos(actor.location);
      updateActorRot(actor.rotation);
      updateActorScale(actor.scale);

      el.classes.add("pawn");
      if (actor is Enemy)  makeEnemy(el, actor);
      
    } else if (actor is Prop) {

      updateActorPos(actor.location - actor.scale / 2.0);
      updateActorRot(actor.rotation);
      setDimensions(el, actor.scale * _pixelScale);

      el.classes.add("prop");
      if (actor is Tree)   el.classes.add("tree");
      if (actor is Shrub)  el.classes.add("shrub");
      if (actor is Door)   makeDoor(el, actor);
    }
  }

  /**
   * Removes the Actor from the view.
   */
  removeActor(Actor actor) {
    remove(actor.name);
  }

  /**
   * Creates a new Character in the View based on the model.
   */
  createCharacter(Character char) {

    // Create Character
    final el = create(_gameLayer, char.name);
    final livesElement = create(get("stats"), "lives");

    // Mark Element as Actor and Character 
    el.classes.add("actor");
    el.classes.add("pawn");
    el.classes.add("character");
    el.attributes["position"] = "translate(-50%, -50%)";

    final world = get("world");
    // Setup listener
    moveCamera(Vector2 pos) => move(world, pos * -_pixelScale);

    updateLives(lives) {
      var text = "";
      for (var i = 0; i < lives; i++) {
        text += "<i class='fa fa-heart'></i>";
      }
      livesElement.setInnerHtml(text);
    }

    // Register listener
    char.onMove.listen((vec) => moveCamera(vec));
    char.onRotate.listen((vec) {
      final radians = atan2(vec.x, vec.y);
      if (radians > PI * 4/5 || radians < -PI * 4/5) {  // North
        el.style.backgroundPositionY = "-525px";
      } else if (radians < -PI / 5) { // East
        el.style.backgroundPositionY = "-589px";
      } else if (radians < PI / 5) {  // South
        el.style.backgroundPositionY = "-653px";
      } else {  // West
        el.style.backgroundPositionY = "-717px";
      }
    });
    char.onScale.listen((vec) => scale(el, vec / 90.0));
    char.onLivesChange.listen(updateLives);

    // Initial update
    moveCamera(char.location);
    scale(el, char.scale / 90.0);
    updateLives(char.charLives);
  }

  /**
   * Turns an Actor Element into a Door.
   */
  makeDoor(Element el, Door door) {

    // Mark as door
    el.classes.add("door");
    
    // Feedback when user touches door
    new Observable(door.onCollide)
      .throttle( new Duration(seconds: 4) )
      .where( (Actor a) => a is Character )
      .listen( (Actor a) => hintBig("You wanna leave already?", new Duration(seconds: 3)) );

  
    new Observable(door.onCollide)
      .throttle( new Duration(seconds: 1) )
      .listen( (Actor a) async {
        activate(el);
        await timeout(new Duration(milliseconds: 250));
        deactivate(el);
      } );
  }

  /**
   * Turns an Actor Element into an Enemy.
   */
  makeEnemy(Element el, Enemy enemy) {

    // Mark as enemy
    el.classes.add("enemy");

    if (enemy is Spider) el.classes.add("spider");
    if (enemy is BigSpider) el.classes.add("big");
    if (enemy is BigRedSpider) el.classes.add("red");


    final cozynessEl = create(el, enemy.name + "-cozyness");
    cozynessEl.classes.add("cozyness");

    final cozynessPercentageEl = create(cozynessEl, enemy.name + "-cozyness-percentage");
    final barSize = new Vector2(max(enemy.scale.x, 100.0), 20.0) * _pixelScale;
    setDimensions(cozynessEl, barSize);
    setDimensions(cozynessPercentageEl, new Vector2(0.0, barSize.y));

    new Observable(enemy.onCozynessChange)
      .throttle(new Duration(milliseconds: 500))
      .listen( (double cozyness) => this.setDimensions(cozynessPercentageEl, new Vector2(barSize.x / 100 * cozyness, barSize.y)) );
    
    // Feedback when user touches enemy
    new Observable(enemy.onCollide)
      .throttle(new Duration(seconds: 4))
      .where( (Actor a) => a is Character )
      .listen( (Actor a) => hintBig("Be careful touching that!", new Duration(seconds: 3)) );
  }




  /**
   * Listens on the input and passes them to inputEvents.
   */
  setupInput(Function cb) {
    //StreamController<Vector2> touchEvent;
    Vector2 origin;

    /*window.onDeviceOrientation.listen((e) {
      if (useGyrosensor) {
        if (running) {
          if (touchEvent == null) {
            touchEvent = new StreamController();
            _inputEvent.add(touchEvent.stream);
          }

          final target = new Vector2(
            e.gamma, // In degree in the range [-90,90]
            max(-90.0, min(90.0, e.beta))  // In degree in the range [-90,90]
          );

          touchEvent.add(target * 3.0); // Convert to percentage.
        } else if(touchEvent != null) {
          touchEvent.add(new Vector2.zero());
          touchEvent.close();
          touchEvent = null;
        }
      }
    });*/

    relay(TouchEvent e) => cb(new Vector2((e.touches[0].page.x - origin.x) / _pixelScale, (e.touches[0].page.y - origin.y) / _pixelScale));

    _inputLayer.onTouchStart.listen((e) {
      e.preventDefault();
      if (running && !useGyrosensor) {

        origin = new Vector2(e.touches[0].page.x, e.touches[0].page.y);
        
        relay(e);
        move(_inputKnob, origin - new Vector2(25.0, 25.0));

        activate(get("Character"));
        activate(_inputKnob);
        get("world").classes.add("changing");
      }
    });

    _inputLayer.onTouchMove.listen((e) {
      e.preventDefault();
      if (running && !useGyrosensor) {
        relay(e);
      }
    });

    _inputLayer.onTouchEnd.listen((e) {
      e.preventDefault();
      if (!useGyrosensor) {
        if (running) {
          cb(new Vector2.zero());
          deactivate(get("Character"));
          get("world").classes.remove("changing");
        }
        deactivate(_inputKnob);
      }
    });
  }
}