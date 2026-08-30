# ==============================================================================
# TOOL NAME:    shell-wizard.ps1 (Windows Native PowerShell Orchestrator)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Enterprise-grade PowerShell Customization Engine with State Management, 
#               Managed Profile Blocks, Theme Live Previews, Dry-Run Mode & Global CLI Registration.
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "Shell-Wizard Ultimate - Gold Standard Engine"

$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
$RepoRoot = Split-Path -Parent $ScriptDir
$ThemesDir = Join-Path -Path $ScriptDir -ChildPath "themes"
$StateDir = Join-Path -Path $HOME -ChildPath ".shell_wizard"
$StateFile = Join-Path -Path $StateDir -ChildPath "current.json"

# Global Dry-Run Flag State
if ($null -eq $global:ShellWizardDryRun) {
    $global:ShellWizardDryRun = $false
}

# Ensure State Directory Exists
if (-not (Test-Path -Path $StateDir)) {
    New-Item -ItemType Directory -Path $StateDir -Force | Out-Null
}

# --- State Management Functions ---
function Get-ShellWizardState {
    if (Test-Path -Path $StateFile) {
        try {
            return Get-Content -Path $StateFile -Raw | ConvertFrom-Json
        } catch {
            return $null
        }
    }
    return [PSCustomObject]@{
        ActiveEngine = "Native"
        ActiveTheme  = "Default"
        ActiveFont   = "Cascadia Mono"
        InstalledCLI = @()
        GlobalAlias  = "Disabled"
        LastUpdated  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }
}

function Save-ShellWizardState {
    param (
        [string]$Engine,
        [string]$Theme,
        [string]$Font,
        [string[]]$InstalledTools,
        [string]$GlobalStatus
    )
    $State = Get-ShellWizardState
    
    # Ensure properties exist on custom object dynamically (Fixes missing property exceptions)
    if (-not ($State.PSObject.Properties['GlobalAlias'])) {
        $State | Add-Member -MemberType NoteProperty -Name "GlobalAlias" -Value "Disabled" -Force
    }

    if ($Engine)         { $State.ActiveEngine = $Engine }
    if ($Theme)          { $State.ActiveTheme  = $Theme }
    if ($Font)           { $State.ActiveFont   = $Font }
    if ($InstalledTools) { $State.InstalledCLI = $InstalledTools }
    if ($GlobalStatus)   { $State.GlobalAlias  = $GlobalStatus }
    
    $State.LastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    
    $State | ConvertTo-Json -Depth 8 | Set-Content -Path $StateFile -Encoding UTF8
}

