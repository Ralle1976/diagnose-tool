#include-once
#include <Crypt.au3>
#include <FileConstants.au3>
#include "error_handler.au3"

; Globale Konstanten
Global Const $PASSWORD_FILE = @ScriptDir & "\config\passwords.dat"
Global Const $SALT = "DiagnoseTool2025" ; Salt für zusätzliche Sicherheit

; Initialisierung der Verschlüsselung
_Crypt_Startup()

; Passwort verschlüsselt speichern
Func SavePassword($sFileName, $sPassword)
    ; Erstelle Verzeichnis falls nicht vorhanden
    DirCreate(@ScriptDir & "\config")
    
    ; Verschlüssele das Passwort
    Local $sEncrypted = _Crypt_EncryptData($sPassword & $SALT, "diagnose-tool-key", $CALG_AES_256)
    If @error Then
        _LogError("Fehler beim Verschlüsseln des Passworts")
        Return False
    EndIf
    
    ; Speichere verschlüsseltes Passwort mit Dateinamen
    Local $hFile = FileOpen($PASSWORD_FILE, $FO_APPEND)
    If $hFile = -1 Then
        _LogError("Fehler beim Öffnen der Passwortdatei")
        Return False
    EndIf
    
    FileWriteLine($hFile, $sFileName & "|" & $sEncrypted)
    FileClose($hFile)
    Return True
EndFunc

; Passwort für eine bestimmte Datei abrufen
Func GetPassword($sFileName)
    If Not FileExists($PASSWORD_FILE) Then
        _LogError("Passwortdatei nicht gefunden")
        Return ""
    EndIf
    
    ; Lese Passwortdatei
    Local $aLines = FileReadToArray($PASSWORD_FILE)
    If @error Then
        _LogError("Fehler beim Lesen der Passwortdatei")
        Return ""
    EndIf
    
    ; Suche nach Dateinamen
    For $sLine In $aLines
        Local $aParts = StringSplit($sLine, "|", $STR_NOCOUNT)
        If $aParts[0] = $sFileName Then
            ; Entschlüssele das Passwort
            Local $sDecrypted = _Crypt_DecryptData($aParts[1], "diagnose-tool-key", $CALG_AES_256)
            If @error Then
                _LogError("Fehler beim Entschlüsseln des Passworts")
                Return ""
            EndIf
            
            ; Entferne Salt
            Return StringReplace($sDecrypted, $SALT, "")
        EndIf
    Next
    
    Return "" ; Kein Passwort gefunden
EndFunc

; Passwort für eine Datei entfernen
Func RemovePassword($sFileName)
    If Not FileExists($PASSWORD_FILE) Then
        Return False
    EndIf
    
    Local $aLines = FileReadToArray($PASSWORD_FILE)
    If @error Then
        _LogError("Fehler beim Lesen der Passwortdatei")
        Return False
    EndIf
    
    ; Temporäre Datei erstellen
    Local $hTemp = FileOpen($PASSWORD_FILE & ".tmp", $FO_OVERWRITE)
    If $hTemp = -1 Then
        _LogError("Fehler beim Erstellen der temporären Datei")
        Return False
    EndIf
    
    ; Kopiere alle Einträge außer den zu löschenden
    For $sLine In $aLines
        Local $aParts = StringSplit($sLine, "|", $STR_NOCOUNT)
        If $aParts[0] <> $sFileName Then
            FileWriteLine($hTemp, $sLine)
        EndIf
    Next
    
    FileClose($hTemp)
    
    ; Ersetze alte Datei mit neuer
    FileMove($PASSWORD_FILE & ".tmp", $PASSWORD_FILE, $FC_OVERWRITE)
    Return True
EndFunc

; Aufräumen beim Beenden
Func _PasswordManager_Cleanup()
    _Crypt_Shutdown()
EndFunc