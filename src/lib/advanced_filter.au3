#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <Array.au3>
#include <File.au3>

; Globale Filter-Variablen
Global $g_filterHistory[0]
Global $g_currentFilter = ""
Global $g_filterPresets = ObjCreate("Scripting.Dictionary")
Global Const $MAX_HISTORY = 10
Global Const $FILTER_PRESET_FILE = @ScriptDir & "\filter_presets.ini"

; Enums für Vergleichsoperatoren
Global Enum $FILTER_EQUALS, $FILTER_CONTAINS, $FILTER_GREATER, $FILTER_LESS, $FILTER_BETWEEN, $FILTER_IN_LIST

Func ShowAdvancedFilter($columnNames)
    _LogInfo("Öffne erweiterten Filter")
    
    Local $hFilterGUI = GUICreate("Erweiterter Filter", 600, 400)
    
    ; Filter-Bedingungen
    GUICtrlCreateGroup("Filter-Bedingungen", 10, 10, 580, 200)
    Local $y = 30
    
    ; Erste Filter-Zeile
    Local $hColumn1 = GUICtrlCreateCombo("", 20, $y, 150, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hColumn1, _ArrayToString($columnNames, "|"), $columnNames[0])
    
    Local $hOperator1 = GUICtrlCreateCombo("", 180, $y, 100, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hOperator1, "ist gleich|enthält|größer als|kleiner als|zwischen|in Liste")
    
    Local $hValue1 = GUICtrlCreateInput("", 290, $y, 150, 20)
    Local $hValue1b = GUICtrlCreateInput("", 450, $y, 100, 20)
    GUICtrlSetState($hValue1b, $GUI_HIDE)
    
    ; AND/OR Dropdown
    $y += 30
    Local $hLogic1 = GUICtrlCreateCombo("", 20, $y, 80, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hLogic1, "UND|ODER")
    
    ; Zweite Filter-Zeile
    $y += 30
    Local $hColumn2 = GUICtrlCreateCombo("", 20, $y, 150, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hColumn2, _ArrayToString($columnNames, "|"), $columnNames[0])
    
    Local $hOperator2 = GUICtrlCreateCombo("", 180, $y, 100, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hOperator2, "ist gleich|enthält|größer als|kleiner als|zwischen|in Liste")
    
    Local $hValue2 = GUICtrlCreateInput("", 290, $y, 150, 20)
    Local $hValue2b = GUICtrlCreateInput("", 450, $y, 100, 20)
    GUICtrlSetState($hValue2b, $GUI_HIDE)
    
    ; Filter-Verlauf
    GUICtrlCreateGroup("Filter-Verlauf", 10, 220, 280, 120)
    Local $hHistory = GUICtrlCreateList("", 20, 240, 260, 90)
    LoadFilterHistory($hHistory)
    
    ; Filter-Vorlagen
    GUICtrlCreateGroup("Vorlagen", 300, 220, 290, 120)
    Local $hPresets = GUICtrlCreateList("", 310, 240, 200, 90)
    Local $hSavePreset = GUICtrlCreateButton("Speichern", 520, 240, 60, 25)
    Local $hDeletePreset = GUICtrlCreateButton("Löschen", 520, 270, 60, 25)
    LoadFilterPresets($hPresets)
    
    ; Buttons
    Local $hApply = GUICtrlCreateButton("Anwenden", 400, 360, 90, 30)
    Local $hCancel = GUICtrlCreateButton("Abbrechen", 500, 360, 90, 30)
    
    GUISetState(@SW_SHOW)
    
    ; Event-Handler für Operator-Änderungen
    GUICtrlSetOnEvent($hOperator1, "_OperatorChanged")
    GUICtrlSetOnEvent($hOperator2, "_OperatorChanged")
    
    Local $filterResult = ""
    
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $hCancel
                GUIDelete($hFilterGUI)
                Return ""
                
            Case $hApply
                $filterResult = BuildFilterExpression( _
                    GUICtrlRead($hColumn1), GUICtrlRead($hOperator1), GUICtrlRead($hValue1), GUICtrlRead($hValue1b), _
                    GUICtrlRead($hLogic1), _
                    GUICtrlRead($hColumn2), GUICtrlRead($hOperator2), GUICtrlRead($hValue2), GUICtrlRead($hValue2b))
                    
                If $filterResult <> "" Then
                    AddToFilterHistory($filterResult)
                    GUIDelete($hFilterGUI)
                    Return $filterResult
                EndIf
                
            Case $hSavePreset
                Local $presetName = InputBox("Vorlage speichern", "Namen für die Filtervorlage eingeben:")
                If Not @error And $presetName <> "" Then
                    SaveFilterPreset($presetName, _
                        GUICtrlRead($hColumn1), GUICtrlRead($hOperator1), GUICtrlRead($hValue1), GUICtrlRead($hValue1b), _
                        GUICtrlRead($hLogic1), _
                        GUICtrlRead($hColumn2), GUICtrlRead($hOperator2), GUICtrlRead($hValue2), GUICtrlRead($hValue2b))
                    LoadFilterPresets($hPresets)
                EndIf
                
            Case $hDeletePreset
                Local $selected = GUICtrlRead($hPresets)
                If $selected <> "" Then
                    DeleteFilterPreset($selected)
                    LoadFilterPresets($hPresets)
                EndIf
                
            Case $hHistory
                Local $selected = GUICtrlRead($hHistory)
                If $selected <> "" Then
                    LoadFilterFromHistory($selected, _
                        $hColumn1, $hOperator1, $hValue1, $hValue1b, _
                        $hLogic1, _
                        $hColumn2, $hOperator2, $hValue2, $hValue2b)
                EndIf
                
            Case $hPresets
                Local $selected = GUICtrlRead($hPresets)
                If $selected <> "" Then
                    LoadFilterPreset($selected, _
                        $hColumn1, $hOperator1, $hValue1, $hValue1b, _
                        $hLogic1, _
                        $hColumn2, $hOperator2, $hValue2, $hValue2b)
                EndIf
        EndSwitch
    WEnd
