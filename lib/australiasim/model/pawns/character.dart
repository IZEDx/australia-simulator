part of australiasim;

class Character extends Pawn
{
 
  int _charLives = 2;

  int get charLives => _charLives;
  set charLives(int lives) => _charLives = lives;

  Vector2 _velocity = new Vector2.zero();

  Character() : super()
  {
      maxSpeed = 400.0;
      name = "Character";

      new Observable(this.onCollide)
      .where((Actor a) => a is Enemy)
      .throttle(new Duration(seconds: 2))
      .listen( (Actor a) => this._touchedEnemy());
  }

  void _touchedEnemy()
  {
      _charLives = max(_charLives - 1, 0);

      if(charLives == 0)
        print("DEAD");
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