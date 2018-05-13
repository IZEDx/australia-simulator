part of australiasim;

class GameView {
  GameMode gamemode;
  final world = querySelector("#world");
  final character = querySelector("#character");
  final input = querySelector("#input");

  GameView(GameMode this.gamemode) {
  }

  setup() {
    input.classes.remove("active");
  }

  onInput(cb(Vector2 worldPos)) {
    input.onTouchStart.listen((e) {
      e.preventDefault();
      character.classes.add("active");
    });
    input.onTouchMove.listen((e) {
      e.preventDefault();
      cb(new Vector2(e.touches[0].page.x - world.offset.left, e.touches[0].page.y - world.offset.top));
    });
    input.onTouchEnd.listen((e) {
      e.preventDefault();
      character.classes.remove("active");
    });
  }
}