part of australiasim;

class Prop extends Actor
{
  Prop() : super()
  {
      this.name = "Prop" + genUID();
  }
  
  void beginPlay()
  {
    this.colliderBoxExtent = this.scale / 2.0;
  }
}