part of australiasim;

class DOMView {

  Map<String, Element> _cache = new Map();

  Future wait(Duration duration) async {
    return new Future.delayed(duration);
  }

  Future<num> nextFrame() async {
    final completer = new Completer<num>();
    window.requestAnimationFrame((time) => completer.complete(time));
    return completer.future;
  }

  Future timeout(Duration duration, {Function before, Function after}) async {
    if ( before != null ) before();
    await wait(duration);
    if ( after  != null ) after();
  }

  Element create(Element host, String id) {
    host.appendHtml("<div id='${id}'>");
    return get(id);
  }

  void remove(String id) {
    var el = get(id);
    if (el != null) el.remove();
  }

  Element get(String id) {
    var el = _cache[id];
    if ( el == null ) el = querySelector("#${id}");
    return el;
  }

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

  void move(   Element el, Vector2 position) => transform(el, position:  position);
  void rotate( Element el, Vector2 rotation) => transform(el, rotation:  rotation);
  
  void show( Element el ) => el.classes.remove( "hidden" );
  void hide( Element el ) => el.classes.add   ( "hidden" );

  void activate( Element el ) => el.classes.add( "active" );
  void deactivate( Element el ) => el.classes.remove( "active" );

  void setDimensions(Element el, Vector2 size) {
    el.style.width  = size.x.toString() + "px";
    el.style.height = size.y.toString() + "px";
  }

}
