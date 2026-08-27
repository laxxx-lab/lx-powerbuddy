# Private/Quest-Engine.ps1

function Get-LXProgressFilePath {
    $dir = Join-Path -Path $HOME -ChildPath ".lxpowerbuddy"
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    return (Join-Path -Path $dir -ChildPath "progress.json")
}

function Get-LXProgress {
    $file = Get-LXProgressFilePath
    if (Test-Path $file) {
        try {
            return (Get-Content $file -Raw -Encoding UTF8 | ConvertFrom-Json)
        } catch {}
    }
    
    # Default progress state
    return [PSCustomObject]@{
        TotalXP = 0
        Level = 1
        Title = "PowerShell Novize"
        CompletedLessons = @()
        CompletedSteps = @{}
        LastActive = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
}

function Save-LXProgress {
    param([Parameter(Mandatory=$true)]$Progress)
    $file = Get-LXProgressFilePath
    $Progress.LastActive = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    
    # Update title based on XP
    if ($Progress.TotalXP -ge 1500) {
        $Progress.Title = "PowerShell Legende [Rang 6]"
    } elseif ($Progress.TotalXP -ge 1000) {
        $Progress.Title = "PowerShell Grossmeister [Rang 5]"
    } elseif ($Progress.TotalXP -ge 600) {
        $Progress.Title = "Pipeline Magier [Rang 4]"
    } elseif ($Progress.TotalXP -ge 300) {
        $Progress.Title = "Skript Ritter [Rang 3]"
    } elseif ($Progress.TotalXP -ge 100) {
        $Progress.Title = "Cmdlet Lehrling [Rang 2]"
    } else {
        $Progress.Title = "PowerShell Novize [Rang 1]"
    }

    $Progress | ConvertTo-Json -Depth 5 | Set-Content -Path $file -Encoding UTF8
}

function Reset-LXProgressData {
    $file = Get-LXProgressFilePath
    if (Test-Path $file) {
        Remove-Item $file -Force -ErrorAction SilentlyContinue
    }
    Write-LXSuccess "Fortschritt wurde erfolgreich zurueckgesetzt!"
}

function Invoke-LXQuestSession {
    param(
        [string]$LessonId,
        [switch]$Interactive
    )

    $allLessons = Get-LXAllLessons
    if ($allLessons.Count -eq 0) {
        Write-LXError "Keine Lektionen in Data/lessons gefunden!"
        return
    }

    $selectedLesson = $null
    if ($LessonId) {
        $selectedLesson = $allLessons | Where-Object { $_.Id -eq $LessonId -or $_.Order -eq $LessonId } | Select-Object -First 1
    }

    if (-not $selectedLesson) {
        Write-LXBanner -Title "LX POWERBUDDY - QUESTS" -Subtitle "Waehle deine Trainings-Mission"
        Write-Host "  Verfuegbare Level:" -ForegroundColor Yellow
        Write-Host ""
        
        $progress = Get-LXProgress
        foreach ($l in $allLessons) {
            $isDone = $progress.CompletedLessons -contains $l.Id
            $badge = if ($isDone) { "[ERLEDIGT]" } else { "[OFFEN]" }
            $badgeColor = if ($isDone) { "Green" } else { "Cyan" }
            
            Write-Host "   $($l.Order). " -NoNewline -ForegroundColor Yellow
            Write-Host "$($l.Title) " -NoNewline -ForegroundColor White
            Write-Host "$badge" -ForegroundColor $badgeColor
            Write-Host "      $($l.Description)" -ForegroundColor Gray
            Write-Host ""
        }

        Write-Host "  Starte ein Level z.B. mit: " -NoNewline -ForegroundColor Gray
        Write-Host "Start-LXLesson -Level 1" -ForegroundColor Green
        return
    }

    # Run the selected lesson
    $progress = Get-LXProgress
    Write-LXBanner -Title "QUEST: $($selectedLesson.Title)" -Subtitle "$($selectedLesson.Steps.Count) Schritte zum Erfolg"
    Write-LXBox -Title "Missions-Briefing" -Content "$($selectedLesson.Description)`n`nTipps:`n- Tippe 'hint' oder 'hilfe', falls du nicht weiterweisst.`n- Tippe 'skip', um einen Schritt zu ueberspringen.`n- Tippe 'exit', um die Quest zu pausieren." -Color Cyan -Icon "[Info]"

    $stepIndex = 1
    foreach ($step in $selectedLesson.Steps) {
        $stepKey = "$($selectedLesson.Id)_$($step.StepNumber)"
        Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkCyan
        Write-Host "  Schritt $($step.StepNumber) von $($selectedLesson.Steps.Count): " -NoNewline -ForegroundColor Yellow
        Write-Host "$($step.Title)" -ForegroundColor White
        Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkCyan
        Write-Host ""
        
        Write-LXBox -Title "Wissen & Theorie" -Content $step.Theory -Color DarkCyan -Icon "[Theorie]"
        Write-LXBox -Title "Deine Aufgabe" -Content $step.Task -Color Yellow -Icon "[Mission]"

        $stepDone = $false
        $attempts = 0

        while (-not $stepDone) {
            Write-Host "  [PS-Buddy-Prompt] > " -NoNewline -ForegroundColor Green
            $userInput = Read-Host
            $inputTrimmed = $userInput.Trim()

            if ($inputTrimmed -in @("exit", "quit", "q")) {
                Write-LXWarning "Quest pausiert. Dein bisheriger Fortschritt ist gespeichert!"
                return
            }

            if ($inputTrimmed -in @("hint", "hilfe", "tipp")) {
                Write-LXInfo "TIPP: $($step.Hint)"
                Write-Host ""
                continue
            }

            if ($inputTrimmed -in @("skip", "ueberspringen", "überspringen")) {
                Write-LXWarning "Schritt uebersprungen."
                $stepDone = $true
                break
            }

            if ([string]::IsNullOrWhiteSpace($inputTrimmed)) {
                continue
            }

            $attempts++

            # Validate input against expected regex pattern
            $isMatch = $false
            if ($step.ExpectedCommandPattern) {
                if ($inputTrimmed -match $step.ExpectedCommandPattern) {
                    $isMatch = $true
                }
            }

            if ($isMatch) {
                # Execute the command so user sees the real output
                Write-Host ""
                Write-Host "  [Ausgabe von PowerShell]:" -ForegroundColor DarkGray
                Write-Host "  ---------------------------------------------------------------" -ForegroundColor DarkGray
                try {
                    Invoke-Expression $inputTrimmed
                } catch {
                    Write-LXWarning "Befehl erzeugte einen Fehler bei der Testausfuehrung: $_"
                }
                Write-Host "  ---------------------------------------------------------------" -ForegroundColor DarkGray
                Write-Host ""

                Write-LXSuccess "PERFEKT! $($step.ExplanationAfter)"
                Write-Host ""

                # Award XP
                $xpEarned = 25
                $progress.TotalXP += $xpEarned
                if (-not $progress.CompletedSteps) { $progress.CompletedSteps = @{} }
                $progress.CompletedSteps[$stepKey] = $true
                Save-LXProgress -Progress $progress

                Write-LXInfo "+$xpEarned XP erhalten! (Gesamt: $($progress.TotalXP) XP | Rang: $($progress.Title))"
                Write-Host ""
                $stepDone = $true
            } else {
                Write-LXError "Noch nicht ganz richtig! Versuch es noch einmal oder tippe 'hint' fuer Hilfe."
                if ($attempts -ge 2) {
                    Write-LXInfo "Tipp zur Erinnerung: $($step.Hint)"
                }
                Write-Host ""
            }
        }
    }

    # Mark lesson completed
    if ($progress.CompletedLessons -notcontains $selectedLesson.Id) {
        $progress.CompletedLessons += $selectedLesson.Id
        $bonusXP = 50
        $progress.TotalXP += $bonusXP
        Save-LXProgress -Progress $progress
        
        Write-Host ""
        Write-Host "  ===============================================================" -ForegroundColor Yellow
        Write-LXSuccess "LEKTION ABGESCHLOSSEN: $($selectedLesson.Title)"
        Write-LXSuccess "Level-Bonus: +$bonusXP XP!"
        Write-Host "  ===============================================================" -ForegroundColor Yellow
        Write-Host ""
    }
}
