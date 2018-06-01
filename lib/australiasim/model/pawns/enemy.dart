part of australiasim;

class Enemy extends Pawn
{
  Enemy() : super()
  {
    this.name = "Enemy" + genUID();
  }

  bool _isEmbattled() => world.gamemode.player != null && world.gamemode.player.location.distanceTo(this.location) < 200.0;

  void tick(double deltaTime)
  {
    if(_isEmbattled())
    {
      final playerPos = world.gamemode.player.location;
      final escapeVector = (worldSize / 2.0 - this.location).normalized();
      this.rotation = this.location + escapeVector * 100.0 - playerPos;

      requestWalkToLocation(this.location + this.rotation * 200.0);
    }

    super.tick(deltaTime);
  }
}