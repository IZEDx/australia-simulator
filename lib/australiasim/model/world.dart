part of australiasim;


class World 
{
    bool                _running = false;
    void     start() => _running = true;
    void      stop() => _running = false;
    bool get running => _running;

    /// IDs of all actors
    List<int> _UIDstore = [];

    List<Actor> actors = [];
    GameMode  gamemode;
    Vector2       size;

    StreamController<Actor> _actorSpawnedEvent = new StreamController();
    Stream<Actor> onActorSpawned;

    StreamController<Actor> _actorRemovedEvent = new StreamController();
    Stream<Actor> onActorRemoved;

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

    T spawnActor<T extends Actor>(T actor, Vector2 location, { Vector2 rotation, Vector2 scale })  
    {
        actor.initialize(this);
        actor.location = location;
        if (rotation != null) actor.rotation = rotation;
        if (scale != null) actor.scale = scale;

        this.actors.add(actor);

        if (running) actor.beginPlay();
        _actorSpawnedEvent.add(actor);

        return actor;
    }

    void removeActor(Actor actor) 
    {
        actors.remove(actor);
        _actorRemovedEvent.add(actor);
    }

    void tick(double time) {
        for (var actor in actors) actor.tick(time);
    }

    void beginPlay() {
        if (!running) start();
        this.actors.forEach((actor) => actor.beginPlay());
    }
}