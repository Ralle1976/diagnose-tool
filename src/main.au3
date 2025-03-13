#RequireAdmin

; Globale Konfigurationseinstellungen
Global Const $g_sSettingsFile = @ScriptDir & "\settings.ini"
Global Const $g_sqliteDLL = @ScriptDir & "\Lib\sqlite3.dll"

#include-once
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIConstants.au3>

#include <Array.au3>
#include <File.au3>
#include <SQLite.au3>
#include <GuiListView.au3>
#include <WinAPI.au3>
#include <Debug.au3>

; Eigene Include-Dateien
#include "lib/globals.au3"
#include "lib/system_functions.au3"
#include "lib/zip_handler.au3"
#include "lib/sqlite_handler.au3"
#include "lib/settings_manager.au3"
#include "lib/logging.au3"
#include "lib/error_handler.au3"
#include "lib/db_functions.au3"
#include "lib/db_functions_ext.au3"
#include "lib/missing_functions.au3"
#include "lib/gui_functions.au3"
#include "lib/export_functions.au3"
#include "lib/decrypt_functions.au3"
#include "lib/listview_copy.au3"
#include "lib/7z_functions.au3"

Global $iExListViewStyle = BitOR(	$LVS_EX_BORDERSELECT, _
                                    $LVS_EX_ONECLICKACTIVATE, _
                                    $LVS_EX_TRACKSELECT, _;                                    $LVS_EX_CHECKBOXES, _
                                    $LVS_EX_DOUBLEBUFFER, _
                                    $LVS_EX_TWOCLICKACTIVATE, _
                                    $LVS_EX_SUBITEMIMAGES, _
                                    $LVS_EX_GRIDLINES, _
                                    $LVS_EX_INFOTIP, _
                                    $LVS_EX_FULLROWSELECT, _
                                    $LVS_EX_LABELTIP, _
                                    $LVS_EX_FLATSB, _
                                    $LVS_AUTOARRANGE	)

Func _CreateMainGUI()
    $g_hGUI = GUICreate("Diagnose Tool", 1000, 700)

    ; Menü erstellen
    Local $idFile = GUICtrlCreateMenu("&Datei")
    $idFileOpen = GUICtrlCreateMenuItem("ZIP öffnen...", $idFile)
    $idFileDBOpen = GUICtrlCreateMenuItem("Datenbank öffnen...", $idFile)
    GUICtrlCreateMenuItem("", $idFile) ; Separator
    $idSettings = GUICtrlCreateMenuItem("Einstellungen...", $idFile)
    GUICtrlCreateMenuItem("", $idFile) ; Separator
    $idFileExit = GUICtrlCreateMenuItem("Beenden", $idFile)

    Local $idView = GUICtrlCreateMenu("&Ansicht")
    $idBtnRefresh = GUICtrlCreateMenuItem("Aktualisieren", $idView)
    $idBtnFilter = GUICtrlCreateMenuItem("Filter...", $idView)

    ; Toolbar
    Local $idToolbar = GUICtrlCreateGroup("", 2, 2, 996, 45)
    $idBtnOpen = GUICtrlCreateButton("ZIP öffnen", 10, 15, 100, 25)
    $idBtnDBOpen = GUICtrlCreateButton("DB öffnen", 120, 15, 100, 25)
    $idBtnExport = GUICtrlCreateButton("Exportieren", 230, 15, 100, 25)
    GUICtrlSetState($idBtnExport, $GUI_DISABLE)

    ; Tabellen-Auswahl
    GUICtrlCreateLabel("Tabelle:", 340, 20, 50, 20)
    $idTableCombo = GUICtrlCreateCombo("", 400, 15, 200, 25)
    GUICtrlSetState($idTableCombo, $GUI_DISABLE)

    $idBtnRefresh = GUICtrlCreateButton("Aktualisieren", 610, 15, 100, 25)
    GUICtrlSetState($idBtnRefresh, $GUI_DISABLE)

    $idBtnFilter = GUICtrlCreateButton("Filter", 720, 15, 100, 25)
    GUICtrlSetState($idBtnFilter, $GUI_DISABLE)

    GUICtrlCreateGroup("", -99, -99, 1, 1)

    ; ListView Notifications handeln
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

    ; ListView für Daten erstellen
    $g_idListView = GUICtrlCreateListView("", 2, 50, 996, 600)
    Local $hListView = GUICtrlGetHandle($g_idListView)

    ; ListView Style anpassen
