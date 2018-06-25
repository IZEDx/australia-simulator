part of australiasim;

class Flower extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Flower" + world.genUID();
        this.scale = new Vector2(90.0, 156.0);
        this.rotation = new Vector2(0.0, 1.0);
    }
}