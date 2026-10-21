# Infrastructure portfolio

Hands-on projects from a Proxmox lab: Linux, Windows Server, OPNsense, VLANs, DNS, monitoring, media streaming, backup/recovery, and deployment automation. Ansible configuration and deployment is now tested; cloud provisioning is on the roadmap.

## Network topology

The [current logical topology](docs/network-topology.md) shows the home LAN, VLANs 10/20/30/40, OPNsense boundaries, internal DNS, media streaming and restricted remote VPN access without publishing addressing or configuration details.

## Projects

1. [HP Z2 infrastructure host and Proxmox installation](projects/01-hp-z2-proxmox-host/README.md)  set up the dedicated host, installed Proxmox VE, and prepared the platform for virtual machines.
2. [Debian web server on Proxmox](projects/02-proxmox-debian-web-server/README.md)  created the Debian/Nginx VM used as this portfolio's internal deployment target, then added UFW and passwordless deployment from Windows.
3. [Debian web server backup and recovery test](projects/03-debian-web-server-backup-and-recovery/README.md)  configured Proxmox backup storage and verified the Debian web server recovery with an isolated restore.
4. [Windows Server domain controller migration](projects/04-windows-server-domain-controller-migration/README.md)  completed the move to DC02, resolved replication, DNS, and RPC issues, transferred all FSMO roles, joined a client, and demoted DC01.
5. [Windows domain backup and recovery](projects/05-windows-domain-backup-and-recovery/README.md)  configured daily Windows Server Backup for DC02 and verified the first full-server backup; the scheduled run and restore test remain to be verified.
6. [Managed switch, VLAN, and OPNsense firewall lab](projects/06-managed-switch-vlan-lab/README.md)  configured VLAN 10 for web services in Proxmox, added OPNsense routing, DHCP and firewall rules, and troubleshot controlled access from the home LAN. The project also records the physical switch setup and distinguishes its role from virtual VLAN separation.
7. [OPNsense config backup + recovery](projects/07-opnsense-configuration-backup/README.md)  stored the firewall configuration backup privately and completed an isolated restore test without publishing the XML export.
8. [Home Control Hub with Frigate](projects/08-home-control-frigate-server/README.md)  created `hch01` as a Debian-based Home Control Hub in VLAN 20, installed Docker and Frigate, connected `cam01` and `cam02`, and controlled local stream access through OPNsense.
9. [Home Control Hub backup and recovery test](projects/09-home-control-hub-backup-and-recovery/README.md)  created a Proxmox backup of `hch01`, restored it as a separate test VM, and verified the recovered Debian, Docker, and Frigate state without overwriting the live service.
10. [Remote VPN access to Home Control Hub with WireGuard](projects/10-remote-vpn-access-opnsense-wireguard/README.md)  configured OPNsense WireGuard so a phone on mobile data can securely reach Frigate on `hch01` in VLAN 20, using a Virgin Hub UDP 51820 port forward and a scoped VPN firewall rule instead of exposing the service publicly.
11. [Internal DNS server with BIND](projects/11-internal-dns-server-bind/README.md)  built `dns01` as a dedicated BIND DNS server in the infrastructure VLAN, created the `internal` zone, distributed it through DHCP options, and verified hostname access across the web, home-control, and main PC paths.
12. [DNS server backup and recovery test](projects/12-dns-server-backup-and-recovery/README.md)  backed up `dns01`, restored it as an isolated test VM, validated BIND and the `internal` zone, and established the standard scheduled backup pattern for important lab servers.
13. [Lab monitoring with Uptime Kuma](projects/13-lab-monitoring-uptime-kuma/README.md)  built `mon01` in the infrastructure VLAN, installed Docker and Uptime Kuma, added service, gateway, DNS, and internet checks, and published the dashboard through `mon.internal`.

14. [Public portfolio mirror](projects/14-public-portfolio-mirror/README.md)  serves the public site from GitHub Pages while keeping `web01` internal.

15. [Jellyfin media server](projects/15-jellyfin-media-server/README.md)  deployed media01 in VLAN 40, separated SSD configuration from HDD media storage, resolved DNS recursion permissions, and verified phone access and TV casting.

Project records describe the build, current state, and remaining checks.


## Automation

- [AUT-001: Website deployment automation](automation/01-website-deployment-automation/README.md)
- [AUT-002: Homepage latest content sync](automation/02-homepage-latest-content-sync/README.md)
- [AUT-003: Web server configuration and deployment with Ansible](automation/03-ansible-web-server-deployment/README.md) — deployed the portfolio to a fresh Debian VM, verified idempotence and restored a stopped nginx service.

## Current website workflow

1. We agree the website changes in ChatGPT.
2. I update the website files on GitHub `draft`.
3. Run `update-web01.bat`. The launcher runs AUT-002 on the downloaded draft pages, then AUT-001 deploys and verifies all six pages on internal `web.internal`.
4. Review the site. If it is ready, merge the same website changes into `main`.
5. GitHub Actions runs AUT-002 on `main` and publishes the generated site to GitHub Pages.

The [review and publication runbook](docs/website-review-and-publication.md) covers setup and recovery. Because the repository is public, draft source is publicly readable.

