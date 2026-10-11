@echo off
setlocal
cd /d "%~dp0"
if errorlevel 1 goto failed

echo Updating and verifying all five website pages...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy-web01.ps1"
if errorlevel 1 goto failed

echo.
echo Update verified successfully.
pause
exit /b 0

:failed
echo.
echo Update failed or could not be verified. Check the error above.
pause
exit /b 1
