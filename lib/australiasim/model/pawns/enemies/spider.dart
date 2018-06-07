part of australiasim;

class Spider extends Enemy
{
  Spider() : super()
  {
      maxSpeed = 400.0;
      name = "Spider" + genUID();
      scale /= 2.0;
  }
}