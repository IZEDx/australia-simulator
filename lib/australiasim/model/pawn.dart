part of australiasim;
/// Base class used for entities which are able to move
class Pawn extends Actor
{
    /// Actual max speed 
    double _maxSpeed = 400.0;
    /// Target location to move towards to
    Vector2 _currentTargetLocation = new Vector2(0.0, 0.0);

    /// Set new max [speed]
    set maxSpeed(double speed) => _maxSpeed = speed;
    /// The max speed
    double get maxSpeed => _maxSpeed;

    /// The current speed
    double get speed => _maxSpeed;

  	/// Constructor 
    Pawn() : super()
    {
        // Pawns use a circle collider by default
        this.isCircleCollider = true;
        this.name = "Pawn" + genUID();
    }

    /// Assign a new target [position]
    void requestWalkToLocation(Vector2 position)
    {
        this._currentTargetLocation = position;
    }

    @override
    void tick(double deltaTime)
    {
        // Movement updates
        final nextPos = _calcNextPosition(deltaTime);
        this.location = nextPos;
      
    }

    /// Returns the next position in the movement to the [_currentTargetLocation] based on a given [deltaTime]
    Vector2 _calcNextPosition(double deltaTime)
    {
        this.rotation = this._currentTargetLocation - this.location;
        final nextPos = (this.rotation * this.speed * deltaTime) + this.location;

        // World edge handling
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
              this.collideEvent.add(actor);

              // Edge sliding
              if(!actor.isCircleCollider)
              {
                  List<Vector2> normals = Actor.getColliderBoxNormals(actor.getBoxColliderCorners(actor.location));

                  normals.add(-normals[0]);
                  normals.add(-normals[1]);

                  if(!this.isCollidingWith(actor, this.location + normals[0] * 15.0) && !this.isCollidingWith(actor, this.location + normals[2] * 15.0))
                  {
                      final nuPos = this.location + normals[0] * this.speed * deltaTime;
                      final nuPos2 = this.location + normals[2] * this.speed * deltaTime;
                      final finPos = nuPos.distanceTo(nextPos) > nuPos2.distanceTo(nextPos) ? nuPos2 : nuPos;

                      if(collidingWithOnPosition(finPos).length == 0)
                        return finPos;
                  }
                  else if(!this.isCollidingWith(actor, this.location + normals[1] * 15.0) && !this.isCollidingWith(actor, this.location + normals[3] * 15.0))
                  {
                      final nuPos = this.location + normals[1] * this.speed * deltaTime;
                      final nuPos2 = this.location + normals[3] * this.speed * deltaTime;
                      final finPos = nuPos.distanceTo(nextPos) > nuPos2.distanceTo(nextPos) ? nuPos2 : nuPos;

                      if(collidingWithOnPosition(finPos).length == 0)
                        return finPos;
                  }
                  else
                  {
                      final filtered = normals.where((v) => !this.isCollidingWith(actor, this.location + v * 15.0)).map((v) =>  this.location + v * this.speed * deltaTime).toList();
                      if(filtered.length == 2)
                      {
                        final finPos = nextPos.distanceTo(filtered[0]) > nextPos.distanceTo(filtered[1]) ? filtered[1] : filtered[0];
                        if(collidingWithOnPosition(finPos).length == 0)
                          return finPos;
                      }  
                  }
              }
          }
        }

        return this.location;
    }
    
    /// Returns a list of other Actors which collide with this Pawn on a given [destLocation]
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