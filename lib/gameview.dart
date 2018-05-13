part of australiasim;

class GameView {
  GameMode gamemode;
  Element character = null;
  Element world = null;

  final game = querySelector("#game");
  final input = querySelector("#input");

  GameView(GameMode this.gamemode) {
    this.reset();
    this.setup();
  }

  reset() {
    if (world != null) {
      game.setInnerHtml("");
      world = null;
      character = null;
    }
    input.classes.remove("active");
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
    input.classes.add("active");

    this.move(new Vector2(cellsize / 2, cellsize / 2));
  }

  move(Vector2 pos) {
    world.style.transform = "translate(-${pos.x}px, -${pos.y}px)";
  }
}