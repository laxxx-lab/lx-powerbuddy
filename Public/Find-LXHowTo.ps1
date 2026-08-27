<#
.SYNOPSIS
    Sucht nach PowerShell-Lösungen und Befehls-Mustern für alltägliche Aufgaben.
.DESCRIPTION
    Find-LXHowTo durchsucht eine integrierte Wissensdatenbank nach passenden
    PowerShell-Einzeilern und Erklärungen basierend auf deinen Suchbegriffen.
.PARAMETER Query
    Suchbegriff oder Frage (z.B. "dateien finden", "port testen", "csv").
.PARAMETER Category
    Filtert nach einer bestimmten Kategorie (z.B. "Dateisystem", "Netzwerk", "Prozesse").
.PARAMETER ListCategories
    Gibt alle verfügbaren Kategorien aus.
.EXAMPLE
    howdo "port testen"
.EXAMPLE
    howdo "dateien rekursiv"
.EXAMPLE
    Find-LXHowTo -Category "Netzwerk"
#>
function Find-LXHowTo {
    [CmdletBinding(DefaultParameterSetName="Search")]
    [Alias("howdo", "lx-howdo")]
    param(
        [Parameter(Position=0, ParameterSetName="Search")]
        [string]$Query,

        [Parameter(ParameterSetName="Search")]
        [string]$Category,

        [Parameter(ParameterSetName="Categories")]
        [switch]$ListCategories
    )

    $database = Get-LXKnowledgeHowTo

    if ($ListCategories) {
        $categories = $database | Select-Object -ExpandProperty Category -Unique | Sort-Object
        Write-LXBanner -Title "HOWDO KATEGORIEN" -Subtitle "Verfügbare Themengebiete"
        foreach ($cat in $categories) {
            $count = ($database | Where-Object Category -eq $cat).Count
            Write-Host "   📁 $cat " -NoNewline -ForegroundColor Cyan
            Write-Host "($count Rezepte)" -ForegroundColor Gray
        }
        Write-Host ""
        Write-LXInfo "Suche in einer Kategorie mit: howdo -Category '$($categories[0])'"
        return
    }

    if ([string]::IsNullOrWhiteSpace($Query) -and [string]::IsNullOrWhiteSpace($Category)) {
        Write-LXBanner -Title "HOWDO SUCHE" -Subtitle "Wie kann ich dir helfen?"
        Write-Host "  Beispiele für Suchbegriffe:" -ForegroundColor Yellow
        Write-Host "   • howdo `"port testen`"" -ForegroundColor Cyan
        Write-Host "   • howdo `"große dateien finden`"" -ForegroundColor Cyan
        Write-Host "   • howdo `"json api abfragen`"" -ForegroundColor Cyan
        Write-Host "   • howdo `"prozess beenden`"" -ForegroundColor Cyan
        Write-Host "   • howdo -ListCategories" -ForegroundColor Cyan
        Write-Host ""
        return
    }

    # Search logic
    $terms = if ($Query) { $Query -split "\s+" | Where-Object { $_.Length -gt 1 } } else { @() }
    
    $results = $database | Where-Object {
        $item = $_
        $matchesCategory = $true
        if ($Category) {
            $matchesCategory = ($item.Category -like "*$Category*")
        }

        if (-not $matchesCategory) { return $false }

        if ($terms.Count -eq 0) { return $true }

        # Match any term in Title, Explanation, Keywords, Command
        $allText = "$($item.Title) $($item.Explanation) $($item.Command) $($item.Keywords -join ' ')"
        foreach ($term in $terms) {
            if ($allText -like "*$term*") {
                return $true
            }
        }
        return $false
    }

    if (-not $results -or $results.Count -eq 0) {
        Write-LXWarning "Keine passenden Rezepte für '$Query' gefunden."
        Write-LXInfo "Tipp: Versuche allgemeinere Begriffe wie 'datei', 'prozess', 'netzwerk' oder 'json'."
        return
    }

    Write-LXBanner -Title "HOWDO ERGEBNISSE" -Subtitle "$($results.Count) Treffer gefunden"

    foreach ($res in $results) {
        $body = @()
        $body += "Befehl:`n  $($res.Command)`n"
        $body += "Erklärung:`n  $($res.Explanation)`n"
        if ($res.Tip) {
            $body += "💡 Pro-Tipp:`n  $($res.Tip)"
        }

        Write-LXBox -Title "$($res.Category): $($res.Title)" -Content ($body -join "`n") -Color Green -Icon "💡"
    }
}
