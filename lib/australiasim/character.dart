part of australiasim;

class Character extends Pawn
{
  Character() : super()
  {
      this.name = "Character";
      this.rotation = new Vector2(0.0, -1.0);
      this.scale = new Vector2(1.0, 1.0);
  }

  walk(Vector2 target) {
    target.add(location);
    requestWalkToLocation(target);
  }
}