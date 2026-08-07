# ==============================================================================
# TOOL NAME:    install.ps1 (Universal Windows Global CLI Installer)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Bypasses execution policy & configures global 'shell-wizard' CLI
# ==============================================================================

# ==> 1. Self-Bypass Execution Policy Block
$CurrentPolicy = Get-ExecutionPolicy -Scope Process
if ($CurrentPolicy -ne "Bypass" -and $CurrentPolicy -ne "Unrestricted") {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
}

# ==> 2. Automated Administrator Elevation Block
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "[+] Elevating process privileges to Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

$AutoRunBat = Join-Path -Path $ScriptDir -ChildPath "autorun.bat"

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "     🧙‍♂️ SHELL-WIZARD ULTIMATE - WINDOWS GLOBAL CLI INSTALLER        " -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -Path $AutoRunBat)) {
    Write-Host "[!] Error: Could not locate autorun.bat at $AutoRunBat" -ForegroundColor Red
    exit 1
}

# ==> 3. Global Setup for CMD & Windows Search (User AppData WindowsApps PATH)
$AppsFolder = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\WindowsApps"
$CmdGlobalFile = Join-Path -Path $AppsFolder -ChildPath "shell-wizard.bat"

$BatchWrapperContent = "@echo off`r`ncall `"$AutoRunBat`" %*"
Set-Content -Path $CmdGlobalFile -Value $BatchWrapperContent -Encoding ASCII -Force

Write-Host "[✔] Configured CMD global wrapper at: $CmdGlobalFile" -ForegroundColor Green

# ==> 4. Global Setup for PowerShell ($PROFILE Alias Function)
if (-not (Test-Path -Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force | Out-Null
    Write-Host "[+] Initialized PowerShell profile at: $PROFILE" -ForegroundColor Yellow
}

$ProfileContent = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue | Out-String
$FunctionSnippet = @"

# --- Shell Wizard Ultimate Global Command ---
function shell-wizard {
    Start-Process -FilePath "$AutoRunBat" -Verb RunAs
}
"@

if ($ProfileContent -notmatch "function shell-wizard") {
    Add-Content -Path $PROFILE -Value $FunctionSnippet
    Write-Host "[✔] Registered 'shell-wizard' function in PowerShell profile!" -ForegroundColor Green
} else {
    Write-Host "[i] 'shell-wizard' function already present in PowerShell profile." -ForegroundColor Cyan
}

Write-Host "`n====================================================================" -ForegroundColor Cyan
Write-Host " [✔] INSTALLATION COMPLETE! " -ForegroundColor Green
Write-Host " Open ANY PowerShell or Command Prompt window and type:" -ForegroundColor Yellow
Write-Host "     shell-wizard" -ForegroundColor BOLD
Write-Host "====================================================================" -ForegroundColor Cyan