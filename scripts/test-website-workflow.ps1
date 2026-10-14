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

    # Run deployment in a child scope with fake GitHub, HTTP and SCP endpoints.
    # No network request or real upload is made by these tests.
    $deploySource = Get-Content (Join-Path $PSScriptRoot 'deploy-web01.ps1') -Raw
    $deploySource = $deploySource.Replace('exit 0', 'return').Replace('exit 1', 'throw')
    foreach ($case in @('ready', 'pending', 'moved', 'bad-hash', 'scp-failure')) {
        & {
            param($CaseName, $Source, $OutputFolder)
            $script:uploaded = $false
            $script:apiCalls = 0
            function scp { $script:uploaded = $true; $global:LASTEXITCODE = 0; if ($CaseName -eq 'scp-failure') { $global:LASTEXITCODE = 1 } }
            function Invoke-RestMethod {
                param($Uri, $Headers, $TimeoutSec)
                if ($Uri -match '/status\?') {
                    $state = 'success'; if ($CaseName -eq 'pending') { $state = 'pending' }
                    return @{ statuses = @(@{ context = 'homepage-sync'; state = $state; updated_at = '2026-01-01' }) }
                }
                $script:apiCalls++
                $sha = 'a' * 40
                if ($CaseName -eq 'moved' -and $script:apiCalls -gt 1) { $sha = 'b' * 40 }
                return @{ sha = $sha }
            }
            function Invoke-WebRequest {
                param([switch]$UseBasicParsing, $Uri, $Headers, $TimeoutSec, $OutFile)
                $body = '<html><body>test</body></html>'
                if ($CaseName -eq 'bad-hash' -and $Uri -match '^http://') { $body = '<html>stale</html>' }
                [IO.File]::WriteAllText($OutFile, $body)
            }
            $failed = $false
            try { & ([scriptblock]::Create($Source)) -Branch draft -LocalFolder $OutputFolder } catch { $failed = $true }
            Assert-True ($failed -eq ($CaseName -ne 'ready')) "Unexpected deployment outcome: $CaseName"
            if ($CaseName -in @('pending', 'moved')) { Assert-True (-not $script:uploaded) "Unsafe upload: $CaseName" }
            $receipt = Join-Path $OutputFolder 'web01-deployment.json'
            Assert-True ((Test-Path $receipt) -eq ($CaseName -eq 'ready')) "Incorrect receipt: $CaseName"
        } $case $deploySource (Join-Path $temp $case)
    }
    Write-Host 'PASS: generation, stale detection, idempotence, markers, deployment readiness, branch movement, hashes, upload failures and receipts.'
} finally {
    Remove-Item $temp -Recurse -Force
}
exit 0

