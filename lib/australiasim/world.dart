part of australiasim;

class World {
  List<Actor> actors = [];
  GameMode gamemode;
  Vector2 size;

  StreamController<Actor> _actorSpawnedEvent = new StreamController();
  Stream<Actor> get onActorSpawned => _actorSpawnedEvent.stream.asBroadcastStream();

  World(Vector2 this.size, GameMode this.gamemode) {

  }

  T spawnActor<T extends Actor>(T actor, Vector2 location, { Vector2 rotation, Vector2 scale })  {
    actor.world = this;
    actor.location = location;
    if (rotation != null) actor.rotation = rotation;
    if (scale != null) actor.scale = scale;
    this.actors.add(actor);
    actor.beginPlay();
    _actorSpawnedEvent.add(actor);
    return actor;
  }

  void tick(double time) {
    for (var actor in actors) actor.tick(time);
  }
}