<#
.SYNOPSIS
    Startet interaktive PowerShell-Lernlektionen und Quests.
.DESCRIPTION
    Start-LXLesson führt dich Schritt für Schritt durch interaktive Aufgaben im Terminal,
    prüft deine Eingaben und belohnt deinen Lernfortschritt mit XP und Rängen.
.PARAMETER Level
    Die Nummer des Levels (1 bis 6) oder die ID der Lektion.
.PARAMETER List
    Zeigt eine Übersicht aller verfügbaren Lektionen und deinen aktuellen Status.
.PARAMETER ResetProgress
    Setzt den gespeicherten Lernfortschritt zurück.
.EXAMPLE
    Start-LXLesson
.EXAMPLE
    Start-LXLesson -Level 2
.EXAMPLE
    Start-LXLesson -List
#>
function Start-LXLesson {
    [CmdletBinding(DefaultParameterSetName="Run")]
    [Alias("lx-quest", "Start-PSQuest", "lx-lesson")]
    param(
        [Parameter(Position=0, ParameterSetName="Run")]
        [string]$Level,

        [Parameter(ParameterSetName="List")]
        [switch]$List,

        [Parameter(ParameterSetName="Reset")]
        [switch]$ResetProgress
    )

    if ($ResetProgress) {
        Reset-LXProgressData
        return
    }

    if ($List -or [string]::IsNullOrEmpty($Level)) {
        Invoke-LXQuestSession
        return
    }

    Invoke-LXQuestSession -LessonId $Level
}
