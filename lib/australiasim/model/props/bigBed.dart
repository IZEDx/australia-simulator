part of australiasim;

class BigBed extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Tree" + world.genUID();
        this.scale = new Vector2(192.0, 240.0);
    }
}
