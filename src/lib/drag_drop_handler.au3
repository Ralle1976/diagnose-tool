#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <File.au3>
#include "error_handler.au3"

; Konstanten für Drag & Drop
Global Const $WM_DROPFILES = 0x0233
Global Const $CF_HDROP = 15

; Erlaubte Dateitypen
Global $g_aAllowedExtensions[] = ["zip", "sqlite", "db", "csv", "xlsx"]

; Aktiviert Drag & Drop für ein Fenster
Func EnableDragDrop($hWnd)
    _WinAPI_ChangeWindowMessageFilterEx($hWnd, $WM_DROPFILES, $MSGFLT_ALLOW)
    _WinAPI_DragAcceptFiles($hWnd, True)
    Return True
EndFunc

; Verarbeitet Drop-Events
Func HandleFileDrop($hWnd, $hDrop)
    ; Hole Anzahl der gedropten Dateien
    Local $iFileCount = DllCall("shell32.dll", "uint", "DragQueryFileW", "handle", $hDrop, "uint", 0xFFFFFFFF, "ptr", 0, "uint", 0)[0]
    If @error Then
        _LogError("Fehler beim Abrufen der Dateianzahl")
        Return False
    EndIf
    
    Local $aFiles[0]
    
    ; Verarbeite jede Datei
    For $i = 0 To $iFileCount - 1
        ; Hole Dateinamen
        Local $iLength = DllCall("shell32.dll", "uint", "DragQueryFileW", "handle", $hDrop, "uint", $i, "ptr", 0, "uint", 0)[0]
        Local $tFileName = DllStructCreate("wchar[" & $iLength + 1 & "]")
        DllCall("shell32.dll", "uint", "DragQueryFileW", "handle", $hDrop, "uint", $i, "struct*", $tFileName, "uint", $iLength + 1)
        
        Local $sFileName = DllStructGetData($tFileName, 1)
        
        ; Prüfe Dateityp
        If IsAllowedFile($sFileName) Then
            _ArrayAdd($aFiles, $sFileName)
            _LogMessage("Datei akzeptiert: " & $sFileName)
        Else
            _LogWarning("Nicht unterstützter Dateityp: " & $sFileName)
            ShowInvalidFileTypeMessage($sFileName)
        EndIf
    Next
    
    ; Gebe Handle frei
    _WinAPI_DragFinish($hDrop)
    
    ; Wenn Dateien gefunden wurden, verarbeite sie
    If UBound($aFiles) > 0 Then
        Return ProcessDroppedFiles($aFiles)
    EndIf
    
    Return False
EndFunc

; Prüft ob eine Datei erlaubt ist
Func IsAllowedFile($sFilePath)
    Local $sExtension = StringLower(_PathGetExt($sFilePath))
    $sExtension = StringTrimLeft($sExtension, 1) ; Entferne den Punkt
    
    For $sAllowed In $g_aAllowedExtensions
        If $sExtension = $sAllowed Then Return True
    Next
    
    Return False
EndFunc

; Zeigt Fehlermeldung für ungültige Dateitypen
Func ShowInvalidFileTypeMessage($sFileName)
    Local $sAllowed = _ArrayToString($g_aAllowedExtensions, ", ", 0, -1)
    MsgBox($MB_ICONWARNING, "Ungültiger Dateityp", _
        "Die Datei '" & $sFileName & "' kann nicht verarbeitet werden." & @CRLF & @CRLF & _
        "Erlaubte Dateitypen sind: " & $sAllowed)
EndFunc

; Verarbeitet die gedropten Dateien
Func ProcessDroppedFiles($aFiles)
    ; Zeige Fortschrittsanzeige
    Local $hProgress = ShowProgressDialog("Verarbeite Dateien", "Initialisiere...")
    
    ; Verarbeite jede Datei
    For $i = 0 To UBound($aFiles) - 1
        Local $sFile = $aFiles[$i]
        Local $iProgress = ($i + 1) * 100 / UBound($aFiles)
        
        ; Update Fortschrittsanzeige
        UpdateProgress($hProgress, $iProgress, "Verarbeite: " & _PathGetFileName($sFile))
        
        ; Verarbeite basierend auf Dateityp
        Switch StringLower(_PathGetExt($sFile))
            Case ".zip"
                _ProcessZipFile($sFile)
            Case ".sqlite", ".db"
                _ProcessDatabaseFile($sFile)
            Case ".csv"
                _ProcessCSVFile($sFile)
            Case ".xlsx"
                _ProcessExcelFile($sFile)
        EndSwitch
    Next
    
    ; Schließe Fortschrittsanzeige
    CloseProgressDialog($hProgress)
    
    Return True
EndFunc

; Hilfsfunktionen für die Dateiverarbeitung
Func _ProcessZipFile($sFile)
    _LogMessage("Verarbeite ZIP: " & $sFile)
    ; Integration mit zip_handler.au3
EndFunc

Func _ProcessDatabaseFile($sFile)
    _LogMessage("Verarbeite Datenbank: " & $sFile)
    ; Integration mit sqlite_handler.au3
EndFunc

Func _ProcessCSVFile($sFile)
    _LogMessage("Verarbeite CSV: " & $sFile)
    ; Integration mit csv_handler.au3
EndFunc

Func _ProcessExcelFile($sFile)
    _LogMessage("Verarbeite Excel: " & $sFile)
    ; Integration mit excel_handler.au3
EndFunc

; Fortschrittsanzeige Funktionen
Func ShowProgressDialog($sTitle, $sMessage)
    Local $hGui = GUICreate($sTitle, 300, 100)
    Local $idProgress = GUICtrlCreateProgress(20, 50, 260, 20)
    Local $idLabel = GUICtrlCreateLabel($sMessage, 20, 20, 260, 20)
    GUISetState(@SW_SHOW)
    Return Dict($hGui, $idProgress, $idLabel)
EndFunc

Func UpdateProgress($hProgress, $iPercent, $sMessage)
    Local $hGui = Dict_Get($hProgress, "GUI")
    Local $idProgress = Dict_Get($hProgress, "Progress")
    Local $idLabel = Dict_Get($hProgress, "Label")
    
    GUICtrlSetData($idProgress, $iPercent)
    GUICtrlSetData($idLabel, $sMessage)
EndFunc

Func CloseProgressDialog($hProgress)
    Local $hGui = Dict_Get($hProgress, "GUI")
    GUIDelete($hGui)
EndFunc

; Dictionary Hilfsfunktionen
Func Dict($hGui, $idProgress, $idLabel)
    Local $aDict[3][2] = [["GUI", $hGui], ["Progress", $idProgress], ["Label", $idLabel]]
    Return $aDict
EndFunc

Func Dict_Get($aDict, $sKey)
    For $i = 0 To UBound($aDict) - 1
        If $aDict[$i][0] = $sKey Then Return $aDict[$i][1]
    Next
    Return Null
EndFunc