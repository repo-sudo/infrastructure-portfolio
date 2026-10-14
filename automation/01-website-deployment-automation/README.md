# AUT-001: Website Deployment Automation

## Goal

Make website deployments to `web01` repeatable and verifiable.

The script downloads the static website from a specific GitHub commit, stages the files locally, uploads them to the internal Nginx server, and verifies that the served pages match the files that were deployed.

## Why It Was Needed

Manual updates were becoming unreliable because it was easy to confuse three different states:

- the latest files in GitHub
- the files copied to the local Windows folder
- the files actually being served by `web01`

Browser caching also made successful deployments look like failed ones.

## Maintained scripts

Use the root [deployment script](../../scripts/deploy-web01.ps1), [Windows launcher](../../scripts/update-web01.bat), and [setup instructions](../../scripts/README.md). These are the same files used by [LAB-002](../../projects/02-proxmox-debian-web-server/README.md).

The workflow grew from manually copying one page to scripted multi-page uploads with SSH keys. As the goal expanded to verifying the deployed version, it gained commit-pinned downloads, HTML validation, and served-file hash checks. Adding Automation increased coverage from five pages to six. The older Project 002 script copies have been retired to keep one maintained implementation.

## Draft review and publication

The [review runbook](../../docs/website-review-and-publication.md) separates draft deployment from public release. AUT-001 deploys a prepared draft to web01; after review, the same draft is merged into main and GitHub Actions publishes it. AUT-002 refreshes the homepage before draft deployment. Save the current launcher and PowerShell script locally; they do not update themselves. For normal review, use only `update-web01.bat`.

## Current Setup

- Source repository: `repo-sudo/infrastructure-portfolio`
- Source branch: `draft` by default; `main` for the approved version
- Website source folder: `website/`
- Internal deployment and review target: `web01`
- Web root: `/var/www/html/`
- Deployment host: Windows admin workstation
- Transfer method: `scp`
- Verification method: SHA256 hash comparison

## Workflow

1. Resolve the selected branch commit SHA and require its successful `homepage-sync` status through the GitHub API.
2. Download each website page from that exact commit.
3. Validate that each downloaded file is non-empty HTML.
4. Copy the staged files into the local website folder.
5. Upload the staged files to `web01` with `scp`.
6. Fetch each served page from `web01`.
7. Compare served-page hashes against the staged files.
8. Report success only when every served page matches, and save the branch, commit and hashes in `web01-deployment.json` for review.

## Pages Covered

- `index.html`
- `projects.html`
- `automation.html`
- `topology.html`
- `lab-notes.html`
- `about.html`

## Problems Found

- Raw GitHub URLs without a fixed commit can pull files from a moving target.
- A deploy script can report success even when the browser still shows old content.
- A page can be uploaded but still not be the version served by the web server.
- Adding a new site page requires updating the deployment script page list.

## Verified Outcome

The deployment script now validates local downloads, uploads all tracked pages, then checks the served copy before reporting success.

## Next Improvements

- Keep the page list updated as the site grows.
- Consider moving the page list into one shared config file.
- Add clearer failure messages for network, GitHub API, SSH, and web-server errors.

