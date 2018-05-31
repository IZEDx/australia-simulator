part of australiasim;

final worldSize = new Vector2(2000.0, 2000.0);

class GameMode {
  World world;
  Character player;

  StreamController<bool> gameOverEvent = new StreamController();
  Stream<bool> onGameOver;

  GameMode()
  {
    onGameOver = gameOverEvent.stream.asBroadcastStream();
  }

  void start() => world == null ? null : world.beginPlay();
  void stop() => world == null ? null : world.stop();
  bool get running => world != null && world.running;

  void load() {
    if (running) return;

    world = new World(worldSize, this);

    // Character
    player = world.spawnActor(new Character(), new Vector2(worldSize.x / 2, 150.0));
    
    // Door
    world.spawnActor(new Door(), new Vector2(worldSize.x / 2, 0.0));

    // Test Box
    world.spawnActor(
      new Prop(), 
      new Vector2(worldSize.x / 2 - 200.0, worldSize.y / 2), 
      scale: new Vector2(300.0, 200.0),
      rotation: new Vector2(0.8, 0.2)
    );
    world.spawnActor(
      new Prop(), 
      new Vector2(worldSize.x / 2 + 200.0, worldSize.y / 2), 
      scale: new Vector2(200.0, 300.0),
      rotation: new Vector2(0.2, 0.8)
    );

    // Spider

    var enemies = 1;

    for (int i = 1; i < enemies + 1; i++) {
      world.spawnActor(
        new Spider(),
        new Vector2(worldSize.x / (enemies + 1) * i, worldSize.y - 300.0)
      );
    }

    world.onActorRemoved.listen((a) {
      enemies--;
      print("${enemies} enemies left");
      if (enemies == 0) gameOverEvent.add(true);
    });
  }

  void moveCharacter(Vector2 t) {
    if (running && player != null) {
      player.walk(t);
    }
  }

  void tick(double time) {
    if (running && world != null) {
      world.tick(time);
    }
  }
}