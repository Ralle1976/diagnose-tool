#include-once
#include <GUIListView.au3>
#include <Array.au3>

Global $g_aSortInfo[2]  ; [0] = Spaltenindex, [1] = Sortierrichtung (0=aufsteigend, 1=absteigend)

Func _ListSort_Init()
    $g_aSortInfo[0] = -1  ; Keine Spalte ausgewählt
    $g_aSortInfo[1] = 0   ; Aufsteigend
EndFunc

Func _ListSort_HandleHeaderClick($idListview, $iColumn)
    ; Gleiche Spalte = Richtung ändern
    If $iColumn = $g_aSortInfo[0] Then
        $g_aSortInfo[1] = Not $g_aSortInfo[1]
    Else
        ; Neue Spalte = Aufsteigend beginnen
        $g_aSortInfo[0] = $iColumn
        $g_aSortInfo[1] = 0
    EndIf
    
    ; Header-Pfeile aktualisieren
    _UpdateSortArrows($idListview)
    
    Return $g_aSortInfo
EndFunc

Func _ListSort_Apply($idListview, $iColumn, $iSortType = 0)
    Local $aItems[_GUICtrlListView_GetItemCount($idListview)][2]
    
    ; Daten sammeln
    For $i = 0 To UBound($aItems) - 1
        $aItems[$i][0] = _GUICtrlListView_GetItemText($idListview, $i, $iColumn)
        $aItems[$i][1] = $i
    Next
    
    ; Sortiertyp bestimmen
    Switch $iSortType
        Case 1 ; Numerisch
            _ArraySort($aItems, $g_aSortInfo[1], 0, 0, 0)
        Case 2 ; Datum (DD.MM.YYYY)
            _ArraySort($aItems, $g_aSortInfo[1], 0, 0, 2)
        Case Else ; Text
            _ArraySort($aItems, $g_aSortInfo[1], 0, 0, 1)
    EndSwitch
    
    ; Listview neu aufbauen
    Local $aTemp[_GUICtrlListView_GetItemCount($idListview)][$g_iColumnCount]
    For $i = 0 To UBound($aItems) - 1
        Local $iOriginalIndex = $aItems[$i][1]
        For $j = 0 To $g_iColumnCount - 1
            $aTemp[$i][$j] = _GUICtrlListView_GetItemText($idListview, $iOriginalIndex, $j)
        Next
    Next
    
    ; ListView leeren und neu füllen
    _GUICtrlListView_DeleteAllItems($idListview)
    For $i = 0 To UBound($aTemp) - 1
        _GUICtrlListView_AddItem($idListview, $aTemp[$i][0])
        For $j = 1 To $g_iColumnCount - 1
            _GUICtrlListView_AddSubItem($idListview, $i, $aTemp[$i][$j], $j)
        Next
    Next
EndFunc

Func _UpdateSortArrows($idListview)
    ; Alte Pfeile entfernen
    Local $iColumnCount = _GUICtrlListView_GetColumnCount($idListview)
    For $i = 0 To $iColumnCount - 1
        _GUICtrlListView_SetColumnHeaderImage($idListview, $i, -1)
    Next
    
    ; Neuen Pfeil setzen
    If $g_aSortInfo[0] >= 0 Then
        Local $iArrow = $g_aSortInfo[1] ? 1 : 0  ; 0=auf, 1=ab
        _GUICtrlListView_SetColumnHeaderImage($idListview, $g_aSortInfo[0], $iArrow)
    EndIf
EndFunc