part of australiasim;

class Enemy extends Pawn
{
  Enemy() : super()
  {
      this.name = "Enemy" + genUID();
  }


  bool _isEmbattled() => world.gamemode.currentPlayerCharacter != null && world.gamemode.currentPlayerCharacter.location.distanceTo(this.location) < 200.0;

  void tick(double deltaTime)
  {
    if(_isEmbattled())
    {
        this.rotation = this.location - world.gamemode.currentPlayerCharacter.location;
        requestWalkToLocation(this.location + this.rotation * 200.0);
    }

    super.tick(deltaTime);
  }
}