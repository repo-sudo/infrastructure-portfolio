# Managed switch, VLAN, and OPNsense firewall lab

**Project:** 006

**Status:** Working end-to-end

## Goal

Add a managed switch to the home lab and use it to practise VLANs, tagged links, virtual-machine networking, routing, DHCP, and firewall rules with OPNsense.

The first outcome was moving the Debian web server into a dedicated Web Services VLAN while keeping controlled access from my main PC on the home LAN. The lab then expanded with VLAN 20 for the Home Control Hub so camera and smart-home services can be separated from the web server.

## Lab equipment

- HP Z2 SFF running Proxmox VE on node `pve01`
- TP-Link Omada SG2008P managed switch
- Virgin Media Hub 3 for the existing home network and internet connection
- OPNsense VM named `fw01`
- Debian/Nginx VM named `web01`
- Debian/Frigate VM named `hch01`

## Final network layout

| Component | Role |
| --- | --- |
| Main PC | Admin workstation on the home LAN |
| OPNsense WAN | Home-LAN-facing firewall interface |
| OPNsense LAN | Gateway for the Web Services VLAN |
| VLAN 10 - Web Services | Dedicated network for the Debian/Nginx web server |
| VLAN 20 - Home Control Hub | Dedicated network for `hch01`, Frigate, and future home-control services |
| VLAN 30 - Infrastructure | Dedicated network for `dns01`, BIND, and future infrastructure services |
| web01 | Debian/Nginx web server inside VLAN 10 |
| hch01 | Debian/Frigate Home Control Hub inside VLAN 20 |
| Proxmox bridge | VLAN-aware bridge carrying tagged VM traffic |
| Managed switch | Carries home LAN and tagged lab VLAN traffic to the Z2 |

The lab has since expanded to VLAN 30, internal DNS and remote VPN access for trusted mobile devices. See the [current logical network topology](../../docs/network-topology.md) for the complete diagram.

## What I configured

1. Installed the managed switch and connected it to the lab.
2. Created VLAN 10 for web server traffic.
3. Configured the Z2 switch port to carry tagged lab VLAN traffic.
4. Enabled VLAN awareness on the Proxmox bridge.
5. Built `fw01` as an OPNsense VM with one interface facing the home LAN and one interface for the lab VLANs.
6. Enabled DHCP on the OPNsense lab interface.
7. Moved `web01` into VLAN 10 and confirmed it received an address from OPNsense.
8. Added a persistent route on the Windows PC so traffic for the VLAN 10 subnet is sent to OPNsense.
9. Created explicit firewall rules for OPNsense GUI access and web access to `web01`.
10. Used OPNsense firewall logs and Windows TCP tests to troubleshoot failed access.
11. Created VLAN 20 for the Home Control Hub and moved `hch01` into that segment.
12. Added a persistent Windows route for VLAN 20 through OPNsense.
13. Created aliases and a scoped firewall rule so `hch01` can reach `cam01` and `cam02` without opening broad access to the whole lab.

## Chronological build notes

### 1. Creating VLAN 10 for web services

I created VLAN 10 on the managed switch and enabled VLAN-aware bridging in Proxmox. The goal was to stop placing the Debian web server directly on the home LAN and start separating web service traffic into its own network.

The important distinction was that a VLAN is only Layer 2 separation. It does not automatically provide DHCP, a default gateway, DNS, internet access, or firewall policy. Those services came later from OPNsense.

### 2. Enabling routing and DHCP with OPNsense

I installed OPNsense as `fw01` and used it as the router/firewall between the home LAN and VLAN 10. The WAN side stayed on the home network, while the LAN side became the gateway for VLAN 10.

I enabled DHCP on the OPNsense lab interface. After fixing VLAN tagging and DHCP, `web01` received a correct lab-VLAN address instead of an APIPA address.

### 3. Adding controlled access from the main PC

The main PC lives outside VLAN 10, so Windows needed a persistent route for the VLAN 10 subnet through OPNsense. Then OPNsense needed specific WAN rules, not broad access.

| Source | Destination | Port | Purpose |
| --- | --- | --- | --- |
| Main PC | This Firewall | HTTPS | OPNsense GUI access |
| Main PC | `web01` | HTTP 80 | Website access |

This allowed the main PC to administer OPNsense and load the web server without opening VLAN 10 generally to the home network.

### 4. Troubleshooting the website rule

The website worked when the firewall was disabled, but timed out when the firewall was active. That proved the VM, IP addressing, nginx service, and Windows route were mostly correct.

The useful checks were:

```sh
ip route
```

on `web01`, which confirmed the default route pointed to OPNsense, and:

```powershell
Test-NetConnection WEB01-IP -Port 80
```

from Windows, which showed the TCP connection was failing even though the firewall rule looked correct.

OPNsense firewall logs showed the main PC's HTTP traffic reaching the firewall. The fix was enabling **Disable reply-to** on the WAN rule for the web server. After applying that rule and clearing states, the website loaded from the main PC.

### 5. Adding VLAN 20 for the Home Control Hub

After VLAN 10 was stable, I created VLAN 20 for the Home Control Hub. `hch01` moved into this VLAN so Frigate and future home-control services are not mixed with the web server.

The important lesson was that there are two different paths to think about:

| Path | Purpose |
| --- | --- |
| Main PC to `hch01` | Opens the Frigate web interface |
| `hch01` to `cam01` / `cam02` | Pulls the local camera streams |

The main PC needed its own persistent route for the VLAN 20 subnet through OPNsense. Separately, OPNsense needed a rule on the VLAN 20 interface so `hch01` could reach the camera aliases.

## What I learned

- VLAN tagging, routing, DHCP, firewall policy, and client routes all have to line up for cross-subnet access to work.
- APIPA on a VM usually means DHCP is not reaching it or not configured correctly.
- A Windows route can be correct while the firewall still blocks or mishandles the traffic.
- OPNsense logs are more useful than guessing once IP addressing and routes look correct.
- Temporarily disabling the firewall can prove a firewall problem, but it is not a fix.
- OPNsense WAN rules can need **Disable reply-to** when the WAN interface is being used as an internal routed path from a private home LAN.
- Opening only HTTP to `web01` is better practice than creating broad allow rules or adding ping just for convenience.
- Accessing an application UI is not the same as proving the application can reach its own backend devices or streams.
- Firewall rules must be applied after saving; an unapplied rule can look correct while still doing nothing.

## Current result

The main PC can access:

- The OPNsense web GUI through a specific firewall rule.
- The website on `web01` through a specific HTTP rule.
- The Frigate interface on `hch01` through the VLAN 20 route and firewall policy.

The route, VLAN, DHCP, firewall rule, and OPNsense `reply-to` behaviour are documented as part of the project. VLAN 10 is now focused on web services, while VLAN 20 is focused on the Home Control Hub.

## Next steps

- Keep VLAN 10 focused on web services, starting with `web01`.
- Keep VLAN 20 focused on the Home Control Hub, including `hch01` and camera-related services.
- Keep VLAN 30 focused on infrastructure services, starting with `dns01`; add monitoring as the next service.
- Keep firewall rules narrow between the home LAN, VPN clients, and each VLAN.

## AI assistance

I used Codex to help plan the VLAN design, interpret OPNsense logs, explain routing and firewall behaviour, and draft this documentation. I made the switch, Proxmox, OPNsense, Windows, and VM configuration changes in my own lab and verified the final access myself.
