part of australiasim;


class LevelManager {
  bool _ready = false;
  String _path;
  List<Level> _levels;

  bool get ready => _ready;

  String get path => _path;

  int get size => _levels.length;

  int get current {
    final idx = window.localStorage.containsKey("level") ? int.parse(window.localStorage["level"]) : 0;
    return idx >= size ? size -1 : idx;
  }
  set current(int idx) {
    idx = (idx >= size ? size -1 : idx);
    window.localStorage["level"] = idx.toString();
    if (idx > unlocked) _unlocked = idx;
  }

  int get unlocked => window.localStorage.containsKey("unlocked") ? int.parse(window.localStorage["unlocked"]) : 0;
  set _unlocked(int idx) => window.localStorage["unlocked"] = idx.toString();

  LevelManager(String this._path) {
  }

  load() async {
    _levels = await Level.loadLevels(_path);
    _ready = true;
  }

  Level get(int level) => _levels[level];
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
          actor.instance = () => _parseActor(actdata["type"].toString());
          actor.location = _listToVec2(actdata["location"]);

          if (_isVec2List(actdata["rotation"])) {
            actor.rotation = _listToVec2(actdata["rotation"]);
          }

          if (_isVec2List(actdata["scale"])) {
            actor.scale = _listToVec2(actdata["scale"]);
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

    for (final lvldata in data) {
      if (lvldata is Map && lvldata["path"] != null) {
        final level = new Level(lvldata["path"]);
        try {
          await level.load();
          if (level.loaded) {
            levels.add(level);
          }
        } catch(err) {}
      }
    }

    return levels;
  }
}


class ActorData {
  Function instance;
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
    case "bigredspider":  actor = new BigRedSpider(); break;
    case "bigspider":     actor = new BigSpider();    break;
    case "spider":        actor = new Spider();       break;
    case "box":           actor = new Box();          break;
    default:              actor = new Actor();        break;
  }
  return actor;
}