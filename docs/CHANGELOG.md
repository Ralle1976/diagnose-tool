# Changelog

## [Unreleased] - 2025-01-30
### Added
- Erweitertes Drag & Drop System
  - Unterstützung für mehrere Dateitypen (ZIP, SQLite, CSV, Excel)
  - Fortschrittsanzeige bei der Verarbeitung
  - Validierung der Dateitypen
  - Benutzerfreundliche Fehlermeldungen
- Kontextmenü-System für ListView
  - Export-Funktionen (Excel, CSV)
  - Filter-Verwaltung
  - Sortierungsoptionen
- Verbesserte GUI-Integration
  - Dynamische Menüerstellung
  - Event-Handler für Benutzerinteraktionen
  - Statusleisten-Updates
- Sicherer Passwort-Manager für ZIP-Dateien
  - AES-256 Verschlüsselung
  - Automatische Passwortabfrage
  - Sichere Speicherung
- Layout-Optimierungen
  - Automatische Spaltenbreitenanpassung
  - Dynamische Größenanpassung
  - Alternierende Zeilenfarben
  - Sortierungspfeile in Spaltenköpfen

### Changed
- Hauptanwendung überarbeitet
  - Integration des Kontextmenü-Systems
  - Verbesserte Event-Verarbeitung
  - Moderneres Layout
  - Drag & Drop Integration
- ZIP-Handler erweitert
  - Integration des Passwort-Managers
  - Verbesserte Fehlerbehandlung

### Upcoming
- Erweiterte Statusanzeigen
- Performance-Optimierungen
  - Lazy Loading für große Datensätze
  - Cache-System
  - Verbesserte SQL-Abfragen