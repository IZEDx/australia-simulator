part of australiasim;

enum EnemyState {escaping, postEscape, idle}
class Enemy extends Pawn
{
    StreamController<double> _cozynessChangeEvent = new StreamController();
    Stream<double> onCozynessChange;

    static const double recoverTime = 3.0;

    static const double changeDirMinTime = 1.0;
    static const double changeDirMaxTime = 2.5;

    static const double cozynessIncSpeed = 5.0;
    static const double cozynessDecSpeed = 30.0;

    double _recoverTimeRemaining = 0.0;
    double _changeDirTimeRemaining = 0.0;

    double _currCozyness = 0.0;

    final _ran = new Random();
        
    EnemyState get state 
    {
        if (_isEmbattled()) 
            return EnemyState.escaping;
        else if (_recoverTimeRemaining != 0.0 ) 
            return EnemyState.postEscape;
        else
            return EnemyState.idle;
    }

    double get cozyness => _currCozyness;
    set cozyness(double coz) 
    {
        _currCozyness = coz;
        _cozynessChangeEvent.add(coz);
    }

    @override
    double get speed  
    {
        switch (state)
        {
            case EnemyState.escaping:
                return maxSpeed;
            case EnemyState.postEscape:
                return maxSpeed * 0.6;
            case EnemyState.idle:
                return maxSpeed * 0.33;
        }     
        return 0.0;
    }

    @override
    void initialize(World world) 
    {
        super.initialize(world);
        this.name = "Enemy" + world.genUID();
        this.onCozynessChange = _cozynessChangeEvent.stream.asBroadcastStream();

        new Observable( this.onCollide )
            .throttle( new Duration(milliseconds: 500) )
            .listen( (Actor a) => this._collided(a) );
    }
    
    @override
    void tick(double deltaTime)
    {
        if(_isEmbattled())
        {
            final playerPos = world.gamemode.player.location;
            final escapeVector = (world.size / 2.0 - this.location).normalized();
            this.rotation = this.location + escapeVector * 70.0 - playerPos;

            _recoverTimeRemaining = recoverTime;

            cozyness = max(cozyness - cozynessDecSpeed * deltaTime, 0.0);
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
                    _changeDirTimeRemaining = _nextRandomTime();
                }
                cozyness = min(cozyness + cozynessIncSpeed * deltaTime, 100.0);
            }
            else
            {
                _changeDirTimeRemaining = _nextRandomTime();
            }

        }

        requestWalkToLocation(this.location + this.rotation * 200.0);

        if (cozyness == 100.0) 
        {
            world.gamemode.gameOverEvent.add(false);
        }
        
        super.tick(deltaTime);
    }

    double _nextRandomTime() => _ran.nextDouble() * (changeDirMaxTime - changeDirMinTime).abs() + changeDirMinTime;

    void _collided(Actor other)
    {
        if      ( !_isEmbattled() ) this.rotation = -this.rotation;
        else if (   other is Pawn ) this.rotation = this.location - other.location;
    }

    bool _isEmbattled() => world.gamemode.player != null && world.gamemode.player.location.distanceTo(this.location) < 200.0;

    void _setRandomRotation()
    {
        this.rotation = new Vector2(_ran.nextDouble() - 0.5, _ran.nextDouble() - 0.5);
    }
}