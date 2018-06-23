part of australiasim;

class Table extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Table" + world.genUID();
        this.scale = new Vector2(144.0, 240.0);
    }
}