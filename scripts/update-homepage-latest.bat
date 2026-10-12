@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "WEBSITE_FOLDER=%SCRIPT_DIR%..\website"

if exist "%SCRIPT_DIR%index.html" set "WEBSITE_FOLDER=%SCRIPT_DIR%"
if exist "%SCRIPT_DIR%website\index.html" set "WEBSITE_FOLDER=%SCRIPT_DIR%website"

set "PS_SCRIPT=%SCRIPT_DIR%update-homepage-latest.ps1"
if not exist "%PS_SCRIPT%" set "PS_SCRIPT=%SCRIPT_DIR%scripts\update-homepage-latest.ps1"

if not exist "%PS_SCRIPT%" goto missing_script

echo Refreshing homepage latest projects and lab notes...
echo Website folder: %WEBSITE_FOLDER%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -WebsiteFolder "%WEBSITE_FOLDER%"
if errorlevel 1 goto failed

echo.
echo Homepage latest sections updated successfully.
pause
exit /b 0

:missing_script
echo.
echo Could not find update-homepage-latest.ps1 next to this launcher.
echo Put this BAT in the same folder as update-homepage-latest.ps1, or in the repository root.
pause
exit /b 1

:failed
echo.
echo Homepage latest update failed. Check the error above.
pause
exit /b 1
