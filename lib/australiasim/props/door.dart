

part of australiasim;

class Door extends Prop
{

  Door() : super()
  {
      this.name = "Door" + genUID();
      this.rotation = new Vector2(0.0, 1.0); // South
      this.scale = new Vector2(130.0, 30.0);
      onCollide.listen(handleCollision);
  }

  handleCollision(Actor actor) {
    if (actor is Enemy) {
      this.world.removeActor(actor);
    }
  }
}
