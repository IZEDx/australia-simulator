part of australiasim;

/// A small bed
class SmallBed extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Small Bed" + world.genUID();
        this.scale = new Vector2(144.0, 243.0);
        this.rotation = new Vector2(0.0, 1.0);
    }
}
