#include-once
#include <GUIConstants.au3>
#include <GuiListView.au3>
#include <SQLite.au3>

Global $g_hDB = 0             ; Database handle
Global $g_hGUI_Viewer = 0     ; Viewer GUI handle
Global $g_idListview = 0      ; Listview handle
Global $g_aTableHeaders[0]    ; Array für Spaltenüberschriften

Func _SQLiteViewer_Show($sDBPath)
    ; Datenbank öffnen
    $g_hDB = _SQLite_Open($sDBPath)
    If @error Then
        MsgBox(16, "Fehler", "Datenbank konnte nicht geöffnet werden: " & $sDBPath)
        Return SetError(1)
    EndIf
    
    ; GUI erstellen
    $g_hGUI_Viewer = GUICreate("SQLite Viewer - " & $sDBPath, 1000, 600)
    
    ; Tabellen-Dropdown erstellen
    Local $idCombo = GUICtrlCreateCombo("", 10, 10, 200, 20)
    _SQLiteViewer_LoadTables($idCombo)
    
    ; Listview für Daten
    $g_idListview = GUICtrlCreateListView("", 10, 40, 980, 500)
    
    ; Filter-Eingabe
    GUICtrlCreateLabel("Filter:", 10, 550, 40, 20)
    Local $idFilter = GUICtrlCreateInput("", 50, 550, 200, 20)
    Local $idBtnFilter = GUICtrlCreateButton("Anwenden", 260, 550, 70, 20)
    
    GUISetState(@SW_SHOW, $g_hGUI_Viewer)
    
    ; Event-Loop
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
                
            Case $idCombo
                _SQLiteViewer_LoadTableData(GUICtrlRead($idCombo))
                
            Case $idBtnFilter
                _SQLiteViewer_ApplyFilter(GUICtrlRead($idCombo), GUICtrlRead($idFilter))
        EndSwitch
    WEnd
    
    ; Aufräumen
    _SQLite_Close($g_hDB)
    GUIDelete($g_hGUI_Viewer)
EndFunc

Func _SQLiteViewer_LoadTables($idCombo)
    Local $hQuery = _SQLite_Query($g_hDB, "SELECT name FROM sqlite_master WHERE type='table';")
    If @error Then Return SetError(1)
    
    While _SQLite_FetchData($hQuery, $aRow) = $SQLITE_OK
        GUICtrlSetData($idCombo, $aRow[0], $aRow[0])
    WEnd
    
    _SQLite_QueryFinalize($hQuery)
EndFunc

Func _SQLiteViewer_LoadTableData($sTable)
    If $sTable = "" Then Return
    
    ; Spalten abrufen
    Local $hQuery = _SQLite_Query($g_hDB, "PRAGMA table_info(" & $sTable & ");")
    If @error Then Return SetError(1)
    
    Local $sColumns = ""
    ReDim $g_aTableHeaders[0]
    
    While _SQLite_FetchData($hQuery, $aRow) = $SQLITE_OK
        $sColumns &= $aRow[1] & "|"
        ReDim $g_aTableHeaders[UBound($g_aTableHeaders) + 1]
        $g_aTableHeaders[UBound($g_aTableHeaders) - 1] = $aRow[1]
    WEnd
    
    _SQLite_QueryFinalize($hQuery)
    
    ; Listview aktualisieren
    _GUICtrlListView_DeleteAllItems($g_idListview)
    _GUICtrlListView_SetColumn($g_idListview, $sColumns)
    
    ; Daten laden
    $hQuery = _SQLite_Query($g_hDB, "SELECT * FROM " & $sTable & " LIMIT 1000;")
    If @error Then Return SetError(2)
    
    While _SQLite_FetchData($hQuery, $aRow) = $SQLITE_OK
        Local $iIndex = _GUICtrlListView_AddItem($g_idListview, $aRow[0])
        For $i = 1 To UBound($aRow) - 1
            _GUICtrlListView_AddSubItem($g_idListview, $iIndex, $aRow[$i], $i)
        Next
    WEnd
    
    _SQLite_QueryFinalize($hQuery)
EndFunc

Func _SQLiteViewer_ApplyFilter($sTable, $sFilter)
    If $sTable = "" Or $sFilter = "" Then Return
    
    ; Filter validieren und escapen
    $sFilter = StringReplace($sFilter, "'", "''")
    
    ; WHERE-Bedingung aufbauen
    Local $sWhere = ""
    For $i = 0 To UBound($g_aTableHeaders) - 1
        If $sWhere <> "" Then $sWhere &= " OR "
        $sWhere &= $g_aTableHeaders[$i] & " LIKE '%" & $sFilter & "%'"
    Next
    
    ; Query ausführen
    Local $sQuery = "SELECT * FROM " & $sTable & " WHERE " & $sWhere & " LIMIT 1000;"
    Local $hQuery = _SQLite_Query($g_hDB, $sQuery)
    If @error Then Return SetError(1)
    
    ; Listview aktualisieren
    _GUICtrlListView_DeleteAllItems($g_idListview)
    
    While _SQLite_FetchData($hQuery, $aRow) = $SQLITE_OK
        Local $iIndex = _GUICtrlListView_AddItem($g_idListview, $aRow[0])
        For $i = 1 To UBound($aRow) - 1
            _GUICtrlListView_AddSubItem($g_idListview, $iIndex, $aRow[$i], $i)
        Next
    WEnd
    
    _SQLite_QueryFinalize($hQuery)
EndFunc