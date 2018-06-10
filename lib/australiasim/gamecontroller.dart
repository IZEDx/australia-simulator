part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  LevelManager levelManager;
  double _lastTick = 0.0;

  bool get running => gameMode.running;

  GameController() {

    gameMode = new GameMode();
    levelManager = new LevelManager("./assets/data/levels.json");
    gameView = new GameView(gameMode, levelManager);

    _init();
    _setupInput();
  }

  _init() async {
    await levelManager.load();
    gameView.closeGameView();

    gameView.get("useGyrosensor").onClick.listen((e) {
      e.preventDefault();
      gameView.useGyrosensor = !gameView.useGyrosensor;
    });

    gameView.get("startGame").onClick.listen((e) {
      e.preventDefault();
      print("Loading level: ${levelManager.current + 1}");
      _start(levelManager.current);
    });

    gameMode.onGameOver.listen((won) {
      if (gameMode.running) {
        print("GameOver! Won: ${won}");
        if (won) {
          levelManager.current = ++levelManager.current % levelManager.size;
        }
        print("Next Level: ${levelManager.current + 1}/${levelManager.size}");
        _stop();
      }
    });

  }

  _setupInput() async {
    gameView.setupInput();
    new Observable(gameView.onInput)
      .where((touches) => running)
      .flatMap((touches) => touches)
      .listen((touch) => gameMode.moveCharacter(touch));
    /*await for (var touches in gameView.onInput) {
      if (running) {
        await for (var touch in touches) {
          gameMode.moveCharacter(touch);
        }
        ;
      }
    }*/
  }

  _start(int level) async {
    if (!running) {
      gameMode.load(levelManager.get(level));
      gameView.openGameView();
      gameMode.start();

      _lastTick = window.performance.now() / 1000;
      final interval = new Duration(milliseconds: 30);
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
      gameMode.stop();
      gameView.closeGameView();
    }
  }

}