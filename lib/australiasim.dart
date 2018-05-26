library australiasim;

import "dart:html";
import "dart:async";
import "dart:math";
import "package:vector_math/vector_math.dart";
import "package:rxdart/rxdart.dart";

part "./australiasim/actor.dart";
part "./australiasim/gamecontroller.dart";
part "./australiasim/gamemode.dart";
part "./australiasim/gameview.dart";
part "./australiasim/world.dart";
part "./australiasim/pawn.dart";
part "./australiasim/prop.dart";
part "./australiasim/character.dart";
part "./australiasim/vector.dart";

const cellsize = 50;

final t = new GameController();
