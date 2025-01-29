#include-once
#include <GUIConstants.au3>
#include <File.au3>
#include <Array.au3>
#include "lib/memory_manager.au3"
#include "lib/zip_handler.au3"
#include "lib/sqlite_handler.au3"
#include "lib/logging.au3"

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
    
    ; Arbeitsverzeichnis erstellen
    If Not FileExists($g_sWorkingDir) Then DirCreate($g_sWorkingDir)
    
    ; GUI erstellen
    $g_hGUI = GUICreate("Diagnose-Tool", 800, 600)
    $g_idListview = GUICtrlCreateListView("Datei|Status|Fortschritt", 10, 10, 780, 500)
    GUICtrlCreateButton("Datei öffnen", 10, 520, 100, 30)
    GUICtrlCreateButton("Verarbeiten", 120, 520, 100, 30)
    GUISetState(@SW_SHOW, $g_hGUI)
    
    ; Hauptschleife
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $idButton1
                _HandleFileOpen()
            Case $idButton2
                _ProcessFiles()
        WndSwitch
    EndSwitch
    
    ; Aufräumen
    _Cleanup()
    Exit
EndFunc

; Dateiverarbeitung
Func _ProcessFiles()
    If $g_bProcessing Then Return
    
    $g_bProcessing = True
    Local $aItems = _GUICtrlListView_GetItemCount($g_idListview)
    
    For $i = 0 To $aItems - 1
        Local $sFilePath = _GUICtrlListView_GetItemText($g_idListview, $i, 0)
        _GUICtrlListView_SetItemText($g_idListview, $i, 1, "Verarbeite...")
        
        ; ZIP-Datei verarbeiten
        Local $sExtractPath = _ZIP_Extract($sFilePath)
        If @error Then
            _GUICtrlListView_SetItemText($g_idListview, $i, 1, "Fehler: ZIP")
            ContinueLoop
        EndIf
        
        ; SQLite-DBs suchen und analysieren
        Local $aDBFiles = _FileListToArray($sExtractPath, "*.db", $FLTA_FILES)
        If Not @error Then
            For $j = 1 To $aDBFiles[0]
                Local $sDBPath = $sExtractPath & "\" & $aDBFiles[$j]
                _DB_Analyze($sDBPath)
                _MemoryManager_Cleanup()
            Next
        EndIf
        
        _GUICtrlListView_SetItemText($g_idListview, $i, 1, "Abgeschlossen")
        _MemoryManager_Cleanup()
    Next
    
    $g_bProcessing = False
EndFunc

; Aufräumen beim Beenden
Func _Cleanup()
    _Log_Write("Anwendung wird beendet")
    _MemoryManager_Cleanup()
    FileDelete($g_sWorkingDir)
EndFunc

; Drag & Drop Handler
Func _HandleFileOpen()
    Local $sFilePath = FileOpenDialog("ZIP-Datei öffnen", "", "ZIP (*.zip)")
    If @error Then Return
    
    Local $sFileName = StringTrimLeft($sFilePath, StringInStr($sFilePath, "\", 0, -1))
    _GUICtrlListView_AddItem($g_idListview, $sFileName)
    _GUICtrlListView_SetItemText($g_idListview, _GUICtrlListView_GetItemCount($g_idListview) - 1, 1, "Bereit")
    _GUICtrlListView_SetItemText($g_idListview, _GUICtrlListView_GetItemCount($g_idListview) - 1, 2, "0%")
EndFunc

; Programm starten
_Main()