@echo off
setlocal EnableExtensions
TITLE Shell-Wizard Ultimate - Master OS Gateway

:: Get script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: Check for Administrator Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [i] Elevating Shell-Wizard to PowerShell Administrator...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -NoExit -Command \"Set-Location ''%~dp0''; & ''%~dp0autorun.bat\"\"' -Verb RunAs"
    exit /b
)

:: Forward to autorun.bat if already elevated
call "%SCRIPT_DIR%autorun.bat" %*