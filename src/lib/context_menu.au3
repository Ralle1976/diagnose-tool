#include-once
#include <GUIConstants.au3>
#include <MsgBoxConstants.au3>

; Kontextmenü-Funktionen für ListView
Func CreateListViewContextMenu($hListView)
    Local $hContextMenu = GUICtrlCreateContextMenu($hListView)
    
    ; Hauptmenüeinträge
    Local $idExport = GUICtrlCreateMenuItem("Exportieren", $hContextMenu)
    Local $idFilter = GUICtrlCreateMenuItem("Filter", $hContextMenu)
    Local $idSort = GUICtrlCreateMenuItem("Sortieren", $hContextMenu)
    GUICtrlCreateMenuItem("", $hContextMenu) ; Separator
    
    ; Untermenü für Export
    Local $idExportExcel = GUICtrlCreateMenuItem("Nach Excel...", $idExport)
    Local $idExportCSV = GUICtrlCreateMenuItem("Als CSV...", $idExport)
    
    ; Untermenü für Filter
    Local $idFilterAdd = GUICtrlCreateMenuItem("Filter hinzufügen...", $idFilter)
    Local $idFilterClear = GUICtrlCreateMenuItem("Filter zurücksetzen", $idFilter)
    Local $idFilterSave = GUICtrlCreateMenuItem("Filter speichern...", $idFilter)
    
    ; Untermenü für Sortierung
    Local $idSortAsc = GUICtrlCreateMenuItem("Aufsteigend", $idSort)
    Local $idSortDesc = GUICtrlCreateMenuItem("Absteigend", $idSort)
    Local $idSortClear = GUICtrlCreateMenuItem("Sortierung zurücksetzen", $idSort)
    
    Return $hContextMenu
EndFunc

; Event-Handler für Kontextmenü
Func HandleContextMenuEvent($hWnd, $iMsg, $wParam, $lParam)
    Switch $iMsg
        Case $WM_COMMAND
            Local $idItem = BitAND($wParam, 0xFFFF) ; Low-Word = Control ID
            Switch $idItem
                Case $idExportExcel
                    _ExportToExcel()
                Case $idExportCSV
                    _ExportToCSV()
                Case $idFilterAdd
                    _ShowFilterDialog()
                Case $idFilterClear
                    _ClearAllFilters()
                Case $idFilterSave
                    _SaveCurrentFilter()
                Case $idSortAsc
                    _SortListViewColumn(True)
                Case $idSortDesc
                    _SortListViewColumn(False)
                Case $idSortClear
                    _ClearSorting()
            EndSwitch
    EndSwitch
EndFunc

; Hilfsfunktionen für Menüaktionen
Func _ExportToExcel()
    ; Integration mit excel_handler.au3
    _LogMessage("Export nach Excel gestartet")
    ; TODO: Implementierung hinzufügen
EndFunc

Func _ExportToCSV()
    ; Integration mit csv_handler.au3
    _LogMessage("Export als CSV gestartet")
    ; TODO: Implementierung hinzufügen
EndFunc

Func _ShowFilterDialog()
    ; Integration mit advanced_filter.au3
    _LogMessage("Filtermaske geöffnet")
    ; TODO: Implementierung hinzufügen
EndFunc

Func _ClearAllFilters()
    _LogMessage("Filter zurückgesetzt")
    ; TODO: Implementierung hinzufügen
EndFunc

Func _SaveCurrentFilter()
    _LogMessage("Filter wird gespeichert")
    ; TODO: Implementierung hinzufügen
EndFunc

Func _SortListViewColumn($bAscending)
    _LogMessage("Sortierung angewendet")
    ; TODO: Implementierung hinzufügen
EndFunc

Func _ClearSorting()
    _LogMessage("Sortierung zurückgesetzt")
    ; TODO: Implementierung hinzufügen
EndFunc