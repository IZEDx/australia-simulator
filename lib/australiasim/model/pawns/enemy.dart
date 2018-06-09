part of australiasim;
enum EnemyState {escaping, postEscape, idle}
class Enemy extends Pawn
{
  static const double recoverTime = 3.0;

  static const double changeDirMinTime = 1.0;
  static const double changeDirMaxTime = 2.5;

  double _recoverTimeRemaining = 0.0;

  double _changeDirTimeRemaining = 0.0;

  final _ran = new Random();
    
  EnemyState get state => _isEmbattled() ? EnemyState.escaping : _recoverTimeRemaining != 0.0 ? EnemyState.postEscape : EnemyState.idle;

  double get speed  
  {
    switch (state)
    {
        case EnemyState.escaping:
            return maxSpeed;
        case EnemyState.postEscape:
            return maxSpeed * 0.7;
        case EnemyState.idle:
            return maxSpeed * 0.38;
    }     
  }

  Enemy() : super()
  {
    this.name = "Enemy" + genUID();
    onCollide.listen(_collided);
  }
  
  bool _isEmbattled() => world.gamemode.player != null && world.gamemode.player.location.distanceTo(this.location) < 200.0;

  void tick(double deltaTime)
  {
    if(_isEmbattled())
    {
      final playerPos = world.gamemode.player.location;
      final escapeVector = (worldSize / 2.0 - this.location).normalized();
      this.rotation = this.location + escapeVector * 70.0 - playerPos;

      

      _recoverTimeRemaining = recoverTime;
    }
    else
    {
        _recoverTimeRemaining = max(0.0, _recoverTimeRemaining - deltaTime);

        if(state == EnemyState.idle)
        {
            _changeDirTimeRemaining = max(0.0, _changeDirTimeRemaining - deltaTime);

            if(_changeDirTimeRemaining == 0)
            {
                _setRandomRotation();
                _changeDirTimeRemaining = _ran.nextDouble() * (changeDirMaxTime - changeDirMinTime).abs() + changeDirMinTime;
            }
        }
        else
        {
            _changeDirTimeRemaining = _ran.nextDouble() * (changeDirMaxTime - changeDirMinTime).abs() + changeDirMinTime;
        }

    }

    requestWalkToLocation(this.location + this.rotation * 200.0);

    super.tick(deltaTime);
  }

  void _collided(Actor other)
  {
      if(!_isEmbattled())
      {
          _setRandomRotation();
      }
      else if(other is Pawn)
      {
          this.rotation = this.location - other.location;
      }
          

  }

  void _setRandomRotation()
  {
      this.rotation = new Vector2(_ran.nextDouble() - 0.5, _ran.nextDouble() - 0.5);
  }
}