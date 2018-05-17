part of australiasim;

class World {
  List<Actor> actors = [];
  GameMode gamemode;

  World(GameMode this.gamemode) {

  }

  T spawnActor<T extends Actor>(T toSpawn(), Vector2 location, Vector2 rotation) {
    final actor = toSpawn();
    actor.world = this;
    actor.location = location;
    actor.rotation = rotation;
    this.actors.add(actor);
    return actor;
  }
}