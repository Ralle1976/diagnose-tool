#include-once
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Array.au3>

Global $g_sqliteDLL = @ScriptDir & "\sqlite3.dll"

Func InitializeSQLite()
    _LogInfo("Initialisiere SQLite")
    
    If Not FileExists($g_sqliteDLL) Then
        _LogError("SQLite DLL nicht gefunden", "Pfad: " & $g_sqliteDLL)
        Return False
    EndIf
    
    _SQLite_Startup($g_sqliteDLL)
    If @error Then
        _LogError("SQLite Initialisierung fehlgeschlagen", "Error: " & @error)
        Return False
    EndIf
    
    Return True
EndFunc

Func OpenDatabase($dbFile)
    _LogInfo("Öffne SQLite Datenbank", "Datei: " & $dbFile)
    
    Local $hDB
    _SQLite_Open($dbFile, $hDB)
    If @error Then
        _LogError("Fehler beim Öffnen der Datenbank", "Datei: " & $dbFile & @CRLF & "Error: " & @error)
        Return 0
    EndIf
    
    Return $hDB
EndFunc

Func CloseDatabase($hDB)
    If $hDB Then
        _LogDebug("Schließe Datenbankverbindung")
        _SQLite_Close($hDB)
    EndIf
EndFunc

Func GetTableInfo($hDB, $table)
    _LogDebug("Hole Tabelleninformationen", "Tabelle: " & $table)
    
    Local $aResult
    Local $query = "PRAGMA table_info(" & $table & ")"
    
    _SQLite_GetTable2d($hDB, $query, $aResult)
    If @error Then
        _LogError("Fehler beim Abfragen der Tabelleninformation", "Query: " & $query & @CRLF & "Error: " & @error)
        Return 0
    EndIf
    
    Return $aResult
EndFunc

Func ListTables($hDB)
    _LogDebug("Liste alle Tabellen")
    
    Local $aResult
    Local $query = "SELECT name FROM sqlite_master WHERE type='table'"
    
    _SQLite_GetTable2d($hDB, $query, $aResult)
    If @error Then
        _LogError("Fehler beim Abfragen der Tabellenliste", "Error: " & @error)
        Return 0
    EndIf
    
    Local $aTables[0]
    If UBound($aResult) > 1 Then
        ReDim $aTables[UBound($aResult) - 1]
        For $i = 1 To UBound($aResult) - 1
            $aTables[$i - 1] = $aResult[$i][0]
        Next
    EndIf
    
    Return $aTables
EndFunc

Func ExecuteQuery($hDB, $query, ByRef $result)
    _LogDebug("Führe SQL Query aus", "Query: " & $query)
    
    _SQLite_GetTable2d($hDB, $query, $result)
    If @error Then
        _LogError("Fehler beim Ausführen der Query", "Query: " & $query & @CRLF & "Error: " & @error)
        Return False
    EndIf
    
    Return True
EndFunc

Func GetTableData($hDB, $table, $limit = 100)
    _LogInfo("Hole Tabellendaten", "Tabelle: " & $table & @CRLF & "Limit: " & $limit)
    
    Local $aResult
    Local $query = "SELECT * FROM " & $table & " LIMIT " & $limit
    
    If Not ExecuteQuery($hDB, $query, $aResult) Then
        Return 0
    EndIf
    
    Return $aResult
EndFunc