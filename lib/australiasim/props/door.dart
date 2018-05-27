

part of australiasim;

class Door extends Prop
{

  Door() : super()
  {
      this.name = "Door" + genUID();
      this._rotation = new Vector2(0.0, -1.0); // North
  }
}
