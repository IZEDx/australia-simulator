part of australiasim;

class GameMode {

  World currentWorld;
  Character currentPlayerCharacter;

  StreamController<Actor> _actorSpawnedEvent = new StreamController();
  Stream<Actor> get onActorSpawned => _actorSpawnedEvent.stream.asBroadcastStream();

  GameMode()
  {
    currentWorld = new World(new Vector2(10.0, 10.0), this);
    currentWorld.onActorSpawned.listen((actor) => _actorSpawnedEvent.add(actor));

    currentPlayerCharacter = new Character();
    currentWorld.spawnActor(() => currentPlayerCharacter, new Vector2(5.0, 5.0), new Vector2(0.0, 1.0));

    currentWorld.spawnActor(() => new Prop(), new Vector2(1.0, 3.0), new Vector2(1.0, 1.0));
    currentWorld.spawnActor(() => new Prop(), new Vector2(1.0, 4.0), new Vector2(0.0, 1.0));

    currentWorld.spawnActor(() => new Prop(), new Vector2(3.0, 1.0), new Vector2(0.0, 1.0));
    currentWorld.spawnActor(() => new Prop(), new Vector2(4.0, 1.0), new Vector2(0.0, 1.0));
  }
  
  void moveCharacter(Vector2 t) {
    if (currentPlayerCharacter != null) {
      currentPlayerCharacter.walk(t);
    }
  }

  void tick(double time) {
    if (currentWorld != null) {
      currentWorld.tick(time);
    }
  }
}