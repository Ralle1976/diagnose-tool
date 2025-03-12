#include-once
#include <WinHttp.au3>
#include <WinHttpConstants.au3>
#include <File.au3>
#include "logging.au3"
#include "missing_functions.au3"

Func _ProcessZipFile($sFile)
    _LogInfo("Starte ZIP-Datei Verarbeitung: " & $sFile)
    
    Local $sTimeStamp = StringReplace(_NowCalc(), ":", "-")
    $sTimeStamp = StringReplace($sTimeStamp, " ", "_")
    $sTimeStamp = StringReplace($sTimeStamp, "/", "-")
    
    Local $sExtractPath = @TempDir & "\diagnose-tool\extracted\DiagnoseTool_" & $sTimeStamp

    _LogInfo("Extrahiere ZIP-Datei nach: " & $sExtractPath)
    
    Local $sPassword = IniRead($g_sSettingsFile, "ZIP", "password", "")
    $sPassword = StringReplace($sPassword, "password=", "")
    _LogInfo("Passwort aus INI gelesen")

    Local $sCmd = '"' & @ScriptDir & "\7za.exe" & '" x -y'
    If $sPassword <> "" Then
        $sCmd &= ' -p"' & $sPassword & '"'
    EndIf
    $sCmd &= ' -o"' & $sExtractPath & '" "' & $sFile & '"'

    DirCreate($sExtractPath)

    Local $iPID = Run($sCmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    Local $sOutput = "", $sError = ""
    
    While ProcessExists($iPID)
        $sOutput &= StdoutRead($iPID)
        $sError &= StderrRead($iPID)
        Sleep(100)
    WEnd
    
    ProcessWaitClose($iPID)
    
    $sOutput &= StdoutRead($iPID)
    $sError &= StderrRead($iPID)

    If StringLen($sError) > 0 Then
        _LogError("Fehler beim Entpacken: " & $sError)
        Return False
    EndIf

    _LogInfo("ZIP-Datei erfolgreich entpackt")
    Return _ProcessExtractedFiles($sExtractPath)
EndFunc