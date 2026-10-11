# Project 014: Public portfolio mirror

## Goal

Publish the portfolio publicly without exposing the home lab web server directly to the internet.

The lab still runs the working copy on `web01`, but the public copy should be served from static hosting such as GitHub Pages or Cloudflare Pages.

This keeps the portfolio easy to share while preserving the security story of the lab.

## Why This Matters

Opening `web01` directly to the internet would turn the lab web server into a public-facing service. That would require public firewall exposure, HTTPS management, hardening, logging, monitoring, and a stronger DMZ-style design.

For a static portfolio, that is not necessary.

The better design is:

| Layer | Role |
| --- | --- |
| GitHub repository | Source of truth for the website files |
| `web01` | Internal lab deployment target for Linux, Nginx, SSH, VLAN, backup, and recovery practice |
| GitHub Pages or Cloudflare Pages | Public HTTPS mirror for recruiters and external viewers |

## Design Decision

The public website should be a static mirror of the `website/` folder.

The home lab server remains part of the project because it proves local infrastructure skills:

- Debian server administration
- Nginx hosting
- SSH deployment
- VLAN placement
- firewall rules
- backup and restore testing
- monitoring

The cloud-hosted copy proves a different skill: choosing the right platform for the right exposure level.

## Public / Private Split

| Question | Decision |
| --- | --- |
| Should `web01` be public? | No, keep it internal |
| Should the portfolio be public? | Yes |
| Should public traffic enter the home lab? | No |
| Should the public copy use HTTPS? | Yes |
| Should the GitHub repo remain the source of truth? | Yes |

## Target Flow

```text
Local edits or GitHub updates
        |
        v
GitHub repository
        |
        +--> web01 internal lab copy
        |
        +--> public static mirror
```

## What This Proves

- I can separate lab infrastructure from public-facing delivery.
- I understand that just because a service can be exposed does not mean it should be.
- I can keep `web01` as a meaningful lab server without making it the public attack surface.
- I can use static hosting for the public version while continuing to operate the internal version.
- I can explain the trade-off between self-hosting, public availability, HTTPS, and security.

## Implementation Options

### Option 1: GitHub Pages

Best first option because the repository already exists and the site is static HTML.

Expected setup:

- Publish the `website/` folder using GitHub Pages.
- Use the GitHub Pages URL as the public portfolio link.
- Keep `web01` as the internal deployment target.

### Option 2: Cloudflare Pages

Better later if a custom domain, DNS management, analytics, redirects, or extra edge controls become useful.

Expected setup:

- Connect Cloudflare Pages to the GitHub repository.
- Set the build output to the static `website/` folder.
- Use the Cloudflare Pages URL or a custom domain.

## Current Status

Decision made: the portfolio should have a public static mirror, while `web01` remains internal.

The next implementation step is to enable the chosen static hosting option and verify that all pages load correctly from the public URL.

## Verification Checklist

When the public mirror is enabled, verify:

- Homepage loads over HTTPS.
- Projects page loads.
- Lab notes page loads.
- Topology page loads.
- About page loads.
- Links between pages work.
- GitHub project links open correctly.
- `web01` remains reachable only through the lab network/VPN path.
- The public version does not expose private IPs, credentials, or sensitive config exports.

## Lessons Learned

- Public availability and self-hosting are separate design decisions.
- A static site does not need to be served from the home lab to prove infrastructure skill.
- Keeping a public mirror outside the lab reduces risk while keeping the internal deployment meaningful.
- The best architecture is not always the most technically impressive one; it is the one that fits the purpose safely.

## Next Steps

- Enable GitHub Pages or Cloudflare Pages.
- Add the public URL to the repository and website.
- Add a short note explaining: "the lab hosts the working copy; the cloud publishes the public copy."
- Consider adding this public mirror to monitoring as an external availability check.

## AI assistance

AI was used to compare the trade-offs between exposing `web01` and using static hosting, then structure the project documentation. The final architecture decision keeps the lab server internal and uses public static hosting for external access.
