part of australiasim;

/// A shrub
class Shrub extends Tree
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Shrub" + world.genUID();
    }
}
