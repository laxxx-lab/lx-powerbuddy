<#
.SYNOPSIS
    Analysiert und erklärt beliebige PowerShell-Befehle und Pipelines im Klartext.
.DESCRIPTION
    Show-LXCommandExplanation zerlegt komplexe PowerShell-Einzeiler und Pipelines in ihre
    Bestandteile (Cmdlets, Parameter, Operatoren) und erklärt Schritt für Schritt
    auf Deutsch, was welcher Teil bewirkt und wie die Daten durch die Pipeline fließen.
.PARAMETER Command
    Der zu erklärende PowerShell-Befehl oder die Pipeline (als String).
.EXAMPLE
    explain "Get-Process | Where-Object CPU -gt 10 | Select-Object -First 5 Name, CPU"
.EXAMPLE
    Explain-LXCommand -Command "Get-ChildItem -Recurse -Filter *.log | Remove-Item -WhatIf"
#>
function Show-LXCommandExplanation {
    [CmdletBinding()]
    [Alias("explain", "lx-explain", "Explain-LXCommand")]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]$Command
    )

    $parsed = Parse-LXCommandLine -CommandLine $Command

    if ($parsed.HasSyntaxErrors) {
        Write-LXError "Syntaxfehler im angegebenen Befehl gefunden:"
        foreach ($err in $parsed.SyntaxErrors) {
            Write-Host "    Zeile $($err.Extent.StartLineNumber): $($err.Message)" -ForegroundColor Red
        }
        return
    }

    Write-LXBanner -Title "COMMAND EXPLAINER" -Subtitle "Pipeline-Analyse im Klartext"
    Write-Host "  Zu analysierender Befehl:" -ForegroundColor Yellow
    Write-Host "  -> $Command" -ForegroundColor White
    Write-Host ""

    foreach ($pipe in $parsed.Pipelines) {
        $totalStages = $pipe.Stages.Count
        Write-Host "  =================================================================" -ForegroundColor Cyan
        Write-Host "  Pipeline-Struktur: $totalStages Stufe(n)" -ForegroundColor Cyan
        Write-Host "  =================================================================" -ForegroundColor Cyan
        Write-Host ""

        foreach ($stage in $pipe.Stages) {
            $stageHeader = "Stufe $($stage.StageNumber)/$($stage.TotalStages): $($stage.CommandInfo.OriginalName)"
            $contentLines = @()
            
            $contentLines += "Befehl:      $($stage.CommandText)"
            $contentLines += "Typ:         $($stage.CommandInfo.CommandType)"
            if ($stage.CommandInfo.ModuleName) {
                $contentLines += "Modul:       $($stage.CommandInfo.ModuleName)"
            }
            $contentLines += ""
            $contentLines += "Funktion:    $($stage.Description)"

            if ($stage.Parameters.Count -gt 0) {
                $contentLines += ""
                $contentLines += "Parameter:"
                foreach ($param in $stage.Parameters) {
                    $valStr = if ($param.Value) { " -> $($param.Value)" } else { " (Schalter/Switch)" }
                    $contentLines += "  - $($param.Name)$valStr"
                }
            }

            if ($stage.Arguments.Count -gt 0) {
                $contentLines += ""
                $contentLines += "Argumente:"
                foreach ($arg in $stage.Arguments) {
                    $contentLines += "  - $arg"
                }
            }

            Write-LXBox -Title $stageHeader -Content ($contentLines -join "`n") -Color Cyan -Icon "[Pipeline]"

            if ($stage.StageNumber -lt $totalStages) {
                Write-Host "           |" -ForegroundColor Yellow
                Write-Host "           v  (Uebergibt .NET-Objekte durch die Pipeline '|')" -ForegroundColor Yellow
                Write-Host "           |" -ForegroundColor Yellow
                Write-Host ""
            }
        }
    }

    Write-LXInfo "Tipp: Fuehre den Befehl mit -WhatIf aus (wenn vom Cmdlet unterstuetzt), um ihn sicher zu testen!"
    Write-Host ""
}
