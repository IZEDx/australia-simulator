part of australiasim;

class Spider extends Enemy
{
  Spider() : super()
  {
      _maxSpeed = 22.0 / 36.0;
      this.name = "Spider" + genUID();
  }
}