part of australiasim;

class Box extends Prop
{

  Box() : super()
  {
      this.name = "Box" + genUID();
      this._rotation = new Vector2(0.0, -1.0); // North
  }
}