#include-once
#include "logging.au3"

; Speichermanagement Konfiguration
Global Const $MEMORY_CHECK_INTERVAL = 1000 ; ms
Global Const $MEMORY_THRESHOLD = 512 * 1024 * 1024 ; 512 MB
Global Const $TEMP_FILE_MAX_AGE = 24 * 60 * 60 ; 24 Stunden

; Interne Variablen
Global $g_aTempFiles[0]
Global $g_hMemoryTimer = 0
Global $g_bMemoryMonitorActive = False

Func _MemoryManager_Init()
    _LogMessage("INFO", "Initialisiere Memory Manager")
    
    ; Timer für Speicherüberwachung erstellen
    $g_hMemoryTimer = TimerInit()
    
    ; Speicherüberwachung aktivieren
    AdlibRegister("_CheckMemoryUsage", $MEMORY_CHECK_INTERVAL)
    $g_bMemoryMonitorActive = True
    
    ; Temporäres Verzeichnis erstellen/prüfen
    Local $sTempDir = @TempDir & "\DiagnoseTool"
    If Not FileExists($sTempDir) Then
        DirCreate($sTempDir)
    EndIf
    
    Return True
EndFunc

Func _MemoryManager_CreateTempFile($sPrefix = "temp")
    Local $sTempFile = @TempDir & "\DiagnoseTool\" & $sPrefix & "_" & @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & @SEC & ".tmp"
    
    _ArrayAdd($g_aTempFiles, $sTempFile)
    _LogMessage("DEBUG", "Temporäre Datei erstellt: " & $sTempFile)
    
    Return $sTempFile
EndFunc

Func _MemoryManager_CleanupTemp($bForce = False)
    Local $iCount = 0
    
    For $i = UBound($g_aTempFiles) - 1 To 0 Step -1
        If FileExists($g_aTempFiles[$i]) Then
            If $bForce Or _IsFileOld($g_aTempFiles[$i]) Then
                FileDelete($g_aTempFiles[$i])
                _ArrayDelete($g_aTempFiles, $i)
                $iCount += 1
            EndIf
        EndIf
    Next
    
    _LogMessage("INFO", "Temporäre Dateien bereinigt: " & $iCount)
    Return $iCount
EndFunc

Func _MemoryManager_SaveArrayToFile($aArray, $sFilePath)
    Local $hFile = FileOpen($sFilePath, 2)  ; 2 = Überschreiben
    If $hFile = -1 Then
        _LogMessage("ERROR", "Fehler beim Öffnen der Datei: " & $sFilePath)
        Return SetError(1, 0, False)
    EndIf
    
    ; Array serialisieren und speichern
    Local $sData = ""
    For $i = 0 To UBound($aArray) - 1
        $sData &= $aArray[$i] & @CRLF
    Next
    
    FileWrite($hFile, $sData)
    FileClose($hFile)
    
    Return True
EndFunc

Func _MemoryManager_LoadArrayFromFile($sFilePath)
    If Not FileExists($sFilePath) Then
        _LogMessage("ERROR", "Datei nicht gefunden: " & $sFilePath)
        Return SetError(1, 0, False)
    EndIf
    
    Local $aArray = FileReadToArray($sFilePath)
    If @error Then
        _LogMessage("ERROR", "Fehler beim Lesen der Datei: " & $sFilePath)
        Return SetError(2, 0, False)
    EndIf
    
    Return $aArray
EndFunc

Func _MemoryManager_Cleanup()
    ; Timer und Überwachung deaktivieren
    AdlibUnRegister("_CheckMemoryUsage")
    $g_bMemoryMonitorActive = False
    
    ; Alle temporären Dateien löschen
    _MemoryManager_CleanupTemp(True)
EndFunc

; Private Hilfsfunktionen
Func _CheckMemoryUsage()
    If Not $g_bMemoryMonitorActive Then
        Return
    EndIf
    
    Local $iMemUsage = MemGetStats()[2]  ; Prozent des genutzten Speichers
    
    If $iMemUsage > 80 Then  ; Wenn mehr als 80% des Speichers genutzt wird
        _LogMessage("WARNING", "Hohe Speicherauslastung erkannt: " & $iMemUsage & "%")
        _MemoryManager_CleanupTemp()  ; Temporäre Dateien bereinigen
        
        If $iMemUsage > 90 Then  ; Kritischer Speicherzustand
            _LogMessage("ERROR", "Kritische Speicherauslastung: " & $iMemUsage & "%")
            GC()  ; Garbage Collection erzwingen
        EndIf
    EndIf
EndFunc

Func _IsFileOld($sFilePath)
    Local $aFileTime = FileGetTime($sFilePath, 0, 1)  ; 1 = Erstellungszeit
    If @error Then Return True  ; Bei Fehler File als alt markieren
    
    Local $iFileAge = _DateDiff('s', $aFileTime[0] & "/" & $aFileTime[1] & "/" & $aFileTime[2] & " " & $aFileTime[3] & ":" & $aFileTime[4] & ":" & $aFileTime[5], _NowCalc())
    
    Return $iFileAge > $TEMP_FILE_MAX_AGE
EndFunc