function Show-Header {
    Clear-Host
    
    $BannerPath = Join-Path -Path $ScriptDir -ChildPath "banner.txt"
    $RootBannerPath = Join-Path -Path $RepoRoot -ChildPath "banner.txt"

    if (Test-Path -Path $BannerPath) {
        Get-Content -Path $BannerPath | Write-Host -ForegroundColor Cyan
    } elseif (Test-Path -Path $RootBannerPath) {
        Get-Content -Path $RootBannerPath | Write-Host -ForegroundColor Cyan
    }

    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "           SHELL-WIZARD ULTIMATE - POWERSHELL ORCHESTRATOR           " -ForegroundColor Cyan
    Write-Host "====================================================================" -ForegroundColor Cyan
    
    $State = Get-ShellWizardState
    $DryRunStatus = if ($global:ShellWizardDryRun) { "[ON - PREVIEW MODE]" } else { "[OFF - LIVE WRITES]" }
    $DryColor = if ($global:ShellWizardDryRun) { "Yellow" } else { "DarkGray" }
    $GlobalAliasText = if ($State.GlobalAlias -eq "Enabled") { "Enabled [shell-wizard]" } else { "Not Registered" }

    Write-Host " [STATUS] Engine: $($State.ActiveEngine) | Theme: $($State.ActiveTheme) | Font: $($State.ActiveFont)" -ForegroundColor DarkGray
    Write-Host " [GLOBAL] CLI Command: $GlobalAliasText" -ForegroundColor DarkGray
    Write-Host " [DRY-RUN] $DryRunStatus" -ForegroundColor $DryColor
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-Console {
    Write-Host ""
    Read-Host "Press [ENTER] to return to menu..."
}

# --- Unified Managed Profile Writer ---
function Write-ManagedProfile {
    param (
        [string[]]$ConfigLines
    )

    $BlockStart = "# >>> SHELL-WIZARD MANAGED BLOCK >>>"
    $BlockEnd   = "# <<< SHELL-WIZARD MANAGED BLOCK <<<"

    $NewBlock = "$BlockStart`n" + ($ConfigLines -join "`n") + "`n$BlockEnd"

    if ($global:ShellWizardDryRun) {
        Write-Host "`n[DRY-RUN] Preview of Managed Block to be written to `$PROFILE:" -ForegroundColor Yellow
        Write-Host $NewBlock -ForegroundColor Green
        return
    }

    if (-not (Test-Path -Path $PROFILE)) {
        $ProfileDir = Split-Path -Parent $PROFILE
        if (-not (Test-Path -Path $ProfileDir)) {
            New-Item -Path $ProfileDir -Type Directory -Force | Out-Null
        }
        New-Item -Path $PROFILE -Type File -Force | Out-Null
    }

    $ExistingContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
    if (-not $ExistingContent) { $ExistingContent = "" }

    if ($ExistingContent -match "(?s)$([regex]::Escape($BlockStart)).*?$([regex]::Escape($BlockEnd))") {
        $UpdatedContent = $ExistingContent -replace "(?s)$([regex]::Escape($BlockStart)).*?$([regex]::Escape($BlockEnd))", $NewBlock
    } else {
        $UpdatedContent = "$ExistingContent`n`n$NewBlock".Trim()
    }

    Set-Content -Path $PROFILE -Value $UpdatedContent -Encoding UTF8
    Write-Host "[OK] Managed profile block updated cleanly in `$PROFILE!" -ForegroundColor Green
}

# --- Autonomous Windows Terminal Font Injector ---
function Set-WindowsTerminalFont {
    param (
        [string]$ExactFontName = "CaskaydiaCove Nerd Font"
    )

    $WTConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if ($global:ShellWizardDryRun) {
        Write-Host "`n[DRY-RUN] Would update Windows Terminal settings.json font face to: '$ExactFontName'" -ForegroundColor Yellow
        return
    }

    Write-Host "--> Configuring Windows Terminal autonomously for font face: '$ExactFontName'..." -ForegroundColor Cyan

    if (Test-Path -Path $WTConfigPath) {
        try {
            $TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $BackupWT = "$WTConfigPath.bak_$TimeStamp"
            Copy-Item -Path $WTConfigPath -Destination $BackupWT -Force

            $JsonRaw = Get-Content -Path $WTConfigPath -Raw | ConvertFrom-Json
            
            if (-not $JsonRaw.profiles.defaults) {
                $JsonRaw.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{}) -ErrorAction SilentlyContinue
            }

            if (-not $JsonRaw.profiles.defaults.font) {
                $JsonRaw.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value ([PSCustomObject]@{ "face" = $ExactFontName }) -ErrorAction SilentlyContinue
            } else {
                $JsonRaw.profiles.defaults.font.face = $ExactFontName
            }

            $JsonRaw | ConvertTo-Json -Depth 32 | Set-Content -Path $WTConfigPath -Encoding UTF8
            Save-ShellWizardState -Font $ExactFontName
            Write-Host "[OK] Windows Terminal font updated to '$ExactFontName' autonomously!" -ForegroundColor Green
            Write-Host "[i] IMPORTANT: Restart your Windows Terminal window to apply font rendering!" -ForegroundColor Yellow
        } catch {
            Write-Host "[!] Could not modify Windows Terminal settings automatically." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[!] Windows Terminal settings file not found (standard PowerShell host in use)." -ForegroundColor Yellow
    }
}

# --- Module 1: Safety Backup / Rollback Engine v2 — Verified, Atomic, Manual-Only ---

function Get-FileHashSafe {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) { return $null }
    try {
        return (Get-FileHash -Path $Path -Algorithm SHA256 -ErrorAction Stop).Hash
    } catch {
        return $null
    }
}

function Copy-ItemAtomic {
    param(
        [string]$Source,
        [string]$Destination,
        [int]$MaxRetries = 3
    )
    $DestDir = Split-Path -Parent $Destination
    if (-not (Test-Path -Path $DestDir)) {
        New-Item -Path $DestDir -Type Directory -Force | Out-Null
    }

    $TempDest = "$Destination.wizard_tmp"
    $SourceHash = Get-FileHashSafe -Path $Source
    if (-not $SourceHash) {
        return @{ Success = $false; Reason = "Source file unreadable or missing: $Source" }
    }

    for ($Attempt = 1; $Attempt -le $MaxRetries; $Attempt++) {
        try {
            Copy-Item -Path $Source -Destination $TempDest -Force -ErrorAction Stop
            $TempHash = Get-FileHashSafe -Path $TempDest

            if ($TempHash -ne $SourceHash) {
                Remove-Item -Path $TempDest -Force -ErrorAction SilentlyContinue
                throw "Hash mismatch after copy (attempt $Attempt)"
            }

            Move-Item -Path $TempDest -Destination $Destination -Force -ErrorAction Stop
            return @{ Success = $true; Reason = "OK" }

        } catch {
            Remove-Item -Path $TempDest -Force -ErrorAction SilentlyContinue
            if ($Attempt -lt $MaxRetries) {
                Start-Sleep -Milliseconds (300 * $Attempt)
            } else {
                return @{ Success = $false; Reason = $_.Exception.Message }
            }
        }
    }
}

