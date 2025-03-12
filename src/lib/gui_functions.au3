#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <ListViewConstants.au3>
#include "logging.au3"
#include "filter_functions.au3"
#include "export_functions.au3"

Func _DeleteAllListViewColumns($hListView)
    Local $iColumns = _GUICtrlListView_GetColumnCount($hListView)
    For $i = $iColumns - 1 To 0 Step -1
        _GUICtrlListView_DeleteColumn($hListView, $i)
    Next
    Return True
EndFunc

Func _DBViewerShowExport()
    Local $hExportGUI = GUICreate("Export", 400, 200, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU))
    
    ; Format auswählen
    GUICtrlCreateLabel("Exportformat:", 10, 10, 80, 20)
    Local $idFormat = GUICtrlCreateCombo("", 90, 8, 120, 20)
    GUICtrlSetData($idFormat, "CSV|Excel|JSON", "CSV")
    
    ; CSV-Optionen
    GUICtrlCreateGroup("CSV-Optionen", 10, 40, 380, 60)
    GUICtrlCreateLabel("Trennzeichen:", 20, 65, 80, 20)
    Local $idDelimiter = GUICtrlCreateInput(";", 100, 63, 30, 20)
    
    ; Buttons
    Local $idExport = GUICtrlCreateButton("Exportieren", 220, 160, 80, 25)
    Local $idCancel = GUICtrlCreateButton("Abbrechen", 310, 160, 80, 25)
    
    GUISetState(@SW_SHOW, $hExportGUI)
    
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idCancel
                GUIDelete($hExportGUI)
                Return
                
            Case $idExport
                Local $sFormat = GUICtrlRead($idFormat)
                Local $sFilename = ""
                Local $sFilter = ""
                Local $bSuccess = False
                
                ; Standard-Dateiname mit Tabellenname erstellen
                Local $sDefaultFileName = $g_sCurrentTable & "_Export"
                
                _LogInfo("Export gestartet - Format: " & $sFormat)
                Switch $sFormat
                    Case "CSV"
                        $sFilter = "CSV-Dateien (*.csv)"
                        $sFilename = FileSaveDialog("CSV exportieren", @DesktopDir, $sFilter, $FD_PATHMUSTEXIST + $FD_PROMPTOVERWRITE, $sDefaultFileName & ".csv")
                        If Not @error Then
                            $bSuccess = _ExportToCSV($sFilename, GUICtrlRead($idDelimiter))
                        EndIf
                        
                    Case "Excel"
                        $sFilter = "Excel-Dateien (*.xlsx)"
                        $sFilename = FileSaveDialog("Excel exportieren", @DesktopDir, $sFilter, $FD_PATHMUSTEXIST + $FD_PROMPTOVERWRITE, $sDefaultFileName & ".xlsx")
                        If Not @error Then
                            $bSuccess = _ExportToExcel($sFilename)
                        EndIf
                        
                    Case "JSON"
                        $sFilter = "JSON-Dateien (*.json)"
                        $sFilename = FileSaveDialog("JSON exportieren", @DesktopDir, $sFilter, $FD_PATHMUSTEXIST + $FD_PROMPTOVERWRITE, $sDefaultFileName & ".json")
                        If Not @error Then
                            $bSuccess = _ExportToJSON($sFilename)
                        EndIf
                EndSwitch
                
                If $sFilename = "" Then
                    _LogInfo("Export abgebrochen - Keine Datei ausgewählt")
                    ContinueLoop
                EndIf
                
                _LogInfo("Export wird ausgeführt nach: " & $sFilename)
                
                If $bSuccess Then
                    MsgBox(64, "Export erfolgreich", "Die Daten wurden erfolgreich exportiert:" & @CRLF & $sFilename)
                    GUIDelete($hExportGUI)
                    Return
                ElseIf $sFilename <> "" Then
                    MsgBox(16, "Fehler", "Beim Export ist ein Fehler aufgetreten.")
                EndIf
        EndSwitch
    WEnd
EndFunc

Func _DBViewerShowFilter()
    Local $hFilterGUI = GUICreate("Filter", 400, 300, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU))
    
    ; Spaltenauswahl
    GUICtrlCreateGroup("Spalte", 10, 10, 380, 60)
    GUICtrlCreateLabel("Filtern nach:", 20, 35, 70, 20)
    Local $idColumn = GUICtrlCreateCombo("", 100, 32, 200, 20)
    
    ; Verfügbare Spalten laden
    Local $aColumns = _GUICtrlListView_GetColumnCount($g_idListView)
    Local $sColumns = ""
    For $i = 0 To $aColumns - 1
        Local $aColInfo = _GUICtrlListView_GetColumn($g_idListView, $i)
        $sColumns &= $aColInfo[5] & "|"
    Next
    GUICtrlSetData($idColumn, StringTrimRight($sColumns, 1))
    Local $aFirstCol = _GUICtrlListView_GetColumn($g_idListView, 0)
    GUICtrlSetData($idColumn, $aFirstCol[5])
    
    ; Filterbedingungen
    GUICtrlCreateGroup("Filterbedingung", 10, 80, 380, 120)
    Local $idCondition = GUICtrlCreateCombo("", 20, 105, 150, 20)
    GUICtrlSetData($idCondition, "Enthält|Beginnt mit|Endet mit|Ist gleich|Ist größer als|Ist kleiner als", "Enthält")
    
    GUICtrlCreateLabel("Wert:", 20, 135, 40, 20)
    Local $idValue = GUICtrlCreateInput("", 70, 132, 310, 20)
    
    Local $idCaseSensitive = GUICtrlCreateCheckbox("Groß-/Kleinschreibung beachten", 20, 165, 200, 20)
    
    ; Buttons
    Local $idApply = GUICtrlCreateButton("Anwenden", 220, 260, 80, 25)
    Local $idReset = GUICtrlCreateButton("Zurücksetzen", 310, 260, 80, 25)
    
    GUISetState(@SW_SHOW, $hFilterGUI)
    
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                GUIDelete($hFilterGUI)
                Return
                
            Case $idReset
                _ResetListViewFilter()
                MsgBox(64, "Filter zurückgesetzt", "Der Filter wurde zurückgesetzt.")
                GUIDelete($hFilterGUI)
                Return
                
            Case $idApply
                Local $sColumn = GUICtrlRead($idColumn)
                Local $sCondition = GUICtrlRead($idCondition)
                Local $sValue = GUICtrlRead($idValue)
                Local $bCaseSensitive = BitAND(GUICtrlRead($idCaseSensitive), $GUI_CHECKED)
                
                Local $iFiltered = _ApplyListViewFilter($sColumn, $sCondition, $sValue, $bCaseSensitive)
                If $iFiltered >= 0 Then
                    MsgBox(64, "Filter angewendet", "Es wurden " & $iFiltered & " Einträge gefunden.")
                    GUIDelete($hFilterGUI)
                    Return
                Else
                    MsgBox(16, "Fehler", "Beim Anwenden des Filters ist ein Fehler aufgetreten.")
                EndIf
        EndSwitch
    WEnd
EndFunc