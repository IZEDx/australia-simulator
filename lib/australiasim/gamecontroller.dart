part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  LevelManager levelManager;
  double _lastTick = 0.0;

  bool get running => gameMode.running;

  GameController() {

    gameMode = new GameMode();
    gameView = new GameView(gameMode);
    levelManager = new LevelManager("./assets/data/levels.json");

    _init();
    _setupInput();
  }

  _init() async {
    await levelManager.load();

    gameView.get("startGame").onClick.listen((e) {
      e.preventDefault();
      _start(levelManager.current);
    });

    gameMode.onGameOver.listen((won) {
      print("GameOver! Won: ${won}");
      levelManager.current = ++levelManager.current % levelManager.size;
      print("Next Level: ${levelManager.current + 1}/${levelManager.size}");
      _stop();
    });
  }

  _setupInput() async {
    gameView.setupInput();
    await for (var touches in gameView.onInput) {
      if (running) {
        await for (var touch in touches) {
          gameMode.moveCharacter(touch);
        }
        gameMode.moveCharacter(new Vector2.zero());
      }
    }
  }

  _start(int level) async {
    if (!running) {
      gameMode.load(levelManager.get(level));
      gameView.openGameView();
      gameMode.start();

      final interval = new Duration(milliseconds: 16);
      while (running) {
        await gameView.timeout(interval);
        final time = window.performance.now() / 1000;
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