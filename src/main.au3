#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include "lib/context_menu.au3"
#include "lib/sqlite_handler.au3"
#include "lib/memory_manager.au3"
#include "lib/error_handler.au3"

; Globale Variablen
Global $g_hGUI, $g_hListView, $g_hStatusBar
Global $g_hContextMenu

Func Main()
    ; GUI erstellen
    $g_hGUI = GUICreate("Diagnose-Tool", 800, 600)
    
    ; Hauptmenü erstellen
    CreateMainMenu()
    
    ; ListView erstellen
    $g_hListView = GUICtrlCreateListView("Spalte 1|Spalte 2|Spalte 3", 10, 10, 780, 540)
    
    ; Kontextmenü für ListView
    $g_hContextMenu = CreateListViewContextMenu($g_hListView)
    
    ; Statusleiste erstellen
    $g_hStatusBar = _GUICtrlStatusBar_Create($g_hGUI)
    _GUICtrlStatusBar_SetText($g_hStatusBar, "Bereit")
    
    ; Event-Handler registrieren
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY_Handler")
    GUIRegisterMsg($WM_COMMAND, "HandleContextMenuEvent")
    
    ; GUI anzeigen
    GUISetState(@SW_SHOW, $g_hGUI)
    
    ; Hauptschleife
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
        EndSwitch
    WEnd
    
    ; Aufräumen
    _MemoryManager_Cleanup()
    GUIDelete($g_hGUI)
EndFunc

Func CreateMainMenu()
    Local $hFile = GUICtrlCreateMenu("&Datei")
    GUICtrlCreateMenuItem("Öffnen...", $hFile)
    GUICtrlCreateMenuItem("", $hFile) ; Separator
    GUICtrlCreateMenuItem("Beenden", $hFile)
    
    Local $hView = GUICtrlCreateMenu("&Ansicht")
    GUICtrlCreateMenuItem("Aktualisieren", $hView)
    GUICtrlCreateMenuItem("Filter...", $hView)
    
    Local $hHelp = GUICtrlCreateMenu("&Hilfe")
    GUICtrlCreateMenuItem("Über...", $hHelp)
EndFunc

Func WM_NOTIFY_Handler($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $wParam
    Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    Local $hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
    Local $iCode = DllStructGetData($tNMHDR, "Code")
    
    Switch $hWndFrom
        Case $g_hListView
            Switch $iCode
                Case $NM_RCLICK
                    ; Kontextmenü anzeigen
                    Local $aPos = MouseGetPos()
                    _TrackPopupMenu($g_hContextMenu, $aPos[0], $aPos[1], $hWnd)
                    Return True
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc

; Programm starten
Main()