@echo off

REM Change to the project directory
cd /d "%~dp0"

REM Open loading page in Chrome/Edge app mode
start chrome.exe --app="file:///%~dp0bin\front\loading.html" --window-size=1400,900
if %errorlevel% neq 0 (
    start msedge.exe --app="file:///%~dp0bin\front\loading.html" --window-size=1400,900
)

REM Run git operations and start servers in hidden mode
wscript "%~dp0start-with-update.vbs"
