part of australiasim;

class SmallBed extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Small Bed" + world.genUID();
        this.scale = new Vector2(144.0, 243.0);
    }
}
