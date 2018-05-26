part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  bool _ticking = false;
  double _lastTick = 0.0;

  GameController() {

    gameMode = new GameMode();
    gameView = new GameView(gameMode);

    gameView.setupView();
    this._listenInput();
    this._requestTick();
  }

  Future _listenInput() async {
    await for (var touches in gameView.onInput) {
      await for (var touch in touches) {
        gameMode.moveCharacter(touch);
      }
      gameMode.moveCharacter(new Vector2.zero());
    }
  }

  void _requestTick() {
    if (!_ticking) {
      window.requestAnimationFrame(_tick);
      _ticking = true;
    }
  }

  void _tick(double time) {
    gameMode.tick(time - _lastTick);
    _lastTick = time;
    _ticking = false;
    this._requestTick();
  }

}