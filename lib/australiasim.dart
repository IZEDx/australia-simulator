library australiasim;

import "dart:html";
import "dart:async";
import "dart:math";
import "package:vector_math/vector_math.dart";
import "package:rxdart/rxdart.dart";

part "./australiasim/gamemode.dart";
part "./australiasim/actor.dart";
part "./australiasim/world.dart";
part "./australiasim/pawn.dart";
part "./australiasim/prop.dart";

part "./australiasim/domview.dart";
part "./australiasim/gameview.dart";

part "./australiasim/gamecontroller.dart";

part "./australiasim/props/door.dart";
part "./australiasim/props/box.dart";

part "./australiasim/pawns/character.dart";
part "./australiasim/pawns/enemy.dart";

part "./australiasim/pawns/enemies/spider.dart";

final t = new GameController();
