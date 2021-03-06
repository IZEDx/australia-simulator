part of australiasim;

/// DOMView is a helper class for common operations on the DOM
class DOMView
{

    /// [Element] cache so Elements don't have to be queried multiple times
    Map<String, Element> _cache = new Map();

    /// Clears the Cache
    clearCache() => _cache.clear();

    /// Creates a new div with the given [id] on the [host] and returns the [Element]
    Element create(Element host, String id)
    {
        host.appendHtml("<div id='${id}'>");
        return get(id);
    }

    /// Removes an Element from the DOM by the [id]
    void remove(String id)
    {
        var el = get(id);
        if (el != null) el.remove();
    }

    /// Gets an [Element] from the DOM by the [id] or from the cache if available
    Element get(String id)
    {
        var el = _cache[id];
        if ( el == null ) el = querySelector("#${id}");
        return el;
    }

    /// Returns a [Future] that resolves before the next animation frame with the given runtime
    Future<num> nextFrame() async
    {
        final completer = new Completer<num>();
        window.requestAnimationFrame( (time) => completer.complete(time) );
        return completer.future;
    }

    /// Returns a [Future] that resolves after [Duration] 
    /// and optionally calls [before] and [after] the Duration.
    Future timeout(Duration duration, {Function before, Function after}) async
    {
        if ( before != null ) before();
        await wait(duration);
        if ( after  != null ) after();
    }

    /// Returns a [Future] that resolves after [duration]
    Future wait(Duration duration) async
    {
        return new Future.delayed(duration);
    }

    /// Updates the transform on [el] using optional Vectors.
    /// This function prevents seperate manual transform updates,
    /// that either update rotatiom, position or scale to override each other.
    void transform(Element el, { Vector2 position, Vector2 rotation, Vector2 scale })
    {
        var transformation = "";

        if (position != null)
        {
            el.attributes["position"] = "translate(${position.x.round()}px, ${position.y.round()}px)";
        }
        
        if (rotation != null)
        {
            final radians = atan2(rotation.x, rotation.y);
            el.attributes["rotation"] = "rotate(${radians}rad)";
        }

        if (scale != null)
        {
            el.attributes["scale"] = "scale(${scale.x}, ${scale.y})";
        }

        if ( el.attributes.containsKey("position")  ) transformation += el.attributes["position"] + " ";
        if ( el.attributes.containsKey("rotation")  ) transformation += el.attributes["rotation"] + " ";
        if ( el.attributes.containsKey("scale")  )    transformation += el.attributes["scale"] + " ";

        el.style.transform = transformation;
    }

    // Moves [el] to [position] using css transform
    void move(   Element el, Vector2 position) => transform(el, position:  position);

    // Rotates [el] to [rotation] using css transform
    void rotate( Element el, Vector2 rotation) => transform(el, rotation:  rotation);

    // Scales [el] to [scale] using css transform
    void scale( Element el, Vector2 scale) => transform(el, scale:  scale);
    
    /// Shows [el] by removing the "hidden" class from it
    void show( Element el ) => el.classes.remove( "hidden" );

    /// Hides [el] by adding the "hidden" class to it
    void hide( Element el ) => el.classes.add   ( "hidden" );

    /// Activates [el] by adding the "active" class to it
    void activate( Element el ) => el.classes.add( "active" );

    /// Deactivates [el] by removing the "active" class from it
    void deactivate( Element el ) => el.classes.remove( "active" );

    // Sets the width and height of [el] to [size]
    void setDimensions(Element el, Vector2 size)
    {
        el.style.width  = size.x.toString() + "px";
        el.style.height = size.y.toString() + "px";
    }

}
