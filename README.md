# Diagnose-Tool

Ein AutoIt-basiertes Tool zur automatischen Verarbeitung von ZIP-Dateien und SQLite-Datenbanken mit optimierter Performance.

## Features

- Automatisches Entpacken von passwortgeschützten ZIP-Dateien
- SQLite-Datenbankanalyse und -visualisierung
- Excel-Export mit Template-System
- Optimierte Performance durch:
  - Lazy Loading für große Datensätze
  - Buffer-System für UI-Updates
  - Proaktives Speichermanagement
- Drag & Drop Unterstützung
- Fortschrittsanzeige für lange Operationen
- Detailliertes Logging-System
- Konfigurierbare Einstellungen

## Installation

1. Stellen Sie sicher, dass AutoIt v3 installiert ist
2. Laden Sie das Repository herunter
3. Platzieren Sie die SQLite DLL (sqlite3.dll) im Programmverzeichnis
4. Excel muss für Export-Funktionen installiert sein
5. Starten Sie die Anwendung über die main.au3

## Konfiguration

Die Einstellungen werden in verschiedenen Dateien gespeichert:
- `settings.ini`: Grundeinstellungen
- `filter_presets.ini`: Gespeicherte Filter
- `templates/`: Excel-Vorlagen
- Weitere Konfigurationsoptionen

## Systemanforderungen

- Windows 7 oder höher
- AutoIt v3
- SQLite3.dll
- Microsoft Excel (für Export-Funktionen)
- Mindestens 4GB RAM empfohlen
- 100MB freier Festplattenspeicher

## Entwicklungsstand

Aktuell implementierte Features:
- [x] Grundlegende GUI
- [x] 7-Zip Integration
- [x] Logging-System
- [x] ZIP-Extraktion
- [x] Fortschrittsanzeige
- [x] Drag & Drop
- [x] Excel-Export System
- [x] Performance-Optimierungen
- [x] Speichermanagement

In Entwicklung:
- [ ] Modul-Integration
- [ ] Unit-Tests
- [ ] Performance-Tests
- [ ] Erweiterte Dokumentation

## Dokumentation

Ausführliche Dokumentation finden Sie in:
- HANDOVER.md: Technische Details und Modulübersicht
- PROGRESS.md: Entwicklungsfortschritt und Planung
- docs/ENTWICKLUNG.md: Entwicklerdokumentation

## Lizenz

MIT License