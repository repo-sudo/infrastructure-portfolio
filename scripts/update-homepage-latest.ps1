[CmdletBinding()]
param(
    [string]$WebsiteFolder,
    [switch]$Check
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($WebsiteFolder)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $WebsiteFolder = Join-Path $PSScriptRoot "..\website"
    }
    elseif (Test-Path -LiteralPath (Join-Path (Get-Location) "website") -PathType Container) {
        $WebsiteFolder = Join-Path (Get-Location) "website"
    }
    else {
        $WebsiteFolder = Get-Location
    }
}

$WebsiteFolder = [IO.Path]::GetFullPath($WebsiteFolder)
Write-Host "Using website folder: $WebsiteFolder"

$indexPath = Join-Path $WebsiteFolder "index.html"
$projectsPath = Join-Path $WebsiteFolder "projects.html"
$automationPath = Join-Path $WebsiteFolder "automation.html"
$notesPath = Join-Path $WebsiteFolder "lab-notes.html"

foreach ($path in @($indexPath, $projectsPath, $automationPath, $notesPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required file not found: $path"
    }
}

$index = (Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8).Replace("`r`n", "`n")
$originalIndex = $index
$projects = (Get-Content -LiteralPath $projectsPath -Raw -Encoding UTF8).Replace("`r`n", "`n")
$automation = (Get-Content -LiteralPath $automationPath -Raw -Encoding UTF8).Replace("`r`n", "`n")
$notes = (Get-Content -LiteralPath $notesPath -Raw -Encoding UTF8).Replace("`r`n", "`n")

function Get-ArticleBlocks {
    param(
        [Parameter(Mandatory=$true)][string]$Html,
        [Parameter(Mandatory=$true)][string]$ClassName
    )

    $pattern = '(?s)<article class="' + [regex]::Escape($ClassName) + '">.*?</article>'
    return [regex]::Matches($Html, $pattern) | ForEach-Object { $_.Value }
}

function Replace-MarkedBlock {
    param(
        [Parameter(Mandatory=$true)][string]$Html,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Content
    )

    $pattern = "(?s)<!-- " + [regex]::Escape($Name) + ":start -->.*?<!-- " + [regex]::Escape($Name) + ":end -->"
    if ([regex]::Matches($Html, $pattern).Count -ne 1) {
        throw "Expected exactly one marker block: $Name"
    }

    $replacement = "<!-- $($Name):start -->`n        $Content`n        <!-- $($Name):end -->"
    return [regex]::Replace($Html, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement }, 1)
}

$latestProjects = @(Get-ArticleBlocks -Html $projects -ClassName "card" | Select-Object -Last 3)
$latestAutomation = @(Get-ArticleBlocks -Html $automation -ClassName "automation-project" | Where-Object { $_ -match 'class="tag active"' } | Select-Object -Last 2)
$latestNotes = @(Get-ArticleBlocks -Html $notes -ClassName "post" | Select-Object -Last 4)

if ($latestProjects.Count -ne 3) {
    throw "Expected 3 latest project cards, found $($latestProjects.Count)."
}
if ($latestAutomation.Count -ne 2) {
    throw "Expected 2 latest active automation entries, found $($latestAutomation.Count)."
}
if ($latestNotes.Count -ne 4) {
    throw "Expected 4 latest lab notes, found $($latestNotes.Count)."
}

$projectContent = $latestProjects -join "`n        "
$automationContent = $latestAutomation -join "`n        "
$notesContent = $latestNotes -join "`n        "

$index = Replace-MarkedBlock -Html $index -Name "latest-projects" -Content $projectContent
$index = Replace-MarkedBlock -Html $index -Name "latest-automation" -Content $automationContent
$index = Replace-MarkedBlock -Html $index -Name "latest-notes" -Content $notesContent

if ($Check) {
    if ($index -cne $originalIndex) { throw "Homepage previews are stale. Run homepage sync and commit index.html before deployment or publication." }
    Write-Host "Homepage previews are current."
    return
}
if ($index -ceq $originalIndex) {
    Write-Host "Homepage previews already current; no file changed."
    return
}
[IO.File]::WriteAllText($indexPath, $index, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Homepage latest sections updated."
Write-Host "Projects: latest 3 from projects.html"
Write-Host "Automation: latest 2 active entries from automation.html"
Write-Host "Lab notes: latest 4 from lab-notes.html"

