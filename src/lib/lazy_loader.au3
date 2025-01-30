#include-once
#include <Array.au3>
#include "error_handler.au3"

; Konstanten für Paging
Global Const $PAGE_SIZE = 100 ; Anzahl der Einträge pro Seite
Global Const $PRELOAD_PAGES = 1 ; Anzahl der vorab geladenen Seiten

; Struktur für Lazy Loading
Global $g_aDataCache[0][0] ; Cache-Array
Global $g_iTotalItems = 0 ; Gesamtanzahl der Items
Global $g_iCurrentPage = 0 ; Aktuelle Seite
Global $g_sLastQuery = "" ; Letzte SQL-Abfrage

; Initialisiert den Lazy Loader
Func InitLazyLoader()
    _ArrayDelete($g_aDataCache, "0-" & UBound($g_aDataCache) - 1)
    $g_iTotalItems = 0
    $g_iCurrentPage = 0
    $g_sLastQuery = ""
EndFunc

; Lädt eine Seite von Daten
Func LoadPage($iPage, $sQuery, $hDatabase)
    Local $iOffset = $iPage * $PAGE_SIZE
    Local $sPageQuery = $sQuery & " LIMIT " & $PAGE_SIZE & " OFFSET " & $iOffset
    
    Local $aResult = _SQLite_GetTable2d($hDatabase, $sPageQuery)
    If @error Then
        _LogError("Fehler beim Laden der Seite " & $iPage)
        Return False
    EndIf
    
    ; Cache aktualisieren
    $g_aDataCache = $aResult
    $g_iCurrentPage = $iPage
    $g_sLastQuery = $sQuery
    
    Return True
EndFunc

; Prüft ob Daten im Cache sind
Func IsPageCached($iPage)
    If $iPage = $g_iCurrentPage Then Return True
    Return False
EndFunc

; Holt Daten mit Lazy Loading
Func GetDataLazy($iIndex, $sQuery, $hDatabase)
    Local $iPage = Floor($iIndex / $PAGE_SIZE)
    
    ; Prüfe ob Seite geladen werden muss
    If Not IsPageCached($iPage) Then
        If Not LoadPage($iPage, $sQuery, $hDatabase) Then
            Return False
        EndIf
    EndIf
    
    ; Berechne lokalen Index
    Local $iLocalIndex = Mod($iIndex, $PAGE_SIZE)
    
    ; Prüfe ob Index gültig
    If $iLocalIndex >= UBound($g_aDataCache) Then
        _LogError("Index außerhalb des gültigen Bereichs")
        Return False
    EndIf
    
    Return $g_aDataCache[$iLocalIndex]
EndFunc

; Gibt die Gesamtanzahl der Items zurück
Func GetTotalItems($sQuery, $hDatabase)
    If $g_iTotalItems = 0 Then
        ; Extrahiere COUNT aus Query
        Local $sCountQuery = "SELECT COUNT(*) FROM (" & $sQuery & ")"
        Local $aResult = _SQLite_GetTable2d($hDatabase, $sCountQuery)
        If @error Then
            _LogError("Fehler beim Ermitteln der Gesamtanzahl")
            Return 0
        EndIf
        $g_iTotalItems = Number($aResult[0][0])
    EndIf
    Return $g_iTotalItems
EndFunc

; Lädt die nächste Seite vorab
Func PreloadNextPage($hDatabase)
    Local $iNextPage = $g_iCurrentPage + 1
    If $iNextPage * $PAGE_SIZE < $g_iTotalItems Then
        LoadPage($iNextPage, $g_sLastQuery, $hDatabase)
    EndIf
EndFunc

; Bereinigt den Cache
Func ClearLazyCache()
    InitLazyLoader()
EndFunc