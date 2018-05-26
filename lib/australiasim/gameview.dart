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

      touchEvent.close();
      touchEvent = null;
    });

    gamemode.onActorSpawned.listen(addActor);
  }

  reset() {
    game.setInnerHtml("");
    world = null;
    character = null;

    input.classes.remove("active");
    header.classes.remove("hidden");
  }


  setup() {
    if (world == null) {
      game.appendHtml("<div id='world' />");
      world = querySelector("#world");
    }

    if (character == null) {
      game.appendHtml("<div class='actor' id='character' />");
      character = querySelector("#character");
    }

    for (var actor in gamemode.currentWorld.actors) addActor(actor);

    input.classes.add("active");
    header.classes.add("hidden");

    this.moveCamera(new Vector2(cellsize / 2, cellsize / 2));
  }

  addActor(Actor actor) {
    var element = querySelector("#"+actor.name);
    if (element == null) {
      world.appendHtml("<div class='actor' id='${actor.name}'>");
      element = querySelector("#"+actor.name);
    }
    
    element.style.transform = "translate(${actor.location.x}px, ${actor.location.y}px)";
  }

  moveCamera(Vector2 pos) {
    world.style.transform = "translate(-${pos.x}px, -${pos.y}px)";
  }
}