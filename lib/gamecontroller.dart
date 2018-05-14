part of australiasim;

class GameController {
  GameMode mode;
  GameView view;
  Timer movementTick;

  GameController() {
    mode = new GameMode();
    view = new GameView(mode);

    var speed = 5.0;
    var pos = new Vector2(0.0,0.0);
    var target = pos;
    onInput((t) {
      target = t;
    }, () { 
      target.setZero(); 
    });

    movementTick = new Timer.periodic(new Duration(milliseconds: 10), (t) {
      pos.add(target / 800.0 * speed);
      if (pos.x < 25) pos.x = 25.0;
      if (pos.y < 25) pos.y = 25.0;
      if (pos.x > 475) pos.x = 475.0;
      if (pos.y > 475) pos.y = 475.0;
      view.move(pos);
    });
  }

  onInput(onInput(Vector2 worldPos), onInputStop()) {
    relay(TouchEvent e) {
      e.preventDefault();
      onInput(new Vector2(
        e.touches[0].page.x - view.world.offset.left, 
        e.touches[0].page.y - view.world.offset.top
      ));
    }

    view.input.onTouchStart.listen((e) {
      view.character.classes.add("active");
      relay(e);
    });

    view.input.onTouchMove.listen((e) {
      e.preventDefault();
      relay(e);
    });

    view.input.onTouchEnd.listen((e) {
      e.preventDefault();
      view.character.classes.remove("active");
      onInputStop();
    });
  }
}