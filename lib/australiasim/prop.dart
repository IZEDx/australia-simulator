part of australiasim;

class Prop extends Actor
{
  Prop()
  {
      this.colliderBoxExtent = new Vector2(100.0, 100.0);
      final ran = new Random();
      this.name = "Prop " + ran.nextInt(1000).toString();
  }
}