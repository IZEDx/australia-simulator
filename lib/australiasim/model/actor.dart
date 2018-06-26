part of australiasim;


/// Base class used for entities in the world
class Actor {

    /// World context the actor is placed in
    World _world = null;

    /// Location
    Vector2 _location = new Vector2(50.0, 50.0);

    /// Rotation
    Vector2 _rotation = new Vector2(0.0, -1.0);

    /// Scale ([colliderBoxExtent] only used for collision calculations)
    Vector2 _scale = new Vector2(100.0, 100.0);

    /// Collider dimensions 
    Vector2 _colliderBoxExtent = new Vector2(100.0, 100.0);

    /// Using a circle or box primitive for collision?
    bool _isCircleCollider = false;

    /// Name
    String _name = "";

    /// Used to broadcast new position on change
    StreamController<Vector2> _moveEvent = new StreamController();
    /// Emits new position on change
    Stream<Vector2> onMove;

    /// Used to broadcast new rotation on change
    StreamController<Vector2> _rotateEvent = new StreamController();
    /// Emits new rotation on change
    Stream<Vector2> onRotate;

    /// Used to broadcast new scale on change
    StreamController<Vector2> _scaleEvent = new StreamController();
    /// Emits new scale on change
    Stream<Vector2> onScale;

    /// Used to broadcast collide events 
    StreamController<Actor> collideEvent = new StreamController();
    /// Emits actors this actor collides with
    Stream<Actor> onCollide;

    /// Constructor
    Actor() {
        this.onMove = _moveEvent.stream.asBroadcastStream();
        this.onRotate = _rotateEvent.stream.asBroadcastStream();
        this.onScale = _scaleEvent.stream.asBroadcastStream();
        this.onCollide = collideEvent.stream.asBroadcastStream();
    }

    /// World
    World get world => _world;

    /// Is this actor still placed in a valid world
    bool get valid => world != null;

    /// Sets new [name]
    set name(String name) => _name = name;
    /// Name
    String get name => _name;

    /// Sets new [location]
    set location(Vector2 location) 
    {
        this._location = location;
        this._moveEvent.add(_location);
    }
    /// Location
    Vector2 get location => _location;

    /// Set new [rotation]
    set rotation(Vector2 rotation) 
    {
        this._rotation = rotation.normalized();
        this._rotateEvent.add(_rotation);
    }
    /// Rotation
    Vector2 get rotation => _rotation;

    /// Sets new [scale]
    set scale(Vector2 scale) 
    {
        _scale = scale;
        _scaleEvent.add(_scale);
    }
    Vector2 get scale => _scale;

    /// Set new collider [dimensions]
    set colliderBoxExtent(Vector2 dimensions) => _colliderBoxExtent = dimensions;
    /// Collider dimensions
    Vector2 get colliderBoxExtent => _colliderBoxExtent;

    /// Sets whether is using [isCircleCollider] for collision
    set isCircleCollider (bool isCircleCollider) => _isCircleCollider  = isCircleCollider ;
    /// Using a circle or box primitive for collision?
    bool get isCircleCollider  => _isCircleCollider ;

    /// Called when the actor is instantiated in the [world]
    void initialize(World world) 
    {
        _world = world;
        this.name = "Actor" + world.genUID();
    }

    /// Called when the level starts
    void beginPlay()
    {
    }
    
    /// Used for operations which need to be done in short intervals where [deltaTime] specifies the time since the last tick
    void tick(double deltaTime) 
    {

    }

    /// Is colliding with [other] on an optional [destLocation]?
    bool isCollidingWith(Actor other, [Vector2 destLocation])
    {
        if (destLocation == null) 
        {
            destLocation = this.location.clone();
        }

        final noBoxColl = !this.isCircleCollider && (this.colliderBoxExtent.x * this.colliderBoxExtent.y <= 0.0 || other.colliderBoxExtent.x * other.colliderBoxExtent.y <= 0.0);
        final noCircleColl = this.isCircleCollider && (max(this.colliderBoxExtent.y, this.colliderBoxExtent.x) <= 0.0 || max(other.colliderBoxExtent.y, other.colliderBoxExtent.x) <= 0.0);

        if(other == null || noBoxColl || noCircleColl)
        {
            return false;
        }

        if(other.isCircleCollider)
        {
            return _isCollidingWithCircle(other, destLocation);
        }
        else
        {
            return _isCollidingWithRectangle(other, destLocation);
        }

    }

