part of australiasim;

class Actor {
  World world = null;
  Vector2 _location = new Vector2(0.0, 0.0);
  Vector2 _rotation = new Vector2(0.0, 0.0);
  Vector2 _scale = new Vector2(1.0, 1.0);

  Actor() {
  }

  bool get valid => world != null;

  set location(Vector2 loc) => _location = loc;
  Vector2 get location => _location;

  set rotation(Vector2 rot) => _rotation = rot;
  Vector2 get rotation => _rotation;

  set scale(Vector2 scale) => _scale = scale;
  Vector2 get scale => _scale;

}