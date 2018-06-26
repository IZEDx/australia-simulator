part of australiasim;

/// A big spider
class BigSpider extends Spider
{
    @override
    void initialize(World world) 
    {
        super.initialize(world);
        name      = "BigSpider" + world.genUID();
        maxSpeed *= 1.25;
    }
    
    @override
    void beginPlay()
    {
        super.beginPlay();
        scale    *= 1.25;
    }
}