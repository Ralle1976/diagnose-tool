#include-once
#include <Excel.au3>
#include <Array.au3>
#include <File.au3>
#include "logging.au3"

Global $g_oExcel = 0
Global $g_oWorkbook = 0
Global $g_sTemplateDir = @ScriptDir & "\templates"

Func _Excel_Init()
    ; Excel-Instanz erstellen
    $g_oExcel = _Excel_Open()
    If @error Then
        _Log_Write("Fehler beim Öffnen von Excel: " & @error)
        Return SetError(1)
    EndIf
    
    ; Template-Verzeichnis prüfen/erstellen
    If Not FileExists($g_sTemplateDir) Then
        DirCreate($g_sTemplateDir)
    EndIf
    
    Return True
EndFunc

Func _Excel_CreateFromTemplate($sTemplate = "")
    ; Wenn kein Template angegeben, neue Arbeitsmappe erstellen
    If $sTemplate = "" Then
        $g_oWorkbook = _Excel_BookNew($g_oExcel)
    Else
        Local $sTemplatePath = $g_sTemplateDir & "\" & $sTemplate
        If Not FileExists($sTemplatePath) Then
            _Log_Write("Template nicht gefunden: " & $sTemplatePath)
            Return SetError(1)
        EndIf
        
        $g_oWorkbook = _Excel_BookOpen($g_oExcel, $sTemplatePath)
    EndIf
    
    If @error Then
        _Log_Write("Fehler beim Erstellen der Excel-Datei: " & @error)
        Return SetError(2)
    EndIf
    
    Return True
EndFunc

Func _Excel_ExportData($aData, $aHeaders, $sWorksheet = "Daten", $iStartRow = 1, $iStartCol = 1)
    If Not IsArray($aData) Or Not IsArray($aHeaders) Then Return SetError(1)
    
    ; Worksheet aktivieren/erstellen
    Local $oWorksheet = _Excel_RangeRead($g_oWorkbook, $sWorksheet)
    If @error Then
        $oWorksheet = _Excel_SheetAdd($g_oWorkbook)
        _Excel_RangeWrite($g_oWorkbook, $oWorksheet, $sWorksheet, 1, 1)
    EndIf
    
    ; Header schreiben
    For $i = 0 To UBound($aHeaders) - 1
        _Excel_RangeWrite($g_oWorkbook, $sWorksheet, $aHeaders[$i], $iStartRow, $iStartCol + $i)
    Next
    
    ; Daten schreiben
    Local $iCurrentRow = $iStartRow + 1
    For $i = 0 To UBound($aData) - 1
        For $j = 0 To UBound($aHeaders) - 1
            _Excel_RangeWrite($g_oWorkbook, $sWorksheet, $aData[$i][$j], $iCurrentRow, $iStartCol + $j)
        Next
        $iCurrentRow += 1
    Next
    
    Return True
EndFunc

Func _Excel_ApplyFormat($sRange, $sFormat)
    If Not $g_oWorkbook Then Return SetError(1)
    
    Switch $sFormat
        Case "header"
            _Excel_RangeWrite($g_oWorkbook, "Format", "Bold", $sRange)
            _Excel_RangeWrite($g_oWorkbook, "Interior.ColorIndex", "15", $sRange)  ; Hellgrau
            
        Case "number"
            _Excel_RangeWrite($g_oWorkbook, "NumberFormat", "#,##0.00", $sRange)
            
        Case "date"
            _Excel_RangeWrite($g_oWorkbook, "NumberFormat", "dd.mm.yyyy", $sRange)
            
        Case "currency"
            _Excel_RangeWrite($g_oWorkbook, "NumberFormat", "#,##0.00 €", $sRange)
            
        Case "percent"
            _Excel_RangeWrite($g_oWorkbook, "NumberFormat", "0.00%", $sRange)
    EndSwitch
    
    Return True
EndFunc

Func _Excel_AutoFitColumns($sWorksheet = "Daten")
    If Not $g_oWorkbook Then Return SetError(1)
    
    Local $oRange = $g_oWorkbook.Worksheets($sWorksheet).UsedRange
    $oRange.Columns.AutoFit()
    
    Return True
EndFunc

Func _Excel_SaveAs($sFilePath)
    If Not $g_oWorkbook Then Return SetError(1)
    
    ; Dateierweiterung prüfen/hinzufügen
    If Not StringRegExp($sFilePath, "\.xlsx?$") Then
        $sFilePath &= ".xlsx"
    EndIf
    
    ; Speichern
    $g_oWorkbook.SaveAs($sFilePath)
    If @error Then
        _Log_Write("Fehler beim Speichern der Excel-Datei: " & @error)
        Return SetError(2)
    EndIf
    
    Return True
EndFunc

Func _Excel_Close()
    If $g_oWorkbook Then
        $g_oWorkbook.Close(False)  ; False = Nicht speichern
        $g_oWorkbook = 0
    EndIf
    
    If $g_oExcel Then
        _Excel_Close($g_oExcel)
        $g_oExcel = 0
    EndIf
EndFunc

Func _Excel_BatchExport($aDataSets, $sTemplate = "", $sOutputDir = @DesktopDir)
    If Not IsArray($aDataSets) Then Return SetError(1)
    
    ; Excel initialisieren
    If Not _Excel_Init() Then Return SetError(2)
    
    ; Für jeden Datensatz
    For $i = 0 To UBound($aDataSets) - 1
        ; Neue Arbeitsmappe aus Template erstellen
        If Not _Excel_CreateFromTemplate($sTemplate) Then ContinueLoop
        
        ; Daten exportieren
        _Excel_ExportData($aDataSets[$i][0], $aDataSets[$i][1])
        
        ; Formatierung anwenden
        _Excel_AutoFitColumns()
        _Excel_ApplyFormat("A1:Z1", "header")  ; Headers formatieren
        
        ; Speichern
        Local $sFileName = "Export_" & $i & "_" & @YEAR & @MON & @MDAY & ".xlsx"
        _Excel_SaveAs($sOutputDir & "\" & $sFileName)
        
        ; Aufräumen
        _Excel_Close()
    Next
    
    Return True
EndFunc