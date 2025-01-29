#include-once
#include "sqlite_handler.au3"
#include "logging.au3"

Global Const $LAZY_LOAD_CHUNK_SIZE = 100
Global Const $MAX_CACHED_CHUNKS = 5

Global $g_aDataCache[0][2]  ; [ChunkIndex][Data]
Global $g_iTotalRecords = 0
Global $g_iCurrentQuery = ""
Global $g_iLastAccessedChunk = -1

Func _LazyLoad_Init($sQuery, $iTotalCount)
    _LogMessage("INFO", "Initialisiere Lazy Loading für " & $iTotalCount & " Datensätze")
    
    $g_iTotalRecords = $iTotalCount
    $g_iCurrentQuery = $sQuery
    ReDim $g_aDataCache[$MAX_CACHED_CHUNKS][2]
    
    Return True
EndFunc

Func _LazyLoad_GetChunk($iIndex)
    Local $iCacheIndex = _FindChunkInCache($iIndex)
    If $iCacheIndex >= 0 Then
        _LogMessage("DEBUG", "Chunk " & $iIndex & " aus Cache geladen")
        $g_iLastAccessedChunk = $iIndex
        Return $g_aDataCache[$iCacheIndex][1]
    EndIf
    
    Local $iOffset = $iIndex * $LAZY_LOAD_CHUNK_SIZE
    Local $sLimitedQuery = $g_iCurrentQuery & " LIMIT " & $LAZY_LOAD_CHUNK_SIZE & " OFFSET " & $iOffset
    
    Local $aData = _SQLite_GetTable2d($sLimitedQuery)
    If @error Then
        _LogMessage("ERROR", "Fehler beim Laden von Chunk " & $iIndex)
        Return SetError(1, 0, False)
    EndIf
    
    _UpdateCache($iIndex, $aData)
    
    $g_iLastAccessedChunk = $iIndex
    Return $aData
EndFunc

Func _LazyLoad_GetVisibleRange($iStartRecord, $iEndRecord)
    Local $iStartChunk = Floor($iStartRecord / $LAZY_LOAD_CHUNK_SIZE)
    Local $iEndChunk = Floor($iEndRecord / $LAZY_LOAD_CHUNK_SIZE)
    
    Local $aResult[0][0]
    
    For $i = $iStartChunk To $iEndChunk
        Local $aChunkData = _LazyLoad_GetChunk($i)
        If Not @error Then
            _ArrayConcatenate($aResult, $aChunkData)
        EndIf
    Next
    
    Local $iStartOffset = Mod($iStartRecord, $LAZY_LOAD_CHUNK_SIZE)
    Local $iEndOffset = UBound($aResult) - (($iEndChunk + 1) * $LAZY_LOAD_CHUNK_SIZE - $iEndRecord)
    
    Return _ArrayExtract($aResult, $iStartOffset, $iEndOffset)
EndFunc

Func _LazyLoad_Cleanup()
    ReDim $g_aDataCache[0][2]
    $g_iTotalRecords = 0
    $g_iCurrentQuery = ""
    $g_iLastAccessedChunk = -1
EndFunc

; Private Hilfsfunktionen
Func _FindChunkInCache($iChunkIndex)
    For $i = 0 To UBound($g_aDataCache) - 1
        If $g_aDataCache[$i][0] = $iChunkIndex Then
            Return $i
        EndIf
    Next
    Return -1
EndFunc

Func _UpdateCache($iChunkIndex, $aData)
    Local $iOldestAccess = 0
    Local $iMaxDistance = 0
    
    For $i = 0 To UBound($g_aDataCache) - 1
        If $g_aDataCache[$i][0] = -1 Then
            $iOldestAccess = $i
            ExitLoop
        EndIf
        
        Local $iDistance = Abs($g_iLastAccessedChunk - $g_aDataCache[$i][0])
        If $iDistance > $iMaxDistance Then
            $iMaxDistance = $iDistance
            $iOldestAccess = $i
        EndIf
    Next
    
    $g_aDataCache[$iOldestAccess][0] = $iChunkIndex
    $g_aDataCache[$iOldestAccess][1] = $aData
EndFunc