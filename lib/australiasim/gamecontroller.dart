part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  bool _ticking = false;
  double _lastTick = 0.0;

  bool get running => gameMode.running;

  GameController() {

    gameMode = new GameMode();
    gameView = new GameView(gameMode);

    this._listenInput();

    gameView.startButton.onClick.listen((e) {
      e.preventDefault();
      _start();
    });

    gameMode.onGameOver.listen((won) {
      print("GameOver! Won: ${won}");
      _stop();
    });
  }

  Future _listenInput() async {
    await for (var touches in gameView.onInput) {
      await for (var touch in touches) {
        gameMode.moveCharacter(touch);
      }
      gameMode.moveCharacter(new Vector2.zero());
    }
    print("Input Ended!");
  }

  void _start() {
    if (!running) {
      _ticking = false;
      gameMode.load();
      gameView.setupView();
      gameMode.start();
      _requestTick();
    }
  }

  void _stop() {
    if (running) {
      gameMode.stop();
      gameView.resetView();
    }
  }

  void _requestTick() {
    if (!_ticking && running) {
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