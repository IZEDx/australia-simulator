part of australiasim;

class BigBed extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "BigBed" + world.genUID();
        this.scale = new Vector2(192.0, 240.0);
        this.rotation = new Vector2(0.0, 1.0);
    }
}
