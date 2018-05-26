part of australiasim;

class Pawn extends Actor
{
    // first number speed in km/h
    double _maxSpeed = (10.0 * 100.0) / 3.6;
    Vector2 _currentTargetLocation = new Vector2(0.0, 0.0);

    set maxSpeed(double speed) => _maxSpeed = speed;
    double get maxSpeed => _maxSpeed;

    Pawn() : super()
    {

        this.colliderBoxExtent = new Vector2(50.0, 50.0);
        this.isCircleCollider = true;

        final ran = new Random();
        this.name = "Pawn" + ran.nextInt(1000).toString();
    }

    void requestWalkToLocation(Vector2 position)
    {
        this._currentTargetLocation = position;
    }

    void tickPhysics(double deltaTime)
    {
        final nextPos = _calcNextPosition(deltaTime);
        if(nextPos != this.location)
        {
            this.location = nextPos;
            //TODO throw next pos event
        }

    }

    Vector2 _calcNextPosition(double deltaTime)
    {
        this.rotation = this._currentTargetLocation - this.location;
        final nextPos = (this.rotation * this.maxSpeed) + this.location;
        final collisions = collidingWithOnPosition(nextPos);
        if(collisions.length == 0)
        {
            return nextPos;
        }
        else
        {
            //HACK! avoid collision stops
            final collX = collidingWithOnPosition(new Vector2(this.location.x, nextPos.y));
            if(collX.length == 0)
                return new Vector2(this.location.x, nextPos.y);

            final collY = collidingWithOnPosition(new Vector2(nextPos.x, this.location.y));
            if(collY.length == 0)
                return new Vector2(nextPos.x, this.location.y);


            for(var actor in collisions)
            {
                if(actor is Pawn)
                  this._onCollideWithOtherPawn(actor);
            }
        }

        return this.location;
    }

    List<Actor> collidingWithOnPosition(Vector2 destLocation)
    {
        List<Actor> tColl = new List<Actor>();

        for(var actor in world.actors)
        {
            if(actor != this && this.isCollidingWith(actor, destLocation))
              tColl.add(actor);
        }

        return tColl;
    }

    void _onCollideWithOtherPawn(Pawn other)
    {
        print("ouch!");
    }

    @override
    void beginPlay()
    {
        super.beginPlay();
        print(this.name + ": Hi, I am ready.");
    }
}