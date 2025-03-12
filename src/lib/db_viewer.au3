; Globale Variablen für die Datenbankverbindung
Global $g_hDB = 0 ; Handle zur SQLite Datenbank

#include-once
#include <SQLite.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "logging.au3"
#include "error_handler.au3"
#include "missing_functions.au3"


Func _DB_IsConnected()
    Return $g_hDB <> 0
EndFunc

Func _DB_Query($sSQL)
    If Not _DB_IsConnected() Then Return SetError(1, 0, 0)
    Local $hQuery
    _SQLite_Query($g_hDB, $sSQL, $hQuery)
    Return $hQuery
EndFunc

Func _DB_FetchNext($hQuery)
    Local $aRow
    Return _SQLite_FetchData($hQuery, $aRow) = $SQLITE_ROW
EndFunc

Func _DB_GetRow($hQuery)
    Local $aRow
    _SQLite_FetchData($hQuery, $aRow)
    Return $aRow
EndFunc

Func _DB_GetRowCount($hQuery)
    Local $aResult, $iRows, $iColumns
    _SQLite_GetTable2D($g_hDB, "SELECT COUNT(*) FROM " & $g_sCurrentTable, $aResult, $iRows, $iColumns)
    If @error Then Return 0
    Return Number($aResult[1][0])
EndFunc

Func _DB_FreeQuery($hQuery)
    Return _SQLite_QueryFinalize($hQuery)
EndFunc

Func _DB_GetLastError()
    Return _SQLite_ErrMsg($g_hDB)
EndFunc

Func _DB_GetColumns($hQuery)
    If Not _DB_IsConnected() Then Return SetError(1, 0, 0)

    ; PRAGMA-Abfrage für Spalteninformationen
    Local $aResult, $iRows, $iColumns
    Local $sSQL = "PRAGMA table_info(" & $g_sCurrentTable & ")"
    _SQLite_GetTable2D($g_hDB, $sSQL, $aResult, $iRows, $iColumns)

    If @error Then
        _LogError("Fehler beim Abrufen der Spalteninformationen: " & _DB_GetLastError())
        Return SetError(2, 0, 0)
    EndIf

    ; Spaltennamen extrahieren (zweite Spalte enthält die Namen)
    Local $aColumns[$iRows]
    For $i = 1 To $iRows
        $aColumns[$i-1] = $aResult[$i][1]  ; Spalte 1 enthält den Spaltennamen
    Next

    _LogInfo("Spalten geladen: " & _ArrayToString($aColumns))
    Return $aColumns
EndFunc