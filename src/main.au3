#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <File.au3>
#include "lib/error_handler.au3"
#include "lib/sqlite_handler.au3"
#include "lib/zip_handler.au3"
#include "lib/excel_handler.au3"
#include "lib/memory_manager.au3"
#include "lib/logging.au3"

; Globale Variablen
Global $g_hGUI, $g_hListView
Global $g_hStatusLabel
Global $g_sWorkingDir = @ScriptDir & "\temp"
Global $g_sLogFile = @ScriptDir & "\logs\app.log"

; GUI Erstellen
Func _Main_CreateGUI()
    ; Hauptfenster
    $g_hGUI = GUICreate("Diagnose-Tool", 800, 600)
    
    ; Menü erstellen
    Local $idFileMenu = GUICtrlCreateMenu("&Datei")
    Local $idFileOpen = GUICtrlCreateMenuItem("ZIP öffnen", $idFileMenu)
    Local $idDBOpen = GUICtrlCreateMenuItem("Datenbank öffnen", $idFileMenu)
    GUICtrlCreateMenuItem("", $idFileMenu)
    Local $idFileExit = GUICtrlCreateMenuItem("Beenden", $idFileMenu)
    
    Local $idExportMenu = GUICtrlCreateMenu("&Export")
    Local $idExportExcel = GUICtrlCreateMenuItem("Nach Excel", $idExportMenu)
    Local $idExportCSV = GUICtrlCreateMenuItem("Nach CSV", $idExportMenu)
    
    ; Toolbar
    Local $idToolbar = GUICtrlCreateGroup("Werkzeuge", 10, 10, 780, 50)
    Local $idRefresh = GUICtrlCreateButton("Aktualisieren", 20, 30, 100, 25)
    Local $idFilter = GUICtrlCreateButton("Filter", 130, 30, 100, 25)
    Local $idClear = GUICtrlCreateButton("Zurücksetzen", 240, 30, 100, 25)
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    
    ; ListView für Daten
    $g_hListView = GUICtrlCreateListView("", 10, 70, 780, 480)
    
    ; Status Label
    $g_hStatusLabel = GUICtrlCreateLabel("Bereit", 10, 560, 780, 20)
    
    GUISetState(@SW_SHOW)
    Return True
EndFunc

