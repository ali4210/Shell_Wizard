# ==============================================================================
# TOOL NAME:    install.ps1 (Universal Windows Global CLI Installer)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Configures global 'shell-wizard' CLI + PowerShell profile hook
# ==============================================================================

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "     Shell-Wizard Ultimate - Windows Global CLI Installer          " -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""

# ==> 1. Check execution policy for the CURRENT USER (this is what governs
#        whether $PROFILE runs on every new PowerShell tab/session)
$UserPolicy = Get-ExecutionPolicy -Scope CurrentUser

if ($UserPolicy -eq 'Restricted' -or $UserPolicy -eq 'Undefined') {
    Write-Host "[!] Shell-Wizard needs to change your PowerShell script permission." -ForegroundColor Yellow
    Write-Host "    Current policy for your account: $UserPolicy"
    Write-Host "    This will be changed to: RemoteSigned (CurrentUser scope only)"
    Write-Host "      - Locally created scripts (like your theme profile) will run freely"
    Write-Host "      - Scripts downloaded from the internet still require a signature"
    Write-Host "      - This does NOT affect other user accounts or the whole machine"
    Write-Host ""
    $Consent = Read-Host "Proceed with this change? (y/n)"

    if ($Consent -eq 'y' -or $Consent -eq 'Y') {
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
            Write-Host "[OK] Execution policy updated for your account." -ForegroundColor Green
        } catch {
            Write-Host "[!] Could not change execution policy: $_" -ForegroundColor Red
            Write-Host "    Your machine may be managed by Group Policy (common on work/school PCs)." -ForegroundColor Yellow
            Write-Host "    Contact your IT admin, or run this manually with elevated rights:" -ForegroundColor Yellow
            Write-Host "      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
            Read-Host "`nPress Enter to exit"
            exit 1
        }
    } else {
        Write-Host "[i] Skipped. Your theme will apply now but WON'T persist on new tabs" -ForegroundColor Yellow
        Write-Host "    until you run this manually:"
        Write-Host "      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    }
} else {
    Write-Host "[OK] Execution policy already allows local scripts ($UserPolicy)" -ForegroundColor Green
}

# ==> 2. Locate autorun.bat (no admin needed — everything below is user-scope)
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
$AutoRunBat = Join-Path -Path $ScriptDir -ChildPath "autorun.bat"

if (-not (Test-Path -Path $AutoRunBat)) {
    Write-Host "[!] Error: Could not locate autorun.bat at $AutoRunBat" -ForegroundColor Red
    exit 1
}

# ==> 3. Global Setup for CMD & Windows Search (User AppData WindowsApps PATH)
$AppsFolder = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\WindowsApps"
$CmdGlobalFile = Join-Path -Path $AppsFolder -ChildPath "shell-wizard.bat"

$BatchWrapperContent = "@echo off`r`ncall `"$AutoRunBat`" %*"
Set-Content -Path $CmdGlobalFile -Value $BatchWrapperContent -Encoding ASCII -Force
Write-Host "[OK] Configured CMD global wrapper at: $CmdGlobalFile" -ForegroundColor Green

# ==> 4. Global Setup for PowerShell ($PROFILE Alias Function)
if (-not (Test-Path -Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force | Out-Null
    Write-Host "[+] Initialized PowerShell profile at: $PROFILE" -ForegroundColor Yellow
}

$ProfileContent = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue | Out-String
$FunctionSnippet = @"

# --- Shell Wizard Ultimate Global Command ---
function shell-wizard {
    & "$AutoRunBat" @args
}
"@

if ($ProfileContent -notmatch "function shell-wizard") {
    Add-Content -Path $PROFILE -Value $FunctionSnippet
    Write-Host "[OK] Registered 'shell-wizard' function in PowerShell profile!" -ForegroundColor Green
} else {
    Write-Host "[i] 'shell-wizard' function already present in PowerShell profile." -ForegroundColor Cyan
}

Write-Host "`n====================================================================" -ForegroundColor Cyan
Write-Host " INSTALLATION COMPLETE" -ForegroundColor Green
Write-Host " Open a NEW PowerShell window and type:  shell-wizard" -ForegroundColor Yellow
Write-Host "====================================================================" -ForegroundColor Cyan