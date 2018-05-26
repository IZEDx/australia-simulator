part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  bool _ticking = false;

  GameController() {

    gameMode = new GameMode();
    gameView = new GameView(gameMode);

    gameView.setupView();
    this._listenInput();
    this._listenMovement();
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

  Future _listenMovement() async {
    await for (var pos in gameMode.onMove) {
      gameView.moveCamera(pos);
    }
  }

  void _requestTick() {
    if (!_ticking) {
      window.requestAnimationFrame(_tick);
      _ticking = true;
    }
  }

  void _tick(double time) {
    gameMode.globalPhysicsTick(time);
    _ticking = false;
    this._requestTick();
  }

}