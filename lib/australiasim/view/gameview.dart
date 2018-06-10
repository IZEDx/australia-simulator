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
    _mainElement.classes.add("loaded"); // Indicate that the game program has loaded
    useGyrosensor = window.localStorage["useGyrosensor"] == "1";
  }
  
  /**
   * Closes the game view and shows the menu.
   */
  closeGameView() async {
    // Reset Game
    _gameLayer.setInnerHtml("");

    get("startGame").setInnerHtml(_levelManager.current > 0 ? "CONTINUE!" : "ENTER!");
    
    if (_levelManager.unlocked > 0) {
      show(get("selectLevel"));
    }

    // Toggle States
    hide(_gameLayer);
    show(_menuLayer);

    await nextFrame(); // Waiting for the next frame, otherwise the css activation animations wouldn't play.

    activate(_menuLayer);
    deactivate(_mainElement);
    deactivate(_gameLayer);
    deactivate(_inputLayer);
  }

  /**
   * Creates a new game view and hides the menu.
   */
  openGameView() async {
    // Setup Elements
    var worldElement = get("world");

    if (get("bigLabel") == null)                create(_gameLayer, "bigLabel");
    if (worldElement    == null) worldElement = create(_gameLayer, "world");

    // Setup World Dimensions
    setDimensions(worldElement, _gameMode.world.size * _pixelScale);
    
    // Setup Listeners
    _gameMode.world.onActorSpawned.listen(createActor);
    _gameMode.world.onActorRemoved.listen(removeActor);
    for (var actor in _gameMode.world.actors) createActor(actor);

    // Toggle States
    show(_gameLayer);
    hide(_menuLayer);

    await nextFrame();

    deactivate(_menuLayer);
    activate(_mainElement);
    activate(_gameLayer);
    activate(_inputLayer);

    // Welcome User
    hintBig("Welcome home!", new Duration(seconds: 4));
  }

  hintBig(String text, Duration duration) async {
    // Check if running
    if (!running) return;

    // Setup Label
    final bigLabel = get("bigLabel");
    bigLabel.setInnerHtml(text);

    // Show Label for duration
    timeout(duration, before: () => activate(bigLabel), after:  () => deactivate(bigLabel));
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
    updateActorPos() => move(el, (actor.location - actor.scale / 2.0) * _pixelScale);
    updateActorScale() => setDimensions(el, actor.scale * _pixelScale);
    updateActorRot() => rotate(el, actor.rotation);

    // Register listeners
    if (actor is Pawn) {
      el.classes.add("pawn");
      actor.onMove.listen((vec) => updateActorPos());
      actor.onRotate.listen((vec) => updateActorRot());
      actor.onScale.listen((vec) => updateActorScale());
    } else if (actor is Prop) {
      el.classes.add("prop");
    }

    // Initial update
    updateActorPos();
    updateActorRot();
    updateActorScale();

    // Branch if actor is door
    if (actor is Door) {
      makeDoor(el, actor);
    }

    // Branch if actor is enemy
    else if (actor is Enemy) {
      makeEnemy(el, actor);
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

    // Mark Element as Actor and Character 
    el.classes.add("actor");
    el.classes.add("pawn");
    el.classes.add("character");
    el.attributes["position"] = "translate(-50%, -50%)";

    // Setup listener
    moveCamera(Vector2 pos) => move(get("world"), pos * -_pixelScale);

    // Register listener
    char.onMove.listen((vec) => moveCamera(vec));
    char.onRotate.listen((vec) => rotate(el, vec));

    // Initial update
    moveCamera(char.location);
    rotate(el, char.rotation);
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
  }

  /**
   * Turns an Actor Element into an Enemy.
   */
  makeEnemy(Element el, Enemy enemy) {

    // Mark as enemy
    el.classes.add("enemy");
    
    // Feedback when user touches enemy
    new Observable(enemy.onCollide)
      .throttle(new Duration(seconds: 4))
      .where( (Actor a) => a is Character )
      .listen( (Actor a) => hintBig("Be careful touching that!", new Duration(seconds: 3)) );
  }




  /**
   * Listens on the input and passes them to inputEvents.
   */
  setupInput() {
    StreamController<Vector2> touchEvent;
    Vector2 origin;

    // TODO: Device Orientation as alternative input
    window.onDeviceOrientation.listen((e) {
      if (useGyrosensor) {
        if (running) {
          if (touchEvent == null) {
            touchEvent = new StreamController();
            _inputEvent.add(touchEvent.stream.asBroadcastStream());
          }

          final target = new Vector2(
            e.gamma, // In degree in the range [-90,90]
            max(-90.0, min(90.0, e.beta))  // In degree in the range [-90,90]
          );

          touchEvent.add(target / _pixelScale); // Convert to percentage.
        } else if(touchEvent != null) {
          touchEvent.add(new Vector2.zero());
          touchEvent.close();
          touchEvent = null;
        }
      }
    });

    relay(TouchEvent e) {
      if (touchEvent != null) {
        final offset = new Vector2(e.touches[0].page.x - origin.x, e.touches[0].page.y - origin.y);
        touchEvent.add(offset / _pixelScale);
      }
    }

    _inputLayer.onTouchStart.listen((e) {
      e.preventDefault();
      if (running && !useGyrosensor) {

        origin = new Vector2(e.touches[0].page.x, e.touches[0].page.y);
        touchEvent = new StreamController();
        _inputEvent.add(touchEvent.stream.asBroadcastStream());
        
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
        if (touchEvent != null) {
          touchEvent.add(new Vector2.zero());
          touchEvent.close();
          touchEvent = null;
        }
        if (running) {
          deactivate(get("Character"));
          get("world").classes.remove("changing");
        }
        deactivate(_inputKnob);
      }
    });
  }
}