;~     Local $hStyle = _WinAPI_GetWindowLong($hListView, $GWL_STYLE)
;~     $hStyle = BitOR($hStyle, $LVS_SINGLESEL, $LVS_SHOWSELALWAYS)  ; Einzelauswahl aktivieren
;~     _WinAPI_SetWindowLong($hListView, $GWL_STYLE, $hStyle)

    ; Erweiterte Styles setzen - nur Gitterlinien, keine volle Zeilenauswahl
    _GUICtrlListView_SetExtendedListViewStyle($hListView, $iExListViewStyle)

    ; Kontextmenü für ListView
    $g_idContextMenu = GUICtrlCreateContextMenu($g_idListView)
    $g_idCopyCell = GUICtrlCreateMenuItem("Zelle kopieren", $g_idContextMenu)
    $g_idCopyRow = GUICtrlCreateMenuItem("Zeile kopieren", $g_idContextMenu)
    $g_idCopySelection = GUICtrlCreateMenuItem("Auswahl kopieren", $g_idContextMenu)
    $g_idCopyWithHeaders = GUICtrlCreateMenuItem("Mit Überschriften kopieren", $g_idContextMenu)
    GUICtrlCreateMenuItem("", $g_idContextMenu) ; Separator
    $g_idDecryptPassword = GUICtrlCreateMenuItem("Passwort entschlüsseln", $g_idContextMenu)
    _DeleteAllListViewColumns($g_idListView)

    ; Fortschrittsanzeige
    $g_idProgress = GUICtrlCreateProgress(2, 655, 996, 20)
    GUICtrlSetState($g_idProgress, $GUI_HIDE)

    ; Statusbar
    $g_idStatus = GUICtrlCreateLabel("Bereit.", 2, 680, 996, 20)

    GUISetState(@SW_SHOW, $g_hGUI)
    Return True
EndFunc

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
    Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    Local $iCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case GUICtrlGetHandle($g_idListView)
            Switch $iCode
                Case $NM_DBLCLK
                    ; Position des Doppelklicks ermitteln
                    Local $tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
                    Local $iRow = DllStructGetData($tInfo, "Index")
                    Local $iCol = DllStructGetData($tInfo, "SubItem")
                    Local $ListViewSubitemText = _GUICtrlListView_GetItem(GUICtrlGetHandle($g_idListView), $iRow, $iCol)

                    ; Inhalt der Zelle lesen

					IF IsArray($ListViewSubitemText) Then
						IF $ListViewSubitemText[3] <> "" Then
                            ConsoleWrite( $ListViewSubitemText[3] & @CRLF)
                                    ClipPut($ListViewSubitemText[3])

;~                             ; Wenn es wie ein verschlüsseltes Passwort aussieht
;~                             If StringRegExp($ListViewSubitemText[3], "^[A-Za-z0-9+/]+={0,2}$") Then
;~                                 Local $sDecrypted = _DecryptPassword($ListViewSubitemText[3])
;~                                 If $sDecrypted <> "" Then
;~                                     MsgBox(64, "Passwort entschlüsselt", "Verschlüsselt: " & $ListViewSubitemText[3] & @CRLF & @CRLF & "Entschlüsselt: " & $sDecrypted)
;~                                 EndIf
;~                             EndIf
                        EndIf
                    EndIf
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc

