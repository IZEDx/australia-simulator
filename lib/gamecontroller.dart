part of australiasim;

class GameController {
  GameMode mode;
  GameView view;

  GameController() {
    mode = new GameMode();
    view = new GameView(mode);
  }
}