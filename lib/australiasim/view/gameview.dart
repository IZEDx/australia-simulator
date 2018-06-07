part of australiasim;

class GameView extends DOMView {
  double _pixelScale = 0.5;
  double _knobJiggle = 5.0;

  GameMode gamemode;
  LevelManager levelManager;

  static final mainElement  = querySelector("#main");
  static final menuLayer    = querySelector("#menuLayer");
  static final gameLayer    = querySelector("#gameLayer");
  static final inputLayer   = querySelector("#inputLayer");
  static final inputKnob    = querySelector("#inputKnob");

  StreamController<Stream<Vector2>> _inputEvent = new StreamController();
  Stream<Stream<Vector2>> onInput;

  get running => this.gamemode.running;

  GameView(GameMode this.gamemode, LevelManager this.levelManager) {
    onInput = _inputEvent.stream.asBroadcastStream();
    mainElement.classes.add("loaded");
  }
  
  closeGameView() async {
    // Reset Game
    gameLayer.setInnerHtml("");

    get("startGame").setInnerHtml(levelManager.current > 0 ? "CONTINUE!" : "ENTER!");
    
    if (levelManager.unlocked > 0) {
      show(get("selectLevel"));
    }

    // Toggle States
    hide(gameLayer);
    show(menuLayer);

    await nextFrame(); // Waiting for the next frame, otherwise the css activation animations wouldn't play.

    activate(menuLayer);
    deactivate(mainElement);
    deactivate(gameLayer);
    deactivate(inputLayer);
  }

  openGameView() async {
    // Setup Elements
    var worldElement = get("world");

    if (get("bigLabel") == null)                create(gameLayer, "bigLabel");
    if (worldElement    == null) worldElement = create(gameLayer, "world");

    // Setup World Dimensions
    setDimensions(worldElement, gamemode.world.size * _pixelScale);
    
    // Setup Listeners
    gamemode.world.onActorSpawned.listen(createActor);
    gamemode.world.onActorRemoved.listen(removeActor);
    for (var actor in gamemode.world.actors) createActor(actor);

    // Toggle States
    show(gameLayer);
    hide(menuLayer);

    await nextFrame();

    deactivate(menuLayer);
    activate(mainElement);
    activate(gameLayer);
    activate(inputLayer);

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

  removeActor(Actor actor) {
    remove(actor.name);
  }

  createCharacter(Character char) {

    // Create Character
    final el = create(gameLayer, char.name);

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

  makeDoor(Element el, Door door) {

    // Mark as door
    el.classes.add("door");
    
    // Feedback when user touches door
    new Observable(door.onCollide)
      .throttle( new Duration(seconds: 4) )
      .where( (Actor a) => a is Character )
      .listen( (Actor a) => hintBig("You wanna leave already?", new Duration(seconds: 3)) );
  }

  makeEnemy(Element el, Enemy enemy) {

    // Mark as enemy
    el.classes.add("enemy");
    
    new Observable(enemy.onCollide)
      .throttle(new Duration(seconds: 4))
      .where( (Actor a) => a is Character )
      .listen( (Actor a) => hintBig("Be careful touching that!", new Duration(seconds: 3)) );
  }

  setupInput() {
    StreamController<Vector2> touchEvent;
    Vector2 origin;

    relay(TouchEvent e) {
      if (touchEvent != null) {
        final offset = new Vector2(e.touches[0].page.x - origin.x, e.touches[0].page.y - origin.y);
        touchEvent.add(offset / _pixelScale);
      }
    }

    // TODO: Device Orientation as alternative input
    //window.onDeviceOrientation.listen((e) => e.)

    inputLayer.onTouchStart.listen((e) {
      e.preventDefault();
      if (running) {

        origin = new Vector2(e.touches[0].page.x, e.touches[0].page.y);
        touchEvent = new StreamController();
        _inputEvent.add(touchEvent.stream.asBroadcastStream());
        
        relay(e);
        move(inputKnob, origin - new Vector2(25.0, 25.0));

        activate(get("Character"));
        activate(inputKnob);
        get("world").classes.add("changing");
      }
    });

    inputLayer.onTouchMove.listen((e) {
      e.preventDefault();
      if (running) {
        relay(e);
      }
    });

    inputLayer.onTouchEnd.listen((e) {
      e.preventDefault();
      if (touchEvent != null) {
        touchEvent.close();
        touchEvent = null;
      }
      if (running) {
        deactivate(get("Character"));
        get("world").classes.remove("changing");
      }
      deactivate(inputKnob);
    });
  }
}