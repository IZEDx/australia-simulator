part of australiasim;

List<int> UIDstore = [];
String genUID() {
  final ran = new Random();
  int n;
  do {
    n = ran.nextInt(1000);
  } while( UIDstore.contains(n) );
  
  return n.toString();
}

class Actor {
  World world = null;
  Vector2 _location = new Vector2(50.0, 50.0);
  Vector2 _rotation = new Vector2(0.0, -1.0);
  Vector2 _scale = new Vector2(100.0, 100.0);
  Vector2 _colliderBoxExtent = new Vector2(100.0, 100.0);
  bool _isCircleCollider = false;
  String _name = "";

  StreamController<Vector2> _moveEvent = new StreamController();
  Stream<Vector2> onMove;

  StreamController<Vector2> _rotateEvent = new StreamController();
  Stream<Vector2> onRotate;

  StreamController<Vector2> _scaleEvent = new StreamController();
  Stream<Vector2> onScale;

  StreamController<Actor> collideEvent = new StreamController();
  Stream<Actor> onCollide;

  Actor() {
    this.name = "Actor" + genUID();
    this.onMove = _moveEvent.stream.asBroadcastStream();
    this.onRotate = _rotateEvent.stream.asBroadcastStream();
    this.onScale = _scaleEvent.stream.asBroadcastStream();
    this.onCollide = collideEvent.stream.asBroadcastStream();
  }

  bool get valid => world != null;

  set name(String name) => _name = name;
  String get name => _name;

  set location(Vector2 loc) {
    _location = loc;
    _moveEvent.add(_location);
  }
  Vector2 get location => _location;

  set rotation(Vector2 rot) {
    _rotation = rot.normalized();
    _rotateEvent.add(_rotation);
  }
  Vector2 get rotation => _rotation;

  set scale(Vector2 scale) {
    _scale = scale;
    _scaleEvent.add(_scale);
  }
  Vector2 get scale => _scale;

  set colliderBoxExtent(Vector2 box) => _colliderBoxExtent = box;
  Vector2 get colliderBoxExtent => _colliderBoxExtent;

  set isCircleCollider (bool isCircleCollider) => _isCircleCollider  = isCircleCollider ;
  bool get isCircleCollider  => _isCircleCollider ;

  void beginPlay()
  {

  }

  void tick(double time) 
  {

  }

  bool isCollidingWith(Actor other, [Vector2 destLocation])
  {
    if (destLocation == null) {
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

  bool _isCollidingWithRectangle(Actor other, Vector2 destLocation)
  {
    if(this.isCircleCollider)
    {
        return _circleBoxCollision(this, destLocation, other, other.location);
    }
    else
    {
        final corners1 = this._getBoxColliderCorners(destLocation);
        final corners2 = other._getBoxColliderCorners(other.location);
     
        List<Vector2> normals = new List<Vector2>();
        normals.addAll(_getColliderBoxNormals(corners1));
        normals.addAll(_getColliderBoxNormals(corners2));

        //corners1.forEach((v) => print("c1: " + corners1.toString()));
        //corners2.forEach((v) => print("c2: " + corners2.toString()));

        for(var normal in normals)
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
  
  List<Vector2> _getBoxColliderCorners(Vector2 destLocation)
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

  static bool _circleBoxCollision(Actor circleActor, Vector2 circleLocation, Actor boxActor, Vector2 boxLocation)
  {
      final unrotatedCirclePos = _rotatePointAround(circleLocation, boxLocation, atan2(boxActor.rotation.x, boxActor.rotation.y));

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

  static List<Vector2> _getColliderBoxNormals(List<Vector2> corners)
  {
      List<Vector2> tList = new List<Vector2>();

      tList.add((corners[1] - corners[0]).normalized());
      tList.add((corners[3] - corners[0]).normalized());

      return tList;

  }

  static Vector2 _rotatePointAround(Vector2 point, Vector2 center, double radians)
  {
    final offset = point - center;

    final x = (offset.x * cos(radians) - (offset.y * sin(radians)));
    final y = (offset.x * sin(radians) + (offset.y * cos(radians)));

    return (new Vector2(x, y)) + center;
  }

  Vector2 getCorrectedOffsetPos(Actor other, Vector2 destLocation)
  {
      if(!this.isCircleCollider || other.isCircleCollider)
          return new Vector2.zero();

      final unrotDest = _rotatePointAround(destLocation, other.location, atan2(other.rotation.x, other.rotation.y));
      final unrotOrigin = _rotatePointAround(this.location, other.location, atan2(other.rotation.x, other.rotation.y));
      final scaledCircleRad = max(this.colliderBoxExtent.x, this.colliderBoxExtent.y);
      final scaledBox = other.colliderBoxExtent;
      final tBox = other.location - (scaledBox / 2.0);

      Vector2 minVector = unrotOrigin.clone();

      if(unrotDest.x > tBox.x && unrotDest.x < tBox.x + scaledBox.x)
      {
        if(unrotDest.x < unrotOrigin.x)
        {
            minVector.x = tBox.x - scaledCircleRad - 1.0;

        }
        else
        {
            minVector.x = tBox.x + scaledBox.x + scaledCircleRad + 1.0;
        }
      }
      
      if(unrotDest.y > tBox.y && unrotDest.y < tBox.y + scaledBox.y)
      {
          if(unrotDest.y < unrotOrigin.y)
          {
              minVector.y = tBox.y - scaledCircleRad - 1.0;
          }
          else
          {
              minVector.y = tBox.y + scaledBox.y + scaledCircleRad + 1.0;
          }
      }  

      print("v " + minVector.toString());

      final dir = (_rotatePointAround(minVector, other.location, -atan2(other.rotation.x, other.rotation.y)) - this.location).normalized();

      return dir;
  }

}