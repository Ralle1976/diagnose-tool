#include-once
#include <File.au3>
#include "logging.au3"
#include "db_functions.au3"

Func _ExtractZip($sZipFile, $sDestFolder, $sPassword = "")
    _LogInfo("Extrahiere ZIP-Datei: " & $sZipFile)
    
    If Not FileExists($sZipFile) Then
        _LogError("ZIP-Datei nicht gefunden: " & $sZipFile)
        Return False
    EndIf
    
    If Not FileExists($sDestFolder) Then
        DirCreate($sDestFolder)
    EndIf
    
    ; 7za Kommando erstellen
    Local $sCmd = '"' & @ScriptDir & "\7za.exe" & '" x -y'
    If $sPassword <> "" Then
        $sCmd &= ' -p"' & $sPassword & '"'
    EndIf
    $sCmd &= ' -o"' & $sDestFolder & '" "' & $sZipFile & '"'
    
    ; Befehl ausführen
    Local $iPID = Run($sCmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    
    Local $sOutput = "", $sError = ""
    While ProcessExists($iPID)
        $sOutput &= StdoutRead($iPID)
        $sError &= StderrRead($iPID)
        Sleep(100)
    WEnd
    
    ProcessWaitClose($iPID)
    
    If StringLen($sError) > 0 Then
        _LogError("Fehler beim Entpacken: " & $sError)
        Return False
    EndIf
    
    _LogInfo("ZIP-Datei erfolgreich entpackt")
    Return True
EndFunc