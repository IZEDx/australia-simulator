part of australiasim;

final worldSize = new Vector2(2000.0, 2000.0);

class GameMode {
  World world;
  Character player;

  StreamController<bool> gameOverEvent = new StreamController();
  Stream<bool> onGameOver;
  
  StreamController<int> _enemyCountChangeEvent = new StreamController();
  Stream<int> onEnemyCountChange;

  int _enemyCount = 0;
  int get enemyCount => _enemyCount;
  set enemyCount(int c) {
    _enemyCount = c;
    _enemyCountChangeEvent.add(c);
  }

  GameMode()
  {
    onGameOver = gameOverEvent.stream.asBroadcastStream();
    onEnemyCountChange = _enemyCountChangeEvent.stream.asBroadcastStream();
  }

  void start() => world == null ? null : world.beginPlay();
  void stop() => world == null ? null : world.stop();
  bool get running => world != null && world.running;

  void load(Level level) {
    if (running) return;

    world = new World(level.size, this);

    // Character
    player = world.spawnActor(new Character(), new Vector2(level.size.x / 2, 150.0));

    const wallWidth = 20.0;
    // Walls
    world.spawnActor(new Box(), new Vector2(level.size.x / 2, 0.0), scale: new Vector2(level.size.x + wallWidth, wallWidth));
    world.spawnActor(new Box(), new Vector2(level.size.x / 2, level.size.y), scale: new Vector2(level.size.x + wallWidth, wallWidth));
    
    world.spawnActor(new Box(), new Vector2(0.0, level.size.y / 2), scale: new Vector2(wallWidth, level.size.y + wallWidth));
    world.spawnActor(new Box(), new Vector2(level.size.x, level.size.y / 2), scale: new Vector2(wallWidth, level.size.y + wallWidth));

    world.spawnActor(new Shrub(), new Vector2(level.size.x / 2.0 - 250.0, -200.0), scale: new Vector2(200.0, 350.0), rotation: new Vector2(0.0, 1.0));
    world.spawnActor(new Shrub(), new Vector2(level.size.x / 2.0 + 250.0, -200.0), scale: new Vector2(200.0, 350.0), rotation: new Vector2(0.0, 1.0));
    
    // Door
    world.spawnActor(new Door(), new Vector2(level.size.x / 2, 0.0));

    enemyCount = 0;

    for (final data in level.actors) {
      Actor actor = world.spawnActor(
        data.instance(), 
        data.location, 
        scale: data.scale,
        rotation: data.rotation
      );

      if (actor is Enemy) {
        enemyCount++;
      }
    }

    world.onActorRemoved.listen((a) {
      enemyCount--;
      print("${enemyCount} enemies left");
      if (enemyCount == 0) gameOverEvent.add(true);
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