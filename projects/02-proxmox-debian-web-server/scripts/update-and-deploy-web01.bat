@echo off
cd /d C:\Lab\Web

echo Downloading latest website files from GitHub...

powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/repo-sudo/infrastructure-portfolio/main/website/index.html' -OutFile 'index.html'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/repo-sudo/infrastructure-portfolio/main/website/projects.html' -OutFile 'projects.html'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/repo-sudo/infrastructure-portfolio/main/website/lab-notes.html' -OutFile 'lab-notes.html'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/repo-sudo/infrastructure-portfolio/main/website/about.html' -OutFile 'about.html'"

echo Deploying to web01...

powershell -ExecutionPolicy Bypass -File .\deploy-web01.ps1

pause
