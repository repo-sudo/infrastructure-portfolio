# Website deployment scripts

This directory contains the maintained deployment implementation used by [LAB-002](../projects/02-proxmox-debian-web-server/README.md) and [AUT-001](../automation/01-website-deployment-automation/README.md).

- [deploy-web01.ps1](deploy-web01.ps1): downloads, validates, uploads, and verifies all six website pages.
- [update-web01.bat](update-web01.bat): Windows launcher for the lab's configured deployment folder.
- [update-homepage-latest.ps1](update-homepage-latest.ps1) and [its launcher](update-homepage-latest.bat): the separate [AUT-002 homepage content refresh](../automation/02-homepage-latest-content-sync/README.md).

## Windows setup

For the existing lab workflow, save the current repository versions of both deployment files under:

```text
C:\Users\admin\Documents\Labs\Web\scripts\deploy-web01.ps1
C:\Users\admin\Documents\Labs\Web\scripts\update-web01.bat
```

Double-click `update-web01.bat`. It uses `C:\Users\admin\Documents\Labs\Web` for the downloaded HTML files and invokes the PowerShell script in that folder's `scripts` subdirectory. The launcher does not update its own local script copy; refresh both files from this directory when the deployment tooling changes. Retire any old shortcut to `update-and-deploy-web01.bat`.

For a repository checkout, run from its root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\deploy-web01.ps1"
```

The PowerShell default local folder is the checkout's `website/` directory. Its current connection defaults target `webadmin@10.10.10.147`, `/var/www/html/`, and `http://10.10.10.147`. Override `-LocalFolder`, `-Server`, `-RemotePath`, and `-SiteUrl` for another environment.

## Update process

1. Resolve the current `main` commit through GitHub's API.
2. Download `index.html`, `projects.html`, `automation.html`, `topology.html`, `lab-notes.html`, and `about.html` from that exact commit.
3. Reject missing, empty, or incomplete HTML files before upload.
4. Save local copies and upload the six staged files through SCP.
5. Fetch each served page with unique query parameters.
6. Compare its SHA256 hash with the downloaded file.
7. Report success only when every served page matches, printing the deployed commit and page links.
8. Remove temporary files on success or failure.

This deploys the committed GitHub website. It replaces local HTML copies; it does not publish uncommitted local edits.

## Progression

The first goal was to serve one page from Debian/Nginx. PowerShell, a clickable launcher, and SSH keys made the growing multi-page site easier to update. As stale pages became harder to diagnose, the process gained commit-pinned downloads, validation, and served-file hash checks. The Automation page brought the total to six pages. The five-page copy previously stored under Project 002 has been retired so both project records point to this implementation.

## Requirements and limits

- Windows PowerShell 5.1 or later and OpenSSH SCP.
- Access to GitHub's API, raw file hosting, the SSH server, and the website.
- Existing SSH authentication, a verified host key, and write permission for the remote directory.
- Public repository access; unauthenticated GitHub API rate limits apply.

Download failures stop before upload. Upload or verification failures return exit code 1. An interrupted upload can leave a partially updated website; the script does not provide atomic deployment or rollback. Hash verification checks exact served content, not appearance or browser cache.
