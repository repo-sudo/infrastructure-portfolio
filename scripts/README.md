# Website scripts

The complete [review and publication runbook](../docs/website-review-and-publication.md) covers GitHub setup, Windows setup, review, approval, and publication without ChatGPT.

| Script | Role |
| --- | --- |
| `deploy-web01.ps1` | AUT-001: deploy a prepared draft or main commit to web01 and verify all six served pages |
| `update-web01.bat` | Windows launcher; defaults to draft; accepts main as its first argument |
| `update-homepage-latest.ps1` | AUT-002: generate static homepage previews; `-Check` validates without writing |
| `update-homepage-latest.bat` | Optional local-only generator; not for the normal review cycle |
| `test-website-workflow.ps1` | Generator tests and simulated deployment failure checks; no real upload |

## Normal review workflow: one launcher

Save `deploy-web01.ps1` and `update-web01.bat` under `C:\Users\admin\Documents\Labs\Web\scripts\` on the admin PC. Double-click `update-web01.bat` for the normal review. It defaults to `draft`.

When the launcher runs, it downloads the six pages from the latest draft commit and runs AUT-002 on the downloaded copy before deploying it to internal `web.internal`. It verifies the six served-page hashes and saves `web01-deployment.json`. Use `update-web01.bat main` only to deploy an approved version. The local scripts do not update themselves.

## Homepage generation

The review launcher runs AUT-002 locally on the downloaded draft pages. GitHub Actions does not run AUT-002 on draft updates. After a merge to `main`, Actions runs AUT-002 to generate the public site. Local use remains available:

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
