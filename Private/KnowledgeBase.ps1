# Private/KnowledgeBase.ps1

$script:LXDataPath = Join-Path -Path $PSScriptRoot -ChildPath "..\Data"

function Get-LXDataRoot {
    return (Resolve-Path $script:LXDataPath).Path
}

function Get-LXKnowledgeCheatsheet {
    $file = Join-Path (Get-LXDataRoot) "cheatsheet.json"
    if (Test-Path $file) {
        return (Get-Content $file -Raw -Encoding UTF8 | ConvertFrom-Json)
    }
    return @()
}

function Get-LXKnowledgeHowTo {
    $file = Join-Path (Get-LXDataRoot) "howdo_database.json"
    if (Test-Path $file) {
        return (Get-Content $file -Raw -Encoding UTF8 | ConvertFrom-Json)
    }
    return @()
}

function Get-LXKnowledgeErrors {
    $file = Join-Path (Get-LXDataRoot) "error_database.json"
    if (Test-Path $file) {
        return (Get-Content $file -Raw -Encoding UTF8 | ConvertFrom-Json)
    }
    return @()
}

function Get-LXAllLessons {
    $lessonsDir = Join-Path (Get-LXDataRoot) "lessons"
    if (-not (Test-Path $lessonsDir)) { return @() }
    
    $lessonFiles = Get-ChildItem -Path $lessonsDir -Filter "*.json" | Sort-Object Name
    $lessons = @()
    foreach ($f in $lessonFiles) {
        try {
            $data = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            $lessons += $data
        } catch {
            Write-Warning "Konnte Lektionsdatei nicht laden: $($f.Name)"
        }
    }
    return ($lessons | Sort-Object Order)
}
