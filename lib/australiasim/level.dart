part of australiasim;

class ActorData {
  Actor object;
  Vector2 location;
  Vector2 rotation;
  Vector2 scale;
}

bool _isVec2List(dynamic list) {
  return list != null && list is List && list.length >= 2;
}

Vector2 _listToVec2(List list) {
  return new Vector2(double.parse(list[0].toString()), double.parse(list[1].toString()));
}

Actor _parseActor(String actorType) {
  Actor actor;
  switch (actorType) {
    case "spider": actor = new Spider(); break;
    default: actor = new Actor();
  }
  return actor;
}

class Level {
  bool loaded = false;
  String path;

  String spawnText = "";
  Vector2 size = new Vector2.zero();
  List<ActorData> actors = [];

  Level(String this.path) {
  }

  load() async {
    final body = await HttpRequest.getString(path);
    final Map data = JSON.decode(body);

    if (data.containsKey("spawnText") && data["spawnText"] is String) {
      spawnText = data["spawnText"];
    }

    if (data.containsKey("size") && _isVec2List(data["size"])) {
      size = _listToVec2(data["size"]);
    }

    if (data.containsKey("actors") && data["actors"] is List) {
      actors.clear();
      for (final actdata in data["actors"]) {
        if (actdata["type"] != null && _isVec2List(actdata["location"])) {

          final actor = new ActorData();
          actor.object = _parseActor(actdata["type"].toString());
          actor.location = _listToVec2(actdata["location"]);

          if (_isVec2List(actdata["rotation"])) {
            actor.rotation = _listToVec2(actdata["rotation"]);
          }

          if (_isVec2List(actdata["scale"])) {
            actor.rotation = _listToVec2(actdata["scale"]);
          }

          actors.add(actor);
        }
      }
    }

    this.loaded = true;
  }

  static Future<List<Level>> loadLevels(String path) async {
    String body = await HttpRequest.getString(path);
    List data = JSON.decode(body);
    if (!(data is List)) return [];

    List<Level> levels = [];
    List<Future> loadingLevels = [];

    _loadLevel(String path) async {
      final level = new Level(path);
      try {
        await level.load();
        if (level.loaded) {
          levels.add(level);
        }
      } catch(err) {}
    }

    for (final lvldata in data) {
      if (lvldata is Map && lvldata["path"] != null) {
        loadingLevels.add(_loadLevel(lvldata["path"])); 
      }
    }

    await Future.wait(loadingLevels);
    return levels;
  }
}