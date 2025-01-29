#include-once
#include <Inet.au3>
#include <String.au3>

Global $g_sevenZipPath = @ScriptDir & "\7z.exe"
Global $g_sevenZipDownloadPage = "https://7-zip.org/download.html"

Func GetLatest7ZipURL()
    _LogDebug("Suche nach aktueller 7-Zip Version")
    
    Local $html = InetRead($g_sevenZipDownloadPage)
    If @error Then
        _LogError("7-Zip Downloadseite nicht erreichbar", "Error: " & @error)
        Return ""
    EndIf
    
    Local $pattern = "href=\"(https://7-zip.org/a/7z(\\d+)-(x64|x86)\\.exe)\""
    Local $matches = StringRegExp($html, $pattern, 3)
    If @error Or UBound($matches) = 0 Then
        _LogError("Keine passende 7-Zip Version gefunden")
        Return ""
    EndIf
    
    Local $url = ""
    If @OSArch = "X64" Then
        For $i = 0 To UBound($matches) - 1
            If StringInStr($matches[$i], "x64") Then 
                $url = $matches[$i]
                ExitLoop
            EndIf
        Next
    Else
        For $i = 0 To UBound($matches) - 1
            If StringInStr($matches[$i], "x86") Then 
                $url = $matches[$i]
                ExitLoop
            EndIf
        Next
    EndIf
    
    If $url <> "" Then
        _LogInfo("7-Zip Download URL gefunden", "URL: " & $url)
    EndIf
    
    Return $url
EndFunc

Func CheckAndDownload7Zip()
    _LogInfo("Überprüfe 7-Zip Installation")
    
    If Not FileExists($g_sevenZipPath) Then
        Local $url = GetLatest7ZipURL()
        If $url = "" Then
            _LogError("7-Zip Download fehlgeschlagen", "Konnte keine Download-URL ermitteln")
            MsgBox(16, "Fehler", "Konnte die aktuelle 7-Zip-Version nicht ermitteln!")
            Return False
        EndIf
        
        _LogInfo("Starte 7-Zip Download", "URL: " & $url)
        InetGet($url, $g_sevenZipPath, 1, 1)
        
        Local $downloadSuccess = False
        Local $startTime = TimerInit()
        Do
            Sleep(500)
            If TimerDiff($startTime) > 60000 Then
                _LogError("7-Zip Download Timeout")
                ExitLoop
            EndIf
        Until InetGetInfo($g_sevenZipPath, 2) = 1
        
        If FileExists($g_sevenZipPath) Then
            _LogInfo("7-Zip erfolgreich heruntergeladen")
            MsgBox(64, "7-Zip Download", "7-Zip wurde erfolgreich heruntergeladen!")
            Return True
        Else
            _LogError("7-Zip konnte nicht heruntergeladen werden")
            MsgBox(16, "Fehler", "7-Zip konnte nicht heruntergeladen werden!")
            Return False
        EndIf
    EndIf
    
    Return True
EndFunc

Func _ExtractZip($zipFile, $destFolder, $password = "")
    _LogInfo("Starte Entpackvorgang", "Datei: " & $zipFile & @CRLF & "Ziel: " & $destFolder)
    
    If Not FileExists($zipFile) Then
        _LogError("ZIP-Datei nicht gefunden", "Pfad: " & $zipFile)
        Return False
    EndIf
    
    If Not FileExists($destFolder) Then
        DirCreate($destFolder)
        _LogDebug("Zielverzeichnis erstellt", "Pfad: " & $destFolder)
    EndIf
    
    Local $command = '"' & $g_sevenZipPath & '" x'
    If $password <> "" Then
        $command &= ' -p' & $password
    EndIf
    $command &= ' -o"' & $destFolder & '" "' & $zipFile & '" -y'
    
    _LogDebug("Ausführe 7-Zip Kommando", "Kommando: " & $command)
    
    Local $pid = RunWait($command, "", @SW_HIDE)
    If @error Or $pid = -1 Then
        _LogError("Entpacken fehlgeschlagen", "Fehlercode: " & @error & @CRLF & "Exit Code: " & $pid)
        Return False
    EndIf
    
    _LogInfo("Entpackvorgang abgeschlossen", "Datei: " & $zipFile)
    Return True
EndFunc