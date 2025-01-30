#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include "lib/context_menu.au3"
#include "lib/sqlite_handler.au3"
#include "lib/memory_manager.au3"
#include "lib/error_handler.au3"
#include "lib/listview_layout.au3"
#include "lib/drag_drop_handler.au3"
#include "lib/status_handler.au3"

; Globale Variablen
Global $g_hGUI, $g_hListView
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
    
    ; Erweiterte Statusleiste initialisieren
    InitStatusBar($g_hGUI, 800)
    ShowTempStatus("Anwendung gestartet", 3000)
    
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
                UpdateMainStatus("Verarbeite Dateien...")
                UpdateItemCount(_GUICtrlListView_GetItemCount($g_hListView))
        EndSwitch
    WEnd
    
    ; Aufräumen
    _MemoryManager_Cleanup()
    _PasswordManager_Cleanup()
    _StatusHandler_Cleanup()
    GUIDelete($g_hGUI)
EndFunc

; Event-Handler für Fenstergrößenänderung
Func GUI_WM_SIZE_Handler($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $wParam
    If $hWnd = $g_hGUI Then
        ; Hole neue Fenstermaße
        Local $aPos = WinGetPos($g_hGUI)
        If Not @error Then
            ; Aktualisiere ListView und Statusleiste
            ResizeListView($g_hListView, $g_hGUI)
            _GUICtrlStatusBar_SetParts($g_hStatusBar, _
                Int($aPos[2] * 0.4), _
                Int($aPos[2] * 0.25), _
                Int($aPos[2] * 0.2), _
                -1)
        EndIf
        Return $GUI_RUNDEFMSG
    EndIf
EndFunc

; Event-Handler für Drag & Drop
Func GUI_WM_DROPFILES_Handler($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $lParam
    
    If $hWnd = $g_hGUI Then
        UpdateMainStatus("Verarbeite Dateien...")
        ShowStatusProgress(0)
        
        ; Verarbeite gedropte Dateien
        Local $bSuccess = HandleFileDrop($hWnd, $wParam)
        
        ; Aktualisiere Status
        If $bSuccess Then
            ShowTempStatus("Dateien erfolgreich verarbeitet", 3000)
            UpdateItemCount(_GUICtrlListView_GetItemCount($g_hListView))
        Else
            ShowTempStatus("Fehler beim Verarbeiten der Dateien", 3000)
        EndIf
        
        Return True
    EndIf
    
    Return $GUI_RUNDEFMSG
EndFunc

; Restliche Funktionen bleiben unverändert...