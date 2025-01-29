#include-once
#include <Array.au3>
#include <Date.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include <IniConstants.au3>

Global Enum $FILTER_TYPE_TEXT, $FILTER_TYPE_NUMBER, $FILTER_TYPE_DATE
Global $g_aOperators[] = ["=", "<>", ">", "<", ">=", "<=", "LIKE", "BETWEEN"]
Global $g_aFilterPresets[0][3]  ; Name, Bedingung, SQL

Func _AdvFilter_Show($aColumns)
    Local $hGUI = GUICreate("Erweiterter Filter", 600, 400)
    
    ; Filter-Bereich
    GUICtrlCreateGroup("Filter-Bedingungen", 10, 10, 580, 280)
    
    ; Spaltenauswahl
    GUICtrlCreateLabel("Spalte:", 20, 30, 50, 20)
    Local $idColumn = GUICtrlCreateCombo("", 70, 30, 150, 20)
    _GUICtrlComboBox_AddArray($idColumn, $aColumns)
    
    ; Operator
    GUICtrlCreateLabel("Operator:", 230, 30, 60, 20)
    Local $idOperator = GUICtrlCreateCombo("", 290, 30, 80, 20)
    _GUICtrlComboBox_AddArray($idOperator, $g_aOperators)
    
    ; Wertebereich
    GUICtrlCreateLabel("Wert:", 380, 30, 40, 20)
    Local $idValue1 = GUICtrlCreateInput("", 420, 30, 80, 20)
    Local $idValue2 = GUICtrlCreateInput("", 510, 30, 80, 20)
    GUICtrlSetState($idValue2, $GUI_HIDE)
    
    ; Typ-Erkennung
    Local $idTypeAuto = GUICtrlCreateCheckbox("Automatische Typ-Erkennung", 20, 60, 150, 20)
    GUICtrlSetState($idTypeAuto, $GUI_CHECKED)
    
    ; Vorschau-Bereich
    Local $idPreview = GUICtrlCreateEdit("", 20, 90, 560, 190, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL))
    
    ; Vorlagen-Verwaltung
    GUICtrlCreateGroup("Filter-Vorlagen", 10, 300, 580, 90)
    Local $idPresetName = GUICtrlCreateInput("", 20, 320, 150, 20)
    Local $idBtnSave = GUICtrlCreateButton("Speichern", 180, 320, 80, 20)
    Local $idBtnLoad = GUICtrlCreateButton("Laden", 270, 320, 80, 20)
    Local $idBtnDelete = GUICtrlCreateButton("Löschen", 360, 320, 80, 20)
    
    ; Hauptbuttons
    Local $idBtnApply = GUICtrlCreateButton("Anwenden", 420, 360, 80, 25)
    Local $idBtnCancel = GUICtrlCreateButton("Abbrechen", 510, 360, 80, 25)
    
    GUISetState(@SW_SHOW, $hGUI)
    
    ; Event Loop
    Local $bResult = False, $sFilter = ""
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idBtnCancel
                ExitLoop
                
            Case $idBtnApply
                $sFilter = _AdvFilter_BuildFilter( _
                    GUICtrlRead($idColumn), _
                    GUICtrlRead($idOperator), _
                    GUICtrlRead($idValue1), _
                    GUICtrlRead($idValue2), _
                    (GUICtrlRead($idTypeAuto) = $GUI_CHECKED))
                $bResult = True
                ExitLoop
                
            Case $idOperator
                ; BETWEEN-Operator zeigt zweites Wertefeld
                If GUICtrlRead($idOperator) = "BETWEEN" Then
                    GUICtrlSetState($idValue2, $GUI_SHOW)
                Else
                    GUICtrlSetState($idValue2, $GUI_HIDE)
                EndIf
                
            Case $idBtnSave
                _AdvFilter_SavePreset( _
                    GUICtrlRead($idPresetName), _
                    GUICtrlRead($idColumn) & "|" & GUICtrlRead($idOperator) & "|" & GUICtrlRead($idValue1) & "|" & GUICtrlRead($idValue2), _
                    _AdvFilter_BuildFilter(GUICtrlRead($idColumn), GUICtrlRead($idOperator), GUICtrlRead($idValue1), GUICtrlRead($idValue2), True))
                    
            Case $idBtnLoad
                Local $aPreset = _AdvFilter_LoadPreset(GUICtrlRead($idPresetName))
                If IsArray($aPreset) Then
                    Local $aValues = StringSplit($aPreset[1], "|")
                    GUICtrlSetData($idColumn, $aValues[1])
                    GUICtrlSetData($idOperator, $aValues[2])
                    GUICtrlSetData($idValue1, $aValues[3])
                    GUICtrlSetData($idValue2, $aValues[4])
                EndIf
                
            Case $idBtnDelete
                _AdvFilter_DeletePreset(GUICtrlRead($idPresetName))
        EndSwitch
    WEnd
    
    GUIDelete($hGUI)
    Return SetError(Not $bResult, 0, $sFilter)
