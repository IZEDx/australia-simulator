part of australiasim;

/// A big red spider (ferrari spider)
class BigRedSpider extends BigSpider
{
    @override
    void initialize(World world) 
    {
        super.initialize(world);
        name      = "BigRedSpider" + world.genUID();
        maxSpeed *= 1.25;
    }

    @override
    void beginPlay()
    {
        super.beginPlay();
        scale    *= 1.25;
    }
}