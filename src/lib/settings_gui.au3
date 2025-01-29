#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <Array.au3>

; Globale Einstellungsvariablen
Global $g_settings = ObjCreate("Scripting.Dictionary")

Func LoadSettings()
    _LogInfo("Lade Einstellungen aus INI")
    
    Local $sections = IniReadSectionNames($g_iniFile)
    If @error Then
        _LogWarning("Keine Einstellungen gefunden, verwende Standardwerte")
        Return SetDefaultSettings()
    EndIf
    
    ; Lade alle Einstellungen
    $g_settings.RemoveAll()
    
    ; Grundeinstellungen
    $g_settings.Add("WatchFolder", IniRead($g_iniFile, "Settings", "WatchFolder", @ScriptDir))
    $g_settings.Add("ZipPassword", IniRead($g_iniFile, "Settings", "ZipPassword", "geheimespasswort"))
    $g_settings.Add("LogLevel", IniRead($g_iniFile, "Settings", "LogLevel", $LOG_INFO))
    $g_settings.Add("AutoCleanup", IniRead($g_iniFile, "Settings", "AutoCleanup", "0"))
    $g_settings.Add("MaxLogSize", IniRead($g_iniFile, "Settings", "MaxLogSize", 10 * 1024 * 1024))
    $g_settings.Add("LogRotateCount", IniRead($g_iniFile, "Settings", "LogRotateCount", 5))
    
    ; SQLite Einstellungen
    $g_settings.Add("SQLitePreviewLimit", IniRead($g_iniFile, "SQLite", "PreviewLimit", 100))
    $g_settings.Add("SQLiteAutoConnect", IniRead($g_iniFile, "SQLite", "AutoConnect", "1"))
    
    _LogInfo("Einstellungen erfolgreich geladen")
    Return True
EndFunc

Func SaveSettings()
    _LogInfo("Speichere Einstellungen in INI")
    
    ; Grundeinstellungen
    IniWrite($g_iniFile, "Settings", "WatchFolder", $g_settings.Item("WatchFolder"))
    IniWrite($g_iniFile, "Settings", "ZipPassword", $g_settings.Item("ZipPassword"))
    IniWrite($g_iniFile, "Settings", "LogLevel", $g_settings.Item("LogLevel"))
    IniWrite($g_iniFile, "Settings", "AutoCleanup", $g_settings.Item("AutoCleanup"))
    IniWrite($g_iniFile, "Settings", "MaxLogSize", $g_settings.Item("MaxLogSize"))
    IniWrite($g_iniFile, "Settings", "LogRotateCount", $g_settings.Item("LogRotateCount"))
    
    ; SQLite Einstellungen
    IniWrite($g_iniFile, "SQLite", "PreviewLimit", $g_settings.Item("SQLitePreviewLimit"))
    IniWrite($g_iniFile, "SQLite", "AutoConnect", $g_settings.Item("SQLiteAutoConnect"))
    
    _LogInfo("Einstellungen erfolgreich gespeichert")
    Return True
EndFunc

Func SetDefaultSettings()
    _LogInfo("Setze Standardeinstellungen")
    
    $g_settings.RemoveAll()
    
    ; Grundeinstellungen
    $g_settings.Add("WatchFolder", @ScriptDir)
    $g_settings.Add("ZipPassword", "geheimespasswort")
    $g_settings.Add("LogLevel", $LOG_INFO)
    $g_settings.Add("AutoCleanup", "0")
    $g_settings.Add("MaxLogSize", 10 * 1024 * 1024)
    $g_settings.Add("LogRotateCount", 5)
    
    ; SQLite Einstellungen
    $g_settings.Add("SQLitePreviewLimit", 100)
    $g_settings.Add("SQLiteAutoConnect", "1")
    
    SaveSettings()
    Return True
EndFunc