; Hauptfunktion für ZIP-Verarbeitung
Func _Main_ProcessZIPFile($sZIPPath)
    _SetStatus("Verarbeite ZIP-Datei...")
    
    ; ZIP extrahieren
    Local $sExtractPath = $g_sWorkingDir & "\" & _GetFileNameWithoutExt($sZIPPath)
    If Not _ZIP_Extract($sZIPPath, $sExtractPath) Then
        _ErrorHandler_HandleError($ERROR_TYPE_ZIP, "Fehler beim Entpacken", $ERROR_LEVEL_ERROR)
        Return False
    EndIf
    
    ; Suche nach SQLite Dateien
    Local $aDBFiles = _FileListToArray($sExtractPath, "*.db", $FLTA_FILES)
    If @error Then
        _ErrorHandler_HandleError($ERROR_TYPE_FILE, "Keine Datenbankdateien gefunden", $ERROR_LEVEL_WARNING)
        Return False
    EndIf
    
    ; Erste DB-Datei öffnen
    _Main_OpenDatabase($sExtractPath & "\" & $aDBFiles[1])
    
    _SetStatus("ZIP-Datei erfolgreich verarbeitet")
    Return True
EndFunc

; Datenbank öffnen und anzeigen
Func _Main_OpenDatabase($sDBPath)
    _SetStatus("Öffne Datenbank...")
    
    ; DB Connection
    Local $hDB = _SQLite_Open($sDBPath)
    If @error Then
        _ErrorHandler_HandleError($ERROR_TYPE_DB, "Fehler beim Öffnen der Datenbank", $ERROR_LEVEL_ERROR)
        Return False
    EndIf
    
    ; Tabellen auflisten
    Local $aTables = _SQLite_GetTableNames($hDB)
    If @error Or Not IsArray($aTables) Then
        _ErrorHandler_HandleError($ERROR_TYPE_DB, "Keine Tabellen gefunden", $ERROR_LEVEL_WARNING)
        Return False
    EndIf
    
    ; Erste Tabelle anzeigen
    _Main_DisplayTable($hDB, $aTables[0])
    
    _SetStatus("Datenbank geladen")
    Return True
EndFunc

; Tabellendaten anzeigen
Func _Main_DisplayTable($hDB, $sTable)
    _SetStatus("Lade Tabellendaten...")
    
    ; Spalten abrufen
    Local $aColumns = _SQLite_GetTableColumns($hDB, $sTable)
    If @error Then Return False
    
    ; ListView vorbereiten
    _GUICtrlListView_DeleteAllItems($g_hListView)
    _GUICtrlListView_DeleteAllColumns($g_hListView)
    
    ; Spalten erstellen
    For $i = 0 To UBound($aColumns) - 1
        _GUICtrlListView_AddColumn($g_hListView, $aColumns[$i], 100)
    Next
    
    ; Daten laden
    Local $sQuery = "SELECT * FROM " & $sTable & " LIMIT 1000"
    Local $aResult = _SQLite_GetTable2d($hDB, $sQuery)
    If @error Then Return False
    
    ; Daten einfügen
    For $i = 1 To $aResult[0][0]
        Local $aRow = StringSplit($aResult[$i][0], "|")
        _GUICtrlListView_AddItem($g_hListView, $aRow[1])
        For $j = 2 To $aRow[0]
            _GUICtrlListView_AddSubItem($g_hListView, $i-1, $aRow[$j], $j-1)
        Next
    Next
    
    _SetStatus("Tabelle geladen: " & $sTable)
    Return True
EndFunc

; Export nach Excel
Func _Main_ExportToExcel()
    _SetStatus("Exportiere nach Excel...")
    
    Local $sTemplate = @ScriptDir & "\templates\export.xlsx"
    Local $sExportFile = @ScriptDir & "\export_" & @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & ".xlsx"
    
    ; Daten aus ListView holen
    Local $aData = _GUICtrlListView_GetItemTextArray($g_hListView)
    
    ; Excel Export
    If Not _Excel_Export($sTemplate, $sExportFile, $aData) Then
        _ErrorHandler_HandleError($ERROR_TYPE_FILE, "Fehler beim Excel-Export", $ERROR_LEVEL_ERROR)
        Return False
    EndIf
    
    _SetStatus("Excel-Export abgeschlossen: " & $sExportFile)
    Return True
EndFunc

; Status aktualisieren
Func _SetStatus($sMessage)
    GUICtrlSetData($g_hStatusLabel, $sMessage)
    _Logging_Log($sMessage)
EndFunc

; Hilfsfunktion: Dateiname ohne Erweiterung
Func _GetFileNameWithoutExt($sFilePath)
    Local $aPathSplit = StringSplit($sFilePath, "\")
    Local $sFileName = $aPathSplit[$aPathSplit[0]]
    Return StringLeft($sFileName, StringInStr($sFileName, ".", 0, -1) - 1)
EndFunc

; Event Loop
Func _Main_EventLoop()
    While 1
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
                
            Case $idFileOpen
                Local $sFile = FileOpenDialog("ZIP-Datei öffnen", "", "ZIP (*.zip)")
                If @error Then ContinueLoop
                _Main_ProcessZIPFile($sFile)
                
            Case $idDBOpen
                Local $sFile = FileOpenDialog("Datenbank öffnen", "", "SQLite DB (*.db)")
                If @error Then ContinueLoop
                _Main_OpenDatabase($sFile)
                
            Case $idExportExcel
                _Main_ExportToExcel()
                
            Case $idExportCSV
                ; TODO: CSV Export implementieren
                
            Case $idRefresh
                ; TODO: Daten neu laden
                
            Case $idFilter
                ; TODO: Filtermaske anzeigen
                
            Case $idClear
                _GUICtrlListView_DeleteAllItems($g_hListView)
                _SetStatus("Ansicht zurückgesetzt")
        EndSwitch
        
        ; Memory Management
        _MemoryManager_Cleanup()
    WEnd
EndFunc

; Programm starten
_ErrorHandler_Init()
_Logging_Init($g_sLogFile)
_MemoryManager_Init()

If Not FileExists($g_sWorkingDir) Then DirCreate($g_sWorkingDir)

_Main_CreateGUI()
_Main_EventLoop()
