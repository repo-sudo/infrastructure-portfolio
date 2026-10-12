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

## Current Setup

- Source repository: `repo-sudo/infrastructure-portfolio`
- Source branch: `main`
- Website source folder: `website/`
- Internal target: `web01`
- Web root: `/var/www/html/`
- Deployment host: Windows admin workstation
- Transfer method: `scp`
- Verification method: SHA256 hash comparison

## Workflow

1. Resolve the latest `main` commit SHA through the GitHub API.
2. Download each website page from that exact commit.
3. Validate that each downloaded file is non-empty HTML.
4. Copy the staged files into the local website folder.
5. Upload the staged files to `web01` with `scp`.
6. Fetch each served page from `web01`.
7. Compare served-page hashes against the staged files.
8. Report success only when every served page matches.

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
