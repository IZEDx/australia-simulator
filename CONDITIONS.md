# Anforderungen

## __AF-1:__ Single-Player-Game als Single-Page-App.
_Australia Simulator_ wird als Progressive Web App mit einem Serviceworker konzipiert, dies stellt weitere technische Anforderungen an das Projekt mit dem resultat, dass die fertige PWA Responsive als Website oder Mobile App funktioniert. 

Außerdem wird durch die PWA ein Service Worker benötigt, der relevante Dateien für das Spiel aktiv cachen kann, sodass das Spiel dann auch im Offline-Modus funktioniert.

## __AF-2:__ Balance zwischen technischer Komplexität und Spielkonzept.

In _Australia Simulator_ muss der Spieler versuchen verschiedene wilde und gefährliche Tiere aus seinem Haus zu verscheuchen, ohne dabei die Tiere zu berühren. 

Die Tiere/Gegner müssen also entsprechend vor dem Spieler abhauen ("es hat mehr Angst als du") und gegebenfalls im Haus idlen oder nach Essen suchen.

Die Logik für die Gegner erhöht die technische Komplexität enorm, deswegen steht noch offen, wie ausführlich diese implementiert werden kann.