#include-once
#include <File.au3>
#include <Date.au3>

Global $g_LogFile = @ScriptDir & "\diagnose.log"

; Info-Level Logging
Func _LogInfo($sMessage, $sDetails = "")
    Local $sTime = _NowTime()
    Local $sLogMessage = "INFO [" & $sTime & "] " & $sMessage
    If $sDetails <> "" Then $sLogMessage &= ": " & $sDetails
    ConsoleWrite($sLogMessage & @CRLF)
    _FileWriteLog($g_LogFile, $sLogMessage)
EndFunc

; Error-Level Logging
Func _LogError($sMessage, $sDetails = "")
    Local $sTime = _NowTime()
    Local $sLogMessage = "ERROR [" & $sTime & "] " & $sMessage
    If $sDetails <> "" Then $sLogMessage &= ": " & $sDetails
    ConsoleWrite($sLogMessage & @CRLF)
    _FileWriteLog($g_LogFile, $sLogMessage)
EndFunc

; Debug-Level Logging 
Func _LogDebug($sMessage, $sDetails = "")
    Local $sTime = _NowTime()
    Local $sLogMessage = "DEBUG [" & $sTime & "] " & $sMessage
    If $sDetails <> "" Then $sLogMessage &= ": " & $sDetails
    ConsoleWrite($sLogMessage & @CRLF)
    _FileWriteLog($g_LogFile, $sLogMessage)
EndFunc