function New-ShellWizardBackup {
    param([switch]$Silent)

    if (-not $Silent) {
        Show-Header
        Write-Host "CREATING VERIFIED BACKUP SNAPSHOT" -ForegroundColor Yellow
        Write-Host ""
    }

    $BackupDir = Join-Path -Path $HOME -ChildPath ".shell_wizard_backups"
    $TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $TargetDir = Join-Path -Path $BackupDir -ChildPath "backup_$TimeStamp"
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

    $WTConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $Targets = @(
        @{ Label = "PowerShell Profile"; Source = $PROFILE; DestName = "Microsoft.PowerShell_profile.ps1" },
        @{ Label = "Windows Terminal Settings"; Source = $WTConfigPath; DestName = "settings.json" }
    )

    $Manifest = @{ CreatedAt = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); Files = @() }
    $AnyFileBackedUp = $false
    $AnyFailure = $false

    foreach ($Item in $Targets) {
        if (-not (Test-Path -Path $Item.Source)) {
            if (-not $Silent) { Write-Host "  [i] $($Item.Label) — not present, skipped" -ForegroundColor DarkGray }
            continue
        }

        $Dest = Join-Path -Path $TargetDir -ChildPath $Item.DestName
        $Result = Copy-ItemAtomic -Source $Item.Source -Destination $Dest

        if ($Result.Success) {
            $Hash = Get-FileHashSafe -Path $Dest
            $Manifest.Files += @{ Name = $Item.DestName; Label = $Item.Label; SHA256 = $Hash }
            if (-not $Silent) { Write-Host "  [OK] $($Item.Label) backed up and verified" -ForegroundColor Green }
            $AnyFileBackedUp = $true
        } else {
            if (-not $Silent) { Write-Host "  [FAIL] $($Item.Label): $($Result.Reason)" -ForegroundColor Red }
            $AnyFailure = $true
        }
    }

    if (-not $AnyFileBackedUp) {
        if (-not $Silent) {
            Write-Host "`n[!] Nothing to back up — no profile or settings found." -ForegroundColor Yellow
        }
        Remove-Item -Path $TargetDir -Recurse -Force -ErrorAction SilentlyContinue
        if (-not $Silent) { Pause-Console }
        return
    }

    $ManifestPath = Join-Path -Path $TargetDir -ChildPath "manifest.json"
    $ManifestTemp = "$ManifestPath.tmp"
    $Manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $ManifestTemp -Encoding UTF8
    Move-Item -Path $ManifestTemp -Destination $ManifestPath -Force

    $AllBackups = Get-ChildItem -Path $BackupDir -Directory | Sort-Object CreationTime -Descending
    if ($AllBackups.Count -gt 10) {
        $AllBackups | Select-Object -Skip 10 | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    if (-not $Silent) {
        Write-Host ""
        if ($AnyFailure) {
            Write-Host "[PARTIAL] Backup completed with some failures — see above. Snapshot: $TargetDir" -ForegroundColor Yellow
        } else {
            Write-Host "[OK] Backup snapshot verified and complete: $TargetDir" -ForegroundColor Green
        }
        Pause-Console
    }
}

function Test-BackupManifest {
    param([string]$BackupPath)

    $ManifestPath = Join-Path -Path $BackupPath -ChildPath "manifest.json"
    if (-not (Test-Path -Path $ManifestPath)) {
        return @{ Valid = $false; Reason = "No manifest.json — legacy or corrupted snapshot"; Files = @() }
    }

    try {
        $Manifest = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
    } catch {
        return @{ Valid = $false; Reason = "manifest.json is corrupted/unreadable"; Files = @() }
    }

    $Verified = @()
    foreach ($File in $Manifest.Files) {
        $FilePath = Join-Path -Path $BackupPath -ChildPath $File.Name
        $ActualHash = Get-FileHashSafe -Path $FilePath
        $Verified += @{ Name = $File.Name; Label = $File.Label; OK = ($ActualHash -eq $File.SHA256) }
    }

    $AllOK = -not ($Verified | Where-Object { -not $_.OK })
    return @{ Valid = $AllOK; Reason = "OK"; Files = $Verified }
}

