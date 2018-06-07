part of australiasim;

class Pawn extends Actor
{
    // speed in cm/s
    double _maxSpeed = 300.0;
    Vector2 _currentTargetLocation = new Vector2(0.0, 0.0);
    bool ticki = true;
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
      if(this.location.distanceTo(this._currentTargetLocation) > 7.0 && ticki)
      {
          final nextPos = _calcNextPosition(deltaTime);
          this.location = nextPos;

          if (this.location.distanceTo(this._currentTargetLocation) < 7.5) {
            _reachTargetEvent.add(this.location);
          }
      }
    }

    Vector2 _calcNextPosition(double deltaTime)
    {
        this.rotation = this._currentTargetLocation - this.location;
        final nextPos = (this.rotation * this.maxSpeed * deltaTime) + this.location;

        // Edge handling

        final r = this.scale / 2.0;
        if (nextPos.x < r.x) nextPos.x = r.x;
        if (nextPos.y < r.y) nextPos.y = r.y;
        if (nextPos.x > this.world.size.x - r.x) nextPos.x = this.world.size.x - r.x;
        if (nextPos.y > this.world.size.y - r.y) nextPos.y = this.world.size.y - r.y;

        final collisions = collidingWithOnPosition(nextPos);
        if(collisions.length == 0)
        {
            return nextPos;
        }
        else
        {
          for(var actor in collisions)
          {
            actor.collideEvent.add(this);

            final nuPos = this.location + this.getCorrectedOffsetPos(actor, nextPos) * this.maxSpeed * deltaTime;

            

            if(nuPos != new Vector2.zero() && collidingWithOnPosition(nuPos).length == 0)
            {
                print("found: " + nuPos.distanceTo(this.location).toString());
                return nuPos;
            }
            
             
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

    @override
    void beginPlay()
    {
        super.beginPlay();
        print(this.name + ": Hi, I am ready.");
        this._currentTargetLocation = this.location.clone();
        this.colliderBoxExtent = this.scale / 2.0; // Circle collider require radius as colliderBox
    }
}