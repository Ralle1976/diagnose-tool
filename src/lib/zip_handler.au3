#include-once
#include <WinHttp.au3>
#include <WinHttpConstants.au3>
#include <Misc-api.au3>
#include <String.au3>
#include <InetConstants.au3>
#include <FileConstants.au3>
#include "logging.au3"

Global $g_sevenZipPath = @ScriptDir & "\7za.exe"

; Download und Installation von 7-Zip
Func CheckAndDownload7Zip()
    _LogInfo("Prüfe 7-Zip Installation")
    
    ; Prüfen ob 7za.exe existiert
    If FileExists($g_sevenZipPath) Then
        _LogInfo("7-Zip bereits vorhanden: " & $g_sevenZipPath)
        Return True
    EndIf
    
    _LogInfo("7-Zip nicht gefunden, starte Download der Standalone Version")
    
    ; Download der Standalone Version
    Local $sURL = "https://7-zip.org/a/7za920.zip"
    Local $sTempZip = @TempDir & "\7za.zip"
    Local $sTempDir = @TempDir & "\7za_temp"
    
    _LogInfo("Starte Download von: " & $sURL)
    _LogInfo("Nach: " & $sTempZip)
    
    ; Download mit InetGet
    InetGet($sURL, $sTempZip, $INET_FORCERELOAD)
    If @error Then
        _LogError("Download fehlgeschlagen", "Error: " & @error)
        Return False
    EndIf
    
    ; Temporäres Verzeichnis erstellen
    If Not FileExists($sTempDir) Then DirCreate($sTempDir)
    
    ; ZIP entpacken (mit Windows-Bordmitteln)
    _LogInfo("Entpacke 7za.exe")
    Local $oShell = ObjCreate("Shell.Application")
    Local $oDir = $oShell.NameSpace($sTempDir)
    Local $oZip = $oShell.NameSpace($sTempZip)
    $oDir.CopyHere($oZip.Items(), 16)
    
    ; Warten bis Entpacken fertig
    Sleep(2000)
    
    ; 7za.exe in Programmverzeichnis kopieren
    If FileExists($sTempDir & "\7za.exe") Then
        _LogInfo("Kopiere 7za.exe nach: " & $g_sevenZipPath)
        FileCopy($sTempDir & "\7za.exe", $g_sevenZipPath, $FC_OVERWRITE)
    Else
        _LogError("7za.exe nicht gefunden nach Entpacken")
        Return False
    EndIf
    
    ; Temporäre Dateien aufräumen
    FileDelete($sTempZip)
    DirRemove($sTempDir, 1)
    
    ; Prüfen ob Installation erfolgreich war
    If FileExists($g_sevenZipPath) Then
        _LogInfo("7-Zip Standalone erfolgreich installiert: " & $g_sevenZipPath)
        Return True
    EndIf
    
    _LogError("7za.exe nach Installation nicht gefunden")
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