<#
.SYNOPSIS
    Analysiert den letzten oder übergebenen PowerShell-Fehler und erklärt ihn verständlich.
.DESCRIPTION
    Trace-LXError nimmt den letzten Fehler aus $Error[0] (oder ein übergebenes Fehlerobjekt),
    prüft die Fehlermeldung und Exception-Typen gegen bekannte Fehlerquellen und liefert
    eine deutsche Übersetzung, die Ursache und konkrete Lösungsvorschläge.
.PARAMETER ErrorRecord
    Das zu analysierende Fehlerobjekt (Standard: $global:Error[0]).
.PARAMETER ListCommon
    Listet die häufigsten PowerShell-Fehlermeldungen und deren Bedeutung auf.
.EXAMPLE
    why-error
.EXAMPLE
    was-los
.EXAMPLE
    Trace-LXError -ListCommon
#>
function Trace-LXError {
    [CmdletBinding(DefaultParameterSetName="Analyze")]
    [Alias("why-error", "was-los", "lx-error")]
    param(
        [Parameter(Position=0, ValueFromPipeline=$true, ParameterSetName="Analyze")]
        [object]$ErrorRecord,

        [Parameter(ParameterSetName="List")]
        [switch]$ListCommon
    )

    $errorDb = Get-LXKnowledgeErrors

    if ($ListCommon) {
        Write-LXBanner -Title "FEHLER-KATALOG" -Subtitle "Häufige PowerShell-Fehler & Lösungen"
        foreach ($item in $errorDb) {
            $content = @()
            $content += "Typ: $($item.ErrorType)"
            $content += "Bedeutung: $($item.Explanation)"
            $content += ""
            $content += "Lösung:"
            foreach ($sol in $item.Solutions) {
                $content += "  • $sol"
            }
            Write-LXBox -Title $item.Title -Content ($content -join "`n") -Color Yellow -Icon "⚠️"
        }
        return
    }

    if (-not $ErrorRecord) {
        if ($global:Error.Count -gt 0) {
            $ErrorRecord = $global:Error[0]
        } else {
            Write-LXSuccess "Alles ruhig! Es ist bisher kein Fehler in dieser PowerShell-Sitzung aufgetreten."
            return
        }
    }

    $errMsg = if ($ErrorRecord.Exception) { $ErrorRecord.Exception.Message } else { $ErrorRecord.ToString() }
    $exType = if ($ErrorRecord.Exception) { $ErrorRecord.Exception.GetType().FullName } else { "" }
    $category = if ($ErrorRecord.CategoryInfo) { $ErrorRecord.CategoryInfo.Category.ToString() } else { "" }
    $cmdName = if ($ErrorRecord.InvocationInfo) { $ErrorRecord.InvocationInfo.MyCommand.Name } else { "" }
    $line = if ($ErrorRecord.InvocationInfo) { $ErrorRecord.InvocationInfo.Line } else { "" }

    # Match against error database
    $matched = $null
    foreach ($entry in $errorDb) {
        if ($errMsg -match $entry.Pattern -or $exType -match $entry.ErrorType) {
            $matched = $entry
            break
        }
    }

    Write-LXBanner -Title "FEHLER-DOKTOR" -Subtitle "Fehleranalyse & Erste Hilfe"

    $rawDetails = @()
    $rawDetails += "Original-Meldung: $errMsg"
    if ($cmdName) { $rawDetails += "Betroffener Befehl: $cmdName" }
    if ($line) { $rawDetails += "Zeile: $line" }
    if ($exType) { $rawDetails += "Exception-Typ: $exType" }

    Write-LXBox -Title "Aufgetretener Fehler" -Content ($rawDetails -join "`n") -Color Red -Icon "❌"

    if ($matched) {
        $diagLines = @()
        $diagLines += "Diagnose: $($matched.Explanation)`n"
        
        if ($matched.Causes) {
            $diagLines += "Mögliche Ursachen:"
            foreach ($c in $matched.Causes) {
                $diagLines += "  • $c"
            }
            $diagLines += ""
        }

        if ($matched.Solutions) {
            $diagLines += "Empfohlene Lösungsschritte:"
            foreach ($s in $matched.Solutions) {
                $diagLines += "  ✅ $s"
            }
        }

        Write-LXBox -Title "Was bedeutet das? ($($matched.Title))" -Content ($diagLines -join "`n") -Color Green -Icon "🩺"
    } else {
        $generalHelp = @()
        $generalHelp += "Dieser spezielle Fehler ist noch nicht im Musterkatalog erfasst."
        $generalHelp += ""
        $generalHelp += "Allgemeine Tipps zur Fehlerbehebung:"
        $generalHelp += "  1. Prüfe die Syntax mit: Get-Command <Befehl> -Syntax"
        $generalHelp += "  2. Schau in die Hilfe: Get-Help <Befehl> -Examples"
        $generalHelp += "  3. Prüfe, ob benötigte Parameter übergeben wurden oder Variablen den Wert `$null haben."

        Write-LXBox -Title "Allgemeine Diagnose" -Content ($generalHelp -join "`n") -Color Yellow -Icon "🔍"
    }
}
