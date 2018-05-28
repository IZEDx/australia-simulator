part of australiasim;

final worldSize = new Vector2(2000.0, 2000.0);

class GameMode {
  bool _running = false;

  World currentWorld;
  Character currentPlayerCharacter;

  StreamController<bool> gameOverEvent = new StreamController();
  Stream<bool> onGameOver;

  GameMode()
  {
    onGameOver = gameOverEvent.stream.asBroadcastStream();
  }

  void start() => _running = true;
  void stop() => _running = false;
  bool get running => _running;

  void load() {
    currentWorld = new World(worldSize, this);

    // Character
    currentPlayerCharacter = currentWorld.spawnActor(new Character(), new Vector2(worldSize.x / 2, 150.0));
    
    // Door
    currentWorld.spawnActor(new Door(), new Vector2(worldSize.x / 2, 0.0));

    // Test Box
    currentWorld.spawnActor(
      new Prop(), 
      new Vector2(worldSize.x / 2 - 200.0, worldSize.y / 2), 
      scale: new Vector2(200.0, 200.0),
      rotation: new Vector2(0.8, 0.2)
    );
    currentWorld.spawnActor(
      new Prop(), 
      new Vector2(worldSize.x / 2 + 200.0, worldSize.y / 2), 
      scale: new Vector2(200.0, 200.0),
      rotation: new Vector2(0.2, 0.8)
    );

    // Spider

    var enemies = 12;

    for (int i = 1; i < enemies + 1; i++) {
      currentWorld.spawnActor(
        new Spider(),
        new Vector2(worldSize.x / (enemies + 1) * i, worldSize.y - 300.0)
      );
    }

    currentWorld.onActorRemoved.listen((a) {
      enemies--;
      print("${enemies} enemies left");
      if (enemies == 0) gameOverEvent.add(true);
    });


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