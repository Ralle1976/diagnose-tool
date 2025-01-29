#include-once
#include <GuiListView.au3>
#include <Array.au3>

; Globale Sortierungsvariablen
Global $g_sortColumn = -1
Global $g_sortOrder = 1 ; 1 = aufsteigend, -1 = absteigend
Global $g_multiSortColumns[0][2] ; Array für Multi-Spalten-Sortierung [spalte][richtung]

Func EnableListViewSorting($hListView)
    _LogDebug("Aktiviere ListView Sortierung")
    
    ; Setze notify style für Header-Klicks
    Local $hHeader = _GUICtrlListView_GetHeader($hListView)
    If $hHeader Then
        Local $style = _WinAPI_GetWindowLong($hHeader, $GWL_STYLE)
        _WinAPI_SetWindowLong($hHeader, $GWL_STYLE, BitOR($style, $HDS_BUTTONS))
    EndIf
    
    ; Entferne NO_SORT style wenn gesetzt
    Local $lstyle = _GUICtrlListView_GetExtendedListViewStyle($hListView)
    _GUICtrlListView_SetExtendedListViewStyle($hListView, BitXOR($lstyle, $LVS_NOSORTHEADER))
EndFunc

Func HandleHeaderClick($hListView, $iColumn)
    _LogDebug("Header-Klick erkannt", "Spalte: " & $iColumn)
    
    ; Prüfe ob SHIFT gedrückt ist für Multi-Sortierung
    Local $multiSort = _IsPressed("10") ; SHIFT key
    
    If Not $multiSort Then
        ; Einzelspalten-Sortierung
        If $g_sortColumn = $iColumn Then
            ; Gleiche Spalte - Richtung umkehren
            $g_sortOrder *= -1
        Else
            ; Neue Spalte - Aufsteigend sortieren
            $g_sortColumn = $iColumn
            $g_sortOrder = 1
        EndIf
        
        ; Multi-Sort Array zurücksetzen
        ReDim $g_multiSortColumns[0][2]
    Else
        ; Multi-Spalten-Sortierung
        Local $found = False
        For $i = 0 To UBound($g_multiSortColumns) - 1
            If $g_multiSortColumns[$i][0] = $iColumn Then
                ; Spalte bereits in Sortierung - Richtung umkehren
                $g_multiSortColumns[$i][1] *= -1
                $found = True
                ExitLoop
            EndIf
        Next
        
        If Not $found Then
            ; Neue Spalte zur Multi-Sortierung hinzufügen
            ReDim $g_multiSortColumns[UBound($g_multiSortColumns) + 1][2]
            $g_multiSortColumns[UBound($g_multiSortColumns) - 1][0] = $iColumn
            $g_multiSortColumns[UBound($g_multiSortColumns) - 1][1] = 1
        EndIf
    EndIf
    
    ; Sortierung anwenden
    SortListView($hListView)
    
    ; Header-Pfeile aktualisieren
    UpdateSortArrows($hListView)
EndFunc

Func SortListView($hListView)
    _LogInfo("Sortiere ListView")
    
    ; Array für Sortierung erstellen
    Local $aItems[_GUICtrlListView_GetItemCount($hListView)][_GUICtrlListView_GetColumnCount($hListView) + 1]
    
    ; Daten in Array kopieren
    For $i = 0 To UBound($aItems) - 1
        ; Item-Text
        $aItems[$i][0] = _GUICtrlListView_GetItemText($hListView, $i)
        
        ; Sub-Items
        For $j = 1 To _GUICtrlListView_GetColumnCount($hListView) - 1
            $aItems[$i][$j] = _GUICtrlListView_GetItemText($hListView, $i, $j)
        Next
        
        ; Original-Index für stabile Sortierung
        $aItems[$i][UBound($aItems, 2) - 1] = $i
    Next
    
    ; Sortieren
    If UBound($g_multiSortColumns) > 0 Then
        ; Multi-Spalten-Sortierung
        _ArraySort($aItems, 0, 0, 0, $g_multiSortColumns[0][0], $g_multiSortColumns[0][1])
        
        For $i = 1 To UBound($g_multiSortColumns) - 1
            _ArraySort($aItems, 0, 0, 0, $g_multiSortColumns[$i][0], $g_multiSortColumns[$i][1])
        Next
    Else
        ; Einzelspalten-Sortierung
        If $g_sortColumn >= 0 Then
            _ArraySort($aItems, 0, 0, 0, $g_sortColumn, $g_sortOrder)
        EndIf
    EndIf
    
    ; ListView leeren
    _GUICtrlListView_DeleteAllItems($hListView)
    
    ; Sortierte Daten zurück in ListView
    For $i = 0 To UBound($aItems) - 1
        Local $iIndex = _GUICtrlListView_AddItem($hListView, $aItems[$i][0])
        For $j = 1 To _GUICtrlListView_GetColumnCount($hListView) - 1
            _GUICtrlListView_AddSubItem($hListView, $iIndex, $aItems[$i][$j], $j)
        Next
    Next
    
    _LogInfo("Sortierung abgeschlossen")
EndFunc

Func UpdateSortArrows($hListView)
    _LogDebug("Aktualisiere Sortierungspfeile")
    
    ; Header Handle
    Local $hHeader = _GUICtrlListView_GetHeader($hListView)
    If Not $hHeader Then Return
    
    ; Alle Spalten durchgehen
    For $i = 0 To _GUICtrlListView_GetColumnCount($hListView) - 1
        Local $format = $HDF_STRING
        
        If UBound($g_multiSortColumns) > 0 Then
            ; Multi-Sort Pfeile
            For $j = 0 To UBound($g_multiSortColumns) - 1
                If $g_multiSortColumns[$j][0] = $i Then
                    $format = BitOR($HDF_STRING, $g_multiSortColumns[$j][1] = 1 ? $HDF_SORTUP : $HDF_SORTDOWN)
                    ExitLoop
                EndIf
            Next
        Else
            ; Single-Sort Pfeil
            If $i = $g_sortColumn Then
                $format = BitOR($HDF_STRING, $g_sortOrder = 1 ? $HDF_SORTUP : $HDF_SORTDOWN)
            EndIf
        EndIf
        
        ; Format setzen
        Local $item = DllStructCreate($tagHDITEM)
        DllStructSetData($item, "Mask", $HDI_FORMAT)
        DllStructSetData($item, "Format", $format)
        _SendMessage($hHeader, $HDM_SETITEM, $i, DllStructGetPtr($item))
    Next
EndFunc

Func GetSortExpression($columnNames)
    _LogDebug("Erstelle SQL-Sortierausdruck")
    
    Local $sort = ""
    
    If UBound($g_multiSortColumns) > 0 Then
        ; Multi-Spalten-Sortierung
        For $i = 0 To UBound($g_multiSortColumns) - 1
            If $sort <> "" Then $sort &= ", "
            $sort &= $columnNames[$g_multiSortColumns[$i][0]] & ($g_multiSortColumns[$i][1] = 1 ? " ASC" : " DESC")
        Next
    Else
        ; Einzelspalten-Sortierung
        If $g_sortColumn >= 0 Then
            $sort = $columnNames[$g_sortColumn] & ($g_sortOrder = 1 ? " ASC" : " DESC")
        EndIf
    EndIf
    
    Return $sort
EndFunc