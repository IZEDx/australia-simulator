part of australiasim;

final worldSize = new Vector2(20.0, 20.0);

class GameMode {
  bool _running = false;

  World currentWorld;
  Character currentPlayerCharacter;

  StreamController<Actor> _actorSpawnedEvent = new StreamController();
  Stream<Actor> get onActorSpawned => _actorSpawnedEvent.stream.asBroadcastStream();

  GameMode()
  {
  }

  void start() => _running = true;
  void stop() => _running = false;
  bool get running => _running;

  void load() {
    currentWorld = new World(worldSize, this);
    currentWorld.onActorSpawned.listen((actor) => _actorSpawnedEvent.add(actor));

    currentPlayerCharacter = currentWorld.spawnActor(new Character(), worldSize / 2.0);

    // Test Box
    currentWorld.spawnActor(
      new Prop(), 
      new Vector2(worldSize.x / 4, worldSize.y / 2), 
      scale: new Vector2(1.0, 1.0),
      rotation: new Vector2(1.0, 0.0)
    );

    //currentWorld.spawnActor(new Prop(), new Vector2(3.0, 1.0), new Vector2(0.0, 1.0));
    //currentWorld.spawnActor(new Prop(), new Vector2(4.0, 1.0), new Vector2(0.0, 1.0));
  }

  void moveCharacter(Vector2 t) {
    if (currentPlayerCharacter != null) {
      currentPlayerCharacter.walk(t);
    }
  }

  void tick(double time) {
    if (_running && currentWorld != null) {
      currentWorld.tick(time);
    }
  }
}