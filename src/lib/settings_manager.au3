#include-once
#include <GUIConstantsEx.au3>
#include "logging.au3"

Func _Settings_ShowDialog()
    Local $hSettingsGUI = GUICreate("Einstellungen", 400, 300)
    
    ; ZIP-Einstellungen
    GUICtrlCreateGroup("ZIP-Einstellungen", 10, 10, 380, 80)
    GUICtrlCreateLabel("Passwort:", 20, 35, 60, 20)
    Local $idPassword = GUICtrlCreateInput(IniRead($g_sSettingsFile, "ZIP", "password", ""), 90, 32, 290, 20, $ES_PASSWORD)
    GUICtrlCreateLabel("Passwort anzeigen", 20, 60, 100, 20)
    Local $idShowPW = GUICtrlCreateCheckbox("", 120, 60, 20, 20)
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    
    ; Datenbank-Einstellungen
    GUICtrlCreateGroup("Datenbank-Einstellungen", 10, 100, 380, 80)
    GUICtrlCreateLabel("Max. Zeilen:", 20, 125, 70, 20)
    Local $idMaxRows = GUICtrlCreateInput(IniRead($g_sSettingsFile, "DATABASE", "max_rows", "1000"), 90, 122, 100, 20, $ES_NUMBER)
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    
    ; Buttons
    Local $idOK = GUICtrlCreateButton("OK", 230, 260, 75, 25)
    Local $idCancel = GUICtrlCreateButton("Abbrechen", 315, 260, 75, 25)
    
    GUISetState(@SW_SHOW, $hSettingsGUI)
    
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idCancel
                GUIDelete($hSettingsGUI)
                Return False
                
            Case $idShowPW
                If BitAND(GUICtrlRead($idShowPW), $GUI_CHECKED) Then
                    GUICtrlSetStyle($idPassword, -1, BitXOR($ES_PASSWORD, $ES_PASSWORD))
                Else
                    GUICtrlSetStyle($idPassword, -1, BitOR($ES_PASSWORD, $ES_PASSWORD))
                EndIf
                
            Case $idOK
                ; Einstellungen speichern
                IniWrite($g_sSettingsFile, "ZIP", "password", GUICtrlRead($idPassword))
                IniWrite($g_sSettingsFile, "DATABASE", "max_rows", GUICtrlRead($idMaxRows))
                _LogInfo("Einstellungen gespeichert")
                GUIDelete($hSettingsGUI)
                Return True
        EndSwitch
    WEnd
EndFunc