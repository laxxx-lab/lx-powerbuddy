# LXPowerBuddy.psm1 - Root Module Loader

$publicPath  = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$privatePath = Join-Path -Path $PSScriptRoot -ChildPath "Private"

# Load Private Helper Functions
if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Load Public Cmdlets
if (Test-Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Define Aliases safely
$aliases = @{
    "explain"            = "Show-LXCommandExplanation"
    "Explain-LXCommand"  = "Show-LXCommandExplanation"
    "lx-explain"         = "Show-LXCommandExplanation"
    "howdo"              = "Find-LXHowTo"
    "lx-howdo"           = "Find-LXHowTo"
    "why-error"          = "Trace-LXError"
    "was-los"            = "Trace-LXError"
    "lx-error"           = "Trace-LXError"
    "ps-dict"            = "Get-LXCheatSheet"
    "lx-dict"            = "Get-LXCheatSheet"
    "cheatsheet"         = "Get-LXCheatSheet"
    "lx-quest"           = "Start-LXLesson"
    "Start-PSQuest"      = "Start-LXLesson"
    "lx-lesson"          = "Start-LXLesson"
    "lx-buddy"           = "Show-LXDashboard"
    "lx-dashboard"       = "Show-LXDashboard"
}

foreach ($aliasName in $aliases.Keys) {
    Set-Alias -Name $aliasName -Value $aliases[$aliasName] -Force -Scope Global -ErrorAction SilentlyContinue
}

# Export Functions and Aliases
Export-ModuleMember -Function @(
    "Start-LXLesson",
    "Show-LXCommandExplanation",
    "Find-LXHowTo",
    "Trace-LXError",
    "Get-LXCheatSheet",
    "Show-LXDashboard"
) -Alias ($aliases.Keys)

# Friendly Load Message
Write-Host "⚡ lx PowerBuddy geladen! Tippe " -NoNewline -ForegroundColor Cyan
Write-Host "lx-buddy" -NoNewline -ForegroundColor Green
Write-Host " oder " -NoNewline -ForegroundColor Cyan
Write-Host "Start-LXLesson" -NoNewline -ForegroundColor Green
Write-Host " um loszulegen." -ForegroundColor Cyan
