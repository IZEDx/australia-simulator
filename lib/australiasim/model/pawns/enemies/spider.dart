part of australiasim;

class Spider extends Enemy
{
  Spider() : super()
  {
      _maxSpeed = 400.0;
      this.name = "Spider" + genUID();
      this.scale /= 2.0;
  }
}