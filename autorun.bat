@echo off
setlocal EnableExtensions
TITLE Shell-Wizard Ultimate - Master OS Gateway

:: Force working directory lock
cd /d "%~dp0"

:: --- AUTO-ELEVATE (shows the UAC Yes/No prompt) ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [i] Requesting Administrator privileges...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs" 2>nul
    if errorlevel 1 (
        echo [!] Administrator access was denied. Shell-Wizard needs it to install tools and fonts.
        pause
    )
    exit /b
)
color 07

:menu
cls

:: Native Batch Banner Reading
if exist "%~dp0banner_wrapper.txt" (
type "%~dp0banner_wrapper.txt"
) else if exist "%~dp0modules\banner_wrapper.txt" (
type "%~dp0modules\banner_wrapper.txt"
) else if exist "%~dp0modules\banner.txt" (
type "%~dp0modules\banner.txt"
) else if exist "%~dp0banner.txt" (
type "%~dp0banner.txt"
)

echo.
echo ====================================================================
echo      SHELL-WIZARD ULTIMATE - OS TARGET SELECTION GATEWAY           
echo ====================================================================
echo.
echo Select target operating system environment to customize:
echo.
echo    [1] Linux Workstation (Instructions for WSL / Linux VM)
echo    [2] macOS Terminal (Instructions for macOS Terminal / Zsh)
echo    [3] Windows Host (Launch PowerShell Engine HERE)
echo    [0] Exit
echo.
echo ====================================================================
set /p "CHOICE=Select OS context [0-3]: "

if "%CHOICE%"=="1" goto opt1
if "%CHOICE%"=="2" goto opt2
if "%CHOICE%"=="3" goto opt3
if "%CHOICE%"=="0" goto opt4

echo.
echo [!] Invalid choice! Please enter 0, 1, 2 or 3.
timeout /t 2 >nul
goto menu

:opt1
cls
echo ====================================================================
echo  [!] LINUX WORKSTATION INSTRUCTIONS
echo ====================================================================
echo.
echo  To run Shell-Wizard on Linux (Kali, Ubuntu, RHEL, CentOS, Arch):
echo     1. Open your Linux terminal or WSL.
echo     2. Navigate to this directory.
echo     3. Execute: ./autorun.sh (or bash install.sh for global access)
echo.
echo ====================================================================
echo.
pause
goto menu

:opt2
cls
echo ====================================================================
echo  [!] MACOS TERMINAL INSTRUCTIONS
echo ====================================================================
echo.
echo  To run Shell-Wizard on macOS:
echo     1. Open Terminal on macOS.
echo     2. Navigate to this directory.
echo     3. Execute: ./autorun.sh
echo.
echo ====================================================================
echo.
pause
goto menu

:opt3
cls
echo ====================================================================
echo  [i] LAUNCHING WINDOWS POWERSHELL ORCHESTRATOR ENGINE...
echo ====================================================================
echo.

cd /d "%~dp0"

if not exist "%~dp0modules\shell-wizard.ps1" (
echo [!] CRITICAL ERROR: Could not find '%~dp0modules\shell-wizard.ps1'
pause
goto menu
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0modules\shell-wizard.ps1"

echo.
echo [!] PowerShell Engine Session Ended.
pause
goto menu

:opt4
exit