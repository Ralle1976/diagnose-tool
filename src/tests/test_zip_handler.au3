#include "../lib/zip_handler.au3"

; Test der URL-Ermittlung
Func TestURLDetection()
    ConsoleWrite("=== Test URL Detection ===" & @CRLF)
    
    ; Test WinHTTP Methode
    ConsoleWrite("Testing WinHTTP method..." & @CRLF)
    Local $sUrl1 = _Get7ZipDownloadUrl_HTTP()
    ConsoleWrite("WinHTTP Result: " & $sUrl1 & @CRLF)
    
    ; Test InetGet Methode
    ConsoleWrite(@CRLF & "Testing InetGet method..." & @CRLF)
    Local $sUrl2 = _Get7ZipDownloadUrl_INet()
    ConsoleWrite("InetGet Result: " & $sUrl2 & @CRLF)
    
    ; Vergleiche Ergebnisse
    If $sUrl1 = $sUrl2 And $sUrl1 <> "" Then
        ConsoleWrite(@CRLF & "SUCCESS: Both methods found same URL" & @CRLF)
    Else
        ConsoleWrite(@CRLF & "WARNING: URLs differ or failed" & @CRLF)
    EndIf
EndFunc

; Test des Downloads
Func TestDownload()
    ConsoleWrite(@CRLF & "=== Test Download ===" & @CRLF)
    
    ; Lösche vorhandene exe falls vorhanden
    If FileExists($g_sevenZipPath) Then
        FileDelete($g_sevenZipPath)
    EndIf
    
    ; Teste Download
    Local $result = CheckAndDownload7Zip()
    
    If $result Then
        ConsoleWrite("SUCCESS: Download complete" & @CRLF)
        ConsoleWrite("File size: " & FileGetSize($g_sevenZipPath) & " bytes" & @CRLF)
    Else
        ConsoleWrite("ERROR: Download failed" & @CRLF)
    EndIf
EndFunc

; Haupt-Test
TestURLDetection()
TestDownload()
