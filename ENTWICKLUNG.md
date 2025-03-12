# Entwicklerdokumentation Diagnose-Tool

## Inhaltsverzeichnis
1. [Projektstruktur](#projektstruktur)
2. [Architektur](#architektur)
3. [Module und Funktionen](#module-und-funktionen)
4. [AutoIt-Besonderheiten](#autoit-besonderheiten)
5. [Entwicklungsrichtlinien](#entwicklungsrichtlinien)
6. [Bekannte Probleme und Lösungen](#bekannte-probleme-und-lösungen)
7. [Entwicklungsaufgaben](#entwicklungsaufgaben)
8. [Versionsverwaltung](#versionsverwaltung)

## Projektstruktur

```
diagnose-tool/
│
├── src/                      # Quellcode
│   ├── 7za.exe               # 7-Zip Kommandozeilenprogramm
│   ├── 7za.dll               # 7-Zip Bibliothek
│   ├── main.au3              # Hauptanwendung
│   ├── settings.ini          # Einstellungsdatei
│   ├── diagnose.log          # Allgemeines Log
│   ├── error.log             # Fehlerlog
│   └── lib/                  # Bibliotheken und Module
│       ├── advanced_filter.au3    # Erweiterte Filterfunktionen
│       ├── db_functions.au3       # Datenbankfunktionen
│       ├── db_viewer.au3          # Datenbankansicht
│       ├── decrypt_functions.au3  # Entschlüsselungsfunktionen
│       ├── error_handler.au3      # Fehlerbehandlung
│       ├── export_functions.au3   # Exportfunktionen
│       ├── filter_functions.au3   # Filterfunktionen
│       ├── globals.au3            # Globale Variablen
│       ├── gui_functions.au3      # GUI-Funktionen
│       ├── listview_copy.au3      # Kopierfunktionen für ListView
│       ├── list_sorting.au3       # Sortierfunktionen
│       ├── logging.au3            # Logging-System
│       ├── missing_functions.au3  # Hilfsfunktionen
│       ├── settings_manager.au3   # Einstellungsverwaltung
│       ├── sqlite3.dll            # SQLite-Bibliothek
│       ├── sqlite_handler.au3     # SQLite-Funktionen
│       ├── system_functions.au3   # Systemfunktionen
│       ├── WinHttp.au3            # HTTP-Funktionen
│       ├── WinHttpConstants.au3   # HTTP-Konstanten
│       ├── zip_functions.au3      # ZIP-Funktionen
│       └── zip_handler.au3        # ZIP-Verarbeitung
│
├── doc/                      # Dokumentation
├── temp/                     # Temporäre Dateien (werden automatisch erstellt)
└── README.md                 # Projekt-Readme
```

## Architektur

Das Diagnose-Tool basiert auf einer modularen Architektur mit klarer Trennung der Verantwortlichkeiten. Die Hauptkomponenten sind:

1. **Benutzeroberfläche (GUI)**: Darstellung der Daten und Interaktion mit dem Benutzer
2. **Datenbankmodul**: Verbindung zur SQLite-Datenbank und Datenabfragen
3. **ZIP-Verarbeitung**: Entpacken von ZIP-Dateien mit 7-Zip
4. **Systemfunktionen**: Initialisierung, Konfiguration und Aufräumen
5. **Hilfsfunktionen**: Logging, Fehlerbehandlung, etc.

### Datenfluss

1. Der Benutzer öffnet eine ZIP-Datei
2. Die ZIP-Datei wird mit 7-Zip entpackt
3. Enthaltene SQLite-Datenbanken werden identifiziert
4. Tabellen der Datenbank werden geladen und im Dropdown-Menü angezeigt
5. Bei Tabellenauswahl werden die Daten in der ListView angezeigt
6. Der Benutzer kann Daten filtern, exportieren oder kopieren

## Module und Funktionen

### Hauptmodul (main.au3)

Das Hauptmodul enthält die GUI-Definition und das Hauptprogramm mit der Ereignisschleife.

Wichtige Funktionen:
- `_CreateMainGUI()`: Erstellt die Benutzeroberfläche
- `WM_NOTIFY()`: Behandelt Windows-Benachrichtigungen
- `Main()`: Hauptfunktion mit der Ereignisschleife

### Systemfunktionen (system_functions.au3)

Dieses Modul enthält grundlegende Systemfunktionen für die Initialisierung und Aufräumarbeiten.

Wichtige Funktionen:
- `_InitSystem()`: Initialisiert das System (SQLite, Logging, Temporäre Verzeichnisse)
- `_Cleanup()`: Bereinigt Ressourcen beim Programmende

### Datenbankfunktionen (db_functions.au3)

Enthält Funktionen für den Datenbankzugriff und die Datenvisualisierung.

Wichtige Funktionen:
- `_DB_Connect()`: Verbindung zur Datenbank herstellen
- `_LoadDatabaseData()`: Daten aus der aktuellen Tabelle laden

### ZIP-Verarbeitung (zip_handler.au3)

Modul zur Verarbeitung von ZIP-Dateien mit 7-Zip.

Wichtige Funktionen:
- `_ProcessZipFile()`: Verarbeitet eine ZIP-Datei (Entpacken, Datenbank öffnen)

### Fehlermanagement (error_handler.au3)

Enthält Funktionen zur Fehlerbehandlung und -protokollierung.

Wichtige Funktionen:
- `_ErrorHandlerInit()`: Initialisiert den Fehlerhandler
- `_ErrorHandler()`: Hauptfehlerbehandlungsfunktion
- `_ShowError()`: Zeigt einen Fehlerdialog an

### Logging (logging.au3)

Umfassendes Logging-System für Fehler- und Informationsprotokolle.

Wichtige Funktionen:
- `_LogInit()`: Initialisiert das Logging-System
- `_LogInfo()`: Protokolliert eine Informationsmeldung
- `_LogError()`: Protokolliert einen Fehler
- `_LogDebug()`: Protokolliert eine Debug-Meldung

## AutoIt-Besonderheiten

### GUI-Management

AutoIt verwendet ein ereignisbasiertes GUI-System:

```autoit
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $idButton
            ; Button-Aktion ausführen
    EndSwitch
WEnd
```

### ListView-Handhabung

Die ListView ist ein komplexes Control, das spezielle Behandlung erfordert:

```autoit
; Spalte hinzufügen
_GUICtrlListView_InsertColumn($idListView, 0, "Spaltenname", 100)

; Zeile hinzufügen
_GUICtrlListView_AddItem($idListView, "Zelle 1")

; Unterelement hinzufügen
_GUICtrlListView_AddSubItem($idListView, 0, "Unterzelle", 1)
```

### Error Handling

AutoIt verwendet globale @error und @extended Variablen für Fehlerbehandlung:

```autoit
Local $iResult = _SomeFunctionCall()
If @error Then
    ; Fehlerbehandlung
    _LogError("Fehler in _SomeFunctionCall: " & @error)
EndIf
```

## Entwicklungsrichtlinien

### Codeformatierung

- Einrückung: Verwenden Sie Tabs oder 4 Leerzeichen
- Kommentare: Detaillierte Kommentare für alle Funktionen
- Namenskonventionen:
  - Globale Variablen: `$g_sVariableName`
  - Lokale Variablen: `$sVariableName`
  - Funktionen: `_FunctionName()`
  - Control-IDs: `$idControlName`
  - Handle-Variablen: `$hHandleName`

### Modularisierung

- Jede Datei sollte eine klare Verantwortlichkeit haben
- Verwenden Sie `#include-once`, um Mehrfacheinbindungen zu vermeiden
- Globale Variablen in entsprechenden Modulen definieren
- Funktionen mit klarer Dokumentation versehen

### Fehlerbehandlung

- Jede Funktion sollte Fehler ordnungsgemäß behandeln
- Verwenden Sie `Return SetError()` für Fehlerrückgabe
- Protokollieren Sie alle Fehler mit `_LogError()`
- Benutzerfreundliche Fehlermeldungen anzeigen

### Performance-Optimierung

- Große Datenmengen in Blöcken verarbeiten
- ListView-Updates mit `_GUICtrlListView_BeginUpdate()` und `_GUICtrlListView_EndUpdate()` umschließen
- Vermeiden Sie unnötige GUI-Updates während Datenoperationen
- Temporäre Dateien regelmäßig bereinigen

## Bekannte Probleme und Lösungen

### Problem: Langsames Laden großer Tabellen

**Symptom**: Bei Tabellen mit vielen Zeilen dauert das Laden sehr lange.

**Lösung**:
- Implementieren Sie ein Paging-System für große Datensätze
- Laden Sie nur die ersten N Zeilen initial und weitere bei Bedarf
- Optimieren Sie die SQL-Abfragen

```autoit
; Beispiel für optimiertes Laden
$sQuery = "SELECT * FROM " & $g_sCurrentTable & " LIMIT " & $iOffset & ", " & $iChunkSize & ";"
```

### Problem: Speicherlecks bei langer Laufzeit

**Symptom**: Bei längerer Laufzeit steigt der Speicherverbrauch kontinuierlich.

**Lösung**:
- Stellen Sie sicher, dass alle Ressourcen ordnungsgemäß freigegeben werden
- Verwenden Sie lokale Variablen statt globaler wo möglich
- Implementieren Sie regelmäßige Speicherbereinigung

### Problem: Fehler beim Entpacken großer ZIP-Dateien

**Symptom**: Bei sehr großen ZIP-Dateien schlägt die Entpackung manchmal fehl.

**Lösung**:
- Implementieren Sie Timeout-Erhöhung für große Dateien
- Fortschrittsanzeige für den Entpackvorgang
- Chunked Processing für große Archive

## Entwicklungsaufgaben

### Kurzfristige Aufgaben

1. **Filterfunktionen verbessern**
   - Mehrfachfilter implementieren
   - Filterdialog benutzerfreundlicher gestalten
   - Filter speichern und wiederverwenden

2. **Exportfunktionen erweitern**
   - Excel-Export mit Formatierung
   - PDF-Export implementieren
   - Exportvorlagen unterstützen

3. **Benutzeroberfläche optimieren**
   - Verbesserte Statusanzeigen
   - Kontextmenüs erweitern
   - Tastaturunterstützung verbessern

### Mittelfristige Aufgaben

1. **Performance-Optimierung**
   - Caching-Mechanismen für häufig genutzte Daten
   - Asynchrones Laden von Daten
   - SQL-Query-Optimierung

2. **Erweitertes Logging**
   - Detailliertere Protokollierung
   - Log-Viewer implementieren
   - Remote-Logging-Optionen

3. **Sicherheitsfunktionen**
   - Verbesserte Passwortverwaltung
   - Datenverschlüsselung für sensible Informationen
   - Berechtigungssystem für verschiedene Benutzer

### Langfristige Aufgaben

1. **Plugin-System**
   - Erweiterbare Architektur für Plugins
   - API für Drittanbieter-Erweiterungen
   - Plugin-Manager-Interface

2. **Netzwerkunterstützung**
   - Fernzugriff auf Datenbanken
   - Synchronisationsfunktionen
   - Cloud-Integration

## Versionsverwaltung

### Git-Workflow

1. **Entwicklungszweige**
   - `main`: Stabile Hauptversion
   - `develop`: Aktuelle Entwicklungsversion
   - Feature-Branches: `feature/name-der-funktion`
   - Bugfix-Branches: `bugfix/name-des-bugs`

2. **Commits**
   - Aussagekräftige Commit-Nachrichten
   - Änderungen in logische Commits aufteilen
   - Referenzieren von Issues in Commit-Nachrichten

3. **Releases**
   - Semantische Versionierung (major.minor.patch)
   - Release-Tags für jede Version
   - Changelogs für jede Version

### Release-Prozess

1. Mergen des `develop`-Zweigs in `main`
2. Erhöhen der Versionsnummer
3. Erstellen eines Release-Tags
4. Aktualisieren der Dokumentation
5. Erstellen der Release-Binaries
6. Veröffentlichen auf GitHub

## Tests und Qualitätssicherung

### Manuelle Tests

- GUI-Funktionalität
- Datenbank-Integration
- ZIP-Verarbeitung
- Fehlerbehandlung

### Automatisierte Tests

- Unit-Tests für Kernmodule
- Integrationstests für Systemkomponenten
- Lasttest für Performance-Schwachstellen

### Kontinuierliche Integration

- Automatische Builds bei jedem Commit
- Test-Durchführung
- Code-Qualitätsmetriken
- Dokumentationsgenerierung

## Fazit und Ausblick

Das Diagnose-Tool ist eine leistungsfähige Anwendung zur Analyse von SQLite-Datenbanken in ZIP-Archiven. Die modulare Architektur ermöglicht eine einfache Erweiterung und Wartung. Mit den geplanten Entwicklungsaufgaben wird das Tool kontinuierlich verbessert, um den Bedürfnissen der Benutzer gerecht zu werden.

Die größten Herausforderungen liegen in der Performance-Optimierung für große Datensätze und der Implementierung erweiterter Filterfunktionen. Durch konsequente Anwendung der Entwicklungsrichtlinien und sorgfältige Tests wird die Qualität und Zuverlässigkeit des Tools auch in Zukunft gewährleistet.