FUnc Main()
    _DebugSetup("Diagnose Tool Debug", True)

    If Not _InitSystem() Then Exit

    _LogInfo("Programm gestartet - Version " & FileGetVersion(@ScriptFullPath))
    _CreateMainGUI()

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idFileExit
                ExitLoop

            Case $idFileOpen, $idBtnOpen
                Local $sFile = FileOpenDialog("ZIP-Datei öffnen", $g_sLastDir, "ZIP-Dateien (*.zip)", $FD_FILEMUSTEXIST)
                If Not @error Then
                    $g_sLastDir = StringLeft($sFile, StringInStr($sFile, "\", 0, -1))
                    _ProcessZipFile($sFile)
                EndIf
                
            Case $idFileDBOpen, $idBtnDBOpen
                Local $sFile = FileOpenDialog("Datenbank öffnen", $g_sLastDir, "SQLite Datenbanken (*.db;*.db3)", $FD_FILEMUSTEXIST)
                If Not @error Then
                    $g_sLastDir = StringLeft($sFile, StringInStr($sFile, "\", 0, -1))
                    _OpenDatabaseFile($sFile)
                EndIf

            Case $idTableCombo
                If Not $g_bIsLoading Then
                    $g_sCurrentTable = GUICtrlRead($idTableCombo)
                    _LoadDatabaseData()
                    ; Nach dem Laden Buttons aktivieren
                    GUICtrlSetState($idBtnFilter, $GUI_ENABLE)
                    GUICtrlSetState($idBtnExport, $GUI_ENABLE)
                EndIf

            Case $idBtnRefresh
                If Not $g_bIsLoading Then
                    _LoadDatabaseData()
                EndIf

            Case $idBtnFilter, $idBtnFilter ; Beide IDs abfangen
                If Not $g_bIsLoading Then
                    _DBViewerShowFilter()
                EndIf

            Case $idBtnExport
                If Not $g_bIsLoading Then
                    _DBViewerShowExport()
                EndIf

            Case $idSettings
                _Settings_ShowDialog()

            Case $g_idCopyCell
                Local $aPos = MouseGetPos()
                Local $aInfo = _GUICtrlListView_HitTest($g_idListView, $aPos[0], $aPos[1])

                If IsArray($aInfo) Then
                    Local $iRow = $aInfo[0]
                    Local $iCol = $aInfo[1]
                    If $aInfo[0] <> -1 Then
                        Local $sText = _GUICtrlListView_GetItem($g_idListView, $iRow, $iCol)
                        If IsArray($sText) Then
                            _LogInfo("Kopiere Zellinhalt: " & $sText[3])
                            ClipPut($sText[3])
                        EndIf
                    EndIf
                EndIf

            Case $g_idCopyRow
                Local $aPos = MouseGetPos()
                Local $aInfo = _GUICtrlListView_HitTest($g_idListView, $aPos[0], $aPos[1])

                If IsArray($aInfo) Then
                    Local $iRow = $aInfo[0]
                    If $aInfo[0] <> -1 Then
                        Local $sRow = ""
                        For $i = 0 To _GUICtrlListView_GetColumnCount($g_idListView) - 1
                            If $sRow <> "" Then $sRow &= ";"
                            Local $sText = _GUICtrlListView_GetItem($g_idListView, $iRow, $i)
                            If IsArray($sText) Then
                                $sRow &= $sText[3]
                            EndIf
                        Next
                        _LogInfo("Kopiere Zeile: " & $sRow)
                        ClipPut($sRow)
                    EndIf
                EndIf

            Case $g_idCopySelection
                Local $aSelected = _GUICtrlListView_GetSelectedIndices($g_idListView, True)
                If IsArray($aSelected) And $aSelected[0] > 0 Then
                    Local $sSelection = ""
                    For $i = 1 To $aSelected[0]
                        If $sSelection <> "" Then $sSelection &= @CRLF
                        Local $iRow = $aSelected[$i]
                        For $j = 0 To _GUICtrlListView_GetColumnCount($g_idListView) - 1
                            If $j > 0 Then $sSelection &= ";"
                            Local $sText = _GUICtrlListView_GetItem($g_idListView, $iRow, $j)
                            If IsArray($sText) Then
                                $sSelection &= $sText[3]
                            EndIf
                        Next
                    Next
                    _LogInfo("Kopiere Auswahl: " & $sSelection)
                    ClipPut($sSelection)
                EndIf

            Case $g_idCopyWithHeaders
                Local $aSelected = _GUICtrlListView_GetSelectedIndices($g_idListView, True)
                If IsArray($aSelected) And $aSelected[0] > 0 Then
                    Local $sText = ""
                    ; Kopfzeile
                    For $i = 0 To _GUICtrlListView_GetColumnCount($g_idListView) - 1
                        If $i > 0 Then $sText &= ";"
                        Local $aCol = _GUICtrlListView_GetColumn($g_idListView, $i)
                        $sText &= $aCol[5]  ; Spaltenname
                    Next
                    $sText &= @CRLF

                    ; Daten
                    For $i = 1 To $aSelected[0]
                        Local $iRow = $aSelected[$i]
                        For $j = 0 To _GUICtrlListView_GetColumnCount($g_idListView) - 1
                            If $j > 0 Then $sText &= ";"
                            Local $sTexta = _GUICtrlListView_GetItem($g_idListView, $iRow, $j)
                            If IsArray($sTexta) Then
                                $sText &= $sTexta[3]
                            EndIf
                        Next
                        $sText &= @CRLF
                    Next
                    _LogInfo("Kopiere mit Überschriften: " & $sText)
                    ClipPut($sText)
                EndIf
            Case $g_idDecryptPassword
                Local $aPos = MouseGetPos()
                Local $hListView = GUICtrlGetHandle($g_idListView)
                Local $aInfo = _GUICtrlListView_HitTest($g_idListView, $aPos[0], $aPos[1])

                If IsArray($aInfo) Then
                    Local $iRow = $aInfo[0]
                    Local $iCol = $aInfo[1]

                    If $aInfo[0] <> -1 Then
                        Local $sEncrypted = _GUICtrlListView_GetItem($g_idListView, $iRow, $iCol)
                        If IsArray($sEncrypted) Then
                            If $sEncrypted[3] <> "" Then
                                _LogInfo("Zu entschlüsselndes Passwort: " & $sEncrypted[3])

                                ; Prüfen ob es ein gültiges Base64-Format ist
                                If Not StringRegExp($sEncrypted[3], "^[A-Za-z0-9+/]+={0,2}$") Then
                                    MsgBox(48, "Hinweis", "Die ausgewählte Zelle enthält kein verschlüsseltes Passwort.")
                                    ContinueLoop
                                EndIf

                                Local $sDecrypted = _DecryptPassword($sEncrypted[3])
                                If $sDecrypted = "" Then
                                    MsgBox(16, "Fehler", "Das Passwort konnte nicht entschlüsselt werden.")
                                Else
                                    MsgBox(64, "Passwort entschlüsselt", "Verschlüsselt: " & $sEncrypted[3] & @CRLF & @CRLF & "Entschlüsselt: " & $sDecrypted)
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
        EndSwitch
    WEnd

    _Cleanup()
EndFunc

Main()