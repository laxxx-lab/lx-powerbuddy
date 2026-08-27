# Private/AST-Parser.ps1

function Parse-LXCommandLine {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CommandLine
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($CommandLine, [ref]$tokens, [ref]$errors)

    $result = @{
        RawCommand = $CommandLine
        HasSyntaxErrors = ($errors.Count -gt 0)
        SyntaxErrors = $errors
        Pipelines = @()
    }

    if ($result.HasSyntaxErrors) {
        return $result
    }

    # Find all pipeline ASTs in the command
    $pipelineAsts = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.PipelineAst] }, $true)

    foreach ($pAst in $pipelineAsts) {
        $pipelineInfo = @{
            PipelineText = $pAst.Extent.Text
            Stages = @()
        }

        $commandAsts = $pAst.PipelineElements
        $stageIndex = 1
        $totalStages = $commandAsts.Count

        foreach ($cmd in $commandAsts) {
            $cmdText = $cmd.Extent.Text
            $cmdElements = $cmd.CommandElements
            
            $cmdName = if ($cmdElements.Count -gt 0) { $cmdElements[0].Extent.Text } else { "" }
            
            # Resolve Command / Alias Details
            $resolvedInfo = @{
                OriginalName = $cmdName
                ResolvedName = $cmdName
                CommandType  = "Unbekannt"
                Synopsis     = ""
                ModuleName   = ""
            }

            if ($cmdName) {
                $resolvedCmd = Get-Command -Name $cmdName -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($resolvedCmd) {
                    $resolvedInfo.CommandType = $resolvedCmd.CommandType.ToString()
                    if ($resolvedCmd.CommandType -eq [System.Management.Automation.CommandTypes]::Alias) {
                        $resolvedInfo.ResolvedName = $resolvedCmd.ResolvedCommandName
                        $resolvedInfo.OriginalName = "$cmdName (Alias für '$($resolvedCmd.ResolvedCommandName)')"
                        # Try to get help on resolved command
                        $targetCmd = Get-Command -Name $resolvedCmd.ResolvedCommandName -ErrorAction SilentlyContinue | Select-Object -First 1
                        if ($targetCmd) {
                            $resolvedInfo.ModuleName = $targetCmd.ModuleName
                        }
                    } else {
                        $resolvedInfo.ModuleName = $resolvedCmd.ModuleName
                    }

                    # Fetch short help synopsis
                    try {
                        $help = Get-Help $resolvedInfo.ResolvedName -ErrorAction SilentlyContinue
                        if ($help -and $help.Synopsis) {
                            $resolvedInfo.Synopsis = $help.Synopsis.Trim()
                        }
                    } catch {}
                }
            }

            # Parse parameters and arguments
            $parameters = @()
            $arguments = @()

            for ($i = 1; $i -lt $cmdElements.Count; $i++) {
                $el = $cmdElements[$i]
                if ($el -is [System.Management.Automation.Language.CommandParameterAst]) {
                    $paramName = $el.ParameterName
                    $paramValue = if ($el.Argument) { $el.Argument.Extent.Text } else { $null }
                    $parameters += @{
                        Name = "-$paramName"
                        Value = $paramValue
                    }
                } else {
                    $arguments += $el.Extent.Text
                }
            }

            # Generate plain text German description for this stage
            $stageDescription = ""
            switch -Regex ($resolvedInfo.ResolvedName) {
                "^(Get-Process)$" {
                    $stageDescription = "Holt laufende Windows-Prozesse als System.Diagnostics.Process-Objekte ab."
                }
                "^(Get-Service)$" {
                    $stageDescription = "Ermittelt den Status aller Windows-Dienste."
                }
                "^(Get-ChildItem)$" {
                    $stageDescription = "Liest Dateien und Verzeichnisse im angegebenen Pfad aus."
                }
                "^(Get-Content)$" {
                    $stageDescription = "Liest den Inhalt einer Datei Zeile für Zeile."
                }
                "^(Where-Object)$" {
                    $stageDescription = "Filtert eingehende Pipeline-Objekte anhand einer Bedingung (lässt nur passende durch)."
                }
                "^(Select-Object)$" {
                    $stageDescription = "Wählt bestimmte Eigenschaften (Spalten) aus oder beschränkt die Anzahl (z.B. -First)."
                }
                "^(Sort-Object)$" {
                    $stageDescription = "Sortiert die Objekte nach den angegebenen Eigenschaften."
                }
                "^(ForEach-Object)$" {
                    $stageDescription = "Führt einen Skriptblock für jedes einzelne Element in der Pipeline aus."
                }
                "^(Group-Object)$" {
                    $stageDescription = "Gruppiert Objekte, die denselben Wert in einer Eigenschaft haben."
                }
                "^(Measure-Object)$" {
                    $stageDescription = "Zählt Objekte oder berechnet mathematische Werte (Summe, Durchschnitt, Min, Max)."
                }
                "^(Out-GridView)$" {
                    $stageDescription = "Öffnet ein interaktives grafisches Fenster mit Filter- und Sortierfunktion."
                }
                "^(Export-Csv)$" {
                    $stageDescription = "Schreibt die Pipeline-Objekte als strukturierte CSV-Datei auf die Festplatte."
                }
                "^(Stop-Process)$" {
                    $stageDescription = "Beendet die übergebenen oder angegebenen Prozesse sofort."
                }
                default {
                    if ($resolvedInfo.Synopsis) {
                        $stageDescription = $resolvedInfo.Synopsis
                    } else {
                        $stageDescription = "Führt den Befehl '$($resolvedInfo.ResolvedName)' aus."
                    }
                }
            }

            $pipelineInfo.Stages += @{
                StageNumber = $stageIndex
                TotalStages = $totalStages
                CommandText = $cmdText
                CommandInfo = $resolvedInfo
                Parameters  = $parameters
                Arguments   = $arguments
                Description = $stageDescription
            }

            $stageIndex++
        }

        $result.Pipelines += $pipelineInfo
    }

    return $result
}
