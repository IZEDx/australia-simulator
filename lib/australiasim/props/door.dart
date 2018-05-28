

part of australiasim;

class Door extends Prop
{
  
  Door() : super()
  {
      this.name = "Door" + genUID();
      this._rotation = new Vector2(0.0, 1.0); // South
      this._scale = new Vector2(100.0, 20.0);
      onCollide.listen(handleCollision);
  }

  handleCollision(Actor actor) {
    if (actor is Enemy) {
      this.world.removeActor(actor);
    }
  }
}
