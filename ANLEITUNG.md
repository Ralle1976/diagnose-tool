# Diagnose-Tool - Ausführliche Anleitung

## Inhaltsverzeichnis
1. [Einführung](#einführung)
2. [Installation](#installation)
3. [Konfiguration](#konfiguration)
4. [Benutzeroberfläche](#benutzeroberfläche)
5. [Arbeiten mit ZIP-Dateien](#arbeiten-mit-zip-dateien)
6. [Datenbankoperationen](#datenbankoperationen)
7. [Datenfilterung](#datenfilterung)
8. [Datenexport](#datenexport)
9. [Passwortentschlüsselung](#passwortentschlüsselung)
10. [Fehlerbehebung](#fehlerbehebung)

## Einführung
Das Diagnose-Tool ist eine spezielle Anwendung zur Analyse von verschlüsselten ZIP-Dateien, die SQLite-Datenbanken enthalten. Es bietet eine einfache grafische Benutzeroberfläche, um diese Daten zu extrahieren, anzuzeigen und zu analysieren.

## Installation

### Systemvoraussetzungen
- Windows 10 oder Windows 11
- Mindestens 4 GB RAM
- 100 MB freier Festplattenspeicher

### Installationsschritte
1. Laden Sie die neueste Version des Diagnose-Tools von GitHub herunter: [https://github.com/Ralle1976/diagnose-tool/releases](https://github.com/Ralle1976/diagnose-tool/releases)
2. Entpacken Sie die ZIP-Datei in ein Verzeichnis Ihrer Wahl
3. Führen Sie die `diagnose-tool.exe` aus oder nutzen Sie die AutoIt-Skriptdatei `main.au3`, wenn Sie AutoIt installiert haben

Für Entwickler:
- Installieren Sie AutoIt v3.3.16.1 oder höher von [https://www.autoitscript.com/site/autoit/downloads/](https://www.autoitscript.com/site/autoit/downloads/)
- Klonen Sie das Repository: `git clone https://github.com/Ralle1976/diagnose-tool.git`

## Konfiguration

### Einstellungsdatei
Die Datei `settings.ini` im Hauptverzeichnis der Anwendung enthält alle Konfigurationsoptionen:

```ini
[ZIP]
password=IHRE_PASSWORT_HIER_EINTRAGEN

[PATHS]
temp_dir=..\temp
extract_dir=..\temp\extracted

[DATABASE]
max_rows=10000
chunk_size=1000

[GUI]
show_progress=1
auto_clear_temp=1

[EXPORT]
excel_template=..\templates\default.xlsx
csv_delimiter=;
```

### Wichtige Einstellungsoptionen

| Sektion | Option | Beschreibung |
|---------|--------|--------------|
| ZIP | password | Passwort für verschlüsselte ZIP-Dateien |
| PATHS | temp_dir | Temporäres Verzeichnis für extrahierte Dateien |
| PATHS | extract_dir | Unterverzeichnis für extrahierte Dateien |
| DATABASE | max_rows | Maximale Anzahl der zu ladenden Zeilen |
| DATABASE | chunk_size | Größe der Datenblöcke beim Laden |
| GUI | show_progress | Fortschrittsanzeige aktivieren (1) oder deaktivieren (0) |
| GUI | auto_clear_temp | Automatisches Löschen temporärer Dateien beim Beenden (1) oder Beibehalten (0) |
| EXPORT | excel_template | Pfad zur Excel-Vorlage für den Export |
| EXPORT | csv_delimiter | Trennzeichen für CSV-Export |

**Wichtig**: Das Passwort sollte sicher gespeichert und nicht öffentlich geteilt werden!

## Benutzeroberfläche

### Hauptfenster
Das Hauptfenster des Diagnose-Tools bietet folgende Elemente:

- **Menüleiste**: Zugriff auf alle Funktionen
  - Datei: ZIP-Dateien öffnen, Einstellungen, Beenden
  - Ansicht: Datenaktualisierung, Filter
- **Werkzeugleiste**: Schnellzugriff auf häufig verwendete Funktionen
  - ZIP öffnen: Auswahl einer ZIP-Datei
  - Exportieren: Daten in verschiedene Formate exportieren
  - Tabellen-Auswahl: Dropdown-Menü mit verfügbaren Tabellen
  - Aktualisieren: Daten neu laden
  - Filter: Filteroptionen für die Daten
- **Datenansicht**: Tabelle mit den geladenen Daten
- **Statusleiste**: Informationen zum aktuellen Zustand und laufenden Operationen

### Tastenkombinationen
- `Strg+O`: ZIP-Datei öffnen
- `Strg+E`: Daten exportieren
- `Strg+R`: Daten aktualisieren
- `Strg+F`: Filter anzeigen
- `F1`: Hilfe anzeigen

## Arbeiten mit ZIP-Dateien

### ZIP-Datei öffnen
1. Klicken Sie auf "ZIP öffnen" in der Werkzeugleiste oder wählen Sie "Datei" > "ZIP öffnen..."
2. Wählen Sie eine ZIP-Datei im Dateiauswahldialog
3. Das Tool versucht, die Datei mit dem in der Konfiguration angegebenen Passwort zu entpacken
4. Nach erfolgreicher Entpackung werden die enthaltenen Datenbanken automatisch erkannt

### ZIP-Verarbeitung
Das Tool verwendet 7-Zip (7za.exe) zum Entpacken der Dateien. Der Entpackvorgang erfolgt im Hintergrund. Alle Dateien werden in das konfigurierte temporäre Verzeichnis extrahiert.

## Datenbankoperationen

### Datenbanken durchsuchen
Nach dem Öffnen einer ZIP-Datei werden alle enthaltenen SQLite-Datenbanken (.db und .db3) automatisch erkannt und die erste wird geöffnet.

### Tabellen anzeigen
1. Wählen Sie eine Tabelle aus dem Dropdown-Menü in der Werkzeugleiste
2. Die Daten der ausgewählten Tabelle werden in der Datenansicht angezeigt
3. Klicken Sie auf die Spaltenüberschriften, um die Daten zu sortieren

### Spalten anpassen
- Die Spaltenbreite kann durch Ziehen der Trennlinien in der Überschrift angepasst werden
- Die Reihenfolge der Spalten ist fest und entspricht der Datenbankstruktur

## Datenfilterung

### Einfacher Filter
1. Klicken Sie auf "Filter" in der Werkzeugleiste
2. Im Filterdialog können Sie Bedingungen für einzelne Spalten festlegen
3. Nach Anwendung des Filters werden nur die entsprechenden Datensätze angezeigt

### Komplexe Filterung
Für komplexere Filteroperationen können Sie mehrere Filterbedingungen kombinieren:

1. Öffnen Sie den Filterdialog
2. Fügen Sie mehrere Bedingungen hinzu (UND/ODER-Verknüpfung)
3. Wählen Sie die Vergleichsoperatoren (=, >, <, LIKE, etc.)
4. Bestätigen Sie mit "Anwenden"

## Datenexport

### CSV-Export
1. Klicken Sie auf "Exportieren" in der Werkzeugleiste
2. Wählen Sie "CSV-Datei" im Exportdialog
3. Geben Sie einen Dateinamen und Zielverzeichnis an
4. Wählen Sie die zu exportierenden Spalten
5. Bestätigen Sie mit "Exportieren"

### Excel-Export
1. Klicken Sie auf "Exportieren" in der Werkzeugleiste
2. Wählen Sie "Excel-Datei" im Exportdialog
3. Geben Sie einen Dateinamen und Zielverzeichnis an
4. Wählen Sie optional eine Excel-Vorlage
5. Bestätigen Sie mit "Exportieren"

## Passwortentschlüsselung

Das Tool bietet eine integrierte Funktion zur Entschlüsselung von Base64-codierten Passwörtern:

1. Rechtsklick auf eine Zelle mit einem verschlüsselten Passwort
2. Wählen Sie "Passwort entschlüsseln" aus dem Kontextmenü
3. Das entschlüsselte Passwort wird in einem Dialogfenster angezeigt

## Fehlerbehebung

### Logdateien
Das Tool erstellt Logdateien im Hauptverzeichnis:
- `diagnose.log`: Allgemeine Programmaktivitäten
- `error.log`: Fehlermeldungen und Warnungen

### Häufige Probleme und Lösungen

**Problem**: ZIP-Datei kann nicht geöffnet werden.
**Lösung**: 
- Überprüfen Sie, ob das korrekte Passwort in der `settings.ini` eingetragen ist
- Stellen Sie sicher, dass die ZIP-Datei nicht beschädigt ist
- Überprüfen Sie die Fehlermeldungen in der `error.log`

**Problem**: Keine Datenbanken gefunden.
**Lösung**:
- Stellen Sie sicher, dass die ZIP-Datei SQLite-Datenbanken (.db oder .db3) enthält
- Überprüfen Sie, ob die Entpackung erfolgreich war (temporäres Verzeichnis prüfen)

**Problem**: Daten werden nicht angezeigt.
**Lösung**:
- Aktualisieren Sie die Ansicht über "Aktualisieren" in der Werkzeugleiste
- Überprüfen Sie, ob Filter aktiv sind und entfernen Sie diese gegebenenfalls
- Prüfen Sie, ob die Datenbank korrekt geöffnet wurde

## Support und Updates

Bei Fragen und Problemen wenden Sie sich bitte an den Projektverantwortlichen oder erstellen Sie ein Issue im GitHub-Repository:

- Repository: [https://github.com/Ralle1976/diagnose-tool/](https://github.com/Ralle1976/diagnose-tool/)
- Issues: [https://github.com/Ralle1976/diagnose-tool/issues](https://github.com/Ralle1976/diagnose-tool/issues)