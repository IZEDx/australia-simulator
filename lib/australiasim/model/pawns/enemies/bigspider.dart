part of australiasim;

class BigSpider extends Spider
{
  BigSpider() : super()
  {
      maxSpeed = 600.0;
      name = "BigSpider" + genUID();
      scale *= 1.5;
  }
}