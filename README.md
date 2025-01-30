# Diagnose-Tool

Ein AutoIt-basiertes Tool zur automatischen Verarbeitung von ZIP-Dateien und SQLite-Datenbanken mit optimierter Performance.

## GitHub Repository
- Repository: https://github.com/Ralle1976/diagnose-tool
- Alle Details zur Implementierung und Integration finden sich in:
  - HANDOVER.md: Technische Details, Module und GitHub API Verwendung
  - PROGRESS.md: Entwicklungsfortschritt und Planung
  - docs/: Entwicklerdokumentation

## Features

### Datenverarbeitung
- Automatisches Entpacken von ZIP-Dateien ✓
- SQLite-Datenbankanalyse und -visualisierung ✓
- Excel-Export mit Template-System ✓
- CSV Import/Export ✓
- Erweiterte Filterfunktionen:
  - Multi-Spalten Filter ✓
  - Datums- und Zahlenbereichsfilter ✓
  - Speicherbare Filter-Vorlagen ✓
- Sortierung nach allen Spalten ✓

### Performance-Optimierungen
- Memory Manager für optimierte Ressourcennutzung ✓
- Proaktives Speichermanagement ✓
- Effiziente Datenbankabfragen ✓
- Statusanzeigen für lange Operationen ✓

### Benutzeroberfläche
- Intuitive Datenbankansicht ✓
- Fortschrittsanzeigen ✓
- Drag & Drop Unterstützung ✓
- Konfigurierbare Einstellungen ✓
- Menüsystem ✓

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
- `templates/`: Excel-Vorlagen

## Entwicklungsstand

### Implementiert (✓):
- [x] Hauptanwendung mit GUI
- [x] ZIP-Extraktion mit 7-Zip
- [x] SQLite-Viewer mit erweiterten Funktionen
- [x] Fortgeschrittene Filtermöglichkeiten
- [x] Sortierung und CSV-Export
- [x] Excel-Export System
- [x] Memory Management
- [x] Performance-Optimierungen
- [x] Error Handler
- [x] Input Validierung

### In Entwicklung:
- [ ] GUI-Verbesserungen
- [ ] Performance-Optimierungen
- [ ] Dokumentation

## Nächste Schritte
1. GUI-Verbesserungen implementieren
2. Performance-Optimierungen für große Datensätze
3. Dokumentation vervollständigen

## Entwickler-Informationen

Für Entwickler stehen folgende Ressourcen zur Verfügung:
- Vollständige Dokumentation in HANDOVER.md
- GitHub API Integration (siehe HANDOVER.md)
- Fortschrittsverfolgung in PROGRESS.md
- Technische Dokumentation in docs/

## Lizenz

MIT License