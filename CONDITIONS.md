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

Dies hat außerdem zur Folge, dass die HTML Elemente nicht immer neu-erstellt werden müssen, sondern lediglich - sobald benötigt - manipuliert. Mithilfe von ```will-update: transform``` lassen sich Performance-relevante Elemente (z.B. Spieler und Gegner) außerdem in ihrer Position verändern, ohne einen Re-Render der HTML Engine zu erzwingen. Das Positionsupdate wird hierbei von der GPU übernommen.

## __AF-4:__ Target device: Smartphone

## __AF-5:__ Mobile First Prinzip

## __AF-6:__ Das Spiel muss schnell und intuitiv erfassbar sein und Spielfreude erzeugen

## __AF-7:__ Das Spiel muss ein Levelkonzept vorsehen

## __AF-8:__ Ggf. erforderliche Speicherkonzepte sind Client-seitig zu realisieren

## __AF-9:__ Dokumentation