part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  LevelManager levelManager;
  double _lastTick = 0.0;

  bool get running => gameMode.running;

  GameController() {

    levelManager = new LevelManager("./assets/data/levels.json");
    gameMode = new GameMode();
    gameView = new GameView(gameMode, levelManager);

    _init();
    _setupInput();
  }

  _init() async {
    await levelManager.load();
    gameView.closeGameView();

    /*gameView.get("useGyrosensor").onClick.listen((e) {
      e.preventDefault();
      gameView.useGyrosensor = !gameView.useGyrosensor;
    });*/

    gameView.get("startGame").onClick.listen((e) {
      e.preventDefault();
      _startGame(levelManager.current);
    });

    gameMode.onGameOver.listen(_gameOver);

  }

  _setupInput() async {
    gameView.setupInput((touch) => gameMode.moveCharacter(touch));
    /*await for (var touches in gameView.onInput) {
      if (running) {
        await for (var touch in touches) {
          gameMode.moveCharacter(touch);
        }
        ;
      }
    }*/
  }

  _startGame(int level) async {
    if (!running) {
      final lvldata = levelManager.get(level);
      gameMode.load(lvldata);
      gameView.openGameView();
      gameMode.start();
      
      gameView.hintBig(lvldata.spawnText, new Duration(seconds: 4));

      _lastTick = window.performance.now() / 1000;
      final interval = new Duration(milliseconds: 32);
      while (running) {
        await gameView.timeout(interval);
        final time = window.performance.now() / 1000;
        gameMode.tick(time - _lastTick);
        _lastTick = time;
      }
    }
  }

  _gameOver(won) async {
    if (gameMode.running) {
      final charEl = gameView.get("Character");
      if (won) {
        levelManager.current = ++levelManager.current % levelManager.size;
      }
      gameMode.stop();
      gameView.deactivate(charEl);
      gameView.timeout(
        new Duration(milliseconds: 768), // Animation time - 32ms to account for the animation jumping back to start.
        before: () => charEl.classes.add(won ? "finish-anim" : "dead-anim"), 
        after: () => charEl.classes.add(won ? "finish" : "dead")
      );
      await gameView.hintBig(won ? "Well Done!" : "Game Over", new Duration(seconds: 3));
      gameView.closeGameView();
    }
  }
}