#include-once
#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include <GuiListView.au3>
#include <Array.au3>
#include "error_handler.au3"
#include "logging.au3"
#include "advanced_filter_core.au3"

; GUI Elemente
Global $g_hFilterGUI, $g_hColumnCombo, $g_hOperatorCombo, $g_hValueInput
Global $g_hFilterList, $g_hAddButton, $g_hRemoveButton, $g_hApplyButton

; Filter GUI erstellen
Func _Filter_ShowDialog($aColumns)
    ; Hauptfenster
    $g_hFilterGUI = GUICreate("Erweiterte Filter", 500, 400)
    
    ; Spaltenauswahl
    GUICtrlCreateLabel("Spalte:", 10, 10, 50, 20)
    $g_hColumnCombo = GUICtrlCreateCombo("", 70, 10, 150, 20)
    _GUICtrlComboBox_AddArray($g_hColumnCombo, $aColumns)
    
    ; Operator
    GUICtrlCreateLabel("Operator:", 10, 40, 50, 20)
    $g_hOperatorCombo = GUICtrlCreateCombo("", 70, 40, 150, 20)
    _GUICtrlComboBox_AddArray($g_hOperatorCombo, _Filter_GetOperatorArray())
    
    ; Wert
    GUICtrlCreateLabel("Wert:", 10, 70, 50, 20)
    $g_hValueInput = GUICtrlCreateInput("", 70, 70, 150, 20)
    
    ; Filter Liste
    $g_hFilterList = GUICtrlCreateList("", 10, 100, 480, 200)
    
    ; Buttons
    $g_hAddButton = GUICtrlCreateButton("Hinzufügen", 10, 310, 100, 30)
    $g_hRemoveButton = GUICtrlCreateButton("Entfernen", 120, 310, 100, 30)
    $g_hApplyButton = GUICtrlCreateButton("Anwenden", 390, 310, 100, 30)
    
    GUISetState(@SW_SHOW, $g_hFilterGUI)
    
    ; Event Loop
    While 1
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                GUIDelete($g_hFilterGUI)
                Return False
                
            Case $g_hAddButton
                _Filter_AddCondition()
                
            Case $g_hRemoveButton
                _Filter_RemoveCondition()
                
            Case $g_hApplyButton
                GUIDelete($g_hFilterGUI)
                Return True
        EndSwitch
    WEnd
EndFunc

; Filter-Bedingung hinzufügen
Func _Filter_AddCondition()
    Local $sColumn = GUICtrlRead($g_hColumnCombo)
    Local $iOperator = _GUICtrlComboBox_GetCurSel($g_hOperatorCombo)
    Local $sValue = GUICtrlRead($g_hValueInput)
    
    ; Validierung
    If $sColumn = "" Or $sValue = "" Then
        _ErrorHandler_HandleError($ERROR_TYPE_INPUT, "Bitte alle Felder ausfüllen", $ERROR_LEVEL_WARNING)
        Return False
    EndIf
    
    ; Filter hinzufügen
    _Filter_AddToSettings($sColumn, $iOperator, $sValue)
    
    ; Liste aktualisieren
    _Filter_UpdateList()
    
    ; Eingabefelder zurücksetzen
    GUICtrlSetData($g_hValueInput, "")
    
    Return True
EndFunc

; Filter-Bedingung entfernen
Func _Filter_RemoveCondition()
    Local $iIndex = _GUICtrlListBox_GetCurSel($g_hFilterList)
    If $iIndex = -1 Then Return
    
    _Filter_RemoveFromSettings($iIndex)
    _Filter_UpdateList()
EndFunc

; Filter-Liste aktualisieren
Func _Filter_UpdateList()
    GUICtrlSetData($g_hFilterList, "")
    
    Local $aSettings = _Filter_GetSettings()
    For $i = 0 To UBound($aSettings) - 1
        Local $sOperator = _Filter_GetOperatorText($aSettings[$i][1])
        Local $sLine = $aSettings[$i][0] & " " & $sOperator & " " & $aSettings[$i][2]
        GUICtrlSetData($g_hFilterList, $sLine)
    Next
EndFunc