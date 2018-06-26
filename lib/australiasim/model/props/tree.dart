part of australiasim;

/// Class for a tree
class Tree extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Tree" + world.genUID();
    }
}
