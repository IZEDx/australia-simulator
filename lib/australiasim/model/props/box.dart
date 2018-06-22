part of australiasim;

class Box extends Prop 
{
    @override
    void initialize(World world) 
    {
        super.initialize(world);
        this.name = "Box" + world.genUID();
    }
}
