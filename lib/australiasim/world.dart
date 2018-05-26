part of australiasim;

class World {
  List<Actor> actors = [];
  GameMode gamemode;
  Vector2 size;

  StreamController<Actor> _actorSpawnedEvent = new StreamController();
  Stream<Actor> get onActorSpawned => _actorSpawnedEvent.stream.asBroadcastStream();

  World(Vector2 this.size, GameMode this.gamemode) {

  }

  T spawnActor<T extends Actor>(T toSpawn(), Vector2 location, Vector2 rotation) {
    final actor = toSpawn();
    actor.world = this;
    actor.location = location;
    actor.rotation = rotation;
    actor.scale = new Vector2(1.0, 1.0);
    this.actors.add(actor);
    actor.beginPlay();
    _actorSpawnedEvent.add(actor);
    return actor;
  }

  void tick(double time) {
    for (var actor in actors) actor.tick(time);
  }
}