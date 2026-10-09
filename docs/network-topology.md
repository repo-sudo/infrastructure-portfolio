# Current lab network topology

The lab is easiest to understand in two views: the network boundaries and the virtual machines hosted by Proxmox. Addresses and connection details are intentionally omitted here.

## Network boundaries

```mermaid
flowchart TB
    internet["Internet"] --> router["ISP router"]
    mobile["Trusted mobile devices"] -->|Remote VPN| router
    router --> home["Home LAN"]
    home --> admin["Admin workstation"]
    home --> firewall["OPNsense firewall"]
    firewall --> web["VLAN 10 / Web Services<br/>web01"]
    firewall --> control["VLAN 20 / Home Control<br/>hch01"]
    firewall --> infra["VLAN 30 / Infrastructure<br/>dns01"]
```

Every path into a lab VLAN passes through OPNsense. OPNsense routes traffic, assigns VLAN client addresses, enforces firewall policy and terminates remote VPN access.

## Proxmox hosting

```mermaid
flowchart TB
    switch["Managed switch"] -->|Tagged VLAN trunk| host["HP Z2 / Proxmox host"]
    host --> firewall["OPNsense VM"]
    host --> web["web01 / Nginx"]
    host --> control["hch01 / Frigate"]
    host --> dns["dns01 / BIND"]
```

The managed switch and the VLAN-aware Proxmox bridge carry the tagged networks. The HP Z2 runs Proxmox; OPNsense and the service systems are virtual machines on that host.

## Important paths

| Source | Destination | Path |
| --- | --- | --- |
| Admin workstation | Lab administration and permitted services | Home LAN → OPNsense → target VLAN |
| Trusted mobile devices | Permitted internal services | ISP router → remote VPN terminated by OPNsense → target VLAN |
| `web01` and `hch01` | `dns01` | Source VLAN → OPNsense → VLAN 30 |
| VLAN clients | Internet | Source VLAN → OPNsense → home LAN → ISP router |

## Network roles

| Network | Current role |
| --- | --- |
| Home LAN | Admin workstation and upstream network for OPNsense |
| VLAN 10 | Web services: `web01` and Nginx |
| VLAN 20 | Home-control services: `hch01` and Frigate |
| VLAN 30 | Infrastructure services: `dns01` and BIND |

This topology document omits addresses, public-facing connection details, VPN configuration, management endpoints, device identifiers and camera connection details. Individual project records may retain private RFC1918 addresses when they explain a historical build or troubleshooting step.