    /// Helper for [isCollidingWith()] when colliding with [other] circle collider actor on [destLocation]
    bool _isCollidingWithCircle(Actor other, Vector2 destLocation)
    {
        if(this.isCircleCollider)
        {
            final tBoxOwn = this.colliderBoxExtent;
            final tBoxOther = other.colliderBoxExtent;
            final dist = other.location.distanceTo(destLocation);
            final d = max(tBoxOwn.x, tBoxOwn.y) + max(tBoxOther.x, tBoxOther.y);
            return dist <= d;
        }
        else
        {
            return _circleBoxCollision(other, other.location, this, destLocation);
        }
    }
    /// Helper for [isCollidingWith()] when colliding with [other] box collider actor on [destLocation]
    bool _isCollidingWithRectangle(Actor other, Vector2 destLocation)
    {
        if(this.isCircleCollider)
        {
            return _circleBoxCollision(this, destLocation, other, other.location);
        }
        else
        {
            final corners1 = this.getBoxColliderCorners(destLocation);
            final corners2 = other.getBoxColliderCorners(other.location);
        
            List<Vector2> normals = new List<Vector2>();
            normals.addAll(getColliderBoxNormals(corners1));
            normals.addAll(getColliderBoxNormals(corners2));

            for(final normal in normals)
            {
                List<double> dots1 = new List<double>();
                List<double> dots2 = new List<double>();
                
                corners1.forEach((v) => dots1.add(normal.dot(v)));
                corners2.forEach((v) => dots2.add(normal.dot(v)));
                
                final b1Max = dots1.reduce(max);
                final b1Min = dots1.reduce(min);
                final b2Max = dots2.reduce(max);
                final b2Min = dots2.reduce(min);

                if(b2Min > b1Max || b2Max < b1Min)
                    return false;
            }
        }

        return true;

    }
    
    /// Returns list of corners this actor had with a box collider on [destLocation]
    List<Vector2> getBoxColliderCorners(Vector2 destLocation)
    {
        List<Vector2> tList = new List<Vector2>();
        final radians = atan2(this.rotation.x, this.rotation.y);

        final tCollider = colliderBoxExtent;

        tList.add(_rotatePointAround(new Vector2(destLocation.x - tCollider.x / 2.0, destLocation.y - tCollider.y / 2.0), destLocation, radians));
        tList.add(_rotatePointAround(new Vector2(destLocation.x - tCollider.x / 2.0, destLocation.y + tCollider.y / 2.0), destLocation, radians));
        tList.add(_rotatePointAround(new Vector2(destLocation.x + tCollider.x / 2.0, destLocation.y + tCollider.y / 2.0), destLocation, radians));
        tList.add(_rotatePointAround(new Vector2(destLocation.x + tCollider.x / 2.0, destLocation.y - tCollider.y / 2.0), destLocation, radians));

        return tList;
    }

    /// Helper method for [_isCollidingWithRectangle] and [_isCollidingWithCircle]. Returns whether a [circleActor] on [circleLocation] and [boxActor] on [boxLocation] collide.
    static bool _circleBoxCollision(Actor circleActor, Vector2 circleLocation, Actor boxActor, Vector2 boxLocation)
    {
        final unrotatedCirclePos = _rotatePointAround(circleLocation, boxLocation, -atan2(boxActor.rotation.x, boxActor.rotation.y));
        final scaledCircle = circleActor.colliderBoxExtent.clone();
        final scaledBox = boxActor.colliderBoxExtent.clone();
        final tBox = boxLocation - (scaledBox / 2.0);
        Vector2 minVector = unrotatedCirclePos.clone();

        if(unrotatedCirclePos.x < tBox.x)
        {
            minVector.x = tBox.x;
        }
        else if(unrotatedCirclePos.x > tBox.x + scaledBox.x)
        {
            minVector.x = tBox.x + scaledBox.x;
        }

        if(unrotatedCirclePos.y < tBox.y)
        {
            minVector.y = tBox.y;
        }
        else if(unrotatedCirclePos.y > tBox.y + scaledBox.y)
        {
            minVector.y = tBox.y + scaledBox.y;
        }

        return unrotatedCirclePos.distanceTo(minVector) < min(scaledCircle.x, scaledCircle.y);
    }

    /// Returns list of normals a collider box has constructed by a list of [corners]
    static List<Vector2> getColliderBoxNormals(List<Vector2> corners)
    {
        List<Vector2> tList = new List<Vector2>();

        tList.add((corners[1] - corners[0]).normalized());
        tList.add((corners[3] - corners[0]).normalized());

        return tList;
    }

    /// Returns location of a [point] when rotated around a [center] by the amount of given [radians]
    static Vector2 _rotatePointAround(Vector2 point, Vector2 center, double radians)
    {
        final offset = point - center;

        final x = (offset.x * cos(radians) - (offset.y * sin(radians)));
        final y = (offset.x * sin(radians) + (offset.y * cos(radians)));

        return (new Vector2(x, y)) + center;
    }
}