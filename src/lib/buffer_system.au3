#include-once
#include "logging.au3"
#include "lazy_loading.au3"

Global Const $BUFFER_UPDATE_INTERVAL = 100 ; ms
Global Const $BUFFER_MAX_BATCH_SIZE = 1000
Global Const $BUFFER_THRESHOLD = 5000 

Global $g_hBufferTimer = 0
Global $g_aUpdateQueue[0]
Global $g_bBufferingActive = False

Func _Buffer_Init()
    _LogMessage("INFO", "Initialisiere Buffer-System")
    
    $g_hBufferTimer = TimerInit()
    AdlibRegister("_ProcessBuffer", $BUFFER_UPDATE_INTERVAL)
    
    Return True
EndFunc

Func _Buffer_AddToQueue($vData)
    If Not IsArray($vData) Then
        Local $aTemp[1] = [$vData]
        $vData = $aTemp
    EndIf
    
    _ArrayConcatenate($g_aUpdateQueue, $vData)
    
    If UBound($g_aUpdateQueue) > $BUFFER_THRESHOLD And Not $g_bBufferingActive Then
        _LogMessage("INFO", "Aktiviere Buffering - Queue-Größe: " & UBound($g_aUpdateQueue))
        $g_bBufferingActive = True
    EndIf
EndFunc

Func _Buffer_UpdateGUI($hListView, $aData)
    If Not IsHWnd($hListView) Then
        _LogMessage("ERROR", "Ungültiges ListView Handle")
        Return SetError(1, 0, False)
    EndIf
    
    If $g_bBufferingActive Then
        _Buffer_AddToQueue($aData)
        Return True
    EndIf
    
    Return _DirectUpdate($hListView, $aData)
EndFunc

Func _Buffer_Flush($hListView)
    _LogMessage("INFO", "Buffer Flush angefordert")
    
    If UBound($g_aUpdateQueue) > 0 Then
        _DirectUpdate($hListView, $g_aUpdateQueue)
        ReDim $g_aUpdateQueue[0]
    EndIf
    
    $g_bBufferingActive = False
EndFunc

Func _Buffer_Cleanup()
    AdlibUnRegister("_ProcessBuffer")
    ReDim $g_aUpdateQueue[0]
    $g_bBufferingActive = False
EndFunc

; Private Hilfsfunktionen
Func _ProcessBuffer()
    If Not $g_bBufferingActive Or UBound($g_aUpdateQueue) = 0 Then
        Return
    EndIf
    
    If TimerDiff($g_hBufferTimer) < $BUFFER_UPDATE_INTERVAL Then
        Return
    EndIf
    
    Local $iBatchSize = _Min(UBound($g_aUpdateQueue), $BUFFER_MAX_BATCH_SIZE)
    Local $aBatch = _ArrayExtract($g_aUpdateQueue, 0, $iBatchSize - 1)
    
    Local $hListView = GUICtrlGetHandle(GUICtrlGetState())
    If IsHWnd($hListView) Then
        _DirectUpdate($hListView, $aBatch)
    EndIf
    
    _ArrayDelete($g_aUpdateQueue, 0, $iBatchSize - 1)
    $g_hBufferTimer = TimerInit()
EndFunc

Func _DirectUpdate($hListView, $aData)
    Local $iSuccess = 0
    
    _GUICtrlListView_BeginUpdate($hListView)
    
    For $i = 0 To UBound($aData) - 1
        If _GUICtrlListView_AddItem($hListView, $aData[$i]) >= 0 Then
            $iSuccess += 1
        EndIf
    Next
    
    _GUICtrlListView_EndUpdate($hListView)
    
    Return $iSuccess
EndFunc

Func _Min($iVal1, $iVal2)
    Return ($iVal1 < $iVal2) ? $iVal1 : $iVal2
EndFunc