#include-once
#include <FileConstants.au3>
#include <ProgressConstants.au3>
#include "password_manager.au3"
#include "error_handler.au3"

Global Const $7ZIP_PATH = @ScriptDir & "\tools\7z.exe"

; Prüft ob 7-Zip verfügbar ist und lädt es ggf. herunter
Func InitializeZipHandler()
    If Not FileExists($7ZIP_PATH) Then
        _LogMessage("7-Zip wird heruntergeladen...")
        ; TODO: Download-Logik implementieren
        Return False
    EndIf
    Return True
EndFunc

; Extrahiert eine ZIP-Datei
Func ExtractZipFile($sZipFile, $sDestPath)
    If Not FileExists($sZipFile) Then
        _LogError("ZIP-Datei nicht gefunden: " & $sZipFile)
        Return False
    EndIf
    
    ; Prüfe ob ein Passwort gespeichert ist
    Local $sPassword = GetPassword($sZipFile)
    Local $sCmd
    
    If $sPassword = "" Then
        ; Kein Passwort gefunden - frage nach
        $sPassword = InputBox("Passwort erforderlich", "Bitte geben Sie das Passwort für " & $sZipFile & " ein:", "", "*")
        If @error Then Return False
        
        ; Frage ob Passwort gespeichert werden soll
        Local $iSave = MsgBox($MB_YESNO, "Passwort speichern", "Soll das Passwort für zukünftige Verwendung gespeichert werden?")
        If $iSave = $IDYES Then
            SavePassword($sZipFile, $sPassword)
        EndIf
    EndIf
    
    ; Erstelle Extraktionsbefehl
    If $sPassword <> "" Then
        $sCmd = '"' & $7ZIP_PATH & '" x "' & $sZipFile & '" -o"' & $sDestPath & '" -p"' & $sPassword & '" -y'
    Else
        $sCmd = '"' & $7ZIP_PATH & '" x "' & $sZipFile & '" -o"' & $sDestPath & '" -y'
    EndIf
    
    ; Führe Extraktion aus
    Local $iPID = Run($sCmd, "", @SW_HIDE, $STDOUT_CHILD)
    If @error Then
        _LogError("Fehler beim Ausführen von 7-Zip")
        Return False
    EndIf
    
    ; Warte auf Abschluss
    Local $sOutput = ""
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ExitLoop
        
        ; TODO: Fortschrittsanzeige aktualisieren
    WEnd
    
    ; Prüfe Ergebnis
    Local $iExitCode = ProcessWaitClose($iPID)
    If $iExitCode <> 0 Then
        _LogError("Fehler beim Entpacken: " & $sOutput)
        Return False
    EndIf
    
    _LogMessage("ZIP-Datei erfolgreich entpackt: " & $sZipFile)
    Return True
EndFunc

; Erstellt eine ZIP-Datei
Func CreateZipFile($sZipFile, $sSourcePath, $sPassword = "")
    If $sPassword <> "" Then
        ; Speichere Passwort wenn angegeben
        SavePassword($sZipFile, $sPassword)
        $sCmd = '"' & $7ZIP_PATH & '" a "' & $sZipFile & '" "' & $sSourcePath & '" -p"' & $sPassword & '" -y'
    Else
        $sCmd = '"' & $7ZIP_PATH & '" a "' & $sZipFile & '" "' & $sSourcePath & '" -y'
    EndIf
    
    Local $iPID = Run($sCmd, "", @SW_HIDE, $STDOUT_CHILD)
    If @error Then
        _LogError("Fehler beim Erstellen der ZIP-Datei")
        Return False
    EndIf
    
    ; Warte auf Abschluss
    Local $sOutput = ""
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ExitLoop
    WEnd
    
    Local $iExitCode = ProcessWaitClose($iPID)
    If $iExitCode <> 0 Then
        _LogError("Fehler beim Erstellen der ZIP-Datei: " & $sOutput)
        Return False
    EndIf
    
    _LogMessage("ZIP-Datei erfolgreich erstellt: " & $sZipFile)
    Return True
EndFunc