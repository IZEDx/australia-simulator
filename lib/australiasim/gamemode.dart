part of australiasim;

class GameMode {

  World currentWorld;

  StreamController<Vector2> _moveEvent = new StreamController();
  Stream<Vector2> get onMove => _moveEvent.stream.asBroadcastStream();

  StreamController<Actor> _actorSpawnedEvent = new StreamController();
  Stream<Actor> get onActorSpawned => _actorSpawnedEvent.stream.asBroadcastStream();

  double speed = 5.0;
  Vector2 pos = new Vector2.zero();
  Vector2 target = new Vector2.zero();

  void moveCharacter(Vector2 t) {
    target = t;
  }

  GameMode()
  {
    this.currentWorld = new World(this);

    this.currentWorld.onActorSpawned.listen((actor) => _actorSpawnedEvent.add(actor));

    currentWorld.spawnActor(() => new Pawn(), new Vector2(0.0, 0.0), new Vector2(0.0, 1.0));

    currentWorld.spawnActor(() => new Prop(), new Vector2(100.0, 300.0), new Vector2(0.0, 1.0)).colliderBoxExtent = new Vector2(2000.0, 100.0);
    currentWorld.spawnActor(() => new Prop(), new Vector2(100.0, 350.0), new Vector2(0.0, 1.0)).colliderBoxExtent = new Vector2(2000.0, 100.0);

    currentWorld.spawnActor(() => new Prop(), new Vector2(350.0, 100.0), new Vector2(0.0, 1.0)).colliderBoxExtent = new Vector2(100.0, 2200.0);
    currentWorld.spawnActor(() => new Prop(), new Vector2(400.0, 100.0), new Vector2(0.0, 1.0)).colliderBoxExtent = new Vector2(100.0, 2200.0);
  }

  void tick(double time) {
    if (target.length == 0) return;

    pos.add(target / 800.0 * speed);
    if (pos.x < 25) pos.x = 25.0;
    if (pos.y < 25) pos.y = 25.0;
    if (pos.x > 475) pos.x = 475.0;
    if (pos.y > 475) pos.y = 475.0;
    _moveEvent.add(pos);
  }
}