#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>
#include <Array.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <GuiComboBox.au3>
#include <StaticConstants.au3>

; Globale GUI-Elemente
Global $g_hSQLiteGUI, $g_hTableList, $g_hDataList, $g_hFilterInput, $g_hFilterColumn
Global $g_hCurrentDB = 0
Global $g_currentTable = ""

Func ShowSQLiteViewer($dbFile)
    _LogInfo("Öffne SQLite Viewer", "Datei: " & $dbFile)
    
    ; Öffne Datenbankverbindung
    $g_hCurrentDB = OpenDatabase($dbFile)
    If $g_hCurrentDB = 0 Then
        _LogError("Konnte Datenbank nicht öffnen", "Datei: " & $dbFile)
        Return False
    EndIf
    
    ; Erstelle Hauptfenster
    $g_hSQLiteGUI = GUICreate("SQLite Viewer - " & $dbFile, 800, 600)
    
    ; Splitter-Layout
    Local $splitterX = 200
    GUICtrlCreateLabel("", $splitterX, 0, 2, 600)
    GUICtrlSetBkColor(-1, 0x999999)
    
    ; Tabellenliste links
    $g_hTableList = GUICtrlCreateListView("Tabellen", 0, 0, $splitterX - 2, 600, BitOR($LVS_REPORT, $LVS_SINGLESEL))
    _GUICtrlListView_SetColumnWidth($g_hTableList, 0, $splitterX - 25)
    
    ; Filterbereich
    Local $filterY = 0
    GUICtrlCreateLabel("Filter:", $splitterX + 10, $filterY + 3, 40, 20)
    $g_hFilterColumn = GUICtrlCreateCombo("", $splitterX + 55, $filterY, 150, 20, $CBS_DROPDOWNLIST)
    $g_hFilterInput = GUICtrlCreateInput("", $splitterX + 215, $filterY, 200, 20)
    Local $hFilterBtn = GUICtrlCreateButton("Filtern", $splitterX + 425, $filterY, 70, 20)
    Local $hClearBtn = GUICtrlCreateButton("Zurücksetzen", $splitterX + 505, $filterY, 80, 20)
    
    ; Daten-ListView
    $g_hDataList = GUICtrlCreateListView("", $splitterX + 10, $filterY + 30, 780 - $splitterX, 560, BitOR($LVS_REPORT, $LVS_NOSORTHEADER))
    
    ; Statusleiste
    Local $hStatus = GUICtrlCreateLabel("Bereit", 10, 580, 780, 20)
    GUICtrlSetBkColor(-1, 0xF0F0F0)
    
    ; Kontextmenü für Tabellenliste
    Local $hContextMenu = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
    Local $hExportCSV = GUICtrlCreateMenuItem("Als CSV exportieren", $hContextMenu)
    Local $hShowStructure = GUICtrlCreateMenuItem("Tabellenstruktur anzeigen", $hContextMenu)
    GUICtrlSetOnEvent($g_hTableList, "_TableList_Click")
    
    ; Lade Tabellenliste
    LoadTableList()
    
    ; GUI anzeigen
    GUISetState(@SW_SHOW, $g_hSQLiteGUI)
    
    ; Event-Loop
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
                
            Case $hFilterBtn
                ApplyFilter()
                
            Case $hClearBtn
                ClearFilter()
                
            Case $hExportCSV
                ExportTableToCSV($g_currentTable)
                
            Case $hShowStructure
                ShowTableStructure($g_currentTable)
        EndSwitch
    WEnd
    
    ; Aufräumen
    If $g_hCurrentDB Then CloseDatabase($g_hCurrentDB)
    GUIDelete($g_hSQLiteGUI)
EndFunc

Func LoadTableList()
    _LogDebug("Lade Tabellenliste")
    
    ; ListView leeren
    _GUICtrlListView_DeleteAllItems($g_hTableList)
    
    ; Tabellen abfragen
    Local $aTables = ListTables($g_hCurrentDB)
    If @error Or Not IsArray($aTables) Then
        _LogError("Fehler beim Laden der Tabellenliste")
        Return
    EndIf
    
    ; Tabellen in ListView einfügen
    For $i = 0 To UBound($aTables) - 1
        _GUICtrlListView_AddItem($g_hTableList, $aTables[$i])
    Next
    
    _LogInfo("Tabellenliste geladen", "Anzahl Tabellen: " & UBound($aTables))
EndFunc

