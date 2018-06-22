part of australiasim;

class GameController {
  GameMode gameMode;
  GameView gameView;
  LevelManager levelManager;

  double _lastTick = 0.0;
  bool _running = false;

  GameController() {

    levelManager = new LevelManager("./assets/data/levels.json");
    gameMode = new GameMode();
    gameView = new GameView(gameMode, levelManager);

    _init();
    _setupInput();
  }

  _init() async {
    await levelManager.load();
    gameView.closeGameView(false);

    /*gameView.get("useGyrosensor").onClick.listen((e) {
      e.preventDefault();
      gameView.useGyrosensor = !gameView.useGyrosensor;
    });*/

    gameView.onSelectLevel.listen((level) => _startGame(level));

    gameView.get("selectLevel").onClick.listen((e) {
        gameView.hide(gameView.get("menu"));
        gameView.show(gameView.get("levelSelection"));
    });

    gameView.get("showMenu").onClick.listen((e) {
        gameView.show(gameView.get("menu"));
        gameView.hide(gameView.get("levelSelection"));
    });

    gameMode.onGameOver.listen(_gameOver);

  }

  _setupInput() async {
    gameView.setupInput((touch) {
      if (_running) gameMode.moveCharacter(touch);
    });
    /*await for (var touches in gameView.onInput) {
      if (running) {
        await for (var touch in touches) {
          gameMode.moveCharacter(touch);
        }
        ;
      }
    }*/
  }

  _startGame(Level lvldata) async {
    if (!_running) {
      gameMode.load(lvldata);
      gameView.openGameView();
      gameMode.start();
      _running = true;
      
      gameView.hintBig(lvldata.spawnText, new Duration(seconds: 4));

      _lastTick = window.performance.now() / 1000;
      final interval = new Duration(milliseconds: 32);
      while (gameMode.running) {
        await gameView.timeout(interval);
        final time = window.performance.now() / 1000;
        gameMode.tick(time - _lastTick);
        _lastTick = time;
      }
    }
  }

  _gameOver(won) async {
    if (!_running) return;
    final charEl = gameView.get("Character");
    _running = false;

    if (won) {
      levelManager.current = ++levelManager.current % levelManager.size;
    }

    gameMode.player.walk(new Vector2.zero());

    // Character animations
    gameView.deactivate(charEl);
    gameView.timeout(
      new Duration(milliseconds: 768), // Animation time - 32ms to account for the animation jumping back to start.
      before: () => charEl.classes.add(won ? "finish-anim" : "dead-anim"), 
      after: () => charEl.classes.add(won ? "finish" : "dead")
    );

    await gameView.hintBig(won ? "Well Done!" : "Game Over", new Duration(seconds: 3));

    gameMode.stop();
    gameView.closeGameView(!won);
  }
}