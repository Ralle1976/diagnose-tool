# Übergabedokumentation für Diagnose-Tool

## Aktueller Stand (31.01.2025)

### Projekt-Übersicht
Das Diagnose-Tool dient zur automatischen Verarbeitung von:
- Passwortgeschützten ZIP-Dateien
- SQLite-Datenbanken
- Excel und CSV Export

### Implementierte Module
1. ZIP-Handler (src/lib/zip_handler.au3) ✓
   - Automatischer Download und Installation von 7-Zip 
   - Unterstützung für passwortgeschützte ZIPs
   - Direktinstallation in Arbeitsverzeichnis

2. SQLite-Handler/Viewer (src/lib/sqlite_handler.au3, sqlite_viewer.au3) ✓
   - Datenbank-Management
   - Tabellenansicht
   - Performance-Optimierung

3. Logging System (src/lib/logging.au3) ✓
   - Zentrales Logging
   - Error-Handler Integration
   - Debug-Unterstützung

4. Export-System (src/lib/excel_handler.au3, csv_handler.au3) ✓
   - Excel mit Template-Support
   - CSV-Export
   - Unicode-Unterstützung

5. Filter-System (src/lib/advanced_filter*.au3) ✓
   - Komplexe Filter
   - GUI Integration
   - Template-System

### GitHub Repository
Repository: https://github.com/Ralle1976/diagnose-tool

### Lokale Entwicklung
Hauptpfad: C:\Users\tango\Downloads\diagnose-tool-main\diagnose-tool-main

### Nächste Schritte
1. GitHub-Aktualisierung:
   - Alle .md Dateien
   - Quellcode-Updates
   - Neue Features

2. Dokumentation:
   - Update aller .md Dateien
   - Technische Dokumentation
   - Benutzerhandbuch

3. Code-Optimierung:
   - ZIP-Handler Tests
   - Performance-Verbesserungen
   - GUI-Verfeinerungen

### Build & Test
1. Voraussetzungen:
   - AutoIt v3
   - Administrative Rechte für 7-Zip Installation
   - ZIP-Passwort in settings.ini

2. Konfiguration:
   - settings.ini: Grundeinstellungen und ZIP-Passwort
   - templates/: Excel-Vorlagen
   - Logging in diagnose.log

### Für den nächsten Chat
1. GitHub API:
   - MCP Server für API-Zugriff nutzen
   - Dokumentations-Updates durchführen
   - Code-Aktualisierung

2. Dateien beachten:
   - Alle .md Dateien im lokalen Pfad
   - Source-Code in src/
   - Implementierungsdetails prüfen