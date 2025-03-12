#include-once
#include <SQLite.au3>
#include <GUIListView.au3>
#include "logging.au3"

Func _DB_Connect($sDBPath)
    If Not FileExists($sDBPath) Then
        _LogError("Datenbank nicht gefunden: " & $sDBPath)
        Return False
    EndIf
    
    _SQLite_Close()
    Local $hDB = _SQLite_Open($sDBPath)
    If @error Then
        _LogError("Fehler beim Öffnen der Datenbank: " & $sDBPath)
        Return False
    EndIf
    
    _LogInfo("Datenbankverbindung hergestellt: " & $sDBPath)
    
    ; Verfügbare Tabellen abrufen
    Local $aResult, $iRows, $iColumns
    Local $sQuery = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
    Local $iRet = _SQLite_GetTable2d(-1, $sQuery, $aResult, $iRows, $iColumns)
    
    If @error Or $iRet = $SQLITE_ERROR Then
        _LogError("Fehler beim Abrufen der Tabellen")
        Return False
    EndIf
    
    _LogInfo("Gefundene Tabellen: " & $iRows)
    
    ; ComboBox leeren und neu füllen
    GUICtrlSetData($idTableCombo, "")
    For $i = 1 To $iRows
        _LogInfo("Füge Tabelle hinzu: " & $aResult[$i][0])
        GUICtrlSetData($idTableCombo, $aResult[$i][0])
    Next
    
    ; Erste Tabelle auswählen
    If $iRows > 0 Then
        $g_sCurrentTable = $aResult[1][0]
        GUICtrlSetData($idTableCombo, $g_sCurrentTable)
        _LogInfo("Aktuelle Tabelle gesetzt: " & $g_sCurrentTable)
        
        ; GUI-Elemente aktivieren
        GUICtrlSetState($idTableCombo, $GUI_ENABLE)
        GUICtrlSetState($idBtnRefresh, $GUI_ENABLE)
        GUICtrlSetState($idBtnFilter, $GUI_ENABLE)
        GUICtrlSetState($idBtnExport, $GUI_ENABLE)
        
        ; Daten der ersten Tabelle laden
        Return _LoadDatabaseData()
    EndIf
    
    Return True
EndFunc

Func _LoadDatabaseData()
    If $g_sCurrentTable = "" Then
        _LogError("Keine Tabelle ausgewählt")
        Return False
    EndIf
    
    $g_bIsLoading = True
    GUICtrlSetData($g_idStatus, "Lade Daten...")
    _LogInfo("Lade Daten aus Tabelle: " & $g_sCurrentTable)
    
    ; Spalteninformationen abrufen
    Local $aColumns, $iRows, $iColumns
    Local $sQuery = "PRAGMA table_info(" & $g_sCurrentTable & ");"    
    _LogInfo("SQL-Query: " & $sQuery)
    Local $iRet = _SQLite_GetTable2d(-1, $sQuery, $aColumns, $iRows, $iColumns)
    If @error Or $iRet = $SQLITE_ERROR Then
        _LogError("Fehler beim Abrufen der Spalteninformationen: " & _SQLite_ErrMsg())
        $g_bIsLoading = False
        Return False
    EndIf
    
    _LogInfo("Spalteninformationen erhalten: " & $iRows & " Spalten")
    
    ; Debug-Ausgabe der Spalteninformationen
    For $i = 1 To $iRows
        _LogInfo("Spalte " & $i & ": ID=" & $aColumns[$i][0] & ", Name=" & $aColumns[$i][1])
    Next
    
    ; ListView vorbereiten
    _GUICtrlListView_BeginUpdate(GUICtrlGetHandle($g_idListView))
    
    ; Bestehende Daten löschen
    _GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($g_idListView))
    _DeleteAllListViewColumns($g_idListView)
    
    ; Spalten erstellen
    _LogInfo("Erstelle " & $iRows & " Spalten")
    For $i = 0 To $iRows - 1
        ; Index 1 enthält den Spaltennamen
        _GUICtrlListView_InsertColumn($g_idListView, $i, $aColumns[$i + 1][1], 100)
    Next
    
    ; Daten laden
    Local $aData, $iDataRows, $iDataColumns
    $sQuery = "SELECT * FROM " & $g_sCurrentTable & " LIMIT 1000;"
    $iRet = _SQLite_GetTable2d(-1, $sQuery, $aData, $iDataRows, $iDataColumns)
    
    If @error Or $iRet = $SQLITE_ERROR Then
        _LogError("Fehler beim Laden der Tabellendaten")
        _GUICtrlListView_EndUpdate(GUICtrlGetHandle($g_idListView))
        $g_bIsLoading = False
        Return False
    EndIf
    
    _LogInfo("Füge " & $iDataRows & " Datensätze ein")
    
    ; Daten einfügen
    For $i = 1 To $iDataRows
        _GUICtrlListView_AddItem($g_idListView, $aData[$i][0])
        For $j = 1 To $iDataColumns - 1
            _GUICtrlListView_AddSubItem($g_idListView, $i - 1, $aData[$i][$j], $j)
        Next
    Next
    
    _GUICtrlListView_EndUpdate(GUICtrlGetHandle($g_idListView))
    
    $g_bIsLoading = False
    GUICtrlSetData($g_idStatus, $iDataRows & " Datensätze geladen.")
    _LogInfo("Datenladen abgeschlossen: " & $iDataRows & " Datensätze")
    
    Return True
EndFunc