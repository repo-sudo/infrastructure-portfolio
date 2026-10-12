[CmdletBinding()]
param(
    [string]$WebsiteFolder = (Join-Path $PSScriptRoot "..\website")
)

$ErrorActionPreference = "Stop"

$indexPath = Join-Path $WebsiteFolder "index.html"
$projectsPath = Join-Path $WebsiteFolder "projects.html"
$notesPath = Join-Path $WebsiteFolder "lab-notes.html"

foreach ($path in @($indexPath, $projectsPath, $notesPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required file not found: $path"
    }
}

$index = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
$projects = Get-Content -LiteralPath $projectsPath -Raw -Encoding UTF8
$notes = Get-Content -LiteralPath $notesPath -Raw -Encoding UTF8

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
    if ($Html -notmatch $pattern) {
        throw "Marker block not found: $Name"
    }

    $replacement = "<!-- $($Name):start -->`r`n        $Content`r`n        <!-- $($Name):end -->"
    return [regex]::Replace($Html, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement }, 1)
}

$latestProjects = @(Get-ArticleBlocks -Html $projects -ClassName "card" | Select-Object -Last 3)
$latestNotes = @(Get-ArticleBlocks -Html $notes -ClassName "post" | Select-Object -Last 4)

if ($latestProjects.Count -ne 3) {
    throw "Expected 3 latest project cards, found $($latestProjects.Count)."
}
if ($latestNotes.Count -ne 4) {
    throw "Expected 4 latest lab notes, found $($latestNotes.Count)."
}

$projectContent = $latestProjects -join "`r`n        "
$notesContent = $latestNotes -join "`r`n        "

$index = Replace-MarkedBlock -Html $index -Name "latest-projects" -Content $projectContent
$index = Replace-MarkedBlock -Html $index -Name "latest-notes" -Content $notesContent

Set-Content -LiteralPath $indexPath -Value $index -Encoding UTF8

Write-Host "Homepage latest sections updated."
Write-Host "Projects: latest 3 from projects.html"
Write-Host "Lab notes: latest 4 from lab-notes.html"
