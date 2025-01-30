#include-once
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include "logging.au3"

; Error Handler Konstanten
Global Const $ERROR_LEVEL_WARNING = 1
Global Const $ERROR_LEVEL_ERROR = 2
Global Const $ERROR_LEVEL_CRITICAL = 3

; Error Typen
Global Const $ERROR_TYPE_FILE = "FILE"
Global Const $ERROR_TYPE_DB = "DATABASE"
Global Const $ERROR_TYPE_ZIP = "ZIP"
Global Const $ERROR_TYPE_MEMORY = "MEMORY"
Global Const $ERROR_TYPE_SYSTEM = "SYSTEM"
Global Const $ERROR_TYPE_INPUT = "INPUT"

; Globale Error Handler Variablen
Global $g_bShowErrors = True
Global $g_bLogErrors = True
Global $g_sErrorLogPath = @ScriptDir & "\logs\error.log"

; Initialisierung des Error Handlers
Func _ErrorHandler_Init($bShowErrors = True, $bLogErrors = True, $sLogPath = "")
    $g_bShowErrors = $bShowErrors
    $g_bLogErrors = $bLogErrors
    If $sLogPath Then $g_sErrorLogPath = $sLogPath
    
    ; Erstelle Log-Verzeichnis falls nicht vorhanden
    Local $sLogDir = StringRegExpReplace($g_sErrorLogPath, "\\[^\\]+$", "")
    If Not FileExists($sLogDir) Then DirCreate($sLogDir)
    
    Return True
EndFunc

; Hauptfunktion für Fehlerbehandlung
Func _ErrorHandler_HandleError($sErrorType, $sErrorMessage, $iErrorLevel = $ERROR_LEVEL_ERROR, $vAdditionalInfo = "")
    ; Fehler-String zusammenbauen
    Local $sDateTime = @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
    Local $sErrorString = StringFormat("[%s] [%s] %s: %s", $sDateTime, $sErrorType, $sErrorMessage, $vAdditionalInfo)
    
    ; Logging wenn aktiviert
    If $g_bLogErrors Then
        _FileWriteLog($g_sErrorLogPath, $sErrorString)
    EndIf
    
    ; Fehleranzeige wenn aktiviert
    If $g_bShowErrors Then
        Local $iMsgBoxType
        Switch $iErrorLevel
            Case $ERROR_LEVEL_WARNING
                $iMsgBoxType = $MB_ICONWARNING
            Case $ERROR_LEVEL_ERROR
                $iMsgBoxType = $MB_ICONERROR
            Case $ERROR_LEVEL_CRITICAL
                $iMsgBoxType = $MB_ICONERROR
            Case Else
                $iMsgBoxType = $MB_ICONINFORMATION
        EndSwitch
        
        MsgBox($iMsgBoxType, "Fehler - " & $sErrorType, $sErrorMessage & @CRLF & @CRLF & "Details: " & $vAdditionalInfo)
    EndIf
    
    ; Bei kritischen Fehlern Programm beenden
    If $iErrorLevel = $ERROR_LEVEL_CRITICAL Then Exit
    
    Return SetError(1, 0, False)
EndFunc

; Validierungsfunktionen
Func _ErrorHandler_ValidateInput($vInput, $sType = "STRING", $vMin = 0, $vMax = 0)
    Switch StringUpper($sType)
        Case "STRING"
            If Not IsString($vInput) Then Return SetError(1, 0, False)
            If $vMax > 0 And StringLen($vInput) > $vMax Then Return SetError(2, 0, False)
            If $vMin > 0 And StringLen($vInput) < $vMin Then Return SetError(3, 0, False)
            
        Case "NUMBER"
            If Not IsNumber($vInput) Then Return SetError(1, 0, False)
            If $vMax > 0 And $vInput > $vMax Then Return SetError(2, 0, False)
            If $vMin > 0 And $vInput < $vMin Then Return SetError(3, 0, False)
            
        Case "FILE"
            If Not FileExists($vInput) Then Return SetError(1, 0, False)
            
        Case "DIR"
            If Not FileExists($vInput) Then Return SetError(1, 0, False)
            If Not StringInStr(FileGetAttrib($vInput), "D") Then Return SetError(2, 0, False)
    EndSwitch
    
    Return True
EndFunc

; Beispiel für die Verwendung:
#cs
    ; Initialisierung
    _ErrorHandler_Init()
    
    ; Beispiel für Datei-Validierung
    Local $sFile = "nichtexistiert.txt"
    If Not _ErrorHandler_ValidateInput($sFile, "FILE") Then
        _ErrorHandler_HandleError($ERROR_TYPE_FILE, "Datei nicht gefunden", $ERROR_LEVEL_ERROR, "Datei: " & $sFile)
    EndIf
    
    ; Beispiel für Zahleneingabe-Validierung
    Local $iValue = 101
    If Not _ErrorHandler_ValidateInput($iValue, "NUMBER", 0, 100) Then
        _ErrorHandler_HandleError($ERROR_TYPE_INPUT, "Ungültiger Zahlenwert", $ERROR_LEVEL_WARNING, "Wert muss zwischen 0 und 100 liegen")
    EndIf
#ce
