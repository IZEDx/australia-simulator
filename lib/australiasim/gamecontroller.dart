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
    this._handleInput();

    gameView.get("startGame").onClick.listen((e) {
      e.preventDefault();
      _start();
    });

    gameMode.onGameOver.listen((won) {
      print("GameOver! Won: ${won}");
      final level = window.localStorage.containsKey("level") ? int.parse(window.localStorage["level"]) : 0;
      window.localStorage["level"] = (level + 1).toString();
      _stop();
    });
  }

  Future _handleInput() async {
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
      var level = window.localStorage.containsKey("level") ? int.parse(window.localStorage["level"]) : 0;
      final levels = await Level.loadLevels("./assets/data/levels.json");

      if (level >= levels.length) level = levels.length - 1;

      gameMode.load(levels[level]);
      gameView.openGameView();
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
      gameView.closeGameView();
      gameMode.stop();
    }
  }

}