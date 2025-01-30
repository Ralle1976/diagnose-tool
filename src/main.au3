#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include "lib/context_menu.au3"
#include "lib/sqlite_handler.au3"
#include "lib/memory_manager.au3"
#include "lib/error_handler.au3"
#include "lib/listview_layout.au3"
#include "lib/drag_drop_handler.au3"

; Globale Variablen
Global $g_hGUI, $g_hListView, $g_hStatusBar
Global $g_hContextMenu

Func Main()
    ; GUI erstellen
    $g_hGUI = GUICreate("Diagnose-Tool", 800, 600)
    
    ; Drag & Drop aktivieren
    EnableDragDrop($g_hGUI)
    
    ; Hauptmenü erstellen
    CreateMainMenu()
    
    ; ListView erstellen
    $g_hListView = GUICtrlCreateListView("Spalte 1|Spalte 2|Spalte 3", 10, 10, 780, 540)
    
    ; Layout-Optimierungen anwenden
    EnableAlternatingRows($g_hListView)
    OptimizeColumnWidths($g_hListView)
    
    ; Kontextmenü für ListView
    $g_hContextMenu = CreateListViewContextMenu($g_hListView)
    
    ; Statusleiste erstellen
    $g_hStatusBar = _GUICtrlStatusBar_Create($g_hGUI)
    _GUICtrlStatusBar_SetText($g_hStatusBar, "Bereit - Dateien hierher ziehen")
    
    ; Event-Handler registrieren
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY_Handler")
    GUIRegisterMsg($WM_COMMAND, "HandleContextMenuEvent")
    GUIRegisterMsg($WM_SIZE, "GUI_WM_SIZE_Handler")
    GUIRegisterMsg($WM_DROPFILES, "GUI_WM_DROPFILES_Handler")
    
    ; GUI anzeigen
    GUISetState(@SW_SHOW, $g_hGUI)
    
    ; Hauptschleife
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $GUI_EVENT_DROPPED
                _LogMessage("Dateien wurden gedroppt")
        EndSwitch
    WEnd
    
    ; Aufräumen
    _MemoryManager_Cleanup()
    _PasswordManager_Cleanup()
    GUIDelete($g_hGUI)
EndFunc

; Event-Handler für Drag & Drop
Func GUI_WM_DROPFILES_Handler($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $lParam
    
    If $hWnd = $g_hGUI Then
        ; Setze Status
        _GUICtrlStatusBar_SetText($g_hStatusBar, "Verarbeite Dateien...")
        
        ; Verarbeite gedropte Dateien
        Local $bSuccess = HandleFileDrop($hWnd, $wParam)
        
        ; Aktualisiere Status
        If $bSuccess Then
            _GUICtrlStatusBar_SetText($g_hStatusBar, "Dateien erfolgreich verarbeitet")
        Else
            _GUICtrlStatusBar_SetText($g_hStatusBar, "Fehler beim Verarbeiten der Dateien")
        EndIf
        
        Return True
    EndIf
    
    Return $GUI_RUNDEFMSG
EndFunc

[... Rest der Datei bleibt gleich ...]