Func LoadTableData($table, $filter = "")
    _LogInfo("Lade Tabellendaten", "Tabelle: " & $table & @CRLF & "Filter: " & $filter)
    
    $g_currentTable = $table
    
    ; ListView leeren
    _GUICtrlListView_DeleteAllItems($g_hDataList)
    
    ; Spalten löschen
    While _GUICtrlListView_GetColumn($g_hDataList, 0)
        _GUICtrlListView_DeleteColumn($g_hDataList, 0)
    WEnd
    
    ; Tabellenstruktur laden
    Local $aColumns = GetTableInfo($g_hCurrentDB, $table)
    If @error Or Not IsArray($aColumns) Then
        _LogError("Fehler beim Laden der Tabellenstruktur")
        Return
    EndIf
    
    ; Spalten erstellen
    For $i = 1 To UBound($aColumns) - 1
        _GUICtrlListView_AddColumn($g_hDataList, $aColumns[$i][1], 120)
        GUICtrlSetData($g_hFilterColumn, $aColumns[$i][1])
    Next
    
    ; Daten laden
    Local $query = "SELECT * FROM " & $table
    If $filter <> "" Then $query &= " WHERE " & $filter
    $query &= " LIMIT " & $g_settings.Item("SQLitePreviewLimit")
    
    Local $aData
    If Not ExecuteQuery($g_hCurrentDB, $query, $aData) Then Return
    
    ; Daten einfügen
    For $i = 1 To UBound($aData) - 1
        Local $index = _GUICtrlListView_AddItem($g_hDataList, $aData[$i][0])
        For $j = 1 To UBound($aData, 2) - 1
            _GUICtrlListView_AddSubItem($g_hDataList, $index, $aData[$i][$j], $j)
        Next
    Next
    
    _LogInfo("Tabellendaten geladen", "Datensätze: " & (UBound($aData) - 1))
EndFunc

Func _TableList_Click()
    Local $index = _GUICtrlListView_GetSelectedIndices($g_hTableList)
    If $index = "" Then Return
    
    Local $table = _GUICtrlListView_GetItemText($g_hTableList, $index)
    LoadTableData($table)
EndFunc

Func ApplyFilter()
    Local $column = GUICtrlRead($g_hFilterColumn)
    Local $value = GUICtrlRead($g_hFilterInput)
    
    If $column = "" Or $value = "" Then Return
    
    Local $filter = $column & " LIKE '%" & $value & "%'"
    LoadTableData($g_currentTable, $filter)
EndFunc

Func ClearFilter()
    GUICtrlSetData($g_hFilterInput, "")
    LoadTableData($g_currentTable)
EndFunc

Func ShowTableStructure($table)
    _LogInfo("Zeige Tabellenstruktur", "Tabelle: " & $table)
    
    Local $aInfo = GetTableInfo($g_hCurrentDB, $table)
    If @error Or Not IsArray($aInfo) Then
        _LogError("Fehler beim Laden der Tabellenstruktur")
        Return
    EndIf
    
    Local $msg = "Tabellenstruktur für " & $table & ":" & @CRLF & @CRLF
    $msg &= "Name         Typ          Nullable    Default" & @CRLF
    $msg &= "----------------------------------------" & @CRLF
    
    For $i = 1 To UBound($aInfo) - 1
        $msg &= StringFormat("%-12s %-12s %-10s %s", _
            $aInfo[$i][1], _  ; Name
            $aInfo[$i][2], _  ; Typ
            $aInfo[$i][3], _  ; Nullable
            $aInfo[$i][4])    ; Default
        $msg &= @CRLF
    Next
    
    MsgBox(64, "Tabellenstruktur", $msg)
EndFunc

Func ExportTableToCSV($table)
    _LogInfo("Exportiere Tabelle als CSV", "Tabelle: " & $table)
    
    Local $sFile = FileSaveDialog("CSV speichern", "", "CSV (*.csv)", 16, $table & ".csv")
    If @error Then Return
    
    Local $query = "SELECT * FROM " & $table
    Local $aData
    If Not ExecuteQuery($g_hCurrentDB, $query, $aData) Then Return
    
    Local $hFile = FileOpen($sFile, 2)
    If $hFile = -1 Then
        _LogError("Fehler beim Öffnen der CSV-Datei", "Datei: " & $sFile)
        Return
    EndIf
    
    ; Schreibe Header
    Local $header = ""
    For $i = 0 To UBound($aData, 2) - 1
        If $i > 0 Then $header &= ";"
        $header &= """" & $aData[0][$i] & """"
    Next
    FileWriteLine($hFile, $header)
    
    ; Schreibe Daten
    For $i = 1 To UBound($aData) - 1
        Local $line = ""
        For $j = 0 To UBound($aData, 2) - 1
            If $j > 0 Then $line &= ";"
            $line &= """" & StringReplace($aData[$i][$j], """", """""") & """"
        Next
        FileWriteLine($hFile, $line)
    Next
    
    FileClose($hFile)
    _LogInfo("CSV-Export abgeschlossen", "Datei: " & $sFile)
    
    MsgBox(64, "Export abgeschlossen", "Die Tabelle wurde erfolgreich exportiert nach:" & @CRLF & $sFile)
EndFunc