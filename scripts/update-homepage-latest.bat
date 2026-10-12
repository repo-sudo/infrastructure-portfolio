@echo off
setlocal

set "WEBSITE_FOLDER=C:\Users\admin\Documents\Labs\Web"
set "SCRIPT_URL=https://raw.githubusercontent.com/repo-sudo/infrastructure-portfolio/main/scripts/update-homepage-latest.ps1"
set "SCRIPT_FILE=%TEMP%\update-homepage-latest.ps1"

if not exist "%WEBSITE_FOLDER%" goto missing_folder

echo Downloading latest homepage sync script from GitHub...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri '%SCRIPT_URL%' -OutFile '%SCRIPT_FILE%'"
if errorlevel 1 goto failed

echo.
echo Refreshing homepage latest projects and lab notes...
echo Website folder: %WEBSITE_FOLDER%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_FILE%" -WebsiteFolder "%WEBSITE_FOLDER%"
if errorlevel 1 goto failed

echo.
echo Homepage latest sections updated successfully.
pause
exit /b 0

:missing_folder
echo.
echo Website folder not found:
echo %WEBSITE_FOLDER%
pause
exit /b 1

:failed
echo.
echo Homepage latest update failed. Check the error above.
pause
exit /b 1
