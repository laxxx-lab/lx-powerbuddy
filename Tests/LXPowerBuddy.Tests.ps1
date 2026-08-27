# Tests/LXPowerBuddy.Tests.ps1
# Automated validation suite for LXPowerBuddy module

$ErrorActionPreference = "Stop"
$scriptRoot = $PSScriptRoot
$moduleRoot = Split-Path -Parent $scriptRoot
$manifestPath = Join-Path $moduleRoot "LXPowerBuddy.psd1"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Running LXPowerBuddy Test Suite" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

$passed = 0
$failed = 0

function Assert-Condition {
    param(
        [string]$TestName,
        [bool]$Condition,
        [string]$Message = ""
    )
    if ($Condition) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "  [FAIL] $TestName - $Message" -ForegroundColor Red
        $script:failed++
    }
}

# 1. Test Module Manifest
Write-Host "`n1. Testing Module Manifest..." -ForegroundColor Yellow
$manifestTest = Test-ModuleManifest -Path $manifestPath -ErrorAction SilentlyContinue
Assert-Condition "Module manifest is valid" ($null -ne $manifestTest) "Manifest test returned null or threw error"

# 2. Test Module Import
Write-Host "`n2. Testing Module Import..." -ForegroundColor Yellow
try {
    Import-Module $manifestPath -Force -ErrorAction Stop
    Assert-Condition "Module imported successfully" ($true)
} catch {
    Assert-Condition "Module imported successfully" ($false) $_.Exception.Message
}

# Also dot-source private files into test scope for deep data validation
Get-ChildItem (Join-Path $moduleRoot "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

# 3. Test Exported Commands & Aliases
Write-Host "`n3. Testing Exported Commands & Aliases..." -ForegroundColor Yellow
$expectedFunctions = @(
    'Start-LXLesson', 'Show-LXCommandExplanation', 'Find-LXHowTo',
    'Trace-LXError', 'Get-LXCheatSheet', 'Show-LXDashboard'
)
foreach ($fn in $expectedFunctions) {
    $cmd = Get-Command -Name $fn -ErrorAction SilentlyContinue
    Assert-Condition "Function '$fn' is available" ($null -ne $cmd)
}

$expectedAliases = @('explain', 'Explain-LXCommand', 'howdo', 'why-error', 'was-los', 'ps-dict', 'lx-quest', 'lx-buddy')
foreach ($al in $expectedAliases) {
    $aliasCmd = Get-Alias -Name $al -ErrorAction SilentlyContinue
    Assert-Condition "Alias '$al' resolves" ($null -ne $aliasCmd)
}

# 4. Test Data Integrity
Write-Host "`n4. Testing Knowledge Base & Lessons..." -ForegroundColor Yellow
$lessons = Get-LXAllLessons
Assert-Condition "Loaded all 6 lessons" ($lessons.Count -eq 6) "Found $($lessons.Count) lessons"

foreach ($l in $lessons) {
    Assert-Condition "Lesson '$($l.Title)' has valid steps" ($l.Steps.Count -gt 0)
}

$cheatsheet = Get-LXKnowledgeCheatsheet
Assert-Condition "Cheatsheet contains entries (>15)" ($cheatsheet.Count -ge 15) "Found $($cheatsheet.Count) entries"

$howdos = Get-LXKnowledgeHowTo
Assert-Condition "HowDo database contains entries (>8)" ($howdos.Count -ge 8) "Found $($howdos.Count) entries"

$errorsDb = Get-LXKnowledgeErrors
Assert-Condition "Error database contains common error patterns" ($errorsDb.Count -ge 5) "Found $($errorsDb.Count) entries"

# 5. Test AST Explainer
Write-Host "`n5. Testing Explain-LXCommand AST Parsing..." -ForegroundColor Yellow
$testCmd = 'Get-Process | Where-Object CPU -gt 10 | Select-Object -First 5 Name, CPU'
$parsed = Parse-LXCommandLine -CommandLine $testCmd
Assert-Condition "Parsed pipeline without syntax errors" (-not $parsed.HasSyntaxErrors)
Assert-Condition "Pipeline has 3 stages" ($parsed.Pipelines[0].Stages.Count -eq 3) "Stages count: $($parsed.Pipelines[0].Stages.Count)"

# 6. Test HowDo Query
Write-Host "`n6. Testing HowDo Search Engine..." -ForegroundColor Yellow
$searchResult = $howdos | Where-Object { $_.Title -like "*port*" -or $_.Keywords -contains "port" }
Assert-Condition "HowDo search finds port testing entry" ($searchResult.Count -ge 1)

# 7. Test Linux/CMD Translator
Write-Host "`n7. Testing Linux/CMD Dictionary..." -ForegroundColor Yellow
$grepMatch = $cheatsheet | Where-Object { $_.UnixCmd -eq "grep" }
Assert-Condition "ps-dict resolves 'grep' to 'Select-String'" ($grepMatch.PSCmdlet -eq "Select-String")

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host " Test Results: $passed Passed, $failed Failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "================================================================" -ForegroundColor Cyan

if ($failed -gt 0) {
    exit 1
}
