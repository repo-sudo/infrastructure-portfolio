$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$temp = Join-Path ([IO.Path]::GetTempPath()) ('website-tests-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $temp | Out-Null
function Assert-True($Condition, $Message) { if (-not $Condition) { throw $Message } }
function Must-Fail([scriptblock]$Action) {
    $failed = $false
    try { & $Action } catch { $failed = $true }
    Assert-True $failed 'Expected a failure, but the operation succeeded.'
}
try {
    foreach ($file in Get-ChildItem $PSScriptRoot -Filter '*.ps1') {
        $tokens = $null; $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
        Assert-True ($errors.Count -eq 0) "PowerShell parse errors in $($file.Name): $errors"
    }
    Copy-Item (Join-Path $root 'website/*') $temp
    $sync = Join-Path $PSScriptRoot 'update-homepage-latest.ps1'
    & $sync -WebsiteFolder $temp
    & $sync -WebsiteFolder $temp -Check
    $indexPath = Join-Path $temp 'index.html'
    $firstHash = (Get-FileHash $indexPath).Hash
    & $sync -WebsiteFolder $temp
    Assert-True ((Get-FileHash $indexPath).Hash -eq $firstHash) 'Generator must be idempotent.'
    $notesPath = Join-Path $temp 'lab-notes.html'
    Add-Content $notesPath '<article class="post"><p>TEST newest note with $5 and accented text</p></article>' -Encoding UTF8
    Must-Fail { & $sync -WebsiteFolder $temp -Check }
    Assert-True ((Get-FileHash $indexPath).Hash -eq $firstHash) 'Check mode modified the homepage.'
    & $sync -WebsiteFolder $temp
    Assert-True ((Get-Content $indexPath -Raw) -match 'TEST newest note with \$5') 'New note or literal dollar sign was lost.'
    & $sync -WebsiteFolder $temp -Check
    $good = Get-Content $indexPath -Raw
    Set-Content $indexPath ($good.Replace('<!-- latest-notes:end -->', '')) -Encoding UTF8
    Must-Fail { & $sync -WebsiteFolder $temp }
    Set-Content $indexPath ($good + '<!-- latest-notes:start --><!-- latest-notes:end -->') -Encoding UTF8
    Must-Fail { & $sync -WebsiteFolder $temp }
    Set-Content $indexPath $good -Encoding UTF8
    Remove-Item (Join-Path $temp 'automation.html')
    Must-Fail { & $sync -WebsiteFolder $temp }

        # Run deployment with fake GitHub, HTTP and SCP endpoints.
    # The real AUT-002 generator runs on the downloaded staging files; no network request or real upload is made.
    $deploySourceFolder = Join-Path $temp 'deploy-source'
    New-Item -ItemType Directory -Path $deploySourceFolder | Out-Null
    Copy-Item (Join-Path $root 'website/*') $deploySourceFolder
    Add-Content (Join-Path $deploySourceFolder 'lab-notes.html') '<article class="post"><time>TEST</time><div><h3>AUT002 deployment integration test</h3><p>Generated during review deployment.</p></div></article>' -Encoding UTF8
    $deploySource = Get-Content (Join-Path $PSScriptRoot 'deploy-web01.ps1') -Raw
    $deploySource = $deploySource.Replace('exit 0', 'return').Replace('exit 1', 'throw')
    foreach ($case in @('ready', 'moved', 'bad-hash', 'scp-failure')) {
        & {
            param($CaseName, $Source, $OutputFolder, $SourceFolder, $GeneratorSource)
            $script:uploaded = $false
            $script:apiCalls = 0
            $script:uploadSnapshotFolder = $OutputFolder + '-remote'
            $ErrorActionPreference = 'Stop'
            function scp {
                $script:uploaded = $true
                $global:LASTEXITCODE = 0
                if ($CaseName -eq 'scp-failure') { $global:LASTEXITCODE = 1; return }
                New-Item -ItemType Directory -Path $script:uploadSnapshotFolder -Force | Out-Null
                foreach ($file in @($args | Where-Object { $_ -match '\.html$' })) {
                    Copy-Item -LiteralPath $file -Destination (Join-Path $script:uploadSnapshotFolder ([IO.Path]::GetFileName($file))) -Force
                }
            }
            function Invoke-RestMethod {
                param($Uri, $Headers, $TimeoutSec)
                $script:apiCalls++
                $sha = 'a' * 40
                if ($CaseName -eq 'moved' -and $script:apiCalls -gt 1) { $sha = 'b' * 40 }
                return @{ sha = $sha }
            }
            function Invoke-WebRequest {
                param([switch]$UseBasicParsing, $Uri, $Headers, $TimeoutSec, $OutFile)
                $uriObject = [Uri]$Uri
                $page = [IO.Path]::GetFileName($uriObject.AbsolutePath)
                if ($uriObject.Host -eq 'raw.githubusercontent.com') {
                    if ($page -eq 'update-homepage-latest.ps1') {
                        Copy-Item -LiteralPath $GeneratorSource -Destination $OutFile -Force
                    } else {
                        Copy-Item -LiteralPath (Join-Path $SourceFolder $page) -Destination $OutFile -Force
                    }
                    return
                }
                if ($CaseName -eq 'bad-hash') {
                    [IO.File]::WriteAllText($OutFile, '<html>stale</html>')
                    return
                }
                Copy-Item -LiteralPath (Join-Path $script:uploadSnapshotFolder $page) -Destination $OutFile -Force
            }
            $failed = $false
            try { & ([scriptblock]::Create($Source)) -Branch draft -LocalFolder $OutputFolder } catch { $failed = $true }
            Assert-True ($failed -eq ($CaseName -ne 'ready')) "Unexpected deployment outcome: $CaseName"
            if ($CaseName -eq 'moved') { Assert-True (-not $script:uploaded) 'Branch movement must stop before upload.' }
            if ($CaseName -eq 'ready') {
                $receipt = Join-Path $OutputFolder 'web01-deployment.json'
                Assert-True (Test-Path $receipt) 'Successful deployment must save a receipt.'
                $generatedIndex = Get-Content (Join-Path $script:uploadSnapshotFolder 'index.html') -Raw
                Assert-True ($generatedIndex -match 'AUT002 deployment integration test') 'AUT-002 must refresh the homepage before upload.'
            } else {
                Assert-True (-not (Test-Path (Join-Path $OutputFolder 'web01-deployment.json'))) "Failed deployment must not save a receipt: $CaseName"
            }
        } $case $deploySource (Join-Path $temp $case) $deploySourceFolder (Join-Path $PSScriptRoot 'update-homepage-latest.ps1')
    }
    Write-Host 'PASS: generation, stale detection, idempotence, markers, local AUT-002 deployment generation, branch movement, hashes, upload failures and receipts.'
} finally {
    Remove-Item $temp -Recurse -Force
}
exit 0