function Restore-ShellWizardBackup {
    Show-Header
    Write-Host "VERIFIED ROLLBACK / RESTORE" -ForegroundColor Yellow
    Write-Host ""

    $BackupDir = Join-Path -Path $HOME -ChildPath ".shell_wizard_backups"
    if (-not (Test-Path -Path $BackupDir)) {
        Write-Host "[!] No backup directory found. Nothing to restore." -ForegroundColor Red
        Pause-Console
        return
    }

    $Backups = Get-ChildItem -Path $BackupDir -Directory | Sort-Object CreationTime -Descending
    if ($Backups.Count -eq 0) {
        Write-Host "[!] No backups found." -ForegroundColor Red
        Pause-Console
        return
    }

    Write-Host "Available Backups:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Backups.Count; $i++) {
        $Check = Test-BackupManifest -BackupPath $Backups[$i].FullName
        $Tag = if ($Check.Valid) { "[VERIFIED]" } else { "[UNVERIFIED]" }
        $Color = if ($Check.Valid) { "Green" } else { "Yellow" }
        Write-Host ("  [{0}] {1}  " -f ($i + 1), $Backups[$i].Name) -NoNewline -ForegroundColor White
        Write-Host $Tag -ForegroundColor $Color
    }
    Write-Host ""

    $SelectIndex = Read-Host "Select backup number to restore [1-$($Backups.Count)] (or C to cancel)"
    if ($SelectIndex -eq "C" -or $SelectIndex -eq "c") { return }

    $Index = [int]$SelectIndex - 1
    if ($Index -lt 0 -or $Index -ge $Backups.Count) {
        Write-Host "`n[!] Invalid selection." -ForegroundColor Red
        Pause-Console
        return
    }

    $SelectedBackup = $Backups[$Index].FullName
    $Check = Test-BackupManifest -BackupPath $SelectedBackup

    if (-not $Check.Valid) {
        Write-Host "`n[!] WARNING: This backup failed integrity verification ($($Check.Reason))." -ForegroundColor Red
        $Force = Read-Host "Restore anyway at your own risk? (y/n)"
        if ($Force -ne 'y' -and $Force -ne 'Y') {
            Write-Host "[i] Restore cancelled — backup was not trusted." -ForegroundColor Yellow
            Pause-Console
            return
        }
    }

    # Safety net: silently snapshot current state before overwriting it,
    # so an unwanted rollback is itself reversible. Fires only here, not on theme changes.
    Write-Host "`n--> Saving a safety snapshot of your current state before rollback..." -ForegroundColor Cyan
    New-ShellWizardBackup -Silent

    $WTConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $RestoreMap = @(
        @{ Label = "PowerShell Profile"; File = "Microsoft.PowerShell_profile.ps1"; Dest = $PROFILE },
        @{ Label = "Windows Terminal Settings"; File = "settings.json"; Dest = $WTConfigPath }
    )

    $AnyRestored = $false
    $AnyFailure = $false

    foreach ($Item in $RestoreMap) {
        $Source = Join-Path -Path $SelectedBackup -ChildPath $Item.File
        if (-not (Test-Path -Path $Source)) {
            Write-Host "  [i] $($Item.Label) — not in this snapshot, skipped" -ForegroundColor DarkGray
            continue
        }

        $Result = Copy-ItemAtomic -Source $Source -Destination $Item.Dest
        if ($Result.Success) {
            Write-Host "  [OK] $($Item.Label) restored and verified" -ForegroundColor Green
            $AnyRestored = $true
        } else {
            Write-Host "  [FAIL] $($Item.Label): $($Result.Reason)" -ForegroundColor Red
            $AnyFailure = $true
        }
    }

    Write-Host ""
    if ($AnyFailure) {
        Write-Host "[PARTIAL] Rollback completed with failures — your pre-rollback state was saved separately." -ForegroundColor Yellow
    } elseif ($AnyRestored) {
        Write-Host "[OK] Rollback complete and verified." -ForegroundColor Green
        Write-Host "[i] Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
    } else {
        Write-Host "[!] Nothing was restored — snapshot may be empty." -ForegroundColor Yellow
    }
    Pause-Console
}

