[CmdletBinding()]
param(
    [string]$LocalFolder = "C:\Lab\Web",
    [string]$Server = "YOUR_SSH_USER@YOUR_SERVER_IP",
    [string]$RemotePath = "/var/www/html/"
)

$ErrorActionPreference = "Stop"
$baseUrl = "https://raw.githubusercontent.com/repo-sudo/infrastructure-portfolio/main/website"
$pages = @("index.html", "projects.html", "lab-notes.html", "about.html")
$stagingFolder = Join-Path ([System.IO.Path]::GetTempPath()) ("web01-deploy-" + [guid]::NewGuid())

try {
    if ($Server -match "YOUR_" -or $Server -notmatch "@") {
        throw "Set the Server parameter to a valid SSH target such as user@server."
    }

    New-Item -ItemType Directory -Path $stagingFolder | Out-Null

    Write-Host "Downloading website pages into a temporary staging folder..."
    foreach ($page in $pages) {
        $destination = Join-Path $stagingFolder $page
        Invoke-WebRequest -Uri "$baseUrl/$page" -OutFile $destination

        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
            throw "Download did not create $page."
        }

        $download = Get-Item -LiteralPath $destination
        if ($download.Length -eq 0) {
            throw "Downloaded file $page is empty."
        }

        $content = Get-Content -LiteralPath $destination -Raw
        if ($content -notmatch "(?i)<html\b" -or $content -notmatch "(?i)</html>") {
            throw "Downloaded file $page does not appear to be a complete HTML document."
        }
    }

    if (-not (Test-Path -LiteralPath $LocalFolder -PathType Container)) {
        New-Item -ItemType Directory -Path $LocalFolder | Out-Null
    }

    foreach ($page in $pages) {
        Copy-Item -LiteralPath (Join-Path $stagingFolder $page) -Destination (Join-Path $LocalFolder $page) -Force
    }

    Write-Host "All pages downloaded and validated. Deploying to web01..."
    $uploadFiles = $pages | ForEach-Object { Join-Path $stagingFolder $_ }\n    & scp @uploadFiles "${Server}:${RemotePath}"
    if ($LASTEXITCODE -ne 0) {
        throw "scp failed with exit code $LASTEXITCODE."
    }

    Write-Host "Deployment complete."
    Write-Host "Verify the homepage and subpages in a browser."
    exit 0
}
catch {
    Write-Error "Deployment stopped: $($_.Exception.Message)"
    exit 1
}
finally {
    if (Test-Path -LiteralPath $stagingFolder) {
        Remove-Item -LiteralPath $stagingFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}
