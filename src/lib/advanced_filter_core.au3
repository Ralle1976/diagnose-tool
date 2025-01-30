#include-once
#include <Array.au3>
#include <Date.au3>
#include "error_handler.au3"

; Filter Typen
Global Const $FILTER_TYPE_TEXT = 1
Global Const $FILTER_TYPE_NUMBER = 2
Global Const $FILTER_TYPE_DATE = 3

; Filter Operatoren
Global Enum $OPERATOR_EQUALS, $OPERATOR_NOT_EQUALS, $OPERATOR_CONTAINS, _
           $OPERATOR_NOT_CONTAINS, $OPERATOR_GREATER, $OPERATOR_LESS, _
           $OPERATOR_GREATER_EQUALS, $OPERATOR_LESS_EQUALS

; Filter-Einstellungen
Global $g_aFilterSettings[0][4]  ; [Spalte, Operator, Wert, Typ]

; Filter-Einstellungen abrufen
Func _Filter_GetSettings()
    Return $g_aFilterSettings
EndFunc

; Filter hinzufügen
Func _Filter_AddToSettings($sColumn, $iOperator, $sValue)
    Local $iType = _Filter_DetermineType($sValue)
    _ArrayAdd($g_aFilterSettings, [$sColumn, $iOperator, $sValue, $iType])
EndFunc

; Filter entfernen
Func _Filter_RemoveFromSettings($iIndex)
    _ArrayDelete($g_aFilterSettings, $iIndex)
EndFunc

; Operatoren-Array abrufen
Func _Filter_GetOperatorArray()
    Return ["Gleich", "Ungleich", "Enthält", "Enthält nicht", _
            "Größer als", "Kleiner als", "Größer gleich", "Kleiner gleich"]
EndFunc

; Operator-Text ermitteln
Func _Filter_GetOperatorText($iOperator)
    Local $aOperators = ["=", "≠", "enthält", "enthält nicht", ">", "<", "≥", "≤"]
    Return $aOperators[$iOperator]
EndFunc

; Filtertyp ermitteln
Func _Filter_DetermineType($sValue)
    ; Zahlenerkennung
    If StringRegExp($sValue, "^\d+$") Then Return $FILTER_TYPE_NUMBER
    
    ; Datumserkennung (Format: DD.MM.YYYY)
    If StringRegExp($sValue, "^\d{2}\.\d{2}\.\d{4}$") Then Return $FILTER_TYPE_DATE
    
    ; Standard: Text
    Return $FILTER_TYPE_TEXT
EndFunc

; Filter auf ListView anwenden
Func _Filter_ApplyToListView($hListView)
    Local $iItems = _GUICtrlListView_GetItemCount($hListView)
    
    ; Alle Items durchgehen
    For $i = $iItems - 1 To 0 Step -1
        If Not _Filter_CheckItem($hListView, $i) Then
            _GUICtrlListView_DeleteItem($hListView, $i)
        EndIf
    Next
    
    Return True
EndFunc

; Einzelnes Item prüfen
Func _Filter_CheckItem($hListView, $iIndex)
    ; Alle Filterbedingungen prüfen
    For $i = 0 To UBound($g_aFilterSettings) - 1
        Local $sColName = $g_aFilterSettings[$i][0]
        Local $iOperator = $g_aFilterSettings[$i][1]
        Local $sFilterValue = $g_aFilterSettings[$i][2]
        Local $iType = $g_aFilterSettings[$i][3]
        
        ; Spaltenindex finden
        Local $iColIndex = _GUICtrlListView_FindColumn($hListView, $sColName)
        If $iColIndex = -1 Then ContinueLoop
        
        ; Wert aus ListView holen
        Local $sItemValue = _GUICtrlListView_GetItemText($hListView, $iIndex, $iColIndex)
        
        ; Werte vergleichen
        If Not _Filter_CompareValues($sItemValue, $sFilterValue, $iOperator, $iType) Then
            Return False
        EndIf
    Next
    
    Return True
EndFunc

; Werte vergleichen
Func _Filter_CompareValues($sValue1, $sValue2, $iOperator, $iType)
    Switch $iType
        Case $FILTER_TYPE_NUMBER
            Return _Filter_CompareNumbers(Number($sValue1), Number($sValue2), $iOperator)
            
        Case $FILTER_TYPE_DATE
            Return _Filter_CompareDates($sValue1, $sValue2, $iOperator)
            
        Case Else
            Return _Filter_CompareText($sValue1, $sValue2, $iOperator)
    EndSwitch
EndFunc

; Zahlenvergleich
Func _Filter_CompareNumbers($nValue1, $nValue2, $iOperator)
    Switch $iOperator
        Case $OPERATOR_EQUALS
            Return $nValue1 = $nValue2
        Case $OPERATOR_NOT_EQUALS
            Return $nValue1 <> $nValue2
        Case $OPERATOR_GREATER
            Return $nValue1 > $nValue2
        Case $OPERATOR_LESS
            Return $nValue1 < $nValue2
        Case $OPERATOR_GREATER_EQUALS
            Return $nValue1 >= $nValue2
        Case $OPERATOR_LESS_EQUALS
            Return $nValue1 <= $nValue2
    EndSwitch
    Return False
EndFunc

; Datumsvergleich
Func _Filter_CompareDates($sDate1, $sDate2, $iOperator)
    Local $tDate1 = _DateStringToDate($sDate1)
    Local $tDate2 = _DateStringToDate($sDate2)
    Return _Filter_CompareNumbers($tDate1, $tDate2, $iOperator)
EndFunc

; Textvergleich
Func _Filter_CompareText($sText1, $sText2, $iOperator)
    Switch $iOperator
        Case $OPERATOR_EQUALS
            Return $sText1 = $sText2
        Case $OPERATOR_NOT_EQUALS
            Return $sText1 <> $sText2
        Case $OPERATOR_CONTAINS
            Return StringInStr($sText1, $sText2) > 0
        Case $OPERATOR_NOT_CONTAINS
            Return StringInStr($sText1, $sText2) = 0
    EndSwitch
    Return False
EndFunc