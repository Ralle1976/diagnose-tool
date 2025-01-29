# Diagnose-Tool

Ein AutoIt-basiertes Tool zur automatischen Verarbeitung von ZIP-Dateien und SQLite-Datenbanken.

## Features

- Automatisches Entpacken von passwortgeschützten ZIP-Dateien
- SQLite-Datenbankanalyse und -visualisierung
- Drag & Drop Unterstützung
- Fortschrittsanzeige für lange Operationen
- Detailliertes Logging-System
- Konfigurierbare Einstellungen

## Installation

1. Stellen Sie sicher, dass AutoIt v3 installiert ist
2. Laden Sie das Repository herunter
3. Platzieren Sie die SQLite DLL (sqlite3.dll) im Programmverzeichnis
4. Starten Sie die Anwendung über die main.au3

## Konfiguration

Die Einstellungen werden in der `settings.ini` gespeichert und beinhalten:
- Überwachungsordner
- ZIP-Passwort
- Log-Level
- Weitere Konfigurationsoptionen

## Entwicklungsstand

Aktuell implementierte Features:
- [x] Grundlegende GUI
- [x] 7-Zip Integration
- [x] Logging-System
- [x] ZIP-Extraktion
- [x] Fortschrittsanzeige
- [x] Drag & Drop

In Entwicklung:
- [ ] Einstellungs-GUI
- [ ] Erweiterte SQLite-Visualisierung
- [ ] Automatische Bereinigung
- [ ] Kontextmenüs

## Lizenz

MIT License