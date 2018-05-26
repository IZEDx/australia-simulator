
# Australia Simulator!
### Get the F*ck out of my House!

![Game](./qrcode.png)

[Anforderungen](./REQUIREMENTS.md) | [Spiel öffnen](https://izedx.github.io/australia-simulator/build/web)

## 1 - Einleitung

Willkommen in Australien.

## 2 - Anforderungen und Konzept

### 2.1 - Anforderungen

Die gegebenen Anforderungen an das Konzept und der technischen Umsetzung finden sich in den [REQUIREMENTS](./REQUIREMENTS.md).

### 2.2 - Spielkonzept: Australia Simulator

Das Spiel Australia Simulator ist ein top-down Arcade Game, bei welchem der Spieler versuchen muss, die wilden Tiere aus seinem Haus zu verscheuchen, bevor diese sich einnisten und die Zeit abläuft oder der Spieler von denen verletzt wird. 

Dabei sieht der Spieler seinen Character in der Mitte des Bildschirms und kann sich in einem 360° Radius bewegen, abhängig davon, wohin der Spieler mit dem Finger zeigt. 

Im Haus laufen abhängig vom derzeitigen Level unterschiedlich viele und schnelle Gegner rum, welche - wenn der Spieler zu nah kommt - versuchen werden vor diesem abzuhauen. Das Ziel ist es, alle dieser Gegner aus dem Haus zu vertreiben, bevor sie ihren "Coziness"-Balken auffüllen (sich anfangen heimisch zu fühlen). Hat der Spieler alle Gegner vetrieben, so hat er das Level bestanden und das nächste Level kann geladen werden.

## 3 - Architektur

Australia Simulator folgt der MVC-Architektur, bei der wir Interaktionen und Ausgaben/View vom Model trennen. Entscheidende Rolle spielt hierbei der GameController, da er View und Model erstellt und auf User-Interaktionen und Timern horcht und diese an das Model weiterleitet.

Der GameView ist für DOM-Manipulation vorgesehen, deswegen erstellt er das Spielfeld und horcht auf Model-Events um den DOM-Tree up-to-date zu halten.

Das Model des Spiels besteht aus mehreren Schichten an Klassen und orientiert sich an bekannten Spiele-Engines wie z.B. der Unreal Engine, allerdings sehr stark auf die Bedürfnisse für dieses Projekt zugeschnitten.

![UML-Diagramm](https://files.ized.io/0157.png)

### 3.1 - Model

Das Model umfasst das GameMode Entity, eine World Entity, sowie Objekte, welche sich in einem Level befinden und von einer Basisklasse (Actor) erben. Actor enthält die grundlegenden Informationen über ein Spielobjekt (Spielfigur, Teile der Welt, ...), um es in einem Level zu positionieren, sowie Kollision abfragen zu können.

So wird zu Beginn eines Spieles die Welt von dem Gamemode aufgebaut (Architektur / Props, Gegner, Player spawnen). 
Zu jeder Zeit kommuniziert der GameController nur mit dem GameMode, welches das Spiel verwaltet und die Interaktionen der Nutzer an seine Spielfigur weiterleitet.

Während das Spiel läuft werden alle beweglichen Objekte (Spielfiguren) "getickt" (hot loop) um die nötigen Berechnungen zu machen, die für das Spiel benötigt werden (positionsupdate, collision, ...).

Zu einem Levelwechsel wird zuerst das aktuelle Level gecleared und dann durch eine neue World ersetzt.

### 3.2 - View

Der View wird zur Darstellung des Models verwendet und vom Controller initiert. Er erstellt die DOM-Elemente die für das Model benötigt werden und reagiert auf Updates des Models zur Aktualisierung.

Wir verwenden im View ein DOM-Element für die 2D Welt - dem Haus, in dem gespielt wird - in welchem wir dann die Actor frei bewegen können. 

Im View soll der Character immer in der Mitte des Bildschirms dargestellt werden, hierfür wird der Character im View fest in der Mitte des Bildschirms erstellt und wenn er sich bewegt wird die Welt im Hintergrund bewegt, statt dem Character selbst.

### 3.3 - Controller

Der Controller ist das zentrale Nervensystem des Spiels, er erstellt das Model und den View und verbindet diese miteinander. Er horcht auf die Eingaben des Spielers und updated das Model entsprechend.

#### 3.3.1 Input

Im Controller horchen wir auf den Input und leiten diesen dann an das Model weiter, die entsprechende Eingabeposition die weitergeleitet wird ist relativ zur Position des Characters, also relativ zur Mitte des Bildschirms.

```dart
  onInput(onInput(Vector2 worldPos), onInputStop()) {
    relay(TouchEvent e) {
      e.preventDefault();
      onInput(new Vector2(
        e.touches[0].page.x - view.world.offset.left, 
        e.touches[0].page.y - view.world.offset.top
      ));
    }

    view.input.onTouchStart.listen((e) {
      relay(e);
    });

    view.input.onTouchMove.listen((e) {
      relay(e);
    });

    view.input.onTouchEnd.listen((e) {
      e.preventDefault();
      onInputStop();
    });
  }
```

Events vom Model an das View muss der Controller nicht selbst weiterleiten, da der View direkt auf den Events des Models horchen kann und sich so up-to-date halten kann. Allerdings ist der Controller dafür verantwortlich weiteren User-Input zu verarbeiten, wie z.B. das Starten eines Spiels und das entsprechende Setup des Views und Models.