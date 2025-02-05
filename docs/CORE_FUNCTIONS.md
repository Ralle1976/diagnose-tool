# Kernfunktionen des Diagnose-Tools

## Hauptmodul (main.au3)

### Initialisierungsfunktionen
- `_InitSystem()`: Systeminitialisierung und Abhängigkeitsprüfung
- `_CreateMainGUI()`: Erstellung der Hauptbenutzeroberfläche
- `Main()`: Hauptprogrammschleife und Event-Handling

### GUI-Komponenten
1. Menüstruktur
   - Datei-Menü (ZIP öffnen, Einstellungen, Beenden)
   - Ansicht-Menü (Aktualisieren, Filter)

2. Toolbar
   - ZIP öffnen Button
   - Exportieren Button
   - Tabellen-Auswahlbox
   - Aktualisieren Button
   - Filter Button

3. Hauptansicht
   - ListView für Datenansicht
   - Fortschrittsanzeige
   - Statusleiste

### Erforderliche Include-Dateien
1. Systembibliotheken
   - GUIConstants.au3
   - Array.au3
   - File.au3
   - GuiListView.au3
   - SQLite.au3
   - WindowsConstants.au3
   - ProgressConstants.au3
   - Debug.au3

2. Projektspezifische Module
   - globals.au3
   - zip_handler.au3
   - sqlite_handler.au3
   - settings_manager.au3
   - logging.au3
   - error_handler.au3
   - db_viewer.au3
   - missing_functions.au3

## Globale Konfiguration

### Dateipfade
- settings.ini: @ScriptDir & "\settings.ini"
- SQLite DLL: @ScriptDir & "\Lib\sqlite3.dll"

### GUI-Identifier
- Hauptfenster: $g_hGUI
- ListView: $g_idListView
- Statusanzeige: $g_idStatus
- Fortschrittsbalken: $g_idProgress

### Datenbankbezogene Variablen
- Aktuelle Datenbank: $g_sCurrentDB
- Aktuelle Tabelle: $g_sCurrentTable
- Ladestatus: $g_bIsLoading

## Ereignisbehandlung

### Hauptereignisse
1. Dateioperationen
   - ZIP-Datei öffnen und verarbeiten
   - Einstellungen aufrufen
   - Programm beenden

2. Tabellenoperationen
   - Tabelle auswählen
   - Daten aktualisieren
   - Filter anwenden
   - Daten exportieren

## Abhängigkeiten und Modulfunktionen

### ZIP-Verarbeitung (zip_handler.au3)
- Entpacken von ZIP-Dateien
- Passwortvalidierung
- Temporäre Dateiverwaltung

### Datenbankoperationen (sqlite_handler.au3)
- Datenbankverbindung
- Tabellenabfragen
- Datenexport

### Einstellungsverwaltung (settings_manager.au3)
- Konfigurationsdatei lesen/schreiben
- Benutzereinstellungen speichern
- Standardwerte verwalten

### Fehlerbehandlung (error_handler.au3)
- Fehlerprotokollierung
- Benutzerbenachrichtigungen
- Fehlerwiederherstellung

Diese Dokumentation wird kontinuierlich aktualisiert, während weitere Module analysiert und optimiert werden.