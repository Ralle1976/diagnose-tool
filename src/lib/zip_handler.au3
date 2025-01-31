#include-once
#include <WinHttp.au3>
#include <WinHttpConstants.au3>
#include <Misc-api.au3>
#include <String.au3>
#include <InetConstants.au3>
#include <FileConstants.au3>
#include "logging.au3"

Global $g_sevenZipPath = @ScriptDir & "\7z.exe"

; Download URL von 7-Zip Webseite ermitteln (Methode 1 mit InetGet)
Func _Get7ZipDownloadUrl_INet($sType = "7zr.exe")
    Local $sBaseUrl = "https://7-zip.org/"
    Local $bData = InetRead($sBaseUrl & "download.html")
    If @error Then
        _LogError("Fehler beim Download der Webseite", "Error: " & @error)
        Return ""
    EndIf
    
    Local $sHtml = BinaryToString($bData, 4) ; 4 = UTF-8
    _LogInfo("HTML geladen, Länge: " & StringLen($sHtml))
    
    ; Suche nach dem ersten Vorkommen des Download-Links
    Local $sPattern = '(?i)href="(a/' & $sType & ')"\'  
    Local $aMatch = StringRegExp($sHtml, $sPattern, 1)
    
    If @error Then
        _LogError("Download-Link nicht gefunden", "Pattern: " & $sPattern)
        Return ""
    EndIf
    
    Local $sUrl = $sBaseUrl & $aMatch[0]
    _LogInfo("Download URL gefunden: " & $sUrl)
    Return $sUrl
EndFunc

; Download URL von 7-Zip Webseite ermitteln (Methode 2 mit WinHTTP)
Func _Get7ZipDownloadUrl_HTTP($sType = "7zr.exe")
    Local $sBaseUrl = "https://7-zip.org/"
    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
    
    _LogInfo("Lade Webseite: " & $sBaseUrl & "download.html")
    
    $oHTTP.Open("GET", $sBaseUrl & "download.html", False)
    $oHTTP.Send()
    
    If $oHTTP.Status <> 200 Then
        _LogError("HTTP Fehler: " & $oHTTP.Status)
        Return ""
    EndIf
    
    Local $sHtml = $oHTTP.ResponseText
    _LogInfo("HTML geladen, Länge: " & StringLen($sHtml))
    
    Local $sPattern = '(?i)href="(a/' & $sType & ')"\'  
    Local $aMatch = StringRegExp($sHtml, $sPattern, 1)
    
    If @error Then
        _LogError("Download-Link nicht gefunden", "Pattern: " & $sPattern)
        Return ""
    EndIf
    
    Local $sUrl = $sBaseUrl & $aMatch[0]
    _LogInfo("Download URL gefunden: " & $sUrl)
    Return $sUrl
EndFunc

; Download und Installation von 7-Zip
Func CheckAndDownload7Zip()
    _LogInfo("Prüfe 7-Zip Installation")
    
    ; Prüfen ob 7z.exe existiert
    If FileExists($g_sevenZipPath) Then
        _LogInfo("7-Zip bereits vorhanden: " & $g_sevenZipPath)
        Return True
    EndIf
    
    _LogInfo("7-Zip nicht gefunden, starte Download der Console Version")
    
    ; Versuche zuerst WinHTTP Methode
    Local $sURL = _Get7ZipDownloadUrl_HTTP()
    If $sURL = "" Then
        _LogInfo("WinHTTP fehlgeschlagen, versuche InetGet...")
        $sURL = _Get7ZipDownloadUrl_INet()
    EndIf
    
    If $sURL = "" Then
        _LogError("Konnte Download-URL nicht ermitteln")
        Return False
    EndIf
    
    _LogInfo("Starte Download von: " & $sURL)
    _LogInfo("Nach: " & $g_sevenZipPath)
    
    ; Download mit InetGet
    Local $hDownload = InetGet($sURL, $g_sevenZipPath, $INET_FORCERELOAD)
    If @error Then
        _LogError("Download fehlgeschlagen", "Error: " & @error)
        Return False
    EndIf
    
    InetClose($hDownload)
    
    ; Prüfen ob Download erfolgreich war
    If Not FileExists($g_sevenZipPath) Then
        _LogError("Download fehlgeschlagen - keine Datei")
        Return False
    EndIf
    
    Local $iFileSize = FileGetSize($g_sevenZipPath)
    _LogInfo("Heruntergeladene Dateigröße: " & $iFileSize & " bytes")
    
    If $iFileSize < 100000 Then ; Mindestgröße für exe
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