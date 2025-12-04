@echo off
echo Checking for updates from repository...
echo.

REM Change to the project directory
cd /d "%~dp0"

REM Fetch the latest changes from remote
git fetch origin

REM Check if there are any changes between local and remote
git diff --quiet HEAD origin/main
if %errorlevel% neq 0 (
    echo Updates found! Pulling latest changes...
    git pull origin main
    @REM if %errorlevel% neq 0 (
    @REM     echo.
    @REM     echo ERROR: Failed to pull changes. Please resolve any conflicts manually.
    @REM     pause
    @REM     exit /b 1
    @REM )
    echo.
    echo Successfully updated to latest version.
) else (
    echo Already up to date.
)

echo.
echo Starting TestCaseGenie...
echo.

REM Launch TestCaseGenie in app mode (Chrome/Edge app window)
wscript "%~dp0start-app-mode.vbs"
