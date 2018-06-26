part of australiasim;

/// CLass for a board
class Board extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Board" + world.genUID();
        this.scale = new Vector2(96.0, 207.0);
        this.rotation = new Vector2(0.0, 1.0);
    }
}