part of australiasim;

class Character extends Pawn
{
  Character() : super()
  {
      this.colliderBoxExtent = new Vector2(100.0, 100.0);
      this.name = "Character";
  }
}