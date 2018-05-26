part of australiasim;

class GameView {
  int _pixelScale = 50;
  GameMode gamemode;
  Element character = null;
  Element world = null;

  final header = querySelector("#header");
  final game = querySelector("#game");
  final input = querySelector("#input");

  StreamController<Stream<Vector2>> _inputEvent = new StreamController();
  Stream<Stream<Vector2>> get onInput => _inputEvent.stream.asBroadcastStream(); 

  GameView(GameMode this.gamemode) {
    this.setupInput();
    gamemode.onActorSpawned.listen(addActorToView);
  }

  resetView() {
    game.setInnerHtml("");
    world = null;
    character = null;

    input.classes.remove("active");
    header.classes.remove("hidden");
  }


  setupView() {
    if (world == null) {
      game.appendHtml("<div id='world' />");
      world = querySelector("#world");
    }

    world.style.width = (gamemode.currentWorld.size.x * _pixelScale).toString() + "px";
    world.style.height = (gamemode.currentWorld.size.y * _pixelScale).toString() + "px";
    print(world.style.width);

    for (var actor in gamemode.currentWorld.actors) addActorToView(actor);

    input.classes.add("active");
    header.classes.add("hidden");
  }

  addActorToView(Actor actor) {
    var el = querySelector("#"+actor.name);
    if (el != null) return;

    if (actor is Character) {
      addCharacterToView(actor);
      return;
    }

    world.appendHtml("<div class='actor' id='${actor.name}'>");
    el = querySelector("#"+actor.name);

    updateActorPos() {
      el.style.left = (actor.location.x * _pixelScale).toString() + "px";
      el.style.top = (actor.location.y * _pixelScale).toString() + "px";
    }

    updateActorRot() {
      final rotation = atan2(actor.rotation.x, actor.rotation.y) * 180 / PI;
      el.style.transform = "translate(-50%, -50%) rotate(${rotation})";
    }

    updateActorScale() {
      el.style.width = (actor.scale.x * _pixelScale).toString() + "px";
      el.style.height = (actor.scale.y * _pixelScale).toString() + "px";
    }

    if (actor is Pawn) {
      actor.onMove.listen((vec) => updateActorPos());
      actor.onRotate.listen((vec) => updateActorRot());
      actor.onScale.listen((vec) => updateActorScale());
    }

    updateActorPos();
    updateActorRot();
    updateActorScale();
  }

  addCharacterToView(Character char) {
    game.appendHtml("<div class='actor' id='${char.name}'>");
    character = querySelector("#"+char.name);

    updateCharacter() {
      final rotation = atan2(char.rotation.x, char.rotation.y) * 180 / PI;
      character.style.transform = "rotate(${rotation})";
    }

    char.onMove.listen((vec) => moveCamera(vec));
    //char.onRotate.listen((vec) => updateCharacter());

    updateCharacter();
    moveCamera(char.location);
  }

  moveCamera(Vector2 pos) {
    world.style.transform = "translate(-${pos.x * _pixelScale}px, -${pos.y * _pixelScale}px)";
  }

  setupInput() {
    StreamController<Vector2> touchEvent;

    relay(TouchEvent e) {
      touchEvent.add(new Vector2(
        (e.touches[0].page.x - world.offset.left) / _pixelScale,  
        (e.touches[0].page.y - world.offset.top) / _pixelScale
      ));
    }

    input.onTouchStart.listen((e) {
      e.preventDefault();

      character.classes.add("active");
      world.classes.add("changing");

      touchEvent = new StreamController();
      _inputEvent.add(touchEvent.stream);
      
      relay(e);
    });

    input.onTouchMove.listen((e) {
      e.preventDefault();
      relay(e);
    });

    input.onTouchEnd.listen((e) {
      e.preventDefault();

      character.classes.remove("active");
      world.classes.remove("changing");

      touchEvent.close();
      touchEvent = null;
    });
  }
}