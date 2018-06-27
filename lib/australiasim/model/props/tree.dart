part of australiasim;

/// A tree
class Tree extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Tree" + world.genUID();
    }
}
