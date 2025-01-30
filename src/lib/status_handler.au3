#include-once
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "error_handler.au3"

; Statusleisten-Bereiche
Global Const $STATUS_MAIN = 0
Global Const $STATUS_ITEMS = 1
Global Const $STATUS_MEMORY = 2
Global Const $STATUS_TIME = 3

; Globale Variablen für Status
Global $g_hStatusBar
Global $g_iLastUpdate = 0
Global $g_iMemoryLimit = 1024 * 1024 * 1024 ; 1GB
Global $g_sLastOperation = ""

; Initialisiert die erweiterte Statusleiste
Func InitStatusBar($hGUI, $iWidth)
    ; Erstelle Statusleiste mit 4 Bereichen
    $g_hStatusBar = _GUICtrlStatusBar_Create($hGUI)
    
    ; Definiere Breiten für die Bereiche
    Local $aParts[4] = [ _
        Int($iWidth * 0.4),  _ ; Hauptstatus
        Int($iWidth * 0.25), _ ; Elementanzahl
        Int($iWidth * 0.2),  _ ; Speichernutzung
        -1]                    ; Zeit (Rest)
    
    _GUICtrlStatusBar_SetParts($g_hStatusBar, $aParts)
    
    ; Initialer Status
    UpdateMainStatus("Bereit")
    UpdateItemCount(0)
    UpdateMemoryStatus()
    UpdateTimeStatus()
    
    ; Timer für regelmäßige Updates
    AdlibRegister("_UpdateStatusTimer", 1000)
    
    Return $g_hStatusBar
EndFunc

; Aktualisiert den Hauptstatus
Func UpdateMainStatus($sStatus)
    $g_sLastOperation = $sStatus
    _GUICtrlStatusBar_SetText($g_hStatusBar, $sStatus, $STATUS_MAIN)
EndFunc

; Aktualisiert die Elementanzahl
Func UpdateItemCount($iCount, $iTotal = 0)
    Local $sText
    If $iTotal > 0 Then
        $sText = "Elemente: " & $iCount & " / " & $iTotal
    Else
        $sText = "Elemente: " & $iCount
    EndIf
    _GUICtrlStatusBar_SetText($g_hStatusBar, $sText, $STATUS_ITEMS)
EndFunc

; Aktualisiert den Speicherstatus
Func UpdateMemoryStatus()
    Local $iMemUsed = MemGetStats()
    Local $iPercent = Int($iMemUsed * 100 / $g_iMemoryLimit)
    
    Local $sText = "RAM: " & _FormatSize($iMemUsed)
    If $iPercent > 80 Then
        ; Warnung bei hoher Speichernutzung
        $sText &= " (!)"
        _LogWarning("Hohe Speichernutzung: " & $iPercent & "%")
    EndIf
    
    _GUICtrlStatusBar_SetText($g_hStatusBar, $sText, $STATUS_MEMORY)
EndFunc

; Aktualisiert die Zeitanzeige
Func UpdateTimeStatus()
    Local $sText = "Letzte Aktion: "
    
    ; Berechne vergangene Zeit
    Local $iDiff = TimerDiff($g_iLastUpdate)
    If $g_iLastUpdate = 0 Then
        $sText &= "Keine"
    ElseIf $iDiff < 60000 Then
        $sText &= "Vor " & Int($iDiff / 1000) & " Sek."
    ElseIf $iDiff < 3600000 Then
        $sText &= "Vor " & Int($iDiff / 60000) & " Min."
    Else
        $sText &= "Vor " & Int($iDiff / 3600000) & " Std."
    EndIf
    
    _GUICtrlStatusBar_SetText($g_hStatusBar, $sText, $STATUS_TIME)
EndFunc

; Timer-Funktion für regelmäßige Updates
Func _UpdateStatusTimer()
    Static $iLastMemUpdate = 0
    
    ; Update Speicherstatus alle 5 Sekunden
    If TimerDiff($iLastMemUpdate) >= 5000 Then
        UpdateMemoryStatus()
        $iLastMemUpdate = TimerInit()
    EndIf
    
    ; Update Zeitstatus
    UpdateTimeStatus()
EndFunc

; Zeigt einen temporären Status an
Func ShowTempStatus($sStatus, $iDuration = 3000)
    Local $sOldStatus = _GUICtrlStatusBar_GetText($g_hStatusBar, $STATUS_MAIN)
    UpdateMainStatus($sStatus)
    
    ; Timer für Zurücksetzen
    AdlibRegister("_ResetTempStatus", $iDuration)
    
    Return $sOldStatus
EndFunc

; Setzt temporären Status zurück
Func _ResetTempStatus()
    AdlibUnRegister("_ResetTempStatus")
    UpdateMainStatus($g_sLastOperation)
EndFunc

; Zeigt einen Fortschrittsbalken in der Statusleiste
Func ShowStatusProgress($iPercent)
    Local $sProgress = ""
    Local $iBlocks = Int($iPercent / 5)
    
    ; Erstelle Fortschrittsbalken mit Blockzeichen
    For $i = 1 To 20
        If $i <= $iBlocks Then
            $sProgress &= "█"
        Else
            $sProgress &= "░"
        EndIf
    Next
    
    $sProgress &= " " & $iPercent & "%"
    _GUICtrlStatusBar_SetText($g_hStatusBar, $sProgress, $STATUS_MAIN)
EndFunc

; Formatiert Größenangaben lesbar
Func _FormatSize($iBytes)
    Local $aSize = ["B", "KB", "MB", "GB"]
    Local $iIndex = 0
    Local $iValue = $iBytes
    
    While $iValue >= 1024 And $iIndex < 3
        $iValue = $iValue / 1024
        $iIndex += 1
    WEnd
    
    Return Round($iValue, 1) & " " & $aSize[$iIndex]
EndFunc

; Aufräumen beim Beenden
Func _StatusHandler_Cleanup()
    AdlibUnRegister("_UpdateStatusTimer")
EndFunc