#include-once
#include <GUIConstants.au3>
#include <GuiListView.au3>
#include <SQLite.au3>
#include "list_sorting.au3"
#include "advanced_filter.au3"
#include "memory_manager.au3"

Global $g_hDB = 0             ; Database handle
Global $g_hGUI_Viewer = 0     ; Viewer GUI handle
Global $g_idListview = 0      ; Listview handle
Global $g_aTableHeaders[0]    ; Array für Spaltenüberschriften
Global $g_iColumnCount = 0    ; Anzahl der Spalten
Global $g_sCurrentTable = ""  ; Aktuelle Tabelle
Global $g_sCurrentFilter = "" ; Aktueller Filter

Func _SQLiteViewer_Show($sDBPath)
    $g_hDB = _SQLite_Open($sDBPath)
    If @error Then
        MsgBox(16, "Fehler", "Datenbank konnte nicht geöffnet werden: " & $sDBPath)
        Return SetError(1)
    EndIf
    
    ; GUI erstellen
    $g_hGUI_Viewer = GUICreate("SQLite Viewer - " & $sDBPath, 1000, 600)
    
    ; Toolbar-Bereich
    GUICtrlCreateGroup("", 10, 10, 980, 50)
    
    ; Tabellen-Dropdown
    GUICtrlCreateLabel("Tabelle:", 20, 25, 50, 20)
    Local $idCombo = GUICtrlCreateCombo("", 70, 25, 200, 20)
    _SQLiteViewer_LoadTables($idCombo)
    
    ; Filter-Buttons
    Local $idBtnQuickFilter = GUICtrlCreateButton("Schnellfilter", 280, 25, 80, 20)
    Local $idBtnAdvFilter = GUICtrlCreateButton("Erweiterter Filter", 370, 25, 100, 20)
    Local $idBtnClearFilter = GUICtrlCreateButton("Filter löschen", 480, 25, 80, 20)
    
    ; Status-Label
    Local $idStatus = GUICtrlCreateLabel("Bereit", 570, 25, 300, 20)
    
    ; Export-Button
    Local $idBtnExport = GUICtrlCreateButton("Exportieren", 900, 25, 80, 20)
    
    ; Listview für Daten mit erweiterten Styles
    $g_idListview = GUICtrlCreateListView("", 10, 70, 980, 520)
    _GUICtrlListView_SetExtendedListViewStyle($g_idListview, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
    
    ; Sortierung initialisieren
    _ListSort_Init()
    
    GUISetState(@SW_SHOW, $g_hGUI_Viewer)
    
    ; Event-Loop
    While 1
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                ExitLoop
                
            Case $idCombo
                $g_sCurrentTable = GUICtrlRead($idCombo)
                $g_sCurrentFilter = ""
                _SQLiteViewer_LoadTableData($g_sCurrentTable)
                GUICtrlSetData($idStatus, "Tabelle geladen: " & $g_sCurrentTable)
                
            Case $idBtnQuickFilter
                Local $sFilter = InputBox("Schnellfilter", "Filterbegriff eingeben:", "")
                If Not @error Then
                    $g_sCurrentFilter = _SQLiteViewer_BuildQuickFilter($sFilter)
                    _SQLiteViewer_ApplyFilter()
                    GUICtrlSetData($idStatus, "Schnellfilter angewendet")
                EndIf
                
            Case $idBtnAdvFilter
                Local $sFilter = _AdvFilter_Show($g_aTableHeaders)
                If Not @error And $sFilter <> "" Then
                    $g_sCurrentFilter = $sFilter
                    _SQLiteViewer_ApplyFilter()
                    GUICtrlSetData($idStatus, "Erweiterter Filter angewendet")
                EndIf
                
            Case $idBtnClearFilter
                $g_sCurrentFilter = ""
                _SQLiteViewer_LoadTableData($g_sCurrentTable)
                GUICtrlSetData($idStatus, "Filter zurückgesetzt")
                
            Case $idBtnExport
                If _SQLiteViewer_Export() Then
                    GUICtrlSetData($idStatus, "Export abgeschlossen")
                Else
                    GUICtrlSetData($idStatus, "Export fehlgeschlagen")
                EndIf
                
            Case $g_idListview
                ; Header-Klick für Sortierung
                Local $aInfo = GUIGetCursorInfo($g_hGUI_Viewer)
                If Not @error And _GUICtrlListView_GetHeader($g_idListview) = $aInfo[4] Then
                    Local $aRect = _GUICtrlListView_GetColumnRect($g_idListview, 0)
                    Local $iColumn = Floor($aInfo[0] / ($aRect[2] - $aRect[0]))
                    Local $aSortInfo = _ListSort_HandleHeaderClick($g_idListview, $iColumn)
                    Local $iSortType = _SQLiteViewer_GetColumnType($iColumn)
                    _ListSort_Apply($g_idListview, $iColumn, $iSortType)
                    GUICtrlSetData($idStatus, "Liste sortiert nach " & $g_aTableHeaders[$iColumn])
                EndIf
        EndSwitch
    WEnd
    
    ; Aufräumen
    _MemoryManager_Cleanup()
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

Func _SQLiteViewer_LoadTableData($sTable, $iLimit = 1000)
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
    
    $g_iColumnCount = UBound($g_aTableHeaders)
    _SQLite_QueryFinalize($hQuery)
    
    ; Listview aktualisieren
    _GUICtrlListView_DeleteAllItems($g_idListview)
    _GUICtrlListView_SetColumns($g_idListview, StringTrimRight($sColumns, 1))
    
    ; Daten laden
    Local $sQuery = "SELECT * FROM " & $sTable
    If $g_sCurrentFilter <> "" Then
        $sQuery &= " WHERE " & $g_sCurrentFilter
    EndIf
    $sQuery &= " LIMIT " & $iLimit & ";"
    
    $hQuery = _SQLite_Query($g_hDB, $sQuery)
    If @error Then Return SetError(2)
    
    While _SQLite_FetchData($hQuery, $aRow) = $SQLITE_OK
        Local $iIndex = _GUICtrlListView_AddItem($g_idListview, $aRow[0])
        For $i = 1 To UBound($aRow) - 1
            _GUICtrlListView_AddSubItem($g_idListview, $iIndex, $aRow[$i], $i)
        Next
    WEnd
    
    _SQLite_QueryFinalize($hQuery)
EndFunc

Func _SQLiteViewer_BuildQuickFilter($sFilter)
    If $sFilter = "" Then Return ""
    
    $sFilter = StringReplace($sFilter, "'", "''")
    Local $sWhere = ""
    
    For $i = 0 To UBound($g_aTableHeaders) - 1
        If $sWhere <> "" Then $sWhere &= " OR "
        $sWhere &= $g_aTableHeaders[$i] & " LIKE '%" & $sFilter & "%'"
    Next
    
    Return $sWhere
EndFunc

Func _SQLiteViewer_ApplyFilter()
    _SQLiteViewer_LoadTableData($g_sCurrentTable)
EndFunc

Func _SQLiteViewer_Export()
    Local $sFile = FileSaveDialog("Daten exportieren", @DesktopDir, "CSV-Dateien (*.csv)", 16, "export.csv")
    If @error Then Return False
    
    Local $hFile = FileOpen($sFile, 2)
    If $hFile = -1 Then Return False
    
    ; Header schreiben
    Local $sHeader = ""
    For $i = 0 To UBound($g_aTableHeaders) - 1
        $sHeader &= $g_aTableHeaders[$i] & ";"
    Next
    FileWriteLine($hFile, StringTrimRight($sHeader, 1))
    
    ; Daten schreiben
    Local $iItems = _GUICtrlListView_GetItemCount($g_idListview)
    For $i = 0 To $iItems - 1
        Local $sLine = ""
        For $j = 0 To $g_iColumnCount - 1
            $sLine &= _GUICtrlListView_GetItemText($g_idListview, $i, $j) & ";"
        Next
        FileWriteLine($hFile, StringTrimRight($sLine, 1))
    Next
    
    FileClose($hFile)
    Return True
EndFunc

Func _SQLiteViewer_GetColumnType($iColumn)
    Local $iType = 0
    Local $sTestValue = _GUICtrlListView_GetItemText($g_idListview, 0, $iColumn)
    
    If StringRegExp($sTestValue, "^\d+\.?\d*$") Then
        $iType = 1
    ElseIf StringRegExp($sTestValue, "^\d{2}\.\d{2}\.\d{4}$") Then
        $iType = 2
    EndIf
    
    Return $iType
EndFunc