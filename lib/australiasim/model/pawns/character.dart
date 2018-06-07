part of australiasim;

class Character extends Pawn
{
  Vector2 _velocity = new Vector2.zero();

  Character() : super()
  {
      this.name = "Character";
  }

  walk(Vector2 velocity) {
    _velocity = velocity;
  }

  tick(double dt) {
    if (_velocity.length != 0) {
      maxSpeed = _velocity.length;
      requestWalkToLocation(location + _velocity);
      super.tick(dt);
    }
  }
}