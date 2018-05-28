part of australiasim;

class Character extends Pawn
{
  Character() : super()
  {
      this.name = "Character";
  }

  walk(Vector2 target) {
    requestWalkToLocation(location + target);
  }
}