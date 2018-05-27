

part of australiasim;

class Door extends Prop
{
  
  StreamController<Pawn> collideEvent = new StreamController();
  Stream<Pawn> get onCollide => collideEvent.stream.asBroadcastStream();

  Door() : super()
  {
      this.name = "Door" + genUID();
      this._rotation = new Vector2(0.0, 1.0); // South
      this._scale = new Vector2(1.0, 0.2);
      onCollide.listen(handleCollision);
  }

  handleCollision(Pawn pawn) {
    if (pawn is Character) {
      print("You wanna leave already?");
    }
  }
}
