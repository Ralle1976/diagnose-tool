#include-once
#include <SQLite.au3>
#include <GUIListView.au3>
#include "logging.au3"
#include "db_functions.au3"

Func _ProcessExtractedFiles($sTempDir)
    If Not FileExists($sTempDir) Then
        _LogError("Verzeichnis nicht gefunden: " & $sTempDir)
        Return False
    EndIf

    Local $aFiles = _FileListToArray($sTempDir, "*.db3", $FLTA_FILES, True)
    If @error Then
        _LogInfo("DB-Suche: Keine DB3 gefunden")
        $aFiles = _FileListToArray($sTempDir, "*.db", $FLTA_FILES, True)
        If @error Then
            _LogInfo("DB-Suche: Auch keine DB gefunden")
            Return False
        EndIf
    EndIf

    _LogInfo("Gefundene Datenbanken: " & $aFiles[0])
    For $i = 1 To $aFiles[0]
        _LogInfo("DB " & $i & ": " & $aFiles[$i])
    Next

    Local $sDBPath = $aFiles[1]
    _LogInfo("Verwende Datenbank: " & $sDBPath)

    Global $g_sCurrentDB = $sDBPath
    Return _DB_Connect($sDBPath)
EndFunc