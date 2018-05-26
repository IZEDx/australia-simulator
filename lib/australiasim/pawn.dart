part of australiasim;

class Pawn extends Actor
{
    // first number speed in km/h
    double _maxSpeed = 10.0 / 3600.0;
    Vector2 _currentTargetLocation = new Vector2(0.0, 0.0);

    set maxSpeed(double speed) => _maxSpeed = speed;
    double get maxSpeed => _maxSpeed;

    StreamController<Vector2> _newTargetEvent = new StreamController();
    Stream<Vector2> get onNewTarget => _newTargetEvent.stream.asBroadcastStream();

    StreamController<Vector2> _reachTargetEvent = new StreamController();
    Stream<Vector2> get onReachTarget => _reachTargetEvent.stream.asBroadcastStream();

    Pawn() : super()
    {
        this.isCircleCollider = true;
        this.name = "Pawn" + genUID();
    }

    void requestWalkToLocation(Vector2 position)
    {
        this._currentTargetLocation = position;
        _newTargetEvent.add(position);
    }

    void tick(double deltaTime)
    {
      final nextPos = _calcNextPosition(deltaTime);
      if(nextPos != this.location)
      {
        this.location = nextPos;

        if (this.location.distanceTo(this._currentTargetLocation) < 1.0) {
          _reachTargetEvent.add(this.location);
        }
      }
    }

    Vector2 _calcNextPosition(double deltaTime)
    {
        this.rotation = this._currentTargetLocation - this.location;
        final nextPos = (this.rotation * this.maxSpeed * deltaTime) + this.location;
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