function Backup-And-Rollback-Engine {
    Show-Header
    Write-Host "SAFETY AND BACKUP ENGINE (WINDOWS POWERSHELL)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Create Verified Backup Snapshot" -ForegroundColor Green
    Write-Host "  [2] Rollback / Restore from Backup (Integrity-Checked)" -ForegroundColor Green
    Write-Host "  [3] Back to Main Menu" -ForegroundColor Green
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Cyan

    $BackupChoice = Read-Host "Select choice [1-3]"
    switch ($BackupChoice) {
        "1" { New-ShellWizardBackup }
        "2" { Restore-ShellWizardBackup }
        "3" { return }
        default { Write-Host "Invalid choice!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}

# --- Module 2: 1-Click Supercharge ---
function Install-WindowsBeautifier {
    Write-Host ""
    Write-Host "--> Installing Oh My Posh theme engine..." -ForegroundColor Cyan
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements

    Write-Host ""
    Write-Host "--> Registering CascadiaCode Nerd Font into Windows Font Engine..." -ForegroundColor Cyan
    oh-my-posh font install CascadiaCode

    Write-Host ""
    Write-Host "--> Installing Terminal-Icons and PSReadLine modules..." -ForegroundColor Cyan
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -AllowClobber -ErrorAction SilentlyContinue
    Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber -ErrorAction SilentlyContinue

    $DefaultThemePath = Join-Path -Path $ThemesDir -ChildPath "jebree.omp.json"

    if (-not (Test-Path -Path $DefaultThemePath)) {
        Write-Host "`n[!] ERROR: Could not find jebree.omp.json in $ThemesDir!" -ForegroundColor Red
        Pause-Console
        return
    }

    $ConfigLines = @(
        "Import-Module Terminal-Icons -ErrorAction SilentlyContinue",
        "Import-Module PSReadLine -ErrorAction SilentlyContinue",
        "Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue",
        "oh-my-posh init pwsh --config '$DefaultThemePath' | Invoke-Expression"
    )

    Write-ManagedProfile -ConfigLines $ConfigLines
    Set-WindowsTerminalFont -ExactFontName "CaskaydiaCove Nerd Font"
    Save-ShellWizardState -Engine "Oh My Posh" -Theme "Jebree" -Font "CaskaydiaCove Nerd Font"

    Write-Host ""
    Write-Host "[OK] WINDOWS POWERSHELL SUPERCHARGE COMPLETE!" -ForegroundColor Green
    Write-Host "Restart your PowerShell window or run: . `$PROFILE" -ForegroundColor Cyan
    Pause-Console
}

# --- Module 3: 100% Offline Theme Switcher ---
function Switch-PowerShellThemes {
    Show-Header
    Write-Host "POWERSHELL OH-MY-POSH THEME SELECTOR (EXPANDED LOCAL SUITE)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Jebree (Recommended Segmented Powerline Prompt)" -ForegroundColor Green
    Write-Host "  [2] Paradox (Classic Powerline Prompt)" -ForegroundColor Green
    Write-Host "  [3] Agnoster (Icon-Rich Status Prompt)" -ForegroundColor Green
    Write-Host "  [4] Bubbles (Rounded Segmented Aesthetic)" -ForegroundColor Green
    Write-Host "  [5] Dracula (High Contrast Dark Aesthetic)" -ForegroundColor Green
    Write-Host "  [6] Blueish (Modern Cyan-Blue Powerline Segmented)" -ForegroundColor Green
    Write-Host "  [7] Tokyo Night (Pastel Neon Dark Aesthetic)" -ForegroundColor Green
    Write-Host "  [8] Catppuccin Mocha (Modern Pastel Theme)" -ForegroundColor Green
    Write-Host "  [9] Gruvbox (Warm Retro Palette)" -ForegroundColor Green
    Write-Host " [10] Nord (Cool Arctic Blue Palette)" -ForegroundColor Green
    Write-Host " [11] Rose Pine (Vintage Soft Palette)" -ForegroundColor Green
    Write-Host " [12] Back to Main Menu" -ForegroundColor Green
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Cyan

    $ThemeChoice = Read-Host "Select theme choice [1-12]"
    $ThemeFileName = ""
    $ThemeName = ""

    switch ($ThemeChoice) {
        "1"  { $ThemeFileName = "jebree.omp.json"; $ThemeName = "Jebree" }
        "2"  { $ThemeFileName = "paradox.omp.json"; $ThemeName = "Paradox" }
        "3"  { $ThemeFileName = "agnoster.omp.json"; $ThemeName = "Agnoster" }
        "4"  { $ThemeFileName = "bubbles.omp.json"; $ThemeName = "Bubbles" }
        "5"  { $ThemeFileName = "dracula.omp.json"; $ThemeName = "Dracula" }
        "6"  { $ThemeFileName = "blueish.omp.json"; $ThemeName = "Blueish" }
        "7"  { $ThemeFileName = "tokyonight.omp.json"; $ThemeName = "Tokyo Night" }
        "8"  { $ThemeFileName = "catppuccin.omp.json"; $ThemeName = "Catppuccin Mocha" }
        "9"  { $ThemeFileName = "gruvbox.omp.json"; $ThemeName = "Gruvbox" }
        "10" { $ThemeFileName = "nord.omp.json"; $ThemeName = "Nord" }
        "11" { $ThemeFileName = "rosepine.omp.json"; $ThemeName = "Rose Pine" }
        "12" { return }
        default { Write-Host "Invalid selection!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    }

    $TargetThemePath = Join-Path -Path $ThemesDir -ChildPath $ThemeFileName

    if (-not (Test-Path -Path $TargetThemePath)) {
        Write-Host "`n[!] Could not find $ThemeFileName inside $ThemesDir" -ForegroundColor Red
        Pause-Console
        return
    }

    Write-Host "`n--- [LIVE PREVIEW: $ThemeName] ---" -ForegroundColor Cyan
    try {
        oh-my-posh print primary --config $TargetThemePath
    } catch {
        Write-Host "  ($ThemeName Theme Preview Rendering)" -ForegroundColor Yellow
    }
    Write-Host "----------------------------------" -ForegroundColor Cyan
    Write-Host ""

    $Confirm = Read-Host "Apply '$ThemeName' theme to your profile? [Y/N]"
    if ($Confirm -ne "Y" -and $Confirm -ne "y") {
        Write-Host "[!] Theme selection cancelled." -ForegroundColor Yellow
        Pause-Console
        return
    }

    $ConfigLines = @(
        "Import-Module Terminal-Icons -ErrorAction SilentlyContinue",
        "Import-Module PSReadLine -ErrorAction SilentlyContinue",
        "Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue",
        "oh-my-posh init pwsh --config '$TargetThemePath' | Invoke-Expression"
    )

    Write-ManagedProfile -ConfigLines $ConfigLines
    Save-ShellWizardState -Engine "Oh My Posh" -Theme $ThemeName

    Write-Host ""
    Write-Host "[OK] Theme updated cleanly to '$ThemeName' in Managed Profile Block!" -ForegroundColor Green
    Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
    Pause-Console
}

# --- Module 4: Standalone Prompt Selector Engine ---
function Standalone-Prompt-Engine {
    Show-Header
    Write-Host "STANDALONE PROMPT SELECTOR ENGINE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Select an independent, standalone shell prompt engine:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Starship Prompt Engine (Rust-Powered 0ms Speed, Multi-Shell)" -ForegroundColor Green
    Write-Host "  [2] Posh-Git Engine (Lightweight Native PowerShell Git Prompt)" -ForegroundColor Green
    Write-Host "  [3] Pure Native PowerShell Prompt (0% Dependencies, Instant Speed)" -ForegroundColor Green
    Write-Host "  [4] Back to Main Menu" -ForegroundColor Green
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Cyan

    $PromptChoice = Read-Host "Select choice [1-4]"

    switch ($PromptChoice) {
        "1" {
            Write-Host "`n--> Ensuring Starship is installed via Winget..." -ForegroundColor Cyan
            if (-not $global:ShellWizardDryRun) {
                winget install Starship.Starship -s winget --accept-source-agreements --accept-package-agreements
            }

            $ConfigLines = @(
                "Import-Module Terminal-Icons -ErrorAction SilentlyContinue",
                "Import-Module PSReadLine -ErrorAction SilentlyContinue",
                "Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue",
                "Invoke-Expression (&starship init powershell)"
            )

            Write-ManagedProfile -ConfigLines $ConfigLines
            Save-ShellWizardState -Engine "Starship" -Theme "Rust Native"
            Write-Host "[OK] Starship Prompt Engine set as active prompt!" -ForegroundColor Green
            Pause-Console
        }
        "2" {
            Write-Host "`n--> Ensuring posh-git is installed..." -ForegroundColor Cyan
            if (-not $global:ShellWizardDryRun) {
                Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber -ErrorAction SilentlyContinue
            }

            $ConfigLines = @(
                "Import-Module Terminal-Icons -ErrorAction SilentlyContinue",
                "Import-Module PSReadLine -ErrorAction SilentlyContinue",
                "Import-Module posh-git -ErrorAction SilentlyContinue",
                "Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue"
            )

            Write-ManagedProfile -ConfigLines $ConfigLines
            Save-ShellWizardState -Engine "Posh-Git" -Theme "Git Light"
            Write-Host "[OK] Posh-Git Engine set as active prompt!" -ForegroundColor Green
            Pause-Console
        }
        "3" {
            $ConfigLines = @(
                "Import-Module Terminal-Icons -ErrorAction SilentlyContinue",
                "Import-Module PSReadLine -ErrorAction SilentlyContinue",
                "Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue",
                'function prompt { $User = [Environment]::UserName; $Path = (Get-Location).Path.Replace($HOME, "~"); $Time = Get-Date -Format "HH:mm:ss"; Write-Host "[$Time] " -NoNewline -ForegroundColor DarkGray; Write-Host "$User" -NoNewline -ForegroundColor Cyan; Write-Host " at " -NoNewline -ForegroundColor DarkGray; Write-Host "$Path" -NoNewline -ForegroundColor Yellow; if (Test-Path .git) { $Branch = (git branch --show-current 2>$null); if ($Branch) { Write-Host " ($Branch)" -NoNewline -ForegroundColor Green } }; return "`n> " }'
            )

            Write-ManagedProfile -ConfigLines $ConfigLines
            Save-ShellWizardState -Engine "Native Pure" -Theme "Fast Pure"
            Write-Host "[OK] Native Pure PowerShell Prompt applied!" -ForegroundColor Green
            Pause-Console
        }
        "4" { return }
        default { Write-Host "Invalid choice!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}

# --- Module 5: Idempotent CLI Tools Installer Suite ---
function Set-CliToolSuite {
    Show-Header
    Write-Host "MODERN CLI PRODUCTIVITY SUITE (FULL IDEMPOTENT SUITE)" -ForegroundColor Yellow
    Write-Host ""

    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    $Tools = @(
        @{ Name = "eza"; Id = "eza-community.eza"; Cmd = "eza" },
        @{ Name = "bat"; Id = "sharkdp.bat"; Cmd = "bat" },
        @{ Name = "fastfetch"; Id = "Fastfetch-cli.Fastfetch"; Cmd = "fastfetch" },
        @{ Name = "atuin"; Id = "AtuinSh.Atuin"; Cmd = "atuin" },
        @{ Name = "starship"; Id = "Starship.Starship"; Cmd = "starship" },
        @{ Name = "ripgrep"; Id = "BurntSushi.ripgrep.MSVC"; Cmd = "rg" },
        @{ Name = "zoxide"; Id = "ajeetdsouza.zoxide"; Cmd = "zoxide" },
        @{ Name = "fzf"; Id = "junegunn.fzf"; Cmd = "fzf" },
        @{ Name = "lazygit"; Id = "JesseDuffield.lazygit"; Cmd = "lazygit" },
        @{ Name = "delta"; Id = "dandavison.delta"; Cmd = "delta" },
        @{ Name = "fd"; Id = "sharkdp.fd"; Cmd = "fd" },
        @{ Name = "dust"; Id = "bootandy.dust"; Cmd = "dust" },
        @{ Name = "procs"; Id = "dalance.procs"; Cmd = "procs" },
        @{ Name = "btm"; Id = "Clement.bottom"; Cmd = "btm"; AltCmd = "bottom" },
        @{ Name = "gh"; Id = "GitHub.cli"; Cmd = "gh" }
    )

    Write-Host "Checking CLI tool installation status on system:" -ForegroundColor Cyan
    Write-Host ""

    $InstalledList = @()

    foreach ($Tool in $Tools) {
        $Installed = Get-Command -Name $Tool.Cmd -ErrorAction SilentlyContinue
        if (-not $Installed -and $Tool.AltCmd) {
            $Installed = Get-Command -Name $Tool.AltCmd -ErrorAction SilentlyContinue
        }

        if (-not $Installed) {
            $WinGetLinkPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\WinGet\Links\$($Tool.Cmd).exe"
            $AltWinGetLinkPath = if ($Tool.AltCmd) { Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\WinGet\Links\$($Tool.AltCmd).exe" } else { "" }
            
            if (Test-Path -Path $WinGetLinkPath) {
                $Installed = Get-Item -Path $WinGetLinkPath
            } elseif ($AltWinGetLinkPath -and (Test-Path -Path $AltWinGetLinkPath)) {
                $Installed = Get-Item -Path $AltWinGetLinkPath
            }
        }

        if ($Installed) {
            Write-Host "  [INSTALLED] $($Tool.Name) ($($Installed.Name))" -ForegroundColor Green
            $InstalledList += $Tool.Name
        } else {
            if ($global:ShellWizardDryRun) {
                Write-Host "  [DRY-RUN]   Would install $($Tool.Name) via Winget" -ForegroundColor Yellow
            } else {
                Write-Host "  [MISSING]   $($Tool.Name) -> Installing via Winget..." -ForegroundColor Yellow
                winget install $Tool.Id -s winget --accept-source-agreements --accept-package-agreements | Out-Null
                $InstalledList += $Tool.Name
            }
        }
    }

    Save-ShellWizardState -InstalledTools $InstalledList
    Write-Host ""
    Write-Host "[OK] All modern CLI tools verified and updated in state file!" -ForegroundColor Green
    Pause-Console
}

# --- Module 6: Font Studio Engine (With Crash Prevention Fix) ---
function Font-Studio-Engine {
    Show-Header
    Write-Host "FONT STUDIO AND AUTONOMOUS TERMINAL BEAUTIFIER" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Select a verified Nerd Font to apply autonomously to Windows Terminal:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] CascadiaCode Nerd Font (Clean, Modern, Recommended)" -ForegroundColor Green
    Write-Host "  [2] JetBrainsMono Nerd Font (Developer Favorite - Fixed String)" -ForegroundColor Green
    Write-Host "  [3] FiraCode Nerd Font (Famous Ligatures Standard)" -ForegroundColor Green
    Write-Host "  [4] Reset Terminal Font to Standard Default (Cascadia Mono)" -ForegroundColor Yellow
    Write-Host "  [5] Back to Main Menu" -ForegroundColor Green
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Cyan

    $FontChoice = Read-Host "Select choice [1-5]"

    switch ($FontChoice) {
        "1" {
            Write-Host "`n--> Registering CascadiaCode Nerd Font into Windows..." -ForegroundColor Cyan
            if (-not $global:ShellWizardDryRun) { oh-my-posh font install CascadiaCode }
            Set-WindowsTerminalFont -ExactFontName "CaskaydiaCove Nerd Font"
            Pause-Console
        }
        "2" {
            Write-Host "`n--> Registering JetBrainsMono Nerd Font into Windows..." -ForegroundColor Cyan
            if (-not $global:ShellWizardDryRun) { oh-my-posh font install JetBrainsMono }
            
            # Detect exact registered font name dynamically in System Registry/Fonts
            $InstalledFonts = (Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts").Property
            $JBFont = $InstalledFonts | Where-Object { $_ -like "*JetBrainsMono*" -or $_ -like "*JetBrains Mono*" } | Select-Object -First 1

            if ($JBFont -like "*NFM*") {
                $TargetFontName = "JetBrainsMono NFM"
            } elseif ($JBFont -like "*NF*") {
                $TargetFontName = "JetBrainsMono NF"
            } else {
                $TargetFontName = "JetBrainsMono Nerd Font"
            }

            Set-WindowsTerminalFont -ExactFontName $TargetFontName
            Pause-Console
        }
        "3" {
            Write-Host "`n--> Registering FiraCode Nerd Font into Windows..." -ForegroundColor Cyan
            if (-not $global:ShellWizardDryRun) { oh-my-posh font install FiraCode }
            Set-WindowsTerminalFont -ExactFontName "FiraCode Nerd Font"
            Pause-Console
        }
        "4" {
            Set-WindowsTerminalFont -ExactFontName "Cascadia Mono"
            Pause-Console
        }
        "5" { return }
        default { Write-Host "Invalid choice!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}

# --- Module 7: Automated 1-Click Global CLI Enabler ---
function Enable-GlobalCliAccess {
    Show-Header
    Write-Host "GLOBAL CLI COMMAND REGISTRATION ENGINE" -ForegroundColor Yellow
    Write-Host ""
    
    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($global:ShellWizardDryRun) {
        Write-Host "[DRY-RUN] Would register directory '$RepoRoot' into User PATH." -ForegroundColor Yellow
        Pause-Console
        return
    }

    if ($UserPath -like "*$RepoRoot*") {
        Write-Host "[OK] Shell-Wizard is ALREADY registered in your System PATH!" -ForegroundColor Green
        Write-Host "You can type 'shell-wizard' from ANY terminal window on your PC." -ForegroundColor Cyan
    } else {
        Write-Host "--> Registering '$RepoRoot' into User PATH Environment..." -ForegroundColor Cyan
        
        $NewPath = "$UserPath;$RepoRoot"
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
        $env:PATH = "$env:PATH;$RepoRoot"

        Save-ShellWizardState -GlobalStatus "Enabled"
        Write-Host ""
        Write-Host "[OK] GLOBAL CLI COMMAND REGISTRATION SUCCESSFUL!" -ForegroundColor Green
        Write-Host "You can now open CMD or PowerShell ANYWHERE and type: shell-wizard" -ForegroundColor Cyan
    }

    Pause-Console
}

# --- Main Application Loop ---
while ($true) {
    Show-Header
    Write-Host "Windows Capability Suite:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Safety & Backup Engine (Backups & Restore Engine)" -ForegroundColor Green
    Write-Host "  [2] 1-Click Complete Windows PowerShell Supercharge" -ForegroundColor Green
    Write-Host "  [3] Extended Oh-My-Posh Theme Selector (11 Local Themes + Live Preview)" -ForegroundColor Green
    Write-Host "  [4] Standalone Prompt Selector Engine (Starship, Posh-Git, Pure Native)" -ForegroundColor Green
    Write-Host "  [5] Install Modern CLI Tools Suite (15 Essential Tools)" -ForegroundColor Green
    Write-Host "  [6] Font Studio Engine (Cascadia, JetBrains, FiraCode Auto-Apply)" -ForegroundColor Green
    Write-Host "  [7] Enable Global CLI Access ('shell-wizard' command anywhere)" -ForegroundColor Yellow
    Write-Host "  [8] Reload Active PowerShell Profile" -ForegroundColor Yellow
    Write-Host "  [D] Toggle Dry-Run Mode [ON/OFF]" -ForegroundColor Cyan
    Write-Host "  [9] Exit" -ForegroundColor Green
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Cyan

    $Choice = Read-Host "Select choice [1-9 or D]"

    switch ($Choice) {
        "1" { Backup-And-Rollback-Engine }
        "2" { Install-WindowsBeautifier }
        "3" { Switch-PowerShellThemes }
        "4" { Standalone-Prompt-Engine }
        "5" { Set-CliToolSuite }
        "6" { Font-Studio-Engine }
        "7" { Enable-GlobalCliAccess }
        "8" {
            Write-Host "`n--> Reloading PowerShell Profile..." -ForegroundColor Cyan
            if (Test-Path -Path $PROFILE) {
                . $PROFILE
                Write-Host "[OK] PowerShell Profile reloaded successfully!" -ForegroundColor Green
            } else {
                Write-Host "[!] No PowerShell Profile found to reload." -ForegroundColor Red
            }
            Pause-Console
        }
        { $_ -in "D", "d" } {
            $global:ShellWizardDryRun = -not $global:ShellWizardDryRun
            $StatusText = if ($global:ShellWizardDryRun) { "ENABLED [ON - PREVIEW MODE]" } else { "DISABLED [OFF - LIVE WRITES]" }
            Write-Host "`n[DRY-RUN] Mode $StatusText" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
        "9" { exit 0 }
        default { Write-Host "Invalid selection!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}