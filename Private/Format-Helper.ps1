# Private/Format-Helper.ps1

function Wrap-LXText {
    param(
        [string]$Text,
        [int]$MaxLen = 64
    )
    if ([string]::IsNullOrEmpty($Text)) { return @("") }
    
    $words = $Text -split '\s+'
    $lines = @()
    $currentLine = ""

    foreach ($w in $words) {
        if ([string]::IsNullOrEmpty($w)) { continue }
        if ($currentLine.Length -eq 0) {
            $currentLine = $w
        } elseif (($currentLine.Length + 1 + $w.Length) -le $MaxLen) {
            $currentLine += " " + $w
        } else {
            $lines += $currentLine
            $currentLine = $w
        }
    }
    if ($currentLine.Length -gt 0) {
        $lines += $currentLine
    }
    return $lines
}

function Write-LXBanner {
    param(
        [string]$Title = "LX POWERBUDDY",
        [string]$Subtitle = "Dein interaktiver PowerShell Lern- & Assistenz-Coach"
    )
    
    $border = "=" * 65
    Write-Host ""
    Write-Host "  $border" -ForegroundColor Cyan
    Write-Host "    __   _  __  ___                             ___           _     _       " -ForegroundColor Cyan
    Write-Host "   / /  | |/ / | _ \___ __ _____ _ _ ___ _  _  | _ )_  _   __| | __| |_  _  " -ForegroundColor Cyan
    Write-Host "  / /__  >  <  |  _/ _ \ V  V / -_) '_/ _ \ || | | _ \ || | / _` |/ _` | || | " -ForegroundColor Cyan
    Write-Host " /____/ /_/\\_\ |_| \___/\_/\_/\___|_|  \___/\_,_| |___/\_,_| \__,_|\__,_|\_, | " -ForegroundColor Cyan
    Write-Host "                                                                  |__/  " -ForegroundColor Cyan
    Write-Host "  $border" -ForegroundColor Cyan
    Write-Host "   [+] $Subtitle" -ForegroundColor Yellow
    Write-Host "  $border" -ForegroundColor Cyan
    Write-Host ""
}

function Write-LXBox {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        [Parameter(Mandatory=$true)]
        [string]$Content,
        [ConsoleColor]$Color = [ConsoleColor]::Cyan,
        [string]$Icon = "[*]"
    )
    
    $rawLines = $Content -split "`n"
    $width = 70
    $contentWidth = $width - 4
    
    Write-Host "  +$('-' * ($width - 2))+" -ForegroundColor $Color
    Write-Host "  | $Icon " -NoNewline -ForegroundColor $Color
    Write-Host "$Title" -NoNewline -ForegroundColor White
    $padding = $width - 5 - $Title.Length - $Icon.Length
    if ($padding -gt 0) { Write-Host (" " * $padding) -NoNewline }
    Write-Host " |" -ForegroundColor $Color
    Write-Host "  +$('-' * ($width - 2))+" -ForegroundColor $Color
    
    foreach ($rawLine in $rawLines) {
        $trimmed = $rawLine.TrimEnd("`r")
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            Write-Host "  | " -NoNewline -ForegroundColor $Color
            Write-Host (" " * $contentWidth) -NoNewline
            Write-Host " |" -ForegroundColor $Color
            continue
        }
        
        $wrapped = Wrap-LXText -Text $trimmed -MaxLen $contentWidth
        foreach ($line in $wrapped) {
            $pad = $contentWidth - $line.Length
            if ($pad -lt 0) { $pad = 0 }
            Write-Host "  | " -NoNewline -ForegroundColor $Color
            Write-Host $line -NoNewline -ForegroundColor Gray
            Write-Host (" " * $pad) -NoNewline
            Write-Host " |" -ForegroundColor $Color
        }
    }
    Write-Host "  +$('-' * ($width - 2))+" -ForegroundColor $Color
    Write-Host ""
}

function Write-LXSuccess {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-LXWarning {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-LXError {
    param([string]$Message)
    Write-Host "  [ERR] $Message" -ForegroundColor Red
}

function Write-LXInfo {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Cyan
}

function Write-LXKeyVal {
    param(
        [string]$Key,
        [string]$Value,
        [ConsoleColor]$KeyColor = [ConsoleColor]::DarkCyan,
        [ConsoleColor]$ValColor = [ConsoleColor]::White
    )
    Write-Host "    $($Key): " -NoNewline -ForegroundColor $KeyColor
    Write-Host $Value -ForegroundColor $ValColor
}
