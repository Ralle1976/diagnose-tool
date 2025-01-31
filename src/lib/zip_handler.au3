#include-once
#include <WinHttp.au3>
#include <WinHttpConstants.au3>
#include <Misc-api.au3>
#include <String.au3>
#include <InetConstants.au3>
#include <FileConstants.au3>
#include "logging.au3"

Global $g_sevenZipPath = @ScriptDir & "\7zr.exe"
Global Const $g_sSevenZipBaseUrl = "https://www.7-zip.org/"

; Download und Installation von 7-Zip
Func CheckAndDownload7Zip()
    _LogInfo("Prüfe 7-Zip Installation")
    
    ; Prüfen ob 7zr.exe existiert
    If FileExists($g_sevenZipPath) Then
        _LogInfo("7-Zip bereits vorhanden: " & $g_sevenZipPath)
        Return True
    EndIf
    
    _LogInfo("7-Zip nicht gefunden, starte Download der Console Version")
    
    ; Download der standalone Console Version
    Local $sURL = $g_sSevenZipBaseUrl & "a/7zr.exe"
    
    _LogInfo("Starte Download von: " & $sURL)
    _LogInfo("Nach: " & $g_sevenZipPath)
    
    ; Download mit InetGet und Fortschrittsüberwachung
    Local $hDownload = InetGet($sURL, $g_sevenZipPath, $INET_FORCERELOAD)
    
    ; Download-Fortschritt überwachen
    Local $iSize = InetGetSize($sURL)
    _LogInfo("Download-Größe: " & $iSize & " bytes")
    
    While Not InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
        Local $iBytes = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
        Local $iProgress = Round($iBytes/$iSize*100)
        _LogInfo("Download-Fortschritt: " & Round($iBytes/1024) & " KB / " & Round($iSize/1024) & " KB (" & $iProgress & "%)")
        Sleep(250)
    WEnd
    
    InetClose($hDownload)
    
    If Not FileExists($g_sevenZipPath) Then
        _LogError("Download fehlgeschlagen - keine Datei")
        Return False
    EndIf
    
    Local $iFileSize = FileGetSize($g_sevenZipPath)
    _LogInfo("Heruntergeladene Dateigröße: " & $iFileSize & " bytes")
    
    If $iFileSize < 100000 Then ; Mindestgröße prüfen
        _LogError("Download fehlgeschlagen - Datei zu klein: " & $iFileSize & " bytes")
        Return False
    EndIf
    
    _LogInfo("7-Zip Console Version erfolgreich heruntergeladen")
    Return True
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