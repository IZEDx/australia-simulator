

part of australiasim;

class Door extends Prop
{
  
  Door() : super()
  {
      this.name = "Door" + genUID();
      this._rotation = new Vector2(0.0, 1.0); // South
      this._scale = new Vector2(1.0, 0.2);
      onCollide.listen(handleCollision);
  }

  handleCollision(Actor actor) {
    if (pawn is Actor) {
      print("You wanna leave already?");
    }
  }
}
