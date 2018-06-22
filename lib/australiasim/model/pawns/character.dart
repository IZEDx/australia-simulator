part of australiasim;

class Character extends Pawn
{
 
    StreamController<int> _livesChangeEvent = new StreamController();
    Stream<int> onLivesChange;

    int _charLives = 2;

    int get charLives => _charLives;
    set charLives(int lives)
    {
        _livesChangeEvent.add(lives);
        _charLives = lives;
    } 

    Vector2 _velocity = new Vector2.zero();
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

    void _touchedEnemy()
    {
        charLives = max(charLives - 1, 0);

        if (charLives == 0)
        {
            world.gamemode.gameOverEvent.add(false);
        }
    }


    void walk(Vector2 velocity)
    {
        _velocity = velocity;
    }

    void tick(double dt)
    {
        if (_velocity.length != 0)
        {
            requestWalkToLocation(location + _velocity);
            super.tick(dt);
        }
    }
}