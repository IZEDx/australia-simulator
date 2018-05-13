# Australia Simulator!

### Get the F*ck out of my House!

[Anforderungen](./CONDITIONS.md) | [Spiel öffnen](https://izedx.github.io/australia-simulator/build/web)

## 1 - Einleitung

Willkommen in Australien.

## 2 - Anforderungen und Konzept

### 2.1 - Anforderungen

Die gegebenen Anforderungen an das Konzept und der technischen Umsetzung finden sich in den [CONDITIONS](./CONDITIONS.md).

### 2.2 - Spielkonzept: Australia Simulator

Das Spiel Australia Simulator ist ein top-down Arcade Game, bei welchem der Spieler versuchen muss, die wilden Tiere aus seinem Haus zu verscheuchen, bevor diese sich einnisten und die Zeit abläuft oder der Spieler von denen verletzt wird. 

Dabei sieht der Spieler seinen Character in der Mitte des Bildschirms und kann sich in einem 360° Radius bewegen, abhängig davon, wohin der Spieler mit dem Finger zeigt. 

Im Haus laufen abhängig vom derzeitigen Level unterschiedlich viele und schnelle Gegner rum, welche - wenn der Spieler zu nah kommt - versuchen werden vor diesem abzuhauen. Das Ziel ist es, alle dieser Gegner aus dem Haus zu vertreiben, bevor sie ihren "Coziness"-Balken auffüllen (sich anfangen heimisch zu fühlen). Hat der Spieler alle Gegner vetrieben, so hat er das Level bestanden und das nächste Level kann geladen werden.

## 3 - Architektur

Australia Simulator folgt der MVC-Architektur, bei der wir Interaktionen und Ausgaben/View vom Model trennen. Entscheidende Rolle spielt hierbei der GameController, da er View und Model erstellt und auf User-Interaktionen und Timern horcht und diese an das Model weiterleitet.

Der GameView ist für DOM-Manipulation vorgesehen, deswegen erstellt er das Spielfeld und horcht auf Model-Events um den DOM-Tree up-to-date zu halten.

Das Model des Spiels besteht aus mehreren Schichten an Klassen und orientiert sich an bekannten Spiele-Engines wie z.B. der Unreal Engine, allerdings sehr stark auf die Bedürfnisse für dieses Projekt zugeschnitten.

### 3.1 - Model

### 3.2 - View

### 3.3 - Controller