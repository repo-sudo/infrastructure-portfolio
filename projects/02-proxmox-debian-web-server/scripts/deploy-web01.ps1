$LocalFolder = "C:\Lab\Web"
$Server = "YOUR_SSH_USER@YOUR_SERVER_IP"
$RemotePath = "/var/www/html/"

Write-Host "Deploying website pages to web01..."

scp "$LocalFolder\*.html" "${Server}:$RemotePath"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment complete."
    Write-Host "Home:      http://YOUR_SERVER_IP/"
    Write-Host "Projects:  http://YOUR_SERVER_IP/projects.html"
    Write-Host "Notes:     http://YOUR_SERVER_IP/lab-notes.html"
    Write-Host "About:     http://YOUR_SERVER_IP/about.html"
} else {
    Write-Host "Deployment failed."
    exit 1
}