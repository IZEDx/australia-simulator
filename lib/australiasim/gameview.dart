part of australiasim;

class GameView {
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

    if (character == null) {
      game.appendHtml("<div class='actor' id='character' />");
      character = querySelector("#character");
    }

    for (var actor in gamemode.currentWorld.actors) addActorToView(actor);

    input.classes.add("active");
    header.classes.add("hidden");

    this.moveCamera(new Vector2(cellsize / 2, cellsize / 2));
  }

  addActorToView(Actor actor) {
    var el = querySelector("#"+actor.name);
    if (el != null) return;

    world.appendHtml("<div class='actor' id='${actor.name}'>");
    el = querySelector("#"+actor.name);
    
    updateActorView() {
      final rotation = atan2(actor.rotation.x, actor.rotation.y) * 180 / PI;
      el.style.transform = "translate(${actor.location.x}px, ${actor.location.y}px) rotate(${rotation})";
    }

    actor.onMove.listen((vec) => updateActorView());
    actor.onRotate.listen((vec) => updateActorView());
    updateActorView();
  }

  moveCamera(Vector2 pos) {
    world.style.transform = "translate(-${pos.x}px, -${pos.y}px)";
  }

  setupInput() {
    StreamController<Vector2> touchEvent;

    relay(TouchEvent e) {
      touchEvent.add(new Vector2(
        e.touches[0].page.x - world.offset.left, 
        e.touches[0].page.y - world.offset.top
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