#include-once
#include <GUIConstants.au3>

; SQLite Globals
Global $g_sCurrentDB = ""
Global $g_sCurrentTable = ""

; GUI Globals
Global $g_hGUI
Global $g_idListView
Global $g_idStatus
Global $g_idProgress
Global $g_bIsLoading = False
Global $g_sLastDir = @DocumentsCommonDir

; GUI-Element IDs
Global $idFileOpen, $idBtnOpen, $idSettings, $idFileExit, $idBtnExport
Global $idTableCombo, $idBtnRefresh, $idBtnFilter

; ListView Kontextmenü IDs
Global $g_idContextMenu
Global $g_idCopyCell, $g_idCopyRow, $g_idCopySelection, $g_idCopyWithHeaders
Global $g_idDecryptPassword
; ListView Copy
Global $idFormatCSV, $idFormatExcel, $idFormatJSON, $idFormatCSV, $idFormatExcel, $idFormatJSON