#include-once
#include <Excel.au3>
#include <Array.au3>
#include "logging.au3"

Global $g_oExcel = 0
Global $g_oWorkbook = 0
Global $g_oWorksheet = 0

; Excel Handler Konfiguration
Global $g_sTemplateDir = @ScriptDir & "\templates"
Global $g_sExportDir = @ScriptDir & "\export"

Func _ExcelHandler_Init()
    _LogMessage("INFO", "Initialisiere Excel-Handler")
    
    If Not _Excel_IsInstalled() Then
        _LogMessage("ERROR", "Excel ist nicht installiert")
        Return SetError(1, 0, False)
    EndIf
    
    $g_oExcel = _Excel_Open(False)
    If @error Then
        _LogMessage("ERROR", "Fehler beim Öffnen von Excel: " & @error)
        Return SetError(2, 0, False)
    EndIf
    
    If Not FileExists($g_sExportDir) Then
        DirCreate($g_sExportDir)
    EndIf
    
    Return True
EndFunc

Func _ExcelHandler_LoadTemplate($sTemplateName)
    Local $sTemplatePath = $g_sTemplateDir & "\" & $sTemplateName
    
    _LogMessage("INFO", "Lade Template: " & $sTemplatePath)
    
    If Not FileExists($sTemplatePath) Then
        _LogMessage("ERROR", "Template nicht gefunden: " & $sTemplatePath)
        Return SetError(1, 0, False)
    EndIf
    
    $g_oWorkbook = _Excel_BookOpen($g_oExcel, $sTemplatePath)
    If @error Then
        _LogMessage("ERROR", "Fehler beim Öffnen des Templates: " & @error)
        Return SetError(2, 0, False)
    EndIf
    
    $g_oWorksheet = _Excel_SheetGet($g_oWorkbook, 1)
    
    Return True
EndFunc

Func _ExcelHandler_ExportData($aData, $sFileName, $aFormatting = Null)
    If Not IsArray($aData) Then
        _LogMessage("ERROR", "Ungültige Daten für Export")
        Return SetError(1, 0, False)
    EndIf
    
    _LogMessage("INFO", "Exportiere Daten nach: " & $sFileName)
    
    If $g_oWorkbook = 0 Then
        $g_oWorkbook = _Excel_BookNew($g_oExcel)
        $g_oWorksheet = _Excel_SheetGet($g_oWorkbook, 1)
    EndIf
    
    For $i = 0 To UBound($aData) - 1
        For $j = 0 To UBound($aData[$i]) - 1
            _Excel_RangeWrite($g_oWorksheet, $i + 1, $j + 1, $aData[$i][$j])
        Next
    Next
    
    If IsArray($aFormatting) Then
        _ApplyFormatting($aFormatting)
    EndIf
    
    Local $sExportPath = $g_sExportDir & "\" & $sFileName
    _Excel_BookSaveAs($g_oWorkbook, $sExportPath)
    
    Return True
EndFunc

Func _ExcelHandler_Cleanup()
    If $g_oWorkbook Then
        _Excel_BookClose($g_oWorkbook)
    EndIf
    
    If $g_oExcel Then
        _Excel_Close($g_oExcel)
    EndIf
    
    $g_oWorkbook = 0
    $g_oWorksheet = 0
    $g_oExcel = 0
EndFunc