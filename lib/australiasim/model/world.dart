part of australiasim;

/// The world the game is running in 
class World 
{
    /// Is the game running?
    bool _running = false;

    /// Start the game
    void start() => _running = true;

    /// Stop the game
    void stop() => _running = false;

    /// Is the game running?
    bool get isRunning => _running;

    /// IDs of all actors
    List<int> _UIDstore = [];

    /// Collection of spawned actors
    List<Actor> actors = [];

     /// Gamemode the current game is running with
    GameMode gamemode;

    /// Size of this world
    Vector2 size;

    /// Used to broadcast newly spawned actors
    StreamController<Actor> _actorSpawnedEvent = new StreamController();
    /// Emits newly spawned actors
    Stream<Actor> onActorSpawned;

    /// Used to broadcast removal of an actor
    StreamController<Actor> _actorRemovedEvent = new StreamController();
    /// Emits actors which got removed
    Stream<Actor> onActorRemoved;

    /// Constructor of a world with a given [size] and [gamemode]
    World(Vector2 this.size, GameMode this.gamemode) 
    {
        onActorSpawned = _actorSpawnedEvent.stream.asBroadcastStream();
        onActorRemoved = _actorRemovedEvent.stream.asBroadcastStream();
    }
    
    /// Returns a unique id 
    String genUID() 
    {
        final ran = new Random();
        int n;
        do {
            n = ran.nextInt(1000);
        } while( _UIDstore.contains(n) );
        
        return n.toString();
    }

    /// Spawns a given [actor] on a given [location] with given optional [rotation] and [scale]. Returns spawned actor.
    T spawnActor<T extends Actor>(T actor, Vector2 location, { Vector2 rotation, Vector2 scale })  
    {
        actor.initialize(this);
        actor.location = location;
        if (rotation != null) actor.rotation = rotation;
        if (scale != null) actor.scale = scale;

        this.actors.add(actor);

        if (isRunning) actor.beginPlay();
        _actorSpawnedEvent.add(actor);

        return actor;
    }

    /// Remove a spawned [actor]
    void removeActor(Actor actor) 
    {
        actors.remove(actor);
        _actorRemovedEvent.add(actor);
    }

     /// Used for operations which need to be done in short intervals where [deltaTime] specifies the time since the last tick
    void tick(double deltaTime) {
        this.actors.forEach((actor) => actor.tick(deltaTime));
    }

    /// Starts the game
    void beginPlay() {
        if (!isRunning) start();
        this.actors.forEach((actor) => actor.beginPlay());
    }
}