#Region Logging-System
Global Enum $LOG_DEBUG, $LOG_INFO, $LOG_WARNING, $LOG_ERROR
Global $g_logLevel = $LOG_INFO
Global $g_logFile = @ScriptDir & "\logs\app.log"
Global $g_maxLogSize = 10 * 1024 * 1024 ; 10MB
Global $g_logRotateCount = 5

Func _LogInit($logFile = Default, $logLevel = Default)
    If $logFile <> Default Then $g_logFile = $logFile
    If $logLevel <> Default Then $g_logLevel = $logLevel
    
    Local $logDir = StringRegExpReplace($g_logFile, "\\[^\\]+$", "")
    If Not FileExists($logDir) Then DirCreate($logDir)
    
    _LogRotateIfNeeded()
    _Log($LOG_INFO, "=== Logging gestartet " & _NowCalc() & " ===")
EndFunc

Func _Log($level, $message, $details = "")
    If $level < $g_logLevel Then Return
    
    Local $levelStr
    Switch $level
        Case $LOG_DEBUG
            $levelStr = "DEBUG"
        Case $LOG_INFO
            $levelStr = "INFO "
        Case $LOG_WARNING
            $levelStr = "WARN "
        Case $LOG_ERROR
            $levelStr = "ERROR"
    EndSwitch
    
    Local $logEntry = _
        @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " " & _
        "[" & $levelStr & "] " & _
        $message
    
    If $details <> "" Then
        $logEntry &= @CRLF & "    " & StringReplace($details, @CRLF, @CRLF & "    ")
    EndIf
    
    FileWrite($g_logFile, $logEntry & @CRLF)
    _LogRotateIfNeeded()
EndFunc

Func _LogRotateIfNeeded()
    If Not FileExists($g_logFile) Then Return
    
    If FileGetSize($g_logFile) >= $g_maxLogSize Then
        For $i = $g_logRotateCount - 1 To 1 Step -1
            Local $oldFile = $g_logFile & "." & $i
            Local $newFile = $g_logFile & "." & ($i + 1)
            If FileExists($oldFile) Then FileMove($oldFile, $newFile, 1)
        Next
        
        FileMove($g_logFile, $g_logFile & ".1", 1)
        _Log($LOG_INFO, "=== Neues Log gestartet nach Rotation ===")
    EndIf
EndFunc

Func _LogDebug($message, $details = "")
    _Log($LOG_DEBUG, $message, $details)
EndFunc

Func _LogInfo($message, $details = "")
    _Log($LOG_INFO, $message, $details)
EndFunc

Func _LogWarning($message, $details = "")
    _Log($LOG_WARNING, $message, $details)
EndFunc

Func _LogError($message, $details = "")
    _Log($LOG_ERROR, $message, $details)
EndFunc
#EndRegion