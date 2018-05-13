
# Australia Simulator!
### Get the F*ck out of my House!

![Game](https://files.ized.io/qrcode.png)

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

![UML-Diagramm](https://files.ized.io/0155.png)

### 3.1 - Model

Das Model umfasst das GameMode Entity, einem World Entity sowie Objekten, welche sich in einem Level befinden und von einer Basisklasse (Actor) erben, welche die grundlegenden Informationen über ein Objekt enthält, um sie in einem Level positionieren zu können.

So wird zu Beginn eines Spieles die Welt von dem Gamemode aufgebaut (Architektur / Props, Gegner, Player spawnen). 
Zu jeder Zeit kommuniziert der GameController nur mit dem GameMode, welches das Spiel verwaltet und die Interaktionen der Nutzer an seine Spielfigur weiterleitet.

Während das Spiel läuft werden alle beweglichen Objekte (Spielfiguren) "getickt" (hot loop) um die nötigen Berechnungen zu machen, die für das Spiel benötigt werden (positionsupdate, collision, ...).

Zu einem Levelwechsel wird zuerst das aktuelle Level gecleared und dann durch eine neue World ersetzt.


### 3.2 - View

### 3.3 - Controller
