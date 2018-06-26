part of australiasim;

/// Instantiates model and view, controls the start/end of
/// the game and passes input from the user onto the model.
class GameController
{

    /// Tick interval
    static final interval = new Duration(milliseconds: 32);

    /// Model instance
    GameMode gameMode;

    /// View instance
    GameView gameView;

    /// LevelManager instance
    LevelManager levelManager;

    /// Time of the last tick
    double _lastTick = 0.0;

    /// State of the whole game
    bool _running = false;

    /// Constructor
    GameController()
    {

        levelManager = new LevelManager("./assets/data/levels.json");
        gameMode = new GameMode();
        gameView = new GameView(gameMode, levelManager);

        _init(); // Further initializations are asynchronously.
        
    }

    /// Asynchronous initializer allows waiting for dependencies.
    _init() async
    {
        // Load the levels
        await levelManager.load();
        
        // Show the main menu
        gameView.closeGameView(false);

        // Open level selection.
        gameView.get("selectLevel").onClick.listen((e)
        {
            gameView.hide(gameView.get("menu"));
            gameView.show(gameView.get("levelSelection"));
        });

        // Close level selection
        gameView.get("showMenu").onClick.listen((e)
        {
            gameView.show(gameView.get("menu"));
            gameView.hide(gameView.get("levelSelection"));
        });

        // Add listener for game start and end
        gameView.onSelectLevel.listen(_runGame);
        gameMode.onGameOver.listen(_gameOver);

        // Add listener for movement
        gameView.onInput.listen((touch)
        {
            if (_running) gameMode.moveCharacter(touch);
        });
    }

    /// Starts the game by loading a level and ticking the gamemode.
    _runGame(Level lvldata) async
    {
        // Prevent multiple starts, less necessary than multiple gameovers, but reasonable.
        if (_running) return;
        _running = true;

        // Load the level into the gamemode
        gameMode.load(lvldata);
        // Open the game view
        gameView.openGameView();
        // Start the gamemode
        gameMode.start();
        
        // Show the spawntext of the level for 4 seconds
        gameView.hintBig(lvldata.spawnText, new Duration(seconds: 4));

        _lastTick = window.performance.now() / 1000; // Start time

        // Keep ticking while the gamemode is running.
        // The gamemode will run 3 seconds longer after the gameover, keep the enemies moving.
        while (gameMode.running) {
            await gameView.timeout(interval); // Wait for interval

            final now = window.performance.now() / 1000;
            gameMode.tick(now - _lastTick); // Run tick through model with deltatime
            _lastTick = now; // Reset last tick
        }
    }

    /// Ends the game by showing endscreen and animating the character.
    /// Then the main menu will be shown.
    _gameOver(won) async
    {
        // Prevent multiple gameovers if enemies do stuff after it has ended
        if (!_running) return;
        _running = false;

        // Update the current level
        if (won) levelManager.current = ++levelManager.current % levelManager.size;

        // Reset player velocity
        gameMode.player.walk(new Vector2.zero());

        // Character animations
        final charEl = gameView.get("Character");
        gameView.deactivate(charEl);
        gameView.timeout(
        new Duration(milliseconds: 768), // (Animation time - 32ms) to account for the animation jumping back to start.
            before: () => charEl.classes.add(won ? "finish-anim" : "dead-anim"), 
            after: () => charEl.classes.add(won ? "finish" : "dead")
        );

        // Indicate whether the game was won and wait for 3 seconds
        await gameView.hintBig(won ? "Well Done!" : "Game Over", new Duration(seconds: 3));

        // Stop the gamemode and show the menu
        gameMode.stop();
        gameView.closeGameView(!won);
    }
}