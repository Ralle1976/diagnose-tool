# Technische Spezifikation des Diagnose-Tools

## Systemarchitektur

Das Diagnose-Tool basiert auf einer modularen Drei-Schicht-Architektur, die folgende Hauptkomponenten umfasst:

Die Präsentationsschicht verwaltet die Benutzeroberfläche und die Benutzerinteraktionen. Sie wurde mit AutoIt GUI-Elementen implementiert und bietet eine intuitive Schnittstelle für Dateioperationen, Tabellenansichten und Datenmanipulation.

Die Geschäftslogikschicht koordiniert die Datenverarbeitung und die Anwendungslogik. Sie integriert die ZIP-Verarbeitung mit 7za.exe und verwaltet die SQLite-Datenbankoperationen.

Die Datenhaltungsschicht stellt die persistente Datenspeicherung und den Datenbankzugriff sicher. Sie verwendet SQLite für die Datenbankoperationen und ein strukturiertes Dateisystem für temporäre Dateien.

## Kernfunktionalitäten

### ZIP-Verarbeitung
Die ZIP-Verarbeitung ermöglicht derzeit:
- Entpacken von passwortgeschützten ZIP-Dateien
- Automatische Erkennung und Verarbeitung von Datenbankdateien
- Systematische Verwaltung temporärer Verzeichnisse

### Datenbankmanagement
Das SQLite-Datenbankmanagement bietet:
- Dynamische Verbindungsherstellung zu SQLite-Datenbanken
- Automatische Erkennung und Auflistung verfügbarer Tabellen
- Effiziente Datendarstellung in der ListView-Komponente

### Benutzeroberfläche
Die GUI-Implementierung umfasst:
- Ein Hauptfenster mit integrierter Menüleiste
- Eine konfigurierbare Werkzeugleiste für häufig genutzte Funktionen
- Eine ListView zur Datenanzeige mit Spaltenmanagement

## Technische Abhängigkeiten

Das System basiert auf folgenden technischen Komponenten:
- AutoIt Version 3.3.16.1 als Entwicklungsplattform
- SQLite3.dll für Datenbankoperationen
- 7za.exe für die ZIP-Archivverarbeitung
- Eine konfigurierte settings.ini für Systemeinstellungen

## Aktuelle Funktionsgrenzen

Der aktuelle Entwicklungsstand weist folgende definierte Einschränkungen auf:
- Die Kopierfunktion für ListView-Inhalte ist noch nicht implementiert
- Die Filterfunktion ist in der GUI vorbereitet, aber noch nicht aktiv
- Der Datenexport ist auf die GUI-Ebene beschränkt

## Konfiguration und Einstellungen

Die Anwendung verwendet eine settings.ini-Datei für:
- ZIP-Passwortmanagement
- Verzeichniskonfigurationen
- Datenbankeinstellungen
- GUI-Präferenzen

## Entwicklungsrichtlinien

Für die weitere Entwicklung gelten folgende Prinzipien:

Die Codeorganisation soll die Modularität wahren und neue Funktionen in entsprechende Module einordnen. Dabei muss die bestehende Funktionalität geschützt werden.

Die Fehlerbehandlung erfordert durchgängiges Logging und benutzerfreundliche Fehlermeldungen. Dies ermöglicht eine effektive Fehlerdiagnose und -behebung.

Die Dokumentation muss bei jeder Funktionserweiterung aktualisiert werden. Dies umfasst Codekommentare, Funktionsbeschreibungen und technische Dokumentation.

## Performance-Überlegungen

Die aktuelle Implementierung berücksichtigt:
- Effiziente Datenbankabfragen durch SQLite-Optimierung
- Speichereffiziente Verarbeitung großer Datensätze
- Reaktionsschnelle GUI-Updates durch optimierte Aktualisierungszyklen

## Sicherheitsaspekte

Das System implementiert grundlegende Sicherheitsmaßnahmen:
- Sichere Verarbeitung von ZIP-Passwörtern
- Kontrollierte Verarbeitung temporärer Dateien
- Validierung von Benutzereingaben

Diese technische Dokumentation wird kontinuierlich mit der Weiterentwicklung des Systems aktualisiert.