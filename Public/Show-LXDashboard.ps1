<#
.SYNOPSIS
    Zeigt das lx PowerBuddy Start-Dashboard mit aktuellem Fortschritt, Level und Tipps.
.DESCRIPTION
    Show-LXDashboard liefert einen schnellen Überblick über deinen XP-Stand, deinen Rang,
    abgeschlossene Lektionen sowie die wichtigsten Befehle des PowerBuddy-Moduls.
.EXAMPLE
    lx-buddy
.EXAMPLE
    Show-LXDashboard
#>
function Show-LXDashboard {
    [CmdletBinding()]
    [Alias("lx-buddy", "lx-dashboard")]
    param()

    $progress = Get-LXProgress
    $allLessons = Get-LXAllLessons
    $howdoDb = Get-LXKnowledgeHowTo

    Write-LXBanner -Title "LX POWERBUDDY DASHBOARD" -Subtitle "Dein Begleiter auf dem Weg zum PowerShell Profi"

    # User Status Box
    $completedCount = $progress.CompletedLessons.Count
    $totalLessons = $allLessons.Count
    $percent = if ($totalLessons -gt 0) { [math]::Round(($completedCount / $totalLessons) * 100) } else { 0 }
    
    $barLength = 20
    $filled = [math]::Round(($percent / 100) * $barLength)
    $empty = $barLength - $filled
    $progressBar = "[" + ("=" * $filled) + (" " * $empty) + "] $percent%"

    $statusContent = @()
    $statusContent += "Rang / Titel:       $($progress.Title)"
    $statusContent += "Gesamt-XP:          $($progress.TotalXP) XP"
    $statusContent += "Lern-Fortschritt:   $completedCount von $totalLessons Levels abgeschlossen"
    $statusContent += "Fortschrittsbalken: $progressBar"
    $statusContent += "Zuletzt aktiv:      $($progress.LastActive)"

    Write-LXBox -Title "Dein Profil & Status" -Content ($statusContent -join "`n") -Color Cyan -Icon "[Status]"

    # Quick Command Guide Box
    $cmdGuide = @()
    $cmdGuide += "Start-LXLesson (lx-quest)  -> Interaktive Lektionen & Uebungen starten"
    $cmdGuide += "explain <Befehl>           -> Befehle & Pipelines im Klartext analysieren"
    $cmdGuide += "howdo <Suchbegriff>        -> Schnelle Hilfe fuer alltaegliche Aufgaben"
    $cmdGuide += "why-error (was-los)        -> Den letzten Fehler verstaendlich erklaeren"
    $cmdGuide += "ps-dict <Befehl>           -> Linux/CMD nach PowerShell uebersetzen"
    $cmdGuide += "lx-buddy                   -> Dieses Dashboard erneut aufrufen"

    Write-LXBox -Title "Verfuegbare PowerBuddy Werkzeuge" -Content ($cmdGuide -join "`n") -Color Yellow -Icon "[Tools]"

    # Tip of the day / Random recipe
    if ($howdoDb.Count -gt 0) {
        $randomTip = Get-Random -InputObject $howdoDb
        $tipContent = @()
        $tipContent += "$($randomTip.Title):"
        $tipContent += "  -> $($randomTip.Command)"
        $tipContent += ""
        $tipContent += "$($randomTip.Explanation)"

        Write-LXBox -Title "Tipp des Tages: $($randomTip.Category)" -Content ($tipContent -join "`n") -Color Green -Icon "[Tip]"
    }

    Write-Host "  Moechtest du trainieren? Starte direkt mit: " -NoNewline -ForegroundColor Gray
    Write-Host "Start-LXLesson -Level 1" -ForegroundColor Green
    Write-Host ""
}
