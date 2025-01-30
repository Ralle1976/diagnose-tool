# Übergabedokumentation für Diagnose-Tool

## GitHub-Repository
Repository: https://github.com/Ralle1976/diagnose-tool
Zugriff via GitHub API möglich - siehe Beispiele unten.

## Aktueller Stand (30.01.2025)

### Implementierte Module
1. Main Application (src/main.au3) ✓
   - Hauptfenster mit Menü
   - Dateiverarbeitung
   - Statusanzeigen
   - Ressourcenmanagement
   - Filter-Integration

2. Logging-System (src/lib/logging.au3) ✓
   - Rotationsfähig
   - Verschiedene Log-Level
   - Strukturierte Ausgabe
   - Error-Handler Integration

3. ZIP-Handler (src/lib/zip_handler.au3) ✓
   - 7-Zip Integration
   - Automatischer Download
   - Fortschrittsanzeige

4. SQLite-Handler (src/lib/sqlite_handler.au3) ✓
   - Datenbankzugriff
   - Tabellenmanagement 
   - Fehlerbehandlung

5. SQLite-Viewer (src/lib/sqlite_viewer.au3) ✓
   - Tabellenansicht mit Sortierung
   - Erweiterte Filterfunktionen
   - CSV/Excel-Export
   - Memory-Optimiert

6. List-Sorting (src/lib/list_sorting.au3) ✓
   - Header-Klick Sortierung
   - Multi-Spalten Support
   - Automatische Typenerkennung

7. Advanced-Filter (src/lib/advanced_filter.au3) ✓
   - Komplexe Filterbedingungen 
   - Filter-Vorlagen System
   - Multi-Spalten Unterstützung
   - GUI & Core Komponenten

8. Memory Manager (src/lib/memory_manager.au3) ✓
   - Proaktive Speicherüberwachung
   - Automatische Ressourcenfreigabe
   - Temporäre Dateiverwaltung

9. Excel-Handler (src/lib/excel_handler.au3) ✓
   - Template-System
   - Formatierungsoptionen
   - Batch-Export Support

10. CSV-Handler (src/lib/csv_handler.au3) ✓
    - Import/Export Funktionen
    - Unicode Support
    - Fehlerbehandlung

11. Error-Handler (src/lib/error_handler.au3) ✓
    - Zentrales Fehler-Logging
    - Benutzerfreundliche Meldungen
    - Verschiedene Error-Level

### GitHub API Beispiele

1. Repository-Informationen abrufen:
```javascript
// Mit MCP GitHub API
await get_file_contents({
    owner: "Ralle1976",
    repo: "diagnose-tool",
    path: "HANDOVER.md"
});
```

2. Dateien aktualisieren:
```javascript
// Mit MCP GitHub API
await create_or_update_file({
    owner: "Ralle1976",
    repo: "diagnose-tool",
    path: "src/main.au3",
    message: "Update main.au3",
    content: "neuer Inhalt",
    branch: "main"
});
```

### Nächste Schritte
1. GUI-Verbesserungen:
   - Kontextmenüs für ListView
   - Erweiterte Statusanzeigen
   - Drag & Drop Optimierung

2. Performance-Optimierung:
   - Lazy Loading für große Datensätze
   - SQL-Query Optimierung
   - Cache-System einführen

3. Dokumentation:
   - Benutzerhandbuch erstellen
   - Code-Dokumentation ergänzen
   - Beispiele hinzufügen

### Wichtige Hinweise
1. AutoIt-Limitierungen:
   - Kein echtes Multi-Threading
   - Timer für UI-Updates
   - Speichermanagement beachten

2. Repository-Struktur:
   - src/: Quellcode
     - lib/: Modulbibliotheken
     - main.au3: Hauptanwendung
   - docs/: Dokumentation
   - templates/: Excel-Vorlagen
   - tests/: Testfälle (zu erstellen)

3. Coding Guidelines:
   - Ausführliche Kommentierung
   - Fehlerbehandlung in jeder Funktion
   - Memory Manager nutzen
   - Logging für wichtige Operationen

### Build & Test
1. Voraussetzungen:
   - AutoIt v3
   - SQLite3.dll im Programmverzeichnis
   - 7-Zip (wird automatisch geladen)
   - Excel für Export-Funktionen

2. Konfiguration:
   - settings.ini: Grundeinstellungen
   - filter_presets.ini: Gespeicherte Filter
   - templates/: Excel-Vorlagen

### Für den nächsten Chat
1. GitHub API verwenden für:
   - Code-Zugriff
   - Dokumentations-Updates
   - Issue-Tracking
2. Alle Informationen in .md Files beachten
3. Implementierungsdetails in Source-Code prüfen