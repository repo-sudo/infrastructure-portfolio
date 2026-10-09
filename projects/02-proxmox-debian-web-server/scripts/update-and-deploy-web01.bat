@echo off
setlocal
cd /d "%~dp0"

echo Updating and deploying web01...
powershell -NoProfile -ExecutionPolicy Bypass -File ".\deploy-web01.ps1"

if errorlevel 1 (
    echo.
    echo Deployment failed. No deployment was attempted unless every page downloaded and validated.
    pause
    exit /b 1
)

echo.
echo Deployment completed successfully.
pause
exit /b 0
