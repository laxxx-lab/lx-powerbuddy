@{
    # Module manifest for LXPowerBuddy
    RootModule = 'LXPowerBuddy.psm1'
    ModuleVersion = '1.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'b4d9a207-6b45-429f-8ea8-cf2d28c2e742'
    Author = 'laxxx-lab'
    CompanyName = 'lx'
    Copyright = '(c) 2026 laxxx-lab. Alle Rechte vorbehalten.'
    Description = 'lx PowerBuddy - Dein interaktiver PowerShell Lern- & Assistenz-Coach direkt im Terminal.'
    PowerShellVersion = '5.1'

    # Functions to export
    FunctionsToExport = @(
        'Start-LXLesson',
        'Show-LXCommandExplanation',
        'Find-LXHowTo',
        'Trace-LXError',
        'Get-LXCheatSheet',
        'Show-LXDashboard'
    )

    # Cmdlets to export
    CmdletsToExport = @()

    # Variables to export
    VariablesToExport = '*'

    # Aliases to export
    AliasesToExport = @(
        'explain', 'Explain-LXCommand', 'lx-explain',
        'howdo', 'lx-howdo',
        'why-error', 'was-los', 'lx-error',
        'ps-dict', 'lx-dict', 'cheatsheet',
        'lx-quest', 'Start-PSQuest', 'lx-lesson',
        'lx-buddy', 'lx-dashboard'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell', 'Learning', 'Tutorial', 'Assistant', 'Interactive', 'Explain', 'Cheatsheet', 'Doctor')
            ProjectUri = 'https://github.com/laxxx-lab/lx-powerbuddy'
            LicenseUri = 'https://github.com/laxxx-lab/lx-powerbuddy/blob/main/LICENSE'
        }
    }
}
