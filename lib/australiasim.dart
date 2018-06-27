library australiasim;

import "dart:html";
import "dart:async";
import "dart:math";
import "dart:convert";
import "package:vector_math/vector_math.dart";
import "package:rxdart/rxdart.dart";

// Controller
part "./australiasim/gamecontroller.dart";
part "./australiasim/level.dart";

// View
part "./australiasim/view/domview.dart";
part "./australiasim/view/gameview.dart";

// Model
part "./australiasim/model/gamemode.dart";
part "./australiasim/model/actor.dart";
part "./australiasim/model/world.dart";
part "./australiasim/model/pawn.dart";
part "./australiasim/model/prop.dart";

part "./australiasim/model/props/smallBed.dart";
part "./australiasim/model/props/bigBed.dart";
part "./australiasim/model/props/table.dart";
part "./australiasim/model/props/door.dart";
part "./australiasim/model/props/board.dart";
part "./australiasim/model/props/box.dart";
part "./australiasim/model/props/tree.dart";
part "./australiasim/model/props/shrub.dart";
part "./australiasim/model/props/chair.dart";
part "./australiasim/model/props/lamp.dart";
part "./australiasim/model/props/flower.dart";

part "./australiasim/model/pawns/character.dart";
part "./australiasim/model/pawns/enemy.dart";

part "./australiasim/model/pawns/enemies/spider.dart";
part "./australiasim/model/pawns/enemies/bigspider.dart";
part "./australiasim/model/pawns/enemies/bigredspider.dart";

/// Maincontroller which is running the game
final GameController mainController = new GameController();