Func ShowSettingsGUI()
    _LogInfo("Öffne Einstellungsdialog")
    
    ; Erstelle Einstellungsfenster
    Local $hSettingsGUI = GUICreate("Einstellungen", 500, 400, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU))
    
    ; Tabs erstellen
    Local $hTab = GUICtrlCreateTab(10, 10, 480, 340)
    
    ; === Allgemeine Einstellungen ===
    GUICtrlCreateTabItem("Allgemein")
    
    ; Überwachungsordner
    GUICtrlCreateLabel("Überwachungsordner:", 20, 40, 150, 20)
    Local $idWatchFolder = GUICtrlCreateInput($g_settings.Item("WatchFolder"), 20, 60, 350, 20)
    Local $idBrowseFolder = GUICtrlCreateButton("...", 380, 60, 30, 20)
    
    ; ZIP-Passwort
    GUICtrlCreateLabel("ZIP-Passwort:", 20, 90, 150, 20)
    Local $idZipPassword = GUICtrlCreateInput($g_settings.Item("ZipPassword"), 20, 110, 200, 20, $ES_PASSWORD)
    Local $idShowPassword = GUICtrlCreateCheckbox("Anzeigen", 230, 110, 100, 20)
    
    ; Log-Level
    GUICtrlCreateLabel("Log-Level:", 20, 140, 150, 20)
    Local $idLogLevel = GUICtrlCreateCombo("", 20, 160, 200, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($idLogLevel, "Debug|Info|Warning|Error", "Info")
    
    ; Auto-Cleanup
    Local $idAutoCleanup = GUICtrlCreateCheckbox("Automatische Bereinigung", 20, 190, 200, 20)
    GUICtrlSetState($idAutoCleanup, $g_settings.Item("AutoCleanup") = "1" ? $GUI_CHECKED : $GUI_UNCHECKED)
    
    ; === SQLite Einstellungen ===
    GUICtrlCreateTabItem("SQLite")
    
    ; Vorschau-Limit
    GUICtrlCreateLabel("Vorschau-Limit:", 20, 40, 150, 20)
    Local $idPreviewLimit = GUICtrlCreateInput($g_settings.Item("SQLitePreviewLimit"), 20, 60, 100, 20, $ES_NUMBER)
    
    ; Auto-Connect
    Local $idAutoConnect = GUICtrlCreateCheckbox("Automatisch verbinden", 20, 90, 200, 20)
    GUICtrlSetState($idAutoConnect, $g_settings.Item("SQLiteAutoConnect") = "1" ? $GUI_CHECKED : $GUI_UNCHECKED)
    
    ; === Log Einstellungen ===
    GUICtrlCreateTabItem("Logging")
    
    ; Max. Log-Größe
    GUICtrlCreateLabel("Maximale Log-Größe (MB):", 20, 40, 150, 20)
    Local $idMaxLogSize = GUICtrlCreateInput($g_settings.Item("MaxLogSize") / 1024 / 1024, 20, 60, 100, 20, $ES_NUMBER)
    
    ; Anzahl Log-Dateien
    GUICtrlCreateLabel("Anzahl Log-Dateien:", 20, 90, 150, 20)
    Local $idLogRotateCount = GUICtrlCreateInput($g_settings.Item("LogRotateCount"), 20, 110, 100, 20, $ES_NUMBER)
    
    GUICtrlCreateTabItem("")
    
    ; Buttons
    Local $idOK = GUICtrlCreateButton("OK", 320, 360, 80, 25)
    Local $idCancel = GUICtrlCreateButton("Abbrechen", 410, 360, 80, 25)
    
    ; GUI anzeigen
    GUISetState(@SW_SHOW, $hSettingsGUI)
    
    ; Event-Loop
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idCancel
                GUIDelete($hSettingsGUI)
                Return False
                
            Case $idBrowseFolder
                Local $folder = FileSelectFolder("Überwachungsordner auswählen", "")
                If Not @error Then
                    GUICtrlSetData($idWatchFolder, $folder)
                EndIf
                
            Case $idShowPassword
                If BitAND(GUICtrlRead($idShowPassword), $GUI_CHECKED) Then
                    GUICtrlSetStyle($idZipPassword, $ES_AUTOHSCROLL)
                Else
                    GUICtrlSetStyle($idZipPassword, BitOR($ES_AUTOHSCROLL, $ES_PASSWORD))
                EndIf
                
            Case $idOK
                ; Speichere Einstellungen
                $g_settings.Item("WatchFolder") = GUICtrlRead($idWatchFolder)
                $g_settings.Item("ZipPassword") = GUICtrlRead($idZipPassword)
                $g_settings.Item("LogLevel") = GUICtrlRead($idLogLevel)
                $g_settings.Item("AutoCleanup") = GUICtrlRead($idAutoCleanup) = $GUI_CHECKED ? "1" : "0"
                $g_settings.Item("SQLitePreviewLimit") = GUICtrlRead($idPreviewLimit)
                $g_settings.Item("SQLiteAutoConnect") = GUICtrlRead($idAutoConnect) = $GUI_CHECKED ? "1" : "0"
                $g_settings.Item("MaxLogSize") = Number(GUICtrlRead($idMaxLogSize)) * 1024 * 1024
                $g_settings.Item("LogRotateCount") = GUICtrlRead($idLogRotateCount)
                
                SaveSettings()
                GUIDelete($hSettingsGUI)
                Return True
        EndSwitch
    WEnd
EndFunc