# Website scripts

The complete [review and publication runbook](../docs/website-review-and-publication.md) covers GitHub setup, Windows setup, review, approval, and publication without ChatGPT.

| Script | Role |
| --- | --- |
| `deploy-web01.ps1` | AUT-001: deploy a prepared draft or main commit to web01 and verify all six served pages |
| `update-web01.bat` | Windows launcher; defaults to draft; accepts main as its first argument |
| `update-homepage-latest.ps1` | AUT-002: generate static homepage previews; `-Check` validates without writing |
| `update-homepage-latest.bat` | Optional local generator launcher; not part of normal draft deployment |
| `test-website-workflow.ps1` | Generator tests and simulated deployment failure checks; no real upload |

## Normal Windows workflow

Save the deployment PowerShell script and BAT under `C:\Users\admin\Documents\Labs\Web\scripts\`. Double-click the BAT after the draft workflow succeeds. It downloads the website to `C:\Users\admin\Documents\Labs\Web`, deploys to web01, and saves `web01-deployment.json` after verification.

The launcher uses the lab's existing server, folder and URL settings. Update both script files when tooling changes; old Windows copies are not upgraded automatically. Running `update-web01.bat main` deploys approved main instead.

From a repository checkout:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\deploy-web01.ps1 -Branch draft
```

The default download folder is the checkout's `website` folder. These downloads overwrite local HTML; use a separate deployment copy if you have uncommitted edits. The parameters `-LocalFolder`, `-Server`, `-RemotePath`, and `-SiteUrl` can override the lab defaults.

## Homepage generation

GitHub Actions normally runs AUT-002 on draft and commits changed output. Local use remains available:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-homepage-latest.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-homepage-latest.ps1 -Check
```

Local generation does not push or deploy. Commit and push any intended local changes to draft, then follow the normal review process.

## Requirements and limits

Windows PowerShell 5.1+, OpenSSH SCP, GitHub/HTTP access, and working SSH authentication are required for internal deployment. The public GitHub API is rate-limited. The deployer requires a successful `homepage-sync` status on the exact commit and refuses a branch that moves during download.

All six pages are downloaded from one commit and validated before upload. Served files are checked with SHA256. A failed upload may be partial; deployment is not atomic and does not provide automatic rollback. A receipt proves file verification, not visual review or human approval.

## Progression

Manual file copying became scripted multi-page uploads, then gained SSH keys, commit-pinned downloads and served-file hashes. Automation increased the page count from five to six. The draft workflow now separates private review from publication while preserving the same verified file-transfer process.
