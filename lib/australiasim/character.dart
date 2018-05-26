part of australiasim;

class Character extends Pawn
{
  Character() : super()
  {
      this.name = "Character";
  }

  walk(Vector2 target) {
    print("---");
    print(location);
    target.add(location);
    print(target);
    requestWalkToLocation(target);
  }
}