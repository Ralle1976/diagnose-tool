# Technische Dokumentation Diagnose-Tool

## Systemarchitektur

Das Diagnose-Tool basiert auf einer modularen Drei-Schicht-Architektur:

### Präsentationsschicht (GUI)
- Implementiert in main.au3
- Benutzeroberfläche mit AutoIt GUI-Elementen
- Event-basierte Benutzerinteraktion
- Statusanzeigen für laufende Prozesse

### Geschäftslogik
- ZIP-Verarbeitung mit 7za.exe Integration
- Datenbankoperationen über SQLite3.dll
- Validierung und Fehlerbehandlung
- Temporäre Dateiverwaltung

### Datenhaltung
- SQLite-Datenbank Anbindung
- Dynamische Tabellenverwaltung
- Konfigurationsdateien (settings.ini)
- Temporäre Datenspeicherung

## Technische Abhängigkeiten

- AutoIt v3.3.16.1+
- SQLite3.dll (32/64-bit kompatibel)
- 7za.exe v21.07
- Windows 7+ Betriebssystem

## Entwicklungsrichtlinien

### Code-Organisation
- Modulare Struktur mit klarer Trennung der Zuständigkeiten
- Wiederverwendbare Funktionen in separaten Include-Dateien
- Konsistente Fehlerbehandlung und Logging

### Namenskonventionen
- Funktionen: PascalCase mit beschreibenden Präfixen
- Variablen: Hungarian Notation für Typklarheit
- Konstanten: Großbuchstaben mit Unterstrichen

### Performance-Optimierung
- Effiziente SQL-Abfragen mit Index-Nutzung
- Minimierung von GUI-Updates
- Speichereffiziente Dateiverarbeitung

## Debugging und Testing

- Integriertes AutoIt Debug-System
- Logging-Framework für Fehleranalyse
- Testumgebung für Kernfunktionen

## Build und Deployment

### Entwicklungsumgebung
- SciTE4AutoIt als primärer Editor
- AutoIt3 Wrapper für Kompilierung
- Versionskontrolle über Git/GitHub

### Release-Prozess
1. Code-Review und Testing
2. Versionsnummer aktualisieren
3. Kompilierung und Paketierung
4. Release-Notes erstellen
5. Deployment auf Zielsysteme