EndFunc

Func _OperatorChanged()
    Local $operator = GUICtrlRead(@GUI_CtrlId)
    Local $valueCtrl = Number(@GUI_CtrlId) + 2
    Local $valueBCtrl = $valueCtrl + 1
    
    Switch $operator
        Case "zwischen"
            GUICtrlSetState($valueBCtrl, $GUI_SHOW)
            GUICtrlSetPos($valueCtrl, 290, -1, 150)
        Case "in Liste"
            GUICtrlSetState($valueBCtrl, $GUI_HIDE)
            GUICtrlSetPos($valueCtrl, 290, -1, 260)
            GUICtrlSetTip($valueCtrl, "Werte mit Komma trennen")
        Case Else
            GUICtrlSetState($valueBCtrl, $GUI_HIDE)
            GUICtrlSetPos($valueCtrl, 290, -1, 260)
            GUICtrlSetTip($valueCtrl, "")
    EndSwitch
EndFunc

Func BuildFilterExpression($col1, $op1, $val1, $val1b, $logic, $col2, $op2, $val2, $val2b)
    _LogDebug("Erstelle Filter-Expression")
    
    Local $filter = ""
    
    ; Erste Bedingung
    $filter &= BuildCondition($col1, $op1, $val1, $val1b)
    
    ; Zweite Bedingung wenn vorhanden
    If $val2 <> "" Then
        $filter &= " " & $logic & " "
        $filter &= BuildCondition($col2, $op2, $val2, $val2b)
    EndIf
    
    Return $filter
EndFunc

