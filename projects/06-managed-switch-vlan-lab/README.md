# Managed switch, VLAN, and OPNsense firewall lab

**Project:** 006

**Status:** Working end-to-end

## Goal

Add a managed switch to the home lab and use it to practise VLANs, tagged links, virtual-machine networking, routing, DHCP, and firewall rules with OPNsense.

The main outcome was moving the Debian web server into a dedicated infrastructure VLAN while keeping controlled access from my main PC on the home LAN.

## Lab equipment

- HP Z2 SFF running Proxmox VE on node `pve01`
- TP-Link Omada SG2008P managed switch
- Virgin Media Hub 3 for the existing home network and internet connection
- OPNsense VM named `fw01`
- Debian/Nginx VM named `web01`

## Final network layout

| Component | Role |
| --- | --- |
| Main PC | Admin workstation on the home LAN |
| OPNsense WAN | Home-LAN-facing firewall interface |
| OPNsense LAN | Gateway for the lab infrastructure VLAN |
| Infrastructure VLAN | Server/lab VM network |
| web01 | Debian/Nginx web server inside the infrastructure VLAN |
| Proxmox bridge | VLAN-aware bridge carrying tagged VM traffic |
| Managed switch | Carries home LAN and tagged lab VLAN traffic to the Z2 |

```text
Home router
    |
Home LAN
    |
Managed switch
    |
HP Z2 / Proxmox VLAN-aware bridge
    |
OPNsense routes between the home LAN and infrastructure VLAN
    |
Infrastructure VLAN
    |
web01 Debian/Nginx server
```

## What I configured

1. Installed the managed switch and connected it to the lab.
2. Created an infrastructure VLAN for server traffic.
3. Configured the Z2 switch port to carry tagged lab VLAN traffic.
4. Enabled VLAN awareness on the Proxmox bridge.
5. Built `fw01` as an OPNsense VM with one interface facing the home LAN and one interface for the lab VLAN.
6. Enabled DHCP on the OPNsense lab interface.
7. Moved `web01` into the lab VLAN and confirmed it received an address from OPNsense.
8. Added a persistent route on the Windows PC so traffic for the lab subnet is sent to OPNsense.
9. Created explicit firewall rules for OPNsense GUI access and web access to `web01`.
10. Used OPNsense firewall logs and Windows TCP tests to troubleshoot failed access.

## Chronological build notes

### 1. Creating the infrastructure VLAN

I created a dedicated infrastructure VLAN on the managed switch and enabled VLAN-aware bridging in Proxmox. The goal was to stop placing every VM directly on the home LAN and start separating lab server traffic into its own network.

The important distinction was that a VLAN is only Layer 2 separation. It does not automatically provide DHCP, a default gateway, DNS, internet access, or firewall policy. Those services came later from OPNsense.

### 2. Enabling routing and DHCP with OPNsense

I installed OPNsense as `fw01` and used it as the router/firewall between the home LAN and the infrastructure VLAN. The WAN side stayed on the home network, while the LAN side became the gateway for the lab VLAN.

I enabled DHCP on the OPNsense lab interface. After fixing VLAN tagging and DHCP, `web01` received a correct lab-VLAN address instead of an APIPA address.

### 3. Adding controlled access from the main PC

The main PC lives outside the lab VLAN, so Windows needed a persistent route for the lab subnet through OPNsense. Then OPNsense needed specific WAN rules, not broad access.

| Source | Destination | Port | Purpose |
| --- | --- | --- | --- |
| Main PC | This Firewall | HTTPS | OPNsense GUI access |
| Main PC | `web01` | HTTP 80 | Website access |

This allowed the main PC to administer OPNsense and load the web server without opening the lab VLAN generally to the home network.

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

## What I learned

- VLAN tagging, routing, DHCP, firewall policy, and client routes all have to line up for cross-subnet access to work.
- APIPA on a VM usually means DHCP is not reaching it or not configured correctly.
- A Windows route can be correct while the firewall still blocks or mishandles the traffic.
- OPNsense logs are more useful than guessing once IP addressing and routes look correct.
- Temporarily disabling the firewall can prove a firewall problem, but it is not a fix.
- OPNsense WAN rules can need **Disable reply-to** when the WAN interface is being used as an internal routed path from a private home LAN.
- Opening only HTTP to `web01` is better practice than creating broad allow rules or adding ping just for convenience.

## Current result

The main PC can access:

- The OPNsense web GUI through a specific firewall rule.
- The website on `web01` through a specific HTTP rule.

The route, VLAN, DHCP, firewall rule, and OPNsense `reply-to` behaviour are documented as part of the project.

## Next steps

- Reserve or statically assign important server IPs in the infrastructure VLAN.
- Keep general server services such as file server, monitoring, or Pi-hole/AdGuard in the infrastructure VLAN.
- Build a separate VLAN for the Windows/Active Directory lab.
- Add future camera/IoT and management VLANs only when the current VLAN design is stable.

## AI assistance

I used Codex to help plan the VLAN design, interpret OPNsense logs, explain routing and firewall behaviour, and draft this documentation. I made the switch, Proxmox, OPNsense, Windows, and VM configuration changes in my own lab and verified the final access myself.
