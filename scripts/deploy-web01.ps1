[CmdletBinding()]
param(
    [ValidateSet("draft", "main")]
    [string]$Branch = "draft",
    [string]$LocalFolder = (Join-Path $PSScriptRoot "..\website"),
    [string]$Server = "webadmin@10.10.10.147",
    [string]$RemotePath = "/var/www/html/",
    [string]$SiteUrl = "http://10.10.10.147"
)

$ErrorActionPreference = "Stop"
$pages = @("index.html", "projects.html", "automation.html", "topology.html", "lab-notes.html", "about.html")
$stagingFolder = Join-Path ([IO.Path]::GetTempPath()) ("web01-deploy-" + [guid]::NewGuid())
$headers = @{ "User-Agent" = "web01-website-updater"; "Cache-Control" = "no-cache" }
$repository = "repo-sudo/infrastructure-portfolio"

try {
    if ($Server -match "YOUR_" -or $Server -notmatch "@") {
        throw "Configure Server with your SSH user@host."
    }
    if ($SiteUrl -match "YOUR_" -or $SiteUrl -notmatch "^https?://") {
        throw "Configure SiteUrl with the website URL."
    }
    Get-Command scp -ErrorAction Stop | Out-Null
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    New-Item -ItemType Directory -Path $stagingFolder | Out-Null

    Write-Host "Waiting for GitHub Actions AUT-002 to prepare the latest $Branch commit..."
    $syncDeadline = [DateTime]::UtcNow.AddMinutes(15)
    $revision = $null
    while ([DateTime]::UtcNow -lt $syncDeadline) {
        $nonce = [guid]::NewGuid().ToString("N")
        $commit = Invoke-RestMethod -Uri "https://api.github.com/repos/$repository/commits/${Branch}?nocache=$nonce" -Headers $headers -TimeoutSec 60
        $candidate = [string]$commit.sha
        if ($candidate -notmatch "^[0-9a-f]{40}$") {
            throw "GitHub did not return a valid commit SHA. Deployment stopped."
        }

        $status = Invoke-RestMethod -Uri "https://api.github.com/repos/$repository/commits/$candidate/status?nocache=$nonce" -Headers $headers -TimeoutSec 60
        $ready = @($status.statuses | Where-Object { $_.context -eq "homepage-sync" } | Sort-Object updated_at -Descending | Select-Object -First 1)
        if ($ready.Count -eq 1 -and $ready[0].state -eq "success") {
            $latest = Invoke-RestMethod -Uri "https://api.github.com/repos/$repository/commits/${Branch}?nocache=$([guid]::NewGuid().ToString('N'))" -Headers $headers -TimeoutSec 60
            if ($latest.sha -eq $candidate) {
                $revision = $candidate
                break
            }
            Write-Host "The branch advanced during homepage sync; waiting for its latest commit."
        } elseif ($ready.Count -eq 1 -and $ready[0].state -in @("failure", "error")) {
            throw "AUT-002 or its validation failed for commit $candidate. Check the GitHub Actions run."
        }

        Write-Host "AUT-002 is still running. Checking again in 10 seconds..."
        Start-Sleep -Seconds 10
    }
    if (-not $revision) {
        throw "Timed out waiting for AUT-002. Check GitHub Actions, then run the launcher again."
    }
    Write-Host "Deploying prepared $Branch commit $revision"
    $baseUrl = "https://raw.githubusercontent.com/$repository/$revision/website"
    $expectedHashes = @{}

    foreach ($page in $pages) {
        Write-Host "Downloading $page"
        $destination = Join-Path $stagingFolder $page
        Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/$page" -Headers $headers -TimeoutSec 60 -OutFile $destination
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
            throw "Download did not create $page."
        }
        if ((Get-Item -LiteralPath $destination).Length -eq 0) {
            throw "Downloaded $page is empty."
        }
        $content = Get-Content -LiteralPath $destination -Raw -Encoding UTF8
        if ($content -notmatch "(?i)<html\b" -or $content -notmatch "(?i)</html>") {
            throw "Downloaded $page is not a complete HTML document."
        }
        $expectedHashes[$page] = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    }

    if (-not (Test-Path -LiteralPath $LocalFolder -PathType Container)) {
        New-Item -ItemType Directory -Path $LocalFolder -Force | Out-Null
    }
    foreach ($page in $pages) {
        Copy-Item -LiteralPath (Join-Path $stagingFolder $page) -Destination (Join-Path $LocalFolder $page) -Force
    }

    $latest = Invoke-RestMethod -Uri "https://api.github.com/repos/$repository/commits/${Branch}?nocache=$([guid]::NewGuid().ToString('N'))" -Headers $headers -TimeoutSec 60
    if ($latest.sha -ne $revision) { throw "The branch changed during download. Run deployment again to review the latest complete version." }
    Write-Host "All six pages downloaded and validated. Uploading..."
    $uploadFiles = @($pages | ForEach-Object { Join-Path $stagingFolder $_ })
    & scp @uploadFiles "$($Server):$RemotePath"
    if ($LASTEXITCODE -ne 0) {
        throw "scp failed with exit code $LASTEXITCODE. Remote files may be partially updated."
    }

    Write-Host "Verifying all six pages served by the website..."
    foreach ($page in $pages) {
        $servedFile = Join-Path $stagingFolder ("served-" + $page)
        $nonce = [guid]::NewGuid().ToString("N")
        $url = $SiteUrl.TrimEnd("/") + "/" + $page + "?revision=" + $revision + "&nocache=" + $nonce
        Invoke-WebRequest -UseBasicParsing -Uri $url -Headers $headers -TimeoutSec 60 -OutFile $servedFile
        $servedHash = (Get-FileHash -LiteralPath $servedFile -Algorithm SHA256).Hash
        if ($servedHash -ne $expectedHashes[$page]) {
            throw "Verification failed for $($page): the website is serving different content. Upload completed, but deployment is not verified."
        }
        Write-Host "Verified $page"
    }

    Write-Host ""
    $receipt = @{ branch = $Branch; commit = $revision; site = $SiteUrl; verified_at = [DateTime]::UtcNow.ToString("o"); hashes = $expectedHashes }
    $receipt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $LocalFolder "web01-deployment.json") -Encoding UTF8
    Write-Host "Review receipt saved to web01-deployment.json"
    Write-Host "SUCCESS: all six served pages match $Branch commit $revision" -ForegroundColor Green
    Write-Host ("Home:       " + $SiteUrl.TrimEnd("/") + "/?revision=" + $revision)
    Write-Host ("Projects:   " + $SiteUrl.TrimEnd("/") + "/projects.html?revision=" + $revision)
    Write-Host ("Automation: " + $SiteUrl.TrimEnd("/") + "/automation.html?revision=" + $revision)
    Write-Host ("Topology:   " + $SiteUrl.TrimEnd("/") + "/topology.html?revision=" + $revision)
    Write-Host ("Notes:      " + $SiteUrl.TrimEnd("/") + "/lab-notes.html?revision=" + $revision)
    Write-Host ("About:      " + $SiteUrl.TrimEnd("/") + "/about.html?revision=" + $revision)
    exit 0
}
catch {
    Write-Host ("FAILED: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
finally {
    if (Test-Path -LiteralPath $stagingFolder) {
        Remove-Item -LiteralPath $stagingFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

