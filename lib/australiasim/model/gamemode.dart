part of australiasim;

/// default wall width the game is using for the outer walls
const wallWidth = 20.0;

/// Class for a gameinstance which represents the current game
class GameMode {

    /// World the game is currently happening in
    World world;
    /// Current player character
    Character player;

    /// Used to broadcast game over events
    StreamController<bool> gameOverEvent = new StreamController();
    /// Emits game over events
    Stream<bool> onGameOver;
    
    /// Used to broadcast change of current enemy count in this session
    StreamController<int> _enemyCountChangeEvent = new StreamController();
    /// Emits current enemy count on change
    Stream<int> onEnemyCountChange;

    /// Current enemy count
    int _enemyCount = 0;

    /// Current enemy count
    int get enemyCount => _enemyCount;

    /// Sets new [enemyCount]
    set enemyCount(int enemyCount) 
    {
        _enemyCount = enemyCount;
        _enemyCountChangeEvent.add(enemyCount);
    }

    /// Constructor
    GameMode()
    {
        onGameOver = gameOverEvent.stream.asBroadcastStream();
        onEnemyCountChange = _enemyCountChangeEvent.stream.asBroadcastStream();
    }

    /// Start the game
    void start() => !loaded ? null : world.beginPlay();

    /// Stop the game
    void stop() => !loaded ? null : world.stop();

    /// Is the game running?
    bool get isRunning   => loaded && world.isRunning;

    /// is the game loaded?
    bool get loaded => world != null;

    /// Loads and inits a new [level]
    void load(Level level) 
    {
        if (isRunning) return;

        // Set State
        enemyCount = 0;
        world = new World(level.size, this);

        // Character
        player = world.spawnActor(new Character(), new Vector2(level.size.x / 2, 150.0));

        // Walls
        world.spawnActor(new Box(), new Vector2(level.size.x / 2,   0.0),               scale: new Vector2(wallWidth + level.size.x, wallWidth));
        world.spawnActor(new Box(), new Vector2(level.size.x / 2,   level.size.y),      scale: new Vector2(wallWidth + level.size.x, wallWidth));
        world.spawnActor(new Box(), new Vector2(0.0,                level.size.y / 2),  scale: new Vector2(wallWidth, level.size.y + wallWidth));
        world.spawnActor(new Box(), new Vector2(level.size.x,       level.size.y / 2),  scale: new Vector2(wallWidth, level.size.y + wallWidth));
        
        // Trees
        world.spawnActor(new Shrub(), new Vector2(-200.0, -200.0), scale: new Vector2(200.0, 350.0), rotation: new Vector2(0.0, 1.0));
        world.spawnActor(new Shrub(), new Vector2(level.size.x + 200.0, -200.0), scale: new Vector2(200.0, 350.0), rotation: new Vector2(0.0, 1.0));
        

        // Spawn Actors
        for (final data in level.actors) 
        {
            Actor actor = world.spawnActor(
                data.instance(), 
                data.location, 
                scale: data.scale,
                rotation: data.rotation
            );

            if (actor is Enemy) enemyCount++;
        }

        // Door
        world.spawnActor(new Door(), new Vector2(level.size.x / 2, 0.0));
        
        // Update State
        world.onActorRemoved.listen((a) {
            if (--enemyCount == 0) gameOverEvent.add(true);
        });
    }

    /// Moves the current player character in this game by a given [velocity]
    void moveCharacter(Vector2 velocity) 
    {
        if (isRunning && player != null) player.walk(velocity);
    }

    /// Used for operations which need to be done in short intervals where [deltaTime] specifies the time since the last tick
    void tick(double deltaTime)
    {
        if (isRunning && world != null) world.tick(deltaTime);
    }
}