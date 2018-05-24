part of australiasim;

class GameController {
  GameMode mode;
  GameView view;
  bool _ticking = false;

  GameController() {

    mode = new GameMode();
    view = new GameView(mode);

    view.setup();
    this._listenInput();
    this._listenMovement();
    this._requestTick();
  }

  Future _listenInput() async {
    await for (var touches in view.onInput) {
      await for (var touch in touches) {
        mode.moveCharacter(touch);
      }
      mode.moveCharacter(new Vector2.zero());
    }
  }

  Future _listenMovement() async {
    await for (var pos in mode.onMove) {
      view.moveCamera(pos);
    }
  }

  void _requestTick() {
    if (!_ticking) {
      window.requestAnimationFrame(_tick);
      _ticking = true;
    }
  }

  void _tick(double time) {
    mode.tick(time);
    _ticking = false;
    this._requestTick();
  }

}