#include <AutoItConstants.au3>
#include <Memory.au3>

Global $g_hMemoryManager = 0
Global $g_iMemThreshold = 80 ; Standard: 80% RAM-Nutzung

Func _MemoryManager_Initialize()
    $g_hMemoryManager = DllOpen("kernel32.dll")
    If $g_hMemoryManager = -1 Then Return SetError(1, 0, False)
    Return True
EndFunc

Func _MemoryManager_SetThreshold($iThreshold)
    If $iThreshold < 0 Or $iThreshold > 100 Then Return SetError(1, 0, False)
    $g_iMemThreshold = $iThreshold
    Return True
EndFunc

Func _MemoryManager_Cleanup()
    If Not ProcessExists(@AutoItPID) Then Return SetError(1, 0, False)
    Local $aMemStats = MemGetStats()
    If $aMemStats[0] > $g_iMemThreshold Then
        GC_Collect() ; Garbage Collection
        _TempFile_CleanupAll()
        Return True
    EndFunc
    Return False
EndFunc