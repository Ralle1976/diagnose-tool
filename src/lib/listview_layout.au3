#include-once
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include "error_handler.au3"

; Konstanten für das Layout
Global Const $MIN_COLUMN_WIDTH = 50
Global Const $MAX_COLUMN_WIDTH = 300
Global Const $DEFAULT_COLUMN_WIDTH = 100

; Optimiert die Spaltenbreiten basierend auf dem Inhalt
Func OptimizeColumnWidths($hListView)
    Local $iColumns = _GUICtrlListView_GetColumnCount($hListView)
    If $iColumns = 0 Then Return
    
    ; Für jede Spalte
    For $i = 0 To $iColumns - 1
        ; Breite an Inhalt anpassen
        _GUICtrlListView_SetColumnWidth($hListView, $i, $LVSCW_AUTOSIZE)
        
        ; Minimum/Maximum Breite sicherstellen
        Local $iWidth = _GUICtrlListView_GetColumnWidth($hListView, $i)
        If $iWidth < $MIN_COLUMN_WIDTH Then
            _GUICtrlListView_SetColumnWidth($hListView, $i, $MIN_COLUMN_WIDTH)
        ElseIf $iWidth > $MAX_COLUMN_WIDTH Then
            _GUICtrlListView_SetColumnWidth($hListView, $i, $MAX_COLUMN_WIDTH)
        EndIf
    Next
EndFunc

; Passt die ListView-Größe an das Fenster an
Func ResizeListView($hListView, $hGUI)
    Local $aClientSize = WinGetClientSize($hGUI)
    If @error Then Return False
    
    ; Berücksichtige Margins und andere UI-Elemente
    Local $iMargin = 10
    Local $iStatusBarHeight = 20
    
    ; Setze neue Größe
    _GUICtrlListView_SetPos($hListView, _
        $iMargin, _
        $iMargin, _
        $aClientSize[0] - 2 * $iMargin, _
        $aClientSize[1] - $iStatusBarHeight - 2 * $iMargin)
        
    ; Spaltenbreiten neu berechnen
    OptimizeColumnWidths($hListView)
EndFunc

; Aktiviert alternierende Zeilenfarben
Func EnableAlternatingRows($hListView)
    ; Setze Custom Draw Style
    Local $iStyle = _GUICtrlListView_GetExtendedListViewStyle($hListView)
    _GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR($iStyle, $LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES))
    
    ; Handler für Custom Draw
    GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY_Handler")
EndFunc

; Event-Handler für Custom Draw
Func _WM_NOTIFY_Handler($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $wParam
    Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    Local $hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
    Local $iCode = DllStructGetData($tNMHDR, "Code")
    
    Switch $hWndFrom
        Case $g_hListView
            Switch $iCode
                Case $NM_CUSTOMDRAW
                    Local $tNMLVCUSTOMDRAW = DllStructCreate($tagNMLVCUSTOMDRAW, $lParam)
                    Local $iDrawStage = DllStructGetData($tNMLVCUSTOMDRAW, "dwDrawStage")
                    
                    Switch $iDrawStage
                        Case $CDDS_PREPAINT
                            Return $CDRF_NOTIFYITEMDRAW
                            
                        Case $CDDS_ITEMPREPAINT
                            Local $iItem = DllStructGetData($tNMLVCUSTOMDRAW, "dwItemSpec")
                            ; Alternierende Farben
                            If Mod($iItem, 2) = 0 Then
                                DllStructSetData($tNMLVCUSTOMDRAW, "clrTextBk", 0xF8F8F8) ; Hellgrau
                            Else
                                DllStructSetData($tNMLVCUSTOMDRAW, "clrTextBk", 0xFFFFFF) ; Weiß
                            EndIf
                            Return $CDRF_NEWFONT
                    EndSwitch
            EndSwitch
    EndSwitch
    
    Return $GUI_RUNDEFMSG
EndFunc

; Zeigt Sortierungspfeile in den Spaltenüberschriften
Func SetColumnSortArrow($hListView, $iColumn, $bAscending)
    Local $iColumns = _GUICtrlListView_GetColumnCount($hListView)
    
    ; Entferne bestehende Pfeile
    For $i = 0 To $iColumns - 1
        _GUICtrlListView_SetHeaderFormat($hListView, $i, $HDF_STRING)
    Next
    
    ; Setze neuen Pfeil
    If $bAscending Then
        _GUICtrlListView_SetHeaderFormat($hListView, $iColumn, BitOR($HDF_STRING, $HDF_SORTUP))
    Else
        _GUICtrlListView_SetHeaderFormat($hListView, $iColumn, BitOR($HDF_STRING, $HDF_SORTDOWN))
    EndIf
EndFunc