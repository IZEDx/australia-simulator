part of australiasim;

/// Class for a chair
class Chair extends Box
{
    @override
    initialize(World world)
    {
        super.initialize(world);
        this.name = "Chair" + world.genUID();
        this.rotation = new Vector2(0.0, 1.0);
    }

    @override
    void set rotation(Vector2 rotation)
    {
        super.rotation = rotation;
        
        // Different chair rotations -> different collision extents
        if(rotation.y.abs() > 0.5)
        {
            if(rotation.y < 0.0)
                this.scale = new Vector2(78.0, 96.0);
            else
                this.scale = new Vector2(66.0, 72.0);
        }
        else 
        {
            this.scale = new Vector2(66.0, 96.0);
        }
    }
}