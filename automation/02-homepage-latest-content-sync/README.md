# AUT-002 - Homepage latest content sync

## Goal

Keep the homepage useful as plain static HTML by copying the latest three project cards and latest four lab-note entries into `website/index.html`.

This avoids relying on browser-side JavaScript for the most important preview sections. A normal browser still works, but link previews, crawlers, and applicant-tracking tools can also see the current projects and lab notes directly in the HTML.

## Setup

- Source project cards: `website/projects.html`
- Source lab notes: `website/lab-notes.html`
- Target homepage: `website/index.html`
- Script: `scripts/update-homepage-latest.ps1`
- Double-click launcher: `scripts/update-homepage-latest.bat`

Double-click `update-homepage-latest.bat` for the normal Windows workflow.

Run the PowerShell script from the repository root with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\update-homepage-latest.ps1"
```

Or run it from the website folder with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "..\scripts\update-homepage-latest.ps1" -WebsiteFolder "."
```

Projects and lab notes are kept oldest-to-newest in their source pages. The script takes the last three project cards and the last four lab-note entries, preserving that same ascending order.

## Decisions

- Keep the homepage static instead of loading latest content with JavaScript.
- Use marker comments in `index.html` so the generated sections are easy to find and replace.
- Treat `projects.html` and `lab-notes.html` as the source of truth instead of maintaining duplicate homepage cards manually.
- Keep this automation independent from the web01 deployment script so the content-refresh step can be tested on its own.

## Problems found

- The homepage previously showed placeholder text until JavaScript fetched the content.
- A crawler or link preview could see "Loading the latest projects..." instead of the real project cards.
- The lab notes source file had a stale comment saying newest entries were first, even though entries are kept oldest-to-newest.

## Verification

After running the script, verify that:

- `website/index.html` contains LAB-012, LAB-013, and LAB-014 in order.
- `website/index.html` contains ENTRY 041, ENTRY 042, ENTRY 043, and ENTRY 044 in order.
- The homepage no longer depends on the JavaScript fetch block for those sections.
- The output confirms: `Homepage latest sections updated.`

A separate launcher can run this script first and then run the web01 deployment automation.
