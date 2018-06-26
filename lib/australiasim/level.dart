part of australiasim;

/// LevelManager loads and holds the level list and also
/// offers operations on the localStorage to store and
/// retrieve "unlocked" and "current" level
class LevelManager {
    /// If the LevelManager is ready
    bool _ready = false;
    bool get ready => _ready;

    /// The path to the levels.json
    String _path;
    String get path => _path;

    /// The list of the loaded levels
    List<Level> _levels;

    /// How many levels exist, should check
    /// if ready first
    int get size => _levels.length;

    /// Get the index of the level the user
    /// is currently at
    int get current {
        final idx = window.localStorage.containsKey("level") ? int.parse(window.localStorage["level"]) : 0;
        return idx >= size ? size -1 : idx;
    }

    /// Update the index of the level the user
    /// is currently at. If the level is higher than 
    /// the unlocked level, the player will unlock
    /// it as well.
    set current(int idx) {
        idx = (idx >= size ? size -1 : idx);
        window.localStorage["level"] = idx.toString();
        if (idx > unlocked) window.localStorage["unlocked"] = idx.toString();
    }

    /// Gets the index of the highest level the user has unlocked
    int get unlocked => window.localStorage.containsKey("unlocked") ? int.parse(window.localStorage["unlocked"]) : 0;

    /// Constructor
    LevelManager(String this._path) {
    }

    /// Loads all levels
    load() async {

        // Get the levels.json
        String body = await HttpRequest.getString(path);
        List data = JSON.decode(body);
        if (!(data is List)) return [];

        // Reset the state
        _levels = [];
        _ready = false;

        // Load each level
        for (final lvldata in data) {
            if (lvldata is Map && lvldata["path"] != null) {
                final level = new Level(lvldata["path"]);
                try {
                    await level.load();
                    if (level.ready) {
                        _levels.add(level);
                    }
                } catch(err) {}
            }
        }

        // Indicate we finished loading
        _ready = true;
    }

    /// Returns a level if it exists,
    /// throws a RangeError if it does not exist.
    Level get(int level) => _levels[level];
}

/// Level loads, parses and holds the data
/// of a single level.json
class Level {
    /// If the Level is ready
    bool _ready = false;
    bool get ready => _ready;

    /// The path to the level.json
    String _path;
    String get path => _path;

    /// The text to show at the start of a level
    String _spawnText = "";
    String get spawnText => _spawnText;

    /// The size of the level
    Vector2 _size = new Vector2.zero();
    Vector2 get size => _size;
    
    /// List of actors of the level
    List<ActorData> _actors = [];
    List<ActorData> get actors => _actors;

    /// Creates a new level with the given path,
    /// unloaded at first
    Level(String this._path) {
    }

    /// Loads the level
    load() async {

        // Download and decode the level.json
        final body = await HttpRequest.getString(path);
        final Map data = JSON.decode(body);

        // Check for spawnText
        if (data.containsKey("spawnText") && data["spawnText"] is String) {
            _spawnText = data["spawnText"];
        }

        // Check for size
        if (data.containsKey("size") && _isVec2List(data["size"])) {
            _size = _listToVec2(data["size"]);
        }

        // Check for the actors
        if (data.containsKey("actors") && data["actors"] is List) {
            _actors.clear();
            for (final actdata in data["actors"]) {
                if (actdata["type"] != null && _isVec2List(actdata["location"])) {

                    final actor = new ActorData();
                    actor.factory = () => _parseActor(actdata["type"].toString());
                    actor.location = _listToVec2(actdata["location"]);

                    if (_isVec2List(actdata["rotation"])) {
                        actor.rotation = _listToVec2(actdata["rotation"]);
                    }

                    if (_isVec2List(actdata["scale"])) {
                        actor.scale = _listToVec2(actdata["scale"]);
                    }

                    _actors.add(actor);
                }
            }
        }

        _ready = true;
    }
}


/// Basic data needed to create and spawn an actor
class ActorData {
    /// Function that creates an instance of this Actor
    ActorFactory factory;

    /// Location to spawn at
    Vector2 location;

    /// Rotation to spawn with
    Vector2 rotation;

    /// Scale to spawn with
    Vector2 scale;
}

/// Factory function that creates an Actor
typedef Actor ActorFactory();

/// Returns whether [list] is a [List] of length 2
bool _isVec2List(dynamic list) {
    return list != null && list is List && list.length >= 2;
}

/// Converts a [list] with a length of at least 2 to a [Vector2]
Vector2 _listToVec2(List list) {
    return new Vector2(double.parse(list[0].toString()), double.parse(list[1].toString()));
}

/// Returns an Actor instance based on the given [actorType]
Actor _parseActor(String actorType) {
    switch (actorType) {
        case "shrub":         return new Shrub();
        case "tree":          return new Tree();   
        case "bigredspider":  return new BigRedSpider();
        case "bigspider":     return new BigSpider();
        case "spider":        return new Spider();
        case "box":           return new Box();
        case "smallbed":      return new SmallBed();
        case "bigbed":        return new BigBed();
        case "lamp":          return new Lamp(); 
        case "table":         return new Table(); 
        case "board":         return new Board();
        case "flower":        return new Flower();
        default:              return new Actor(); 
    }
}