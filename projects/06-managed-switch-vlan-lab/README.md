# Managed switch and VLAN lab

**Project:** 006

**Status:** In progress

## Goal

Add a managed switch to the home lab and use it to practise VLANs, tagged links, and virtual-machine networking on Proxmox.

## Lab equipment

- HP Z2 SFF running Proxmox VE on node `pve01`
- TP-Link Omada SG2008P managed switch
- Virgin Media Hub 3 for the existing home network and internet connection

## What I have configured

1. Installed the managed switch, connected it to the lab, and set up an Omada account.
2. Created VLAN 10 named `LAB` on the switch.
3. Connected switch port 6 to the Z2 and configured port 6 as tagged for VLAN 10. The existing untagged home-network connection remains available for Proxmox management.
4. Enabled VLAN awareness on the Proxmox `vmbr0` bridge, which is attached to the host's physical network interface.

The Proxmox management address and gateway stayed unchanged after applying the bridge setting.

## Current topology

```text
Virgin Media Hub 3 ── Omada SG2008P ── port 6 ── HP Z2 / Proxmox
                                         │
                              VLAN 1 untagged + VLAN 10 tagged
```

- **VLAN 1:** Existing home LAN, used for Proxmox management.
- **VLAN 10 (`LAB`):** Separate Layer 2 segment reserved for lab guest traffic.
- **Proxmox bridge:** `vmbr0`, connected to the physical NIC, with VLAN awareness enabled.

## Current limits

VLAN 10 exists on the switch and can be carried to Proxmox, but I have not yet connected a guest VM to it or tested guest traffic. A VLAN does not provide DHCP, a default gateway, internet access, or firewall rules by itself. OPNsense is planned as a virtual router/firewall for the lab VLAN; it has not been installed or configured yet.

## Next steps

1. Create an OPNsense VM with a home-network-facing WAN interface and a VLAN 10 lab interface.
2. Configure DHCP and firewall rules for the lab network.
3. Connect a test VM to VLAN 10 and verify its address, gateway, DNS, internet access, and isolation from the home LAN.
4. Record the results and any troubleshooting.

## What this practises

- Creating and naming a VLAN on a managed switch.
- Carrying tagged traffic over a physical link to a hypervisor.
- Enabling VLAN-aware bridging in Proxmox while keeping host management on the existing LAN.
- Adding routing, DHCP, and firewall policy to a segmented lab network.

## AI assistance

I used Codex to explain VLANs and tagged ports and to help document the work. I made the switch and Proxmox configuration changes in my own lab.