# SQLite3 DLL Information

Diese Anwendung benötigt die Datei `sqlite3.dll`, die aus Platzgründen nicht direkt im Repository enthalten ist.

## Installation

1. Lade die aktuelle SQLite3 DLL von der offiziellen SQLite-Webseite herunter: https://www.sqlite.org/download.html
   - Wähle die Datei "Precompiled Binaries for Windows" (32-bit oder 64-bit, je nach System)

2. Kopiere die `sqlite3.dll` in das `src/lib/` Verzeichnis des Projekts

## Alternativ

Du kannst die `sqlite3.dll` auch aus einer bestehenden Installation kopieren. Die DLL sollte mit der AutoIt SQLite-UDF kompatibel sein.

Die Datei wird für den Betrieb des Diagnose-Tools zwingend benötigt und muss im `lib`-Verzeichnis liegen.
