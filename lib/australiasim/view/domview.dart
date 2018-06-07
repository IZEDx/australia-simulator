part of australiasim;

/**
 * DOMView Helper Class for common operations on the DOM.
 */
class DOMView {

  /**
   * Element cache so Elements don't have to be queried multiple times.
   */
  Map<String, Element> _cache = new Map();

  /**
   * Clears the Cache.
   */
  clearCache() => _cache.clear();

  /**
   * Returns a future that resolves after the given Duration.
   */
  Future wait(Duration duration) async {
    return new Future.delayed(duration);
  }

  /**
   * Returns a future that resolves before the next animation frame with the given runtime.
   */
  Future<num> nextFrame() async {
    final completer = new Completer<num>();
    window.requestAnimationFrame((time) => completer.complete(time));
    return completer.future;
  }

  /**
   * Returns a future that resolves after the given Duration 
   * and calls optional callbacks before and after the Duration.
   */
  Future timeout(Duration duration, {Function before, Function after}) async {
    if ( before != null ) before();
    await wait(duration);
    if ( after  != null ) after();
  }

  /**
   * Creates a new div with the given id on the host and returns the Element.
   */
  Element create(Element host, String id) {
    host.appendHtml("<div id='${id}'>");
    return get(id);
  }

  /**
   * Removes an Element from the DOM by the id.
   */
  void remove(String id) {
    var el = get(id);
    if (el != null) el.remove();
  }

  /**
   * Gets an Element from the DOM by the id or from the cache if available.
   */
  Element get(String id) {
    var el = _cache[id];
    if ( el == null ) el = querySelector("#${id}");
    return el;
  }

  /**
   * Updates the transform on an Element using optional Vectors.
   * This function prevents seperate manual transform updates,
   * that either update rotation or position to override each other.
   */
  void transform(Element el, { Vector2 position, Vector2 rotation }) {
    var transformation = "";

    if (position != null) {
      el.attributes["position"] = "translate(${position.x}px, ${position.y}px)";
    }
    
    if (rotation != null) {
      final degrees = atan2(rotation.x, rotation.y);
      el.attributes["rotation"] = "rotate(${-degrees}rad)";
    }

    if ( el.attributes.containsKey("position")  ) transformation += el.attributes["position"] + " ";
    if ( el.attributes.containsKey("rotation")  ) transformation += el.attributes["rotation"] + " ";

    el.style.transform = transformation;
  }

  /**
   * Moves the Element to the given position.
   */
  void move(   Element el, Vector2 position) => transform(el, position:  position);
  /**
   * Rotates the Element to the given rotation.
   */
  void rotate( Element el, Vector2 rotation) => transform(el, rotation:  rotation);
  
  /**
   * Shows the Element.
   */
  void show( Element el ) => el.classes.remove( "hidden" );
  /**
   * Hides the Element.
   */
  void hide( Element el ) => el.classes.add   ( "hidden" );

  /**
   * Activates the Element.
   */
  void activate( Element el ) => el.classes.add( "active" );
  /**
   * Deactivates the Element.
   */
  void deactivate( Element el ) => el.classes.remove( "active" );

  /**
   * Sets the width and height of the Element.
   */
  void setDimensions(Element el, Vector2 size) {
    el.style.width  = size.x.toString() + "px";
    el.style.height = size.y.toString() + "px";
  }

}
