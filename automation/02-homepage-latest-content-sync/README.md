# AUT-002: Homepage latest content sync

## Goal

Keep homepage previews current automatically: the latest three projects, two active automation entries, and four lab notes are stored directly in HTML.

## Sources and output

| Source | Selection |
| --- | --- |
| `website/projects.html` | Last three project cards |
| `website/automation.html` | Last two active automation entries |
| `website/lab-notes.html` | Last four notes |

The sources stay oldest-to-newest. The generator replaces the three marked sections of `website/index.html`, preserving that order and leaving other homepage content alone.

The homepage therefore contains three generated preview areas:

- **Latest projects:** the newest three project cards.
- **Latest automation:** the newest two entries marked `Active` on `automation.html` (currently AUT-001 and AUT-002).
- **Latest lab notes:** the newest four notes from `lab-notes.html`.

## Automatic workflow

[Website sync and publication](../../.github/workflows/website.yml) runs after pushes to draft or main. On draft it runs the [generator](../../scripts/update-homepage-latest.ps1), commits index.html only if changed, validates the result, and marks that exact commit with a successful `homepage-sync` status. AUT-001 will deploy only a prepared commit.

On main the generator runs in check-only mode. A stale homepage blocks publication rather than changing the approved website. Only main can enter the public Pages deployment job.

The [runbook](../../docs/website-review-and-publication.md) explains draft editing, review, approval and publication, including how to operate without ChatGPT.

## Progression

The homepage first loaded previews with browser JavaScript. Static generation made the content available directly in HTML. The first Windows launcher updated only local files, which did not fit the GitHub-first editing workflow. Generation now runs in GitHub on the draft branch before review, so it no longer depends on a separate local action or somebody remembering to refresh the homepage.

## Local use

The [PowerShell script](../../scripts/update-homepage-latest.ps1) remains independently runnable. Use `-WebsiteFolder` to select a folder and `-Check` to report stale previews without modifying files. The [local BAT](../../scripts/update-homepage-latest.bat) is optional and neither publishes nor deploys.

## Validation

The generator rejects missing files, missing or duplicate marker blocks, and too few entries. Repeated generation is idempotent. The [workflow tests](../../scripts/test-website-workflow.ps1) cover new notes, stale detection, literal dollar signs, malformed markers, unchanged output, deployment readiness, branch movement, served-file hash mismatches, upload failures, and deployment receipts. GitHub's readiness status is attached to the generated commit, not merely the original triggering commit.

The current verification examples are:

1. Add a new lab note and confirm `-Check` detects a stale homepage.
2. Run normal generation and confirm the new note appears in the marked homepage preview block.
3. Run generation again and confirm the output is unchanged (idempotence).
4. Confirm deployment refuses a pending homepage-sync status, a moved branch, a hash mismatch, or an upload failure.

