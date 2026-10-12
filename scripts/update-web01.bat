@echo off
setlocal

cd /d "C:\Users\admin\Documents\Labs\Web"
if errorlevel 1 goto failed

powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\deploy-web01.ps1" -LocalFolder "C:\Users\admin\Documents\Labs\Web" -Server "webadmin@10.10.10.147" -RemotePath "/var/www/html/" -SiteUrl "http://10.10.10.147"
if errorlevel 1 goto failed

echo.
echo All six website pages updated and verified.
pause
exit /b 0

:failed
echo.
echo Update failed or could not be verified. Check the error above.
pause
exit /b 1