Func BuildCondition($column, $operator, $value, $value2)
    Switch $operator
        Case "ist gleich"
            Return $column & " = '" & SQLiteEscape($value) & "'"
            
        Case "enthält"
            Return $column & " LIKE '%" & SQLiteEscape($value) & "%'"
            
        Case "größer als"
            Return $column & " > '" & SQLiteEscape($value) & "'"
            
        Case "kleiner als"
            Return $column & " < '" & SQLiteEscape($value) & "'"
            
        Case "zwischen"
            Return $column & " BETWEEN '" & SQLiteEscape($value) & "' AND '" & SQLiteEscape($value2) & "'"
            
        Case "in Liste"
            Local $values = StringSplit($value, ",", $STR_NOCOUNT)
            For $i = 0 To UBound($values) - 1
                $values[$i] = "'" & SQLiteEscape(StringStripWS($values[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING)) & "'"
            Next
            Return $column & " IN (" & _ArrayToString($values, ", ") & ")"
    EndSwitch
    
    Return ""
EndFunc

Func SQLiteEscape($value)
    Return StringReplace($value, "'", "''")
EndFunc

Func AddToFilterHistory($filter)
    _LogDebug("Füge Filter zum Verlauf hinzu")
    
    ; Prüfe ob Filter bereits existiert
    For $i = 0 To UBound($g_filterHistory) - 1
        If $g_filterHistory[$i] = $filter Then
            _ArrayDelete($g_filterHistory, $i)
            ExitLoop
        EndIf
    Next
    
    ; Füge neuen Filter hinzu
    _ArrayInsert($g_filterHistory, 0, $filter)
    
    ; Begrenze History-Größe
    If UBound($g_filterHistory) > $MAX_HISTORY Then
        ReDim $g_filterHistory[$MAX_HISTORY]
    EndIf
    
    SaveFilterHistory()
EndFunc

Func LoadFilterHistory($hList)
    _LogDebug("Lade Filter-Verlauf")
    
    GUICtrlSetData($hList, "")
    For $filter In $g_filterHistory
        GUICtrlSetData($hList, $filter)
    Next
EndFunc

Func SaveFilterPreset($name, $col1, $op1, $val1, $val1b, $logic, $col2, $op2, $val2, $val2b)
    _LogInfo("Speichere Filter-Vorlage", "Name: " & $name)
    
    Local $data = $col1 & "|" & $op1 & "|" & $val1 & "|" & $val1b & "|" & _
                  $logic & "|" & _
                  $col2 & "|" & $op2 & "|" & $val2 & "|" & $val2b
                  
    IniWrite($FILTER_PRESET_FILE, "Presets", $name, $data)
EndFunc

Func LoadFilterPresets($hList)
    _LogDebug("Lade Filter-Vorlagen")
    
    GUICtrlSetData($hList, "")
    Local $presets = IniReadSection($FILTER_PRESET_FILE, "Presets")
    If Not @error Then
        For $i = 1 To $presets[0][0]
            GUICtrlSetData($hList, $presets[$i][0])
        Next
    EndIf
EndFunc

Func LoadFilterPreset($name, $hCol1, $hOp1, $hVal1, $hVal1b, $hLogic, $hCol2, $hOp2, $hVal2, $hVal2b)
    _LogDebug("Lade Filter-Vorlage", "Name: " & $name)
    
    Local $data = IniRead($FILTER_PRESET_FILE, "Presets", $name, "")
    If $data = "" Then Return
    
    Local $parts = StringSplit($data, "|")
    If @error Then Return
    
    GUICtrlSetData($hCol1, $parts[1])
    GUICtrlSetData($hOp1, $parts[2])
    GUICtrlSetData($hVal1, $parts[3])
    GUICtrlSetData($hVal1b, $parts[4])
    GUICtrlSetData($hLogic, $parts[5])
    GUICtrlSetData($hCol2, $parts[6])
    GUICtrlSetData($hOp2, $parts[7])
    GUICtrlSetData($hVal2, $parts[8])
    GUICtrlSetData($hVal2b, $parts[9])
EndFunc

Func DeleteFilterPreset($name)
    _LogInfo("Lösche Filter-Vorlage", "Name: " & $name)
    IniDelete($FILTER_PRESET_FILE, "Presets", $name)
EndFunc