part of australiasim;

class Prop extends Actor 
{
    @override
    void initialize(World world) 
    {
        super.initialize(world);
        this.name = "Prop" + world.genUID();
    }

    @override
    void beginPlay() 
    {
        super.beginPlay();
        this.colliderBoxExtent = this.scale.clone();
    }
}
