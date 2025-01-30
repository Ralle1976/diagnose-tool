#include-once
#include <File.au3>
#include <Array.au3>
#include "error_handler.au3"
#include "logging.au3"

; CSV Export Funktion
Func _CSV_Export($sFilePath, $aData, $sDelimiter = ";")
    If Not IsArray($aData) Then
        _ErrorHandler_HandleError($ERROR_TYPE_INPUT, "Ungültige Eingabedaten für CSV Export", $ERROR_LEVEL_ERROR)
        Return False
    EndIf
    
    ; Datei öffnen
    Local $hFile = FileOpen($sFilePath, $FO_OVERWRITE + $FO_UNICODE)
    If $hFile = -1 Then
        _ErrorHandler_HandleError($ERROR_TYPE_FILE, "Fehler beim Erstellen der CSV Datei", $ERROR_LEVEL_ERROR)
        Return False
    EndIf
    
    ; Daten schreiben
    For $i = 0 To UBound($aData) - 1
        ; Zeile zusammenbauen
        Local $sLine = ""
        For $j = 0 To UBound($aData[$i]) - 1
            ; Wert escapen wenn nötig
            Local $sValue = $aData[$i][$j]
            If StringInStr($sValue, $sDelimiter) Or StringInStr($sValue, '"') Then
                $sValue = '"' & StringReplace($sValue, '"', '""') & '"'
            EndIf
            
            ; Zur Zeile hinzufügen
            $sLine &= $sValue
            If $j < UBound($aData[$i]) - 1 Then $sLine &= $sDelimiter
        Next
        
        ; Zeile schreiben
        FileWriteLine($hFile, $sLine)
    Next
    
    ; Datei schließen
    FileClose($hFile)
    
    Return True
EndFunc

; CSV Import Funktion
Func _CSV_Import($sFilePath, $sDelimiter = ";")
    If Not FileExists($sFilePath) Then
        _ErrorHandler_HandleError($ERROR_TYPE_FILE, "CSV Datei nicht gefunden", $ERROR_LEVEL_ERROR)
        Return False
    EndIf
    
    ; Datei einlesen
    Local $aLines = FileReadToArray($sFilePath)
    If @error Then
        _ErrorHandler_HandleError($ERROR_TYPE_FILE, "Fehler beim Lesen der CSV Datei", $ERROR_LEVEL_ERROR)
        Return False
    EndIf
    
    Local $aData[UBound($aLines)]
    
    ; Zeilen verarbeiten
    For $i = 0 To UBound($aLines) - 1
        Local $sLine = $aLines[$i]
        Local $aFields = []
        Local $iStart = 1, $iPos = 1
        Local $bInQuotes = False
        
        ; Zeile parsen
        While $iPos <= StringLen($sLine)
            Local $sChar = StringMid($sLine, $iPos, 1)
            
            ; Anführungszeichen behandeln
            If $sChar = '"' Then
                $bInQuotes = Not $bInQuotes
            ; Delimiter gefunden
            ElseIf $sChar = $sDelimiter And Not $bInQuotes Then
                Local $sField = StringMid($sLine, $iStart, $iPos - $iStart)
                ; Anführungszeichen entfernen wenn vorhanden
                If StringLeft($sField, 1) = '"' And StringRight($sField, 1) = '"' Then
                    $sField = StringMid($sField, 2, StringLen($sField) - 2)
                EndIf
                _ArrayAdd($aFields, $sField)
                $iStart = $iPos + 1
            EndIf
            
            $iPos += 1
        WEnd
        
        ; Letztes Feld hinzufügen
        Local $sField = StringMid($sLine, $iStart)
        If StringLeft($sField, 1) = '"' And StringRight($sField, 1) = '"' Then
            $sField = StringMid($sField, 2, StringLen($sField) - 2)
        EndIf
        _ArrayAdd($aFields, $sField)
        
        $aData[$i] = $aFields
    Next
    
    Return $aData
EndFunc