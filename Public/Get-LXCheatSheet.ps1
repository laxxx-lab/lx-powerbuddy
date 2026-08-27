<#
.SYNOPSIS
    Übersetzt Linux- (Bash) und CMD-Befehle in modernes PowerShell.
.DESCRIPTION
    Get-LXCheatSheet ist ein Wörterbuch für Umsteiger von Linux / CMD auf PowerShell.
    Es zeigt das native PowerShell-Cmdlet, die Aliase, Code-Beispiele und erklärt
    den entscheidenden Unterschied (z.B. warum Objekte statt reiner Textzeilen fließen).
.PARAMETER Command
    Der zu suchende Befehl (z.B. "grep", "ls", "curl", "ps", "rm").
.PARAMETER Category
    Filtert nach einer bestimmten Kategorie (z.B. "Dateisystem", "Prozesse", "Netzwerk").
.PARAMETER All
    Zeigt die gesamte Übersetzungstabelle als Übersicht an.
.EXAMPLE
    ps-dict "grep"
.EXAMPLE
    ps-dict "ls"
.EXAMPLE
    ps-dict -All
#>
function Get-LXCheatSheet {
    [CmdletBinding(DefaultParameterSetName="Search")]
    [Alias("ps-dict", "lx-dict", "cheatsheet")]
    param(
        [Parameter(Position=0, ParameterSetName="Search")]
        [string]$Command,

        [Parameter(ParameterSetName="Search")]
        [string]$Category,

        [Parameter(ParameterSetName="All")]
        [switch]$All
    )

    $cheatDb = Get-LXKnowledgeCheatsheet

    if ($All -or ([string]::IsNullOrEmpty($Command) -and [string]::IsNullOrEmpty($Category))) {
        Write-LXBanner -Title "BASH / CMD ➔ POWERSHELL WÖRTERBUCH" -Subtitle "Alle Übersetzungen auf einen Blick"
        
        $table = foreach ($item in $cheatDb) {
            [PSCustomObject]@{
                "Linux / Bash" = $item.UnixCmd
                "Windows CMD"  = $item.WindowsCmd
                "PowerShell Cmdlet" = $item.PSCmdlet
                "Kurz-Aliase"  = ($item.Aliases -join ", ")
                "Kategorie"    = $item.Category
            }
        }

        $table | Format-Table -AutoSize
        Write-Host ""
        Write-LXInfo "Details zu einem Befehl abrufen mit: ps-dict <Befehl> (z.B. ps-dict grep)"
        return
    }

    # Search by Command or Category
    $results = $cheatDb | Where-Object {
        $item = $_
        $matchesCat = $true
        if ($Category) {
            $matchesCat = ($item.Category -like "*$Category*")
        }
        if (-not $matchesCat) { return $false }

        if (-not $Command) { return $true }

        $cmdLower = $Command.ToLower().Trim()
        return ($item.UnixCmd.ToLower() -like "*$cmdLower*" -or 
                $item.WindowsCmd.ToLower() -like "*$cmdLower*" -or 
                $item.PSCmdlet.ToLower() -like "*$cmdLower*" -or 
                ($item.Aliases -join " ").ToLower() -like "*$cmdLower*")
    }

    if (-not $results -or $results.Count -eq 0) {
        Write-LXWarning "Keine Übersetzung für '$Command' gefunden."
        Write-LXInfo "Tippe 'ps-dict -All', um die vollständige Tabelle zu sehen."
        return
    }

    Write-LXBanner -Title "POWERSHELL TRANSLATOR" -Subtitle "$($results.Count) Treffer gefunden"

    foreach ($entry in $results) {
        $content = @()
        $content += "Linux / Bash:       $($entry.UnixCmd)"
        $content += "Windows CMD:        $($entry.WindowsCmd)"
        $content += "PowerShell Cmdlet:  $($entry.PSCmdlet)"
        if ($entry.Aliases) {
            $content += "Schnell-Aliase:     $($entry.Aliases -join ', ')"
        }
        $content += ""
        $content += "Beschreibung:       $($entry.Description)"
        $content += ""
        $content += "Praxis-Beispiel:    $($entry.Example)"
        $content += ""
        $content += "⚡ Hauptunterschied: $($entry.KeyDifference)"

        Write-LXBox -Title "$($entry.UnixCmd) ➔ $($entry.PSCmdlet)" -Content ($content -join "`n") -Color Cyan -Icon "🔄"
    }
}
