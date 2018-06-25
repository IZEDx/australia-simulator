part of australiasim;

class Lamp extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Lamp" + world.genUID();
        this.scale = new Vector2(72.0, 93.0);
        this.rotation = new Vector2(0.0, 1.0);
    }
}