part of australiasim;

class GameController {
  GameMode mode;
  GameView view;
  Timer movementTick;

  GameController() {
    mode = new GameMode();
    view = new GameView(mode);

    const speed = 10.0;
    var pos = new Vector2(0.0,0.0);
    var target = pos;
    view.onInput((t) => target = t, () => target.setZero());

    movementTick = new Timer.periodic(new Duration(milliseconds: 100), (t) {
      pos.add(target.normalized() * speed);
      view.move(pos);
    });
  }

  onInteraction() {

  }
}