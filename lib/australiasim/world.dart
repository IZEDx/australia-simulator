part of australiasim;

class World {
  List<Actor> actors = [];
  GameMode gamemode;

  StreamController<Actor> _actorSpawnedEvent = new StreamController();
  Stream<Actor> get onActorSpawned => _actorSpawnedEvent.stream.asBroadcastStream();

  World(GameMode this.gamemode) {

  }

  T spawnActor<T extends Actor>(T toSpawn(), Vector2 location, Vector2 rotation) {
    final actor = toSpawn();
    actor.world = this;
    actor.location = location;
    actor.rotation = rotation;
    this.actors.add(actor);
    actor.beginPlay();
    _actorSpawnedEvent.add(actor);
    return actor;
  }
}