EndFunc

Func _AdvFilter_BuildFilter($sColumn, $sOperator, $sValue1, $sValue2, $bAutoType = True)
    If $sColumn = "" Or $sOperator = "" Then Return ""
    
    Local $sFilter = ""
    Local $iType = $FILTER_TYPE_TEXT
    
    ; Typ-Erkennung wenn aktiviert
    If $bAutoType Then
        If StringRegExp($sValue1, "^\d+\.?\d*$") Then
            $iType = $FILTER_TYPE_NUMBER
        ElseIf StringRegExp($sValue1, "^\d{2}\.\d{2}\.\d{4}$") Then
            $iType = $FILTER_TYPE_DATE
        EndIf
    EndIf
    
    ; Werte entsprechend formatieren
    Switch $iType
        Case $FILTER_TYPE_NUMBER
            ; Numerische Werte direkt verwenden
            $sFilter = $sColumn & " " & $sOperator & " " & $sValue1
            If $sOperator = "BETWEEN" And $sValue2 <> "" Then
                $sFilter &= " AND " & $sValue2
            EndIf
            
        Case $FILTER_TYPE_DATE
            ; Datum in SQL-Format konvertieren
            Local $sDate1 = _AdvFilter_FormatDate($sValue1)
            $sFilter = $sColumn & " " & $sOperator & " '" & $sDate1 & "'"
            If $sOperator = "BETWEEN" And $sValue2 <> "" Then
                Local $sDate2 = _AdvFilter_FormatDate($sValue2)
                $sFilter &= " AND '" & $sDate2 & "'"
            EndIf
            
        Case Else
            ; Text mit Anführungszeichen
            If $sOperator = "LIKE" Then
                $sValue1 = StringReplace($sValue1, "*", "%")
                $sFilter = $sColumn & " LIKE '%" & $sValue1 & "%'"
            Else
                $sFilter = $sColumn & " " & $sOperator & " '" & $sValue1 & "'"
                If $sOperator = "BETWEEN" And $sValue2 <> "" Then
                    $sFilter &= " AND '" & $sValue2 & "'"
                EndIf
            EndIf
    EndSwitch
    
    Return $sFilter
EndFunc

Func _AdvFilter_FormatDate($sDate)
    Local $aDate = StringSplit($sDate, ".")
    If UBound($aDate) <> 4 Then Return ""
    Return $aDate[3] & "-" & $aDate[2] & "-" & $aDate[1]
EndFunc

Func _AdvFilter_SavePreset($sName, $sCondition, $sSQL)
    If $sName = "" Then Return SetError(1)
    
    Local $sFile = @ScriptDir & "\filter_presets.ini"
    IniWrite($sFile, $sName, "condition", $sCondition)
    IniWrite($sFile, $sName, "sql", $sSQL)
    _AdvFilter_LoadPresets()
EndFunc

Func _AdvFilter_LoadPreset($sName)
    If $sName = "" Then Return SetError(1)
    
    For $i = 0 To UBound($g_aFilterPresets) - 1
        If $g_aFilterPresets[$i][0] = $sName Then
            Return $g_aFilterPresets[$i]
        EndIf
    Next
    
    Return SetError(1)
EndFunc

Func _AdvFilter_DeletePreset($sName)
    If $sName = "" Then Return SetError(1)
    
    Local $sFile = @ScriptDir & "\filter_presets.ini"
    IniDelete($sFile, $sName)
    _AdvFilter_LoadPresets()
EndFunc

Func _AdvFilter_LoadPresets()
    Local $sFile = @ScriptDir & "\filter_presets.ini"
    If Not FileExists($sFile) Then Return
    
    Local $aSections = IniReadSectionNames($sFile)
    If @error Then Return
    
    ReDim $g_aFilterPresets[$aSections[0]][3]
    
    For $i = 1 To $aSections[0]
        $g_aFilterPresets[$i-1][0] = $aSections[$i]
        $g_aFilterPresets[$i-1][1] = IniRead($sFile, $aSections[$i], "condition", "")
        $g_aFilterPresets[$i-1][2] = IniRead($sFile, $aSections[$i], "sql", "")
    Next
EndFunc