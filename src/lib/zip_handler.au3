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
    
    _LogInfo("7-Zip nicht gefunden, starte Download der Standalone Version")
    
    ; Download der Extra Version mit Standalone Console
    Local $sURL = "https://7-zip.org/a/7z2409-extra.7z"
    Local $sTempFile = @TempDir & "\7z-extra.7z"
    Local $sTempDir = @TempDir & "\7z_temp"
    
    _LogInfo("Starte Download von: " & $sURL)
    _LogInfo("Nach: " & $sTempFile)
    
    ; Download mit InetGet und Fortschrittsüberwachung
    Local $hDownload = InetGet($sURL, $sTempFile, $INET_FORCERELOAD)
    
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
    
    If Not FileExists($sTempFile) Then
        _LogError("Download fehlgeschlagen - keine Datei")
        Return False
    EndIf
    
    ; Temporäres Verzeichnis erstellen
    If Not FileExists($sTempDir) Then DirCreate($sTempDir)
    
    ; Wenn wir hier sind und keine 7z.exe haben, müssen wir zuerst 7zr.exe herunterladen
    If Not FileExists(@ScriptDir & "\7zr.exe") Then
        Local $sBootstrapURL = "https://7-zip.org/a/7zr.exe"
        _LogInfo("Lade 7zr.exe für initiales Entpacken")
        InetGet($sBootstrapURL, @ScriptDir & "\7zr.exe", $INET_FORCERELOAD)
    EndIf
    
    ; Extra Paket mit 7zr.exe entpacken
    Local $sCmd = '"' & @ScriptDir & '\7zr.exe" x "' & $sTempFile & '" -o"' & $sTempDir & '" -y'
    _LogInfo("Entpacke Extra Paket: " & $sCmd)
    
    RunWait($sCmd, "", @SW_HIDE)
    
    ; 7z.exe ins Zielverzeichnis kopieren
    If FileExists($sTempDir & "\x64\7z.exe") Then
        _LogInfo("Kopiere 64-bit 7z.exe")
        FileCopy($sTempDir & "\x64\7z.exe", $g_sevenZipPath, $FC_OVERWRITE)
    ElseIf FileExists($sTempDir & "\7z.exe") Then
        _LogInfo("Kopiere 32-bit 7z.exe")
        FileCopy($sTempDir & "\7z.exe", $g_sevenZipPath, $FC_OVERWRITE)
    Else
        _LogError("Keine 7z.exe im Extra Paket gefunden")
        Return False
    EndIf
    
    ; Temporäre Dateien aufräumen
    FileDelete($sTempFile)
    FileDelete(@ScriptDir & "\7zr.exe") ; Bootstrap exe löschen
    DirRemove($sTempDir, 1)
    
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