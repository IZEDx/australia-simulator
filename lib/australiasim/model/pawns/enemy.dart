part of australiasim;

/// States an enemy can have during playtime
enum EnemyState {escaping, postEscape, idle}

/// Base class for any type of enemy
class Enemy extends Pawn
{
    /// Used to broadcast new cozyness on change
    StreamController<double> _cozynessChangeEvent = new StreamController();
    /// Emits new cozyness on change
    Stream<double> onCozynessChange;

    /// Time an enemy needs to recover after being embattled before being in [EnemyState.idle] again
    static const double recoverTime = 3.0;

    /// Min time before changing the walk direction
    static const double changeDirMinTime = 1.0;
    /// Max time before changing the walk direction
    static const double changeDirMaxTime = 2.5;

    /// Speed the [cozyness] increases when being in [EnemyState.idle]
    static const double cozynessIncSpeed = 5.0;
    /// Speed the [cozyness] decreases when being in [EnemyState.escaping]
    static const double cozynessDecSpeed = 30.0;

    /// Current time remainung before changing from [EnemyState.postEscape] to [EnemyState.idle]
    double _recoverTimeRemaining = 0.0;
    /// Current time remainung remainung before changing the walking direction
    double _changeDirTimeRemaining = 0.0;

    /// Current cozyness
    double _currCozyness = 0.0;

    /// Used for random behavior
    final _ran = new Random();
        
    /// Current state
    EnemyState get state 
    {
        if (_isEmbattled()) 
            return EnemyState.escaping;
        else if (_recoverTimeRemaining != 0.0 ) 
            return EnemyState.postEscape;
        else
            return EnemyState.idle;
    }

    /// Cozyness
    double get cozyness => _currCozyness;

    /// Sets new [cozyness] 
    set cozyness(double cozyness) 
    {
        _currCozyness = cozyness;
        _cozynessChangeEvent.add(cozyness);
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
            .throttle( new Duration(milliseconds: 700) )
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

    /// Generates a random time by given [changeDirMinTime] and [changeDirMaxTime]
    double _nextRandomTime() => _ran.nextDouble() * (changeDirMaxTime - changeDirMinTime).abs() + changeDirMinTime;

    /// Handles collision with a given [other] actor
    void _collided(Actor other)
    {
        if (!_isEmbattled())
        {
            final rand = new Vector2.random().normalized();               
            this.rotation = (-this.rotation) * 10.0 + rand * 8.5;
        } 
        else if (other is Pawn) 
        {
            this.rotation = this.location - other.location;
        }
    }

    /// Is this pawn embattled by the player?
    bool _isEmbattled() => world.gamemode.player != null && world.gamemode.player.location.distanceTo(this.location) < 200.0;

    /// Sets a new random walking direction
    void _setRandomRotation()
    {
        this.rotation = new Vector2(_ran.nextDouble() - 0.5, _ran.nextDouble() - 0.5);
    }
}