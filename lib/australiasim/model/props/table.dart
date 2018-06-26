part of australiasim;

/// Class for a table
class Table extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Table" + world.genUID();
        this.scale = new Vector2(144.0, 240.0);
        this.rotation = new Vector2(0.0, 1.0);
    }
}