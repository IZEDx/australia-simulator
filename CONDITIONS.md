# Anforderungen

## __AF-1:__ Single-Player-Game als Single-Page-App
_Australia Simulator_ wird als Progressive Web App mit einem Serviceworker konzipiert, dies stellt weitere technische Anforderungen an das Projekt mit dem resultat, dass die fertige PWA Responsive als Website oder Mobile App funktioniert.

Außerdem wird durch die PWA ein Service Worker benötigt, der relevante Dateien für das Spiel aktiv cachen kann, sodass das Spiel dann auch im Offline-Modus funktioniert.

## __AF-2:__ Balance zwischen technischer Komplexität und Spielkonzept

In _Australia Simulator_ muss der Spieler versuchen verschiedene wilde und gefährliche Tiere aus seinem Haus zu verscheuchen, ohne dabei die Tiere zu berühren. 

Die Tiere/Gegner müssen also entsprechend vor dem Spieler abhauen ("es hat mehr Angst als du") und gegebenfalls im Haus idlen oder nach Essen suchen.

Die Logik für die Gegner erhöht die technische Komplexität enorm, deswegen steht noch offen, wie ausführlich diese implementiert werden kann.

## __AF-3:__ DOM-Tree basiert

_Australia Simulator_ verwendet ein MVC Model, bei dem der DOM-Tree das View darstellt und entsprechend das Spiel rendert und Inputs akzeptiert. 

Das Spiel verwendet kein festes Grid in dem Spielobjekte von Zelle zu Zelle verschoben werden können, sondern stattdessen lose Elemente, die benötigt werden für die Spielobjekte, die dann frei in der Spielwelt bewegt und animiert werden können.

Dies hat außerdem zur Folge, dass die HTML Elemente nicht immer neu-erstellt werden müssen, sondern lediglich - sobald benötigt - manipuliert. Mithilfe von ```will-update``` lassen sich Performance-relevante Elemente (z.B. Spielwelt und Gegner) außerdem in ihrer Position verändern, ohne einen Re-Render der HTML Engine zu erzwingen. Das Positionsupdate wird hierbei von der GPU übernommen.

## __AF-4:__ Target device: Smartphone

_Australia Simulator_ wird eine responsive PWA und somit auf iOS und Android, ebenso wie in modernen HTML5 Browsern gleich funktionieren. Als device-agnostic Eingabemethode haben wir uns eine Point-and-Move Steuerung ausgedacht, bei der der Spieler mit der Maus oder per Touchscreen irgendwo auf der Karte gedrückt hält und der Character bewegt sich dorthin. Sollte der Spieler wieder los lassen oder von einem Hinderniss blockiert werden bleibt der Character stehen.

Für Desktop bietet sich allerdings darüberhinaus auch noch eine Pfeiltasten Bedienung an.


## __AF-5:__ Mobile First Prinzip

Für erweiterte UI Interaktionen, wie z.B. das wegdrücken von Modals am Anfang einer Runde bieten sich neben klassischen Eingabearten (Close-Button obere rechte Ecke vom Widget) außerdem Touchscreen Interaktionen an, wie das Wegswipen vom Widget. Da wo es angebracht ist, wollen wir die Interaktionen für Touchscreens vereinfachen.

## __AF-6:__ Das Spiel muss schnell und intuitiv erfassbar sein und Spielfreude erzeugen

Das gesamte Spiel kann man nur mit einer einzigen Eingabemethode spielen und es ist entsprechend intuitiv aufzugreifen. Wie viel Spielspaß dieses Spiel am Ende tatsächlich erzeugen kann und wielange das Spiel diesen aufrecht erhalten kann, muss in einem späteren Schritt balanciert werden.

## __AF-7:__ Das Spiel muss ein Levelkonzept vorsehen

_Australia Simulator_ wird mindestens sieben im Schwierigkeitsgrad aufsteigende Level anbieten, wobei die jeweilige Karte in der Größe festgelegt werden kann aber dann Zufallsgeneriert wird. Weitere Einstellungsmöglichkeiten für die Level beinhalten: Anzahl der Gegner, Art der Gegner, Geschwindigkeit der Gegner, Geschwindigkeit/Einschüchterung des Spielers, Anzahl des Essens/Wohlfühlsfaktor der Gegner.

## __AF-8:__ Ggf. erforderliche Speicherkonzepte sind Client-seitig zu realisieren

Es ist vorgesehen den Levelfortschritt im localStorage abzuspeichern, damit der Spieler dort weitermachen kann, wo er aufgehört hat. Weitere Daten, wie Einstellungen für das Spiel etc. können ebenfalls im localStorage abgespeichert werden.

## __AF-9:__ Dokumentation

[Die Dokumentation findet sich in der README.](./README.md)