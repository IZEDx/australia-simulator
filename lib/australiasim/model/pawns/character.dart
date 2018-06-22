part of australiasim;

/// Class for the "hero" possesed by the player
class Character extends Pawn
{
    /// Used to broadcast new amount of lives on change
    StreamController<int> _livesChangeEvent = new StreamController();
    /// Emits new amount of lives on change
    Stream<int> onLivesChange;

    /// Lives 
    int _charLives = 2;

    /// Lives 
    int get charLives => _charLives;

    /// Sets new [lives] count
    set charLives(int lives)
    {
        _livesChangeEvent.add(lives);
        _charLives = lives;
    } 

    /// Velocity
    Vector2 _velocity = new Vector2.zero();

    @override
    get speed => maxSpeed * min(_velocity.length, 100.0) / 100;

    @override
    void initialize(World world) 
    {
        super.initialize(world);
        maxSpeed = 400.0;
        name = "Character";
        this.onLivesChange = _livesChangeEvent.stream.asBroadcastStream();

        new Observable(this.onCollide)
            .where((Actor a) => a is Enemy)
            .throttle(new Duration(seconds: 1))
            .listen( (Actor a) => this._touchedEnemy());
    }

    /// Used to count down lives on collision with an enemy, handles game over when "dead".
    void _touchedEnemy()
    {
        charLives = max(charLives - 1, 0);

        if (charLives == 0)
        {
            world.gamemode.gameOverEvent.add(false);
        }
    }

    /// Used to control the direction and speed of the movement by a given [velocity] 
    void walk(Vector2 velocity)
    {
        _velocity = velocity;
    }

    @override
    void tick(double deltaTime)
    {
        if (_velocity.length != 0)
        {
            requestWalkToLocation(location + _velocity);
            super.tick(deltaTime);
        }
    }
}