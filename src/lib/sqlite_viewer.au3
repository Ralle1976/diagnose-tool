[Vorheriger Inhalt...]

Func _SQLiteViewer_Export()
    Local Enum $EXPORT_CSV, $EXPORT_EXCEL
    
    ; Export-Dialog
    Local $hExportGUI = GUICreate("Export", 300, 180)
    GUICtrlCreateLabel("Format:", 10, 10, 50, 20)
    Local $idFormat = GUICtrlCreateCombo("", 70, 10, 150, 20)
    GUICtrlSetData($idFormat, "CSV|Excel", "Excel")
    
    ; Excel-spezifische Optionen
    Local $idGroupExcel = GUICtrlCreateGroup("Excel-Optionen", 10, 40, 280, 90)
    Local $idTemplate = GUICtrlCreateCombo("", 20, 60, 150, 20)
    _Excel_LoadTemplates($idTemplate)
    Local $idFormatting = GUICtrlCreateCheckbox("Formatierung anwenden", 20, 90, 120, 20)
    GUICtrlSetState($idFormatting, $GUI_CHECKED)
    
    ; Buttons
    Local $idExport = GUICtrlCreateButton("Exportieren", 120, 140, 80, 25)
    Local $idCancel = GUICtrlCreateButton("Abbrechen", 210, 140, 80, 25)
    
    GUISetState(@SW_SHOW, $hExportGUI)
    
    Local $bResult = False
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idCancel
                ExitLoop
                
            Case $idFormat
                ; Excel-Optionen ein-/ausblenden
                If GUICtrlRead($idFormat) = "Excel" Then
                    GUICtrlSetState($idGroupExcel, $GUI_SHOW)
                Else
                    GUICtrlSetState($idGroupExcel, $GUI_HIDE)
                EndIf
                
            Case $idExport
                Switch GUICtrlRead($idFormat)
                    Case "CSV"
                        $bResult = _SQLiteViewer_ExportCSV()
                        
                    Case "Excel"
                        $bResult = _SQLiteViewer_ExportExcel( _
                            GUICtrlRead($idTemplate), _
                            (GUICtrlRead($idFormatting) = $GUI_CHECKED))
                EndSwitch
                ExitLoop
        EndSwitch
    WEnd
    
    GUIDelete($hExportGUI)
    Return $bResult
EndFunc

Func _SQLiteViewer_ExportCSV()
    Local $sFile = FileSaveDialog("CSV exportieren", @DesktopDir, "CSV-Dateien (*.csv)", 16, "export.csv")
    If @error Then Return False
    
    Local $hFile = FileOpen($sFile, 2)
    If $hFile = -1 Then Return False
    
    ; Header schreiben
    Local $sHeader = ""
    For $i = 0 To UBound($g_aTableHeaders) - 1
        $sHeader &= $g_aTableHeaders[$i] & ";"
    Next
    FileWriteLine($hFile, StringTrimRight($sHeader, 1))
    
    ; Daten schreiben
    Local $iItems = _GUICtrlListView_GetItemCount($g_idListview)
    For $i = 0 To $iItems - 1
        Local $sLine = ""
        For $j = 0 To $g_iColumnCount - 1
            $sLine &= _GUICtrlListView_GetItemText($g_idListview, $i, $j) & ";"
        Next
        FileWriteLine($hFile, StringTrimRight($sLine, 1))
    Next
    
    FileClose($hFile)
    Return True
EndFunc

Func _SQLiteViewer_ExportExcel($sTemplate = "", $bFormatting = True)
    ; Excel initialisieren
    If Not _Excel_Init() Then Return False
    
    ; Neue Arbeitsmappe erstellen
    If Not _Excel_CreateFromTemplate($sTemplate) Then Return False
    
    ; Daten sammeln
    Local $iItems = _GUICtrlListView_GetItemCount($g_idListview)
    Local $aData[$iItems][$g_iColumnCount]
    
    For $i = 0 To $iItems - 1
        For $j = 0 To $g_iColumnCount - 1
            $aData[$i][$j] = _GUICtrlListView_GetItemText($g_idListview, $i, $j)
        Next
    Next
    
    ; Daten exportieren
    _Excel_ExportData($aData, $g_aTableHeaders)
    
    ; Formatierung anwenden
    If $bFormatting Then
        _Excel_AutoFitColumns()
        _Excel_ApplyFormat("A1:" & Chr(64 + $g_iColumnCount) & "1", "header")
        
        ; Spaltentypen erkennen und formatieren
        For $i = 0 To $g_iColumnCount - 1
            Local $iType = _SQLiteViewer_GetColumnType($i)
            Local $sCol = Chr(65 + $i)
            Switch $iType
                Case 1  ; Nummer
                    _Excel_ApplyFormat($sCol & "2:" & $sCol & ($iItems + 1), "number")
                Case 2  ; Datum
                    _Excel_ApplyFormat($sCol & "2:" & $sCol & ($iItems + 1), "date")
            EndSwitch
        Next
    EndIf
    
    ; Speichern
    Local $sFile = FileSaveDialog("Excel exportieren", @DesktopDir, "Excel-Dateien (*.xlsx)", 16, "export.xlsx")
    If Not @error Then
        _Excel_SaveAs($sFile)
    EndIf
    
    ; Aufräumen
    _Excel_Close()
    Return True
EndFunc

Func _Excel_LoadTemplates($idCombo)
    GUICtrlSetData($idCombo, "Keine|standard.xlsx", "Keine")
    
    Local $aTemplates = _FileListToArray($g_sTemplateDir, "*.xls*", $FLTA_FILES)
    If Not @error Then
        For $i = 1 To $aTemplates[0]
            GUICtrlSetData($idCombo, $aTemplates[$i])
        Next
    EndIf
EndFunc