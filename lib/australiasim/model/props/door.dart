part of australiasim;

/// Class for the door
class Door extends Box
{
    @override
    void initialize(World world) 
    {
        super.initialize(world);
        this.name = "Door" + world.genUID();
        onCollide.listen(handleCollision);
    }

    @override
    beginPlay()
    {
        super.beginPlay();
        this.rotation = new Vector2(0.0, 1.0); // South
        this.scale = new Vector2(130.0, 30.0);
    }

    handleCollision(Actor actor) 
    {
        if (actor is Enemy) this.world.removeActor(actor);
    }
}
