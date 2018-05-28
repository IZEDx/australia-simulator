part of australiasim;

class GameView {
  double _pixelScale = 0.5;
  GameMode gamemode;
  Element character = null;
  Element world = null;
  Element bigLabel = null;

  final menuLayer = querySelector("#menuLayer");
  final gameLayer = querySelector("#gameLayer");
  final inputLayer = querySelector("#inputLayer");
  final main = querySelector("#main");

  final startButton = querySelector("#startGame");

  StreamController<Stream<Vector2>> _inputEvent = new StreamController();
  Stream<Stream<Vector2>> get onInput => _inputEvent.stream.asBroadcastStream(); 

  GameView(GameMode this.gamemode) {
    this._setupInput();
  }

  showText(String text, Duration duration) {
    bigLabel.classes.add("active");
    bigLabel.setInnerHtml(text);
    Timer timer;
    timer = new Timer.periodic(duration, (d) {
      timer.cancel();
      bigLabel.classes.remove("active");
    });
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
    
    gamemode.currentWorld.onActorSpawned.listen(_addActorToView);
    gamemode.currentWorld.onActorRemoved.listen(_removeActorFromView);

    if (bigLabel == null) {
      gameLayer.appendHtml("<div id='bigLabel'>");
      bigLabel = querySelector("#bigLabel");
    }

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

    showText("Welcome", new Duration(seconds: 4));
  }

  _removeActorFromView(Actor actor) {
    var el = querySelector("#"+actor.name);
    if (el != null) el.remove();
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

    updateActorRot() {
      final rotation = atan2(actor.rotation.x, actor.rotation.y);
      el.style.transform = "translate(-50%, -50%) rotate(${rotation}rad)";
    }

    if (actor.isCircleCollider) {
      el.classes.add("circle");
    }

    if (actor is Pawn) {
      actor.onMove.listen((vec) => updateActorPos());
      actor.onRotate.listen((vec) => updateActorRot());
      actor.onScale.listen((vec) => updateActorScale());
    }

    updateActorPos();
    updateActorRot();
    updateActorScale();

    if (actor is Door) {
      _addDoorToView(el, actor);
    }
  }

  _addDoorToView(Element el, Door door) {
    el.classes.add("door");
    
    new Observable(door.onCollide)
      .throttle(new Duration(seconds: 4))
      .where( (Actor a) => a is Character )
      .listen( (Actor a) => showText("You wanna leave already?", new Duration(seconds: 3)) );
  }

  _addCharacterToView(Character char) {
    gameLayer.appendHtml("<div class='actor' id='${char.name}'>");
    character = querySelector("#"+char.name);

    char.onMove.listen((vec) => _moveCamera(vec));
    //char.onRotate.listen((vec) => updateCharacter());

    _moveCamera(char.location);
  }

  _moveCamera(Vector2 pos) {
    world.style.transform = "translate(-${pos.x * _pixelScale}px, -${pos.y * _pixelScale}px)";
  }

  _setupInput() {
    StreamController<Vector2> touchEvent;

    relay(TouchEvent e) {
      if (touchEvent != null) {
        touchEvent.add(new Vector2(
          (e.touches[0].page.x - world.offset.left) / _pixelScale,  
          (e.touches[0].page.y - world.offset.top) / _pixelScale
        ));
      }
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

      if (touchEvent != null) {
        touchEvent.close();
        touchEvent = null;
      }
    });
  }
}