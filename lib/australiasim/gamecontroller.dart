part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  double _lastTick = 0.0;

  bool get running => gameMode.running;

  GameController() {

    gameMode = new GameMode();
    gameView = new GameView(gameMode);

    gameView.setupInput();
    this._listenInput();

    gameView.get("startGame").onClick.listen((e) {
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
      if (running) {
        await for (var touch in touches) {
          gameMode.moveCharacter(touch);
        }
        gameMode.moveCharacter(new Vector2.zero());
      }
    }
  }

  _start() async {
    if (!running) {
      gameMode.load();
      gameView.setup();
      gameMode.start();

      while (running) {
        final time = await gameView.nextFrame();
        gameMode.tick(time - _lastTick);
        _lastTick = time;
      }
    }
  }

  _stop() {
    if (running) {
      gameView.reset();
      gameMode.stop();
    }
  }

}