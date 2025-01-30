#include-once
#include <GUIConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <GuiListView.au3>
#include "lib/memory_manager.au3"
#include "lib/zip_handler.au3"
#include "lib/sqlite_handler.au3"
#include "lib/sqlite_viewer.au3"
#include "lib/logging.au3"
#include "lib/excel_handler.au3"

; Globale Variablen
Global $g_hGUI = 0
Global $g_idListview = 0
Global $g_sWorkingDir = @ScriptDir & "\work"
Global $g_bProcessing = False

; Hauptfunktion
Func _Main()
    ; Initialisierung
    _Log_Initialize()
    _Log_Write("Anwendung gestartet")
    _MemoryManager_Init()
    
    ; Arbeitsverzeichnis erstellen/prüfen
    If Not FileExists($g_sWorkingDir) Then 
        DirCreate($g_sWorkingDir)
    Else
        _CleanupWorkDir()
    EndIf
    
    ; Excel prüfen
    Local $bExcelAvailable = _Excel_Init()
    If @error Then 
        _Log_Write("Excel nicht verfügbar - Export-Funktionen eingeschränkt")
    EndIf
    _Excel_Close()
    
    ; Hauptfenster erstellen
    $g_hGUI = GUICreate("Diagnose-Tool", 800, 600)
    
    ; Menü
    Local $idFile = GUICtrlCreateMenu("&Datei")
    Local $idFileOpen = GUICtrlCreateMenuItem("Öffnen...", $idFile)
    Local $idFileExit = GUICtrlCreateMenuItem("Beenden", $idFile)
    
    Local $idTools = GUICtrlCreateMenu("&Werkzeuge")
    Local $idToolsSettings = GUICtrlCreateMenuItem("Einstellungen...", $idTools)
    
    Local $idHelp = GUICtrlCreateMenu("&Hilfe")
    Local $idHelpAbout = GUICtrlCreateMenuItem("Über...", $idHelp)
    
    ; Toolbar
    Local $idToolbar = GUICtrlCreateGroup("", 10, 10, 780, 50)
    Local $idBtnOpen = GUICtrlCreateButton("Datei öffnen", 20, 25, 100, 30)
    Local $idBtnProcess = GUICtrlCreateButton("Verarbeiten", 130, 25, 100, 30)
    GUICtrlSetState($idBtnProcess, $GUI_DISABLE)
    
    ; Status
    Local $idStatus = GUICtrlCreateLabel("Bereit", 240, 30, 300, 20)
    
    ; Listview für Dateien
    $g_idListview = GUICtrlCreateListView("Datei|Status|Fortschritt", 10, 70, 780, 520)
    _GUICtrlListView_SetExtendedListViewStyle($g_idListview, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
    
    GUISetState(@SW_SHOW, $g_hGUI)
    
    ; Event Loop
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idFileExit
                ExitLoop
                
            Case $idFileOpen, $idBtnOpen
                _HandleFileOpen()
                If _GUICtrlListView_GetItemCount($g_idListview) > 0 Then
                    GUICtrlSetState($idBtnProcess, $GUI_ENABLE)
                EndIf
                
            Case $idBtnProcess
                GUICtrlSetState($idBtnProcess, $GUI_DISABLE)
                GUICtrlSetData($idStatus, "Verarbeite Dateien...")
                _ProcessFiles($idStatus)
                GUICtrlSetData($idStatus, "Bereit")
                GUICtrlSetState($idBtnProcess, $GUI_ENABLE)
                
            Case $idToolsSettings
                ; TODO: Settings-Dialog implementieren
                
            Case $idHelpAbout
                MsgBox(64, "Über", "Diagnose-Tool" & @CRLF & @CRLF & "Version: 1.0" & @CRLF & "© 2025")
        EndSwitch
    WEnd
    
    ; Aufräumen
    _Cleanup()
EndFunc

; Dateien verarbeiten
Func _ProcessFiles($idStatus)
    If $g_bProcessing Then Return
    
    $g_bProcessing = True
    Local $iItems = _GUICtrlListView_GetItemCount($g_idListview)
    
    For $i = 0 To $iItems - 1
        Local $sFilePath = _GUICtrlListView_GetItemText($g_idListview, $i, 0)
        _GUICtrlListView_SetItemText($g_idListview, $i, 1, "Verarbeite...")
        GUICtrlSetData($idStatus, "Verarbeite: " & $sFilePath)
        
        ; ZIP extrahieren
        Local $sExtractPath = _ZIP_Extract($sFilePath, $g_sWorkingDir)
        If @error Then
            _GUICtrlListView_SetItemText($g_idListview, $i, 1, "Fehler: ZIP")
            ContinueLoop
        EndIf
        
        ; SQLite-DBs suchen und analysieren
        Local $aDBFiles = _FileListToArray($sExtractPath, "*.db", $FLTA_FILES)
        If Not @error Then
            For $j = 1 To $aDBFiles[0]
                Local $sDBPath = $sExtractPath & "\" & $aDBFiles[$j]
                GUICtrlSetData($idStatus, "Analysiere DB: " & $aDBFiles[$j])
                _SQLiteViewer_Show($sDBPath)
            Next
        EndIf
        
        _GUICtrlListView_SetItemText($g_idListview, $i, 1, "Abgeschlossen")
        _MemoryManager_Cleanup()
    Next
    
    $g_bProcessing = False
EndFunc

; Datei öffnen
Func _HandleFileOpen()
    Local $sFilePath = FileOpenDialog("ZIP-Datei öffnen", "", "ZIP (*.zip)")
    If @error Then Return
    
    Local $sFileName = StringTrimLeft($sFilePath, StringInStr($sFilePath, "\", 0, -1))
    _GUICtrlListView_AddItem($g_idListview, $sFileName)
    _GUICtrlListView_SetItemText($g_idListview, _GUICtrlListView_GetItemCount($g_idListview) - 1, 1, "Bereit")
    _GUICtrlListView_SetItemText($g_idListview, _GUICtrlListView_GetItemCount($g_idListview) - 1, 2, "0%")
EndFunc

; Arbeitsverzeichnis bereinigen
Func _CleanupWorkDir()
    Local $aFiles = _FileListToArray($g_sWorkingDir, "*.*", $FLTA_FILESFOLDERS)
    If Not @error Then
        For $i = 1 To $aFiles[0]
            FileDelete($g_sWorkingDir & "\" & $aFiles[$i])
        Next
    EndIf
EndFunc

; Aufräumen beim Beenden
Func _Cleanup()
    _Log_Write("Anwendung wird beendet")
    _MemoryManager_Cleanup()
    _CleanupWorkDir()
    DirRemove($g_sWorkingDir, 1)
EndFunc

; Programm starten
_Main()