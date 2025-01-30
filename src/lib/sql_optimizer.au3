#include-once
#include <SQLite.au3>
#include "error_handler.au3"
#include "cache_manager.au3"

; Konstanten für Query-Optimierung
Global Const $MAX_BATCH_SIZE = 1000
Global Const $INDEX_THRESHOLD = 1000

; Optimiert eine SELECT-Query
Func OptimizeSelectQuery($sQuery)
    ; Entferne unnötige Wildcards
    $sQuery = StringReplace($sQuery, "SELECT *", "SELECT " & _GetRequiredColumns($sQuery))
    
    ; Füge LIMIT hinzu wenn nicht vorhanden
    If Not StringInStr($sQuery, " LIMIT ") Then
        $sQuery &= " LIMIT " & $MAX_BATCH_SIZE
    EndIf
    
    ; Optimiere WHERE-Bedingungen
    $sQuery = _OptimizeWhereClauses($sQuery)
    
    Return $sQuery
EndFunc

; Ermittelt die benötigten Spalten aus der Query
Func _GetRequiredColumns($sQuery)
    ; Extrahiere Spalten aus WHERE, ORDER BY, GROUP BY
    Local $sColumns = ""
    
    ; WHERE-Spalten
    Local $aMatches = StringRegExp($sQuery, "WHERE\s+([^;]+?)\s+(?:ORDER|GROUP|LIMIT|$)", 1)
    If Not @error Then
        $sColumns &= _ExtractColumnsFromCondition($aMatches[0])
    EndIf
    
    ; ORDER BY-Spalten
    $aMatches = StringRegExp($sQuery, "ORDER\s+BY\s+([^;]+?)(?:\s+LIMIT|$)", 1)
    If Not @error Then
        If $sColumns Then $sColumns &= ", "
        $sColumns &= StringReplace($aMatches[0], " ASC", "")
        $sColumns = StringReplace($sColumns, " DESC", "")
    EndIf
    
    ; Mindestens ID zurückgeben
    If Not $sColumns Then $sColumns = "rowid"
    
    Return $sColumns
EndFunc

; Optimiert WHERE-Bedingungen
Func _OptimizeWhereClauses($sQuery)
    ; Ersetze OR durch UNION wenn möglich
    If StringInStr($sQuery, " OR ") Then
        Local $aSubQueries = StringSplit($sQuery, " OR ", $STR_NOCOUNT)
        If UBound($aSubQueries) <= 3 Then ; Maximal 3 OR-Verknüpfungen
            Local $sOptimized = ""
            For $i = 0 To UBound($aSubQueries) - 1
                If $i > 0 Then $sOptimized &= " UNION "
                $sOptimized &= "SELECT " & _GetRequiredColumns($sQuery) & " FROM (" & $aSubQueries[$i] & ")"
            Next
            Return $sOptimized
        EndIf
    EndIf
    
    Return $sQuery
EndFunc

; Erstellt Index wenn nötig
Func CreateOptimizedIndex($hDatabase, $sTable, $sColumn)
    ; Prüfe ob Index bereits existiert
    Local $sCheckQuery = "SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND tbl_name='" & $sTable & "' AND sql LIKE '%(" & $sColumn & ")%'"
    Local $aResult = _SQLite_GetTable2d($hDatabase, $sCheckQuery)
    If @error Then Return False
    
    If Number($aResult[1][0]) > 0 Then Return True ; Index existiert bereits
    
    ; Prüfe Datenmenge
    $sCheckQuery = "SELECT COUNT(*) FROM " & $sTable
    $aResult = _SQLite_GetTable2d($hDatabase, $sCheckQuery)
    If @error Then Return False
    
    If Number($aResult[1][0]) < $INDEX_THRESHOLD Then Return True ; Zu wenig Daten für Index
    
    ; Erstelle Index
    Local $sIndexName = "idx_" & $sTable & "_" & $sColumn
    Local $sCreateIndex = "CREATE INDEX IF NOT EXISTS " & $sIndexName & " ON " & $sTable & "(" & $sColumn & ")"
    
    _SQLite_Exec($hDatabase, $sCreateIndex)
    If @error Then
        _LogError("Fehler beim Erstellen des Index: " & $sIndexName)
        Return False
    EndIf
    
    Return True
EndFunc

; Führt eine optimierte Query aus
Func ExecuteOptimizedQuery($hDatabase, $sQuery)
    ; Cache-Key generieren
    Local $sCacheKey = "sql_" & MD5($sQuery)
    
    ; Prüfe Cache
    Local $vResult = CacheGet($sCacheKey)
    If Not @error Then Return $vResult
    
    ; Query optimieren
    Local $sOptimizedQuery = OptimizeSelectQuery($sQuery)
    
    ; Query ausführen
    Local $aResult = _SQLite_GetTable2d($hDatabase, $sOptimizedQuery)
    If @error Then
        _LogError("Fehler bei Ausführung der Query: " & $sOptimizedQuery)
        Return False
    EndIf
    
    ; Ergebnis cachen
    CacheSet($sCacheKey, $aResult)
    
    Return $aResult
EndFunc

; Führt Batch-Operationen durch
Func ExecuteBatchOperation($hDatabase, $sTableName, $aData, $sOperation = "INSERT")
    _SQLite_Exec($hDatabase, "BEGIN TRANSACTION")
    
    Local $iSuccess = 0
    Local $iBatchSize = UBound($aData)
    
    Switch $sOperation
        Case "INSERT"
            For $i = 0 To $iBatchSize - 1
                Local $sQuery = "INSERT INTO " & $sTableName & " VALUES (" & $aData[$i] & ")"
                _SQLite_Exec($hDatabase, $sQuery)
                If Not @error Then $iSuccess += 1
            Next
            
        Case "UPDATE"
            For $i = 0 To $iBatchSize - 1
                Local $sQuery = "UPDATE " & $sTableName & " SET " & $aData[$i]
                _SQLite_Exec($hDatabase, $sQuery)
                If Not @error Then $iSuccess += 1
            Next
    EndSwitch
    
    If $iSuccess = $iBatchSize Then
        _SQLite_Exec($hDatabase, "COMMIT")
        Return True
    Else
        _SQLite_Exec($hDatabase, "ROLLBACK")
        Return False
    EndIf
EndFunc