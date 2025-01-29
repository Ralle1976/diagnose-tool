# Diagnose-Tool

Ein AutoIt-basiertes Tool zur automatischen Verarbeitung von ZIP-Dateien und SQLite-Datenbanken mit optimierter Performance.

## Features

### Datenverarbeitung
- Automatisches Entpacken von ZIP-Dateien
- SQLite-Datenbankanalyse und -visualisierung
- Erweiterte Filterfunktionen:
  - Multi-Spalten Filter
  - Datums- und Zahlenbereichsfilter
  - Speicherbare Filter-Vorlagen
- Sortierung nach allen Spalten
- CSV-Export Funktion

### Performance-Optimierungen
- Memory Manager für optimierte Ressourcennutzung
- Proaktives Speichermanagement
- Effiziente Datenbankabfragen
- Statusanzeigen für lange Operationen

### Benutzeroberfläche
- Intuitive Datenbankansicht
- Fortschrittsanzeigen
- Drag & Drop Unterstützung
- Konfigurierbare Einstellungen

## Installation

1. Voraussetzungen:
   - AutoIt v3 installiert
   - Windows 7 oder höher
   - Mindestens 4GB RAM empfohlen
   - 100MB freier Festplattenspeicher

2. Installation:
   - Repository herunterladen
   - SQLite3.dll im Programmverzeichnis platzieren
   - main.au3 ausführen

## Konfiguration

Die Einstellungen werden in verschiedenen Dateien verwaltet:
- `settings.ini`: Grundeinstellungen
- `filter_presets.ini`: Gespeicherte Filtervorlagen
- `templates/`: Excel-Vorlagen (in Entwicklung)

## Entwicklungsstand

Aktuell implementiert:
- [x] Grundlegende GUI
- [x] ZIP-Extraktion mit 7-Zip
- [x] SQLite-Viewer mit erweiterten Funktionen
- [x] Fortgeschrittene Filtermöglichkeiten
- [x] Sortierung und CSV-Export
- [x] Memory Management
- [x] Performance-Optimierungen

In Entwicklung:
- [ ] Excel-Export System
- [ ] Umfassende Fehlerbehandlung
- [ ] Erweiterte Dokumentation

## Dokumentation

Ausführliche Dokumentation finden Sie in:
- HANDOVER.md: Technische Details und Modulübersicht
- PROGRESS.md: Entwicklungsfortschritt und Planung
- docs/ENTWICKLUNG.md: Entwicklerdokumentation

## Lizenz

MIT License