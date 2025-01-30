#include-once
#include <Array.au3>
#include <Date.au3>
#include "error_handler.au3"

; Cache-Einstellungen
Global Const $CACHE_MAX_SIZE = 100 * 1024 * 1024 ; 100MB maximale Größe
Global Const $CACHE_EXPIRE_TIME = 5 * 60 ; 5 Minuten Cache-Lebensdauer

; Cache-Struktur
Global $g_aCacheData[0][4] ; [Key, Data, Timestamp, Size]
Global $g_iCurrentCacheSize = 0

; Initialisiert den Cache-Manager
Func InitCacheManager()
    _ArrayDelete($g_aCacheData, "0-" & UBound($g_aCacheData) - 1)
    $g_iCurrentCacheSize = 0
EndFunc

; Speichert Daten im Cache
Func CacheSet($sKey, $vData)
    ; Berechne Datengröße
    Local $iSize = 0
    Switch VarGetType($vData)
        Case "Array"
            $iSize = UBound($vData) * 8 ; Geschätzte Größe pro Element
        Case "Binary"
            $iSize = BinaryLen($vData)
        Case "String"
            $iSize = StringLen($vData) * 2 ; UTF-16 Zeichengröße
        Case Else
            $iSize = 8 ; Standard für einfache Datentypen
    EndSwitch
    
    ; Prüfe ob genug Platz vorhanden ist
    While $g_iCurrentCacheSize + $iSize > $CACHE_MAX_SIZE
        If Not RemoveOldestCacheEntry() Then
            _LogError("Cache ist voll und kann nicht bereinigt werden")
            Return False
        EndIf
    WEnd
    
    ; Suche nach existierendem Eintrag
    Local $iIndex = _ArraySearch($g_aCacheData, $sKey, 0, 0, 0, 0, 1, 0)
    
    If $iIndex >= 0 Then
        ; Update existierenden Eintrag
        $g_iCurrentCacheSize -= Number($g_aCacheData[$iIndex][3])
        $g_aCacheData[$iIndex][1] = $vData
        $g_aCacheData[$iIndex][2] = _TimerInit()
        $g_aCacheData[$iIndex][3] = $iSize
    Else
        ; Füge neuen Eintrag hinzu
        Local $aNewEntry[1][4] = [[$sKey, $vData, _TimerInit(), $iSize]]
        _ArrayAdd($g_aCacheData, $aNewEntry)
    EndIf
    
    $g_iCurrentCacheSize += $iSize
    Return True
EndFunc

; Holt Daten aus dem Cache
Func CacheGet($sKey)
    Local $iIndex = _ArraySearch($g_aCacheData, $sKey, 0, 0, 0, 0, 1, 0)
    
    If $iIndex >= 0 Then
        ; Prüfe ob Eintrag abgelaufen ist
        If _TimerDiff($g_aCacheData[$iIndex][2]) > $CACHE_EXPIRE_TIME * 1000 Then
            RemoveCacheEntry($iIndex)
            Return SetError(1, 0, False)
        EndIf
        
        ; Aktualisiere Zeitstempel
        $g_aCacheData[$iIndex][2] = _TimerInit()
        Return $g_aCacheData[$iIndex][1]
    EndIf
    
    Return SetError(1, 0, False)
EndFunc

; Löscht einen Cache-Eintrag
Func RemoveCacheEntry($iIndex)
    $g_iCurrentCacheSize -= Number($g_aCacheData[$iIndex][3])
    _ArrayDelete($g_aCacheData, $iIndex)
EndFunc

; Löscht den ältesten Cache-Eintrag
Func RemoveOldestCacheEntry()
    If UBound($g_aCacheData) = 0 Then Return False
    
    ; Finde ältesten Eintrag
    Local $iOldestIndex = 0
    Local $fOldestTime = Number($g_aCacheData[0][2])
    
    For $i = 1 To UBound($g_aCacheData) - 1
        If Number($g_aCacheData[$i][2]) < $fOldestTime Then
            $fOldestTime = Number($g_aCacheData[$i][2])
            $iOldestIndex = $i
        EndIf
    Next
    
    RemoveCacheEntry($iOldestIndex)
    Return True
EndFunc

; Bereinigt abgelaufene Cache-Einträge
Func CleanupCache()
    For $i = UBound($g_aCacheData) - 1 To 0 Step -1
        If _TimerDiff($g_aCacheData[$i][2]) > $CACHE_EXPIRE_TIME * 1000 Then
            RemoveCacheEntry($i)
        EndIf
    Next
EndFunc

; Löscht den gesamten Cache
Func ClearCache()
    InitCacheManager()
EndFunc

; Gibt Cache-Statistiken zurück
Func GetCacheStats()
    Local $iEntries = UBound($g_aCacheData)
    Local $sStats = "Cache-Statistik:" & @CRLF & _
                   "Einträge: " & $iEntries & @CRLF & _
                   "Größe: " & Round($g_iCurrentCacheSize / 1024 / 1024, 2) & " MB" & @CRLF & _
                   "Auslastung: " & Round($g_iCurrentCacheSize / $CACHE_MAX_SIZE * 100, 1) & "%"
    Return $sStats
EndFunc