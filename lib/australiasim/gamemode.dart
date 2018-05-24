part of australiasim;

class GameMode {

  StreamController<Vector2> _moveEvent = new StreamController();
  Stream<Vector2> get onMove => _moveEvent.stream.asBroadcastStream();

  double speed = 5.0;
  Vector2 pos = new Vector2.zero();
  Vector2 target = new Vector2.zero();

  void moveCharacter(Vector2 t) {
    target = t;
  }

  void tick(double time) {
    if (target.length == 0) return;

    pos.add(target / 800.0 * speed);
    if (pos.x < 25) pos.x = 25.0;
    if (pos.y < 25) pos.y = 25.0;
    if (pos.x > 475) pos.x = 475.0;
    if (pos.y > 475) pos.y = 475.0;
    _moveEvent.add(pos);
  }
}