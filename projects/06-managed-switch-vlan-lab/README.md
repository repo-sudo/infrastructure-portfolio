# Managed switch, VLAN, and OPNsense firewall lab

**Project:** 006  
**Status:** Live — VLAN routing, DHCP, and scoped access are working across the lab.  
**Portfolio website:** `web01` is the internal deployment target; GitHub Pages serves the public site.

## Purpose

Separate lab services into VLANs, then use OPNsense for routing, DHCP, and firewall rules. Proxmox carries VM traffic internally; the Omada switch handles VLAN-tagged traffic crossing physical ports.

## Network layout

| Network or service | Role |
| --- | --- |
| Home LAN | Admin workstation and upstream network |
| `fw01` / OPNsense | Routes between networks; provides DHCP and firewall policy |
| VLAN 10 | `web01`, internal Nginx site |
| VLAN 20 | `hch01`, Home Control Hub and Frigate |
| VLAN 30 | `dns01` / BIND and `mon01` / Uptime Kuma |
| Proxmox bridge | VLAN-aware connection for the VMs |
| Omada SG2008P | Carries tagged VLAN traffic over the physical uplink |

See the [current topology](../../docs/network-topology.md) for the full network and hosting diagrams.

## What I configured

- Added VLAN-aware networking in Proxmox and configured the switch uplink for tagged traffic.
- Built `fw01` with a home-LAN-facing interface and lab VLAN gateways.
- Enabled DHCP for the lab VLANs and moved `web01` and `hch01` into VLANs 10 and 20.
- Added persistent routes on the admin PC and narrow firewall rules for permitted management and service access.
- Allowed `hch01` to reach the camera aliases needed by Frigate.

## Troubleshooting and verification

The website timed out while OPNsense rules were enabled. Firewall logs showed the request reaching the WAN rule; enabling **Disable reply-to** on that rule and clearing states restored access.

I verified the OPNsense GUI and internal website from the admin PC, and the Frigate interface and camera streams through their separate paths. VLAN tags, routes, DHCP, and firewall rules each had to match; disabling the firewall was only a diagnostic test.

## Current roles

- VLAN 10: internal web service.
- VLAN 20: home-control service.
- VLAN 30: infrastructure services.
- OPNsense controls routed access; VMs in the same VLAN can communicate without leaving the Proxmox host.

## Follow-up

Keep firewall rules narrow as services change. Monitoring and remote VPN access are documented in LAB-013 and LAB-010.

## AI assistance

Codex helped explain VLAN, routing, and firewall behaviour and structure these notes. I configured the switch, Proxmox, OPNsense, Windows routes, and VMs, then checked the service paths in the lab.
