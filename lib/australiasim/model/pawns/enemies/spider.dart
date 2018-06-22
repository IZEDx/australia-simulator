part of australiasim;

class Spider extends Enemy
{
    @override
    void initialize(World world) 
    {
        super.initialize(world);
        name     = "Spider" + world.genUID();
        maxSpeed = 400.0;
    }

    @override
    void beginPlay()
    {
        super.beginPlay();
        scale   /= 1.5;
    }
}