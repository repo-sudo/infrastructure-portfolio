# Project 014: Public portfolio mirror

**Status:** Public site is live. The first publication through the repository's GitHub Actions workflow is not recorded.

**Portfolio website:** `web01` is the internal deployment and review target; GitHub Pages serves the public site.

## Purpose

Publish the static portfolio without exposing the home lab to public traffic.

| Component | Role |
| --- | --- |
| GitHub repository | Source of truth for website files |
| `web01` | Internal Nginx deployment and review target |
| GitHub Pages | Public HTTPS site |

The public and internal copies serve different purposes. `web01` remains useful for Linux, Nginx, SSH, VLAN, backup, and recovery practice. Public traffic goes to GitHub Pages and does not enter the home network.

## Current public site

[https://repo-sudo.github.io/infrastructure-portfolio/](https://repo-sudo.github.io/infrastructure-portfolio/)

The portfolio is recorded as live on GitHub Pages. Earlier publication used the `gh-pages` branch. The repository now contains an Actions workflow for approved `main` commits; confirm Pages is set to **GitHub Actions** and verify its first successful publication before considering that path complete.

## Website update and release

1. Agree the website changes in ChatGPT.
2. Commit the changes to `draft`.
3. Run `update-web01.bat`. GitHub Actions runs AUT-002 automatically after the draft update; the launcher waits for its prepared commit, then AUT-001 deploys it to internal `web01` for review.
4. After review, merge the same commit into `main`.
5. GitHub Actions checks the reviewed homepage and publishes those exact `website/` files to GitHub Pages. It does not regenerate approved content after review.

The [review and publication runbook](../../docs/website-review-and-publication.md) covers setup and failure handling. The repository is public, so draft content is publicly readable even before publication.

## Checks

For a release, confirm the six site pages and their links work, the public site uses HTTPS, and the internal `web01` copy remains private to the lab/VPN. Do not publish private addresses, credentials, or OPNsense XML exports.

## AI assistance

Codex helped compare public hosting options and document the workflow. The lab server remains internal; GitHub Pages serves the public copy.
