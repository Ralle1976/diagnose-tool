#include-once
#include <GUIConstants.au3>
#include <GuiListView.au3>

Global $g_iCurrentItem = -1
Global $g_idListview = 0

Func _Progress_Init($idListview)
    $g_idListview = $idListview
EndFunc

Func _Progress_SetItem($iItem)
    $g_iCurrentItem = $iItem
EndFunc

Func _Progress_Update($iPercent)
    If $g_iCurrentItem = -1 Then Return
    
    ; Prozentsatz validieren
    If $iPercent < 0 Then $iPercent = 0
    If $iPercent > 100 Then $iPercent = 100
    
    ; Fortschritt aktualisieren
    _GUICtrlListView_SetItemText($g_idListview, $g_iCurrentItem, 2, $iPercent & "%")
    
    ; GUI aktualisieren ohne Blockierung
    GUISetState(@SW_SHOW)
EndFunc

Func _Progress_SetStatus($sStatus)
    If $g_iCurrentItem = -1 Then Return
    _GUICtrlListView_SetItemText($g_idListview, $g_iCurrentItem, 1, $sStatus)
    GUISetState(@SW_SHOW)
EndFunc