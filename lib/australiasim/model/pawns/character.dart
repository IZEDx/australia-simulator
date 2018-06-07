part of australiasim;

class Character extends Pawn
{
  Vector2 _velocity = new Vector2.zero();

  Character() : super()
  {
      maxSpeed = 400.0;
      name = "Character";
  }

  get speed => maxSpeed * min(_velocity.length, 100.0) / 100;

  walk(Vector2 velocity) {
    _velocity = velocity;
  }

  tick(double dt) {
    if (_velocity.length != 0) {
      requestWalkToLocation(location + _velocity);
      super.tick(dt);
    }
  }
}