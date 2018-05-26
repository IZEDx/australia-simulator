part of australiasim;

class GameView {
  int _pixelScale = 50;
  GameMode gamemode;
  Element character = null;
  Element world = null;

  final menuLayer = querySelector("#menuLayer");
  final gameLayer = querySelector("#gameLayer");
  final inputLayer = querySelector("#inputLayer");
  final main = querySelector("#main");

  final startButton = querySelector("#startGame");

  StreamController<Stream<Vector2>> _inputEvent = new StreamController();
  Stream<Stream<Vector2>> get onInput => _inputEvent.stream.asBroadcastStream(); 

  GameView(GameMode this.gamemode) {
    this._setupInput();
    gamemode.onActorSpawned.listen(_addActorToView);
  }

  resetView() {
    gameLayer.setInnerHtml("");
    world = null;
    character = null;

    gameLayer.classes.add("hidden");
    inputLayer.classes.add("hidden");
    menuLayer.classes.remove("hidden");
    main.classes.remove("active");
  }


  setupView() {
    if (world == null) {
      gameLayer.appendHtml("<div id='world' />");
      world = querySelector("#world");
    }

    world.style.width = (gamemode.currentWorld.size.x * _pixelScale).toString() + "px";
    world.style.height = (gamemode.currentWorld.size.y * _pixelScale).toString() + "px";
    
    for (var actor in gamemode.currentWorld.actors) _addActorToView(actor);

    gameLayer.classes.remove("hidden");
    inputLayer.classes.remove("hidden");
    menuLayer.classes.add("hidden");
    main.classes.add("active");
  }

  _addActorToView(Actor actor) {
    var el = querySelector("#"+actor.name);
    if (el != null) return;

    if (actor is Character) {
      _addCharacterToView(actor);
      return;
    }

    world.appendHtml("<div class='actor' id='${actor.name}'>");
    el = querySelector("#"+actor.name);

    updateActorPos() {
      el.style.left = (actor.location.x * _pixelScale).toString() + "px";
      el.style.top = (actor.location.y * _pixelScale).toString() + "px";
    }


    updateActorScale() {
      el.style.width = (actor.scale.x * _pixelScale).toString() + "px";
      el.style.height = (actor.scale.y * _pixelScale).toString() + "px";
    }

    if (actor is Pawn) {
      actor.onMove.listen((vec) => updateActorPos());
      actor.onRotate.listen((vec) => _updateActorRot(actor, el));
      actor.onScale.listen((vec) => updateActorScale());
    }

    updateActorPos();
    _updateActorRot(actor, el);
    updateActorScale();
  }

  _addCharacterToView(Character char) {
    gameLayer.appendHtml("<div class='actor' id='${char.name}'>");
    character = querySelector("#"+char.name);

    char.onMove.listen((vec) => _moveCamera(vec));
    //char.onRotate.listen((vec) => updateCharacter());

    _updateActorRot(char, character);
    _moveCamera(char.location);
  }

  _updateActorRot(Actor actor, Element el) {
    final rotation = atan2(actor.rotation.x, actor.rotation.y) * 180 / PI;
    el.style.transform = "translate(-50%, -50%) rotate(${rotation})";
  }

  _moveCamera(Vector2 pos) {
    world.style.transform = "translate(-${pos.x * _pixelScale}px, -${pos.y * _pixelScale}px)";
  }

  _setupInput() {
    StreamController<Vector2> touchEvent;

    relay(TouchEvent e) {
      touchEvent.add(new Vector2(
        (e.touches[0].page.x - world.offset.left) / _pixelScale,  
        (e.touches[0].page.y - world.offset.top) / _pixelScale
      ));
    }

    inputLayer.onTouchStart.listen((e) {
      e.preventDefault();

      character.classes.add("active");
      world.classes.add("changing");

      touchEvent = new StreamController();
      _inputEvent.add(touchEvent.stream);
      
      relay(e);
    });

    inputLayer.onTouchMove.listen((e) {
      e.preventDefault();
      relay(e);
    });

    inputLayer.onTouchEnd.listen((e) {
      e.preventDefault();

      character.classes.remove("active");
      world.classes.remove("changing");

      touchEvent.close();
      touchEvent = null;
    });
  }
}