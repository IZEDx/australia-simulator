part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  bool _running = false;
  bool _ticking = false;
  double _lastTick = 0.0;

  GameController() {

    gameMode = new GameMode();
    gameView = new GameView(gameMode);

    this._listenInput();
    gameView.startButton.onClick.listen((e) {
      e.preventDefault();
      _start();
    });
  }

  Future _listenInput() async {
    await for (var touches in gameView.onInput) {
      await for (var touch in touches) {
        gameMode.moveCharacter(touch);
      }
      gameMode.moveCharacter(new Vector2.zero());
    }
  }

  void _setupNavigation() {
    
  }

  void _start() {
    if (!_running) {
      _running = true;
      _ticking = false;
      gameView.setupView();
      _requestTick();
    }
  }

  void _stop() {
    if (_running) {
      _running = false;
      gameView.resetView();
    }
  }

  void _requestTick() {
    if (!_ticking && _running) {
      _ticking = true;
      window.requestAnimationFrame(_tick);
    }
  }

  void _tick(double time) {
    gameMode.tick(time - _lastTick);
    _lastTick = time;
    _ticking = false;
    this._requestTick();
  }

}