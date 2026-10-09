# Current lab network topology

This diagram shows the lab's logical structure without publishing addressing, VPN parameters, management endpoints or device-specific details.

```mermaid
flowchart TB
    internet["Internet"] --> router["ISP router"]
    phones["Two trusted phones"] -->|Remote VPN access| router
    router --> home["Home LAN"]
    home --> pc["Main PC"]
    home --> switch["Managed switch"]
    switch -->|Tagged VLAN trunk| pve["Proxmox host"]
    home --> fw["OPNsense firewall/router"]
    pve --- fw
    fw -->|Restricted inter-VLAN traffic| v10["VLAN 10 / Web Services"]
    fw -->|Restricted inter-VLAN traffic| v20["VLAN 20 / Home Control"]
    fw -->|Restricted inter-VLAN traffic| v30["VLAN 30 / Infrastructure"]
    v10 --> web["web01 / Nginx"]
    v20 --> hch["hch01 / Frigate"]
    v30 --> dns["dns01 / BIND"]
    dns -.->|Internal DNS| web
    dns -.->|Internal DNS| hch
    phones -.->|Permitted service access| hch
```

## Network roles

| Network or path | Role |
| --- | --- |
| Home LAN | Main workstation and upstream path for the lab firewall |
| VLAN 10 | Web services, currently `web01` and Nginx |
| VLAN 20 | Home-control services, currently `hch01` and Frigate |
| VLAN 30 | Infrastructure services, currently `dns01` and BIND |
| Remote VPN access | Restricted access from two trusted phones to permitted internal services |
| OPNsense | Inter-VLAN routing, DHCP, firewall policy and VPN termination |
| Managed switch and Proxmox networking | Tagged Layer 2 path between the physical host and virtual networks |

## Security boundary

OPNsense restricts traffic between the home LAN, the three VLANs and remote VPN clients. Internal DNS provides service names across the permitted paths. The repository intentionally omits addresses, public-facing details, VPN configuration, management endpoints, device identifiers and camera connection details.

The diagram is logical rather than a physical cabling plan. `fw01` runs as an OPNsense VM on the Proxmox host.
