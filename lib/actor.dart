part of australiasim;

class Actor {
  World world;
  Vector2 _location;
  Vector2 _rotation;
  Vector2 _scale;

  Actor(World this.world, Vector2 location) {
    this._location = location;
  }

  set location(Vector2 loc) => _location = loc;
  Vector2 get location => _location;

  set rotation(Vector2 rot) => _rotation = rot;
  Vector2 get rotation => _rotation;

  set scale(Vector2 scale) => _scale = scale;
  Vector2 get scale => _scale;

}