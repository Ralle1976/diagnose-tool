#include-once
#include <WinHttp.au3>
#include <WinHttpConstants.au3>
#include <Misc-api.au3>
#include <String.au3>
#include <InetConstants.au3>
#include <FileConstants.au3>
#include "logging.au3"

Global $g_sevenZipPath = @ScriptDir & "\7z.exe"

; Download und Installation von 7-Zip
Func CheckAndDownload7Zip()
    _LogInfo("Prüfe 7-Zip Installation")
    
    ; Prüfen ob 7z.exe existiert
    If FileExists($g_sevenZipPath) Then
        _LogInfo("7-Zip bereits vorhanden: " & $g_sevenZipPath)
        Return True
    EndIf
    
    _LogInfo("7-Zip nicht gefunden, starte Download")
    
    ; Download direkt von der aktuellen Version
    Local $sURL = "https://7-zip.org/a/7z2409-x64.exe"
    Local $sSetupFile = @ScriptDir & "\7z_setup.exe"
    
    _LogInfo("Starte Download von: " & $sURL)
    _LogInfo("Nach: " & $sSetupFile)
    
    ; Download mit InetGet
    Local $hDownload = InetGet($sURL, $sSetupFile, BitOR($INET_FORCERELOAD, $INET_IGNORESSL))
    
    ; Download-Fortschritt überwachen
    Local $iSize = InetGetSize($sURL)
    _LogInfo("Download-Größe: " & $iSize & " bytes")
    
    While Not InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
        Local $iBytes = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
        _LogInfo("Download-Fortschritt: " & Round($iBytes/1024) & " KB / " & Round($iSize/1024) & " KB (" & Round($iBytes/$iSize*100) & "%)")
        Sleep(250)
    WEnd
    
    InetClose($hDownload)
    
    If Not FileExists($sSetupFile) Then
        _LogError("Download fehlgeschlagen - keine Datei")
        Return False
    EndIf
    
    Local $iFileSize = FileGetSize($sSetupFile)
    _LogInfo("Heruntergeladene Dateigröße: " & $iFileSize & " bytes")
    
    If $iFileSize < 1000000 Then ; Mindestens ~1MB
        _LogError("Download fehlgeschlagen - Datei zu klein: " & $iFileSize & " bytes")
        Return False
    EndIf
    
    ; Setup ausführen
    _LogInfo("Installiere 7-Zip: " & $sSetupFile)
    Local $iPID = Run($sSetupFile & " /S /D=" & @ScriptDir, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    _LogInfo("Setup gestartet mit PID: " & $iPID)
    
    ; Auf Installation warten
    ProcessWaitClose($iPID)
    _LogInfo("Setup beendet")
    
    ; Setup-Datei aufräumen
    FileDelete($sSetupFile)
    
    ; Prüfen ob Installation erfolgreich war
    If FileExists($g_sevenZipPath) Then
        _LogInfo("7-Zip erfolgreich installiert: " & $g_sevenZipPath)
        Return True
    EndIf
    
    _LogError("7z.exe nach Installation nicht gefunden")
    Return False
EndFunc

; ZIP-Datei entpacken
Func _ExtractZip($sZipFile, $sDestFolder, $sPassword = "")
    _LogInfo("Starte Entpackvorgang", "Datei: " & $sZipFile & @CRLF & "Ziel: " & $sDestFolder)
    
    ; Erst prüfen ob 7-Zip vorhanden ist, sonst herunterladen
    If Not CheckAndDownload7Zip() Then
        _LogError("7-Zip konnte nicht installiert werden")
        Return False
    EndIf
    
    ; Eingaben prüfen
    If Not FileExists($sZipFile) Then
        _LogError("ZIP-Datei nicht gefunden", "Pfad: " & $sZipFile)
        Return False
    EndIf
    
    ; Zielverzeichnis erstellen falls nötig
    If Not FileExists($sDestFolder) Then
        DirCreate($sDestFolder)
        _LogInfo("Zielverzeichnis erstellt: " & $sDestFolder)
    EndIf
    
    ; 7-Zip Kommando bauen
    Local $sCmd = '"' & $g_sevenZipPath & '" x -y'
    If $sPassword <> "" Then $sCmd &= ' -p"' & $sPassword & '"'
    $sCmd &= ' -o"' & $sDestFolder & '" "' & $sZipFile & '"'
    
    _LogInfo("Führe 7-Zip Kommando aus", "Kommando (PW versteckt): " & StringReplace($sCmd, $sPassword, "******"))
    
    Local $iReturn = RunWait($sCmd, "", @SW_HIDE)
    If $iReturn <> 0 Then
        _LogError("Entpacken fehlgeschlagen", "Exit Code: " & $iReturn)
        Return False
    EndIf
    
    _LogInfo("ZIP-Datei erfolgreich entpackt")
    Return True
EndFunc