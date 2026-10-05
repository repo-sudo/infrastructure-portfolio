# Home Control Hub with Frigate

## Goal

Build a Linux-based home control server for local camera monitoring and future smart-home services. This project starts with Frigate as the first workload and uses Docker Compose so the service can be backed up, changed, and restarted cleanly.

## Environment

| Component | Value |
| --- | --- |
| Hypervisor | Proxmox VE |
| VM name | hch01 |
| OS | Debian Linux |
| Runtime | Docker + Docker Compose |
| Application | Frigate |
| Cameras | cam01, cam02 |
| Network segment | VLAN 20 |
| Access | Local network only, controlled by OPNsense rules |

## What I Built

- Created a dedicated Debian VM named `hch01` for home control and camera services.
- Installed Docker and Docker Compose to run Frigate as a containerised service.
- Created persistent Frigate folders under `/opt/frigate` for configuration and storage.
- Deployed Frigate using a `docker-compose.yml` file.
- Added `cam01` and `cam02` to Frigate.
- Reserved DHCP addresses for the Frigate server and both cameras so the service remains stable after reboots or lease changes.
- Created VLAN 20 for the Home Control Hub network.
- Moved `hch01` into VLAN 20 and confirmed DHCP, routing, and web access to the Frigate interface.
- Added a persistent route on the main PC so the VLAN 20 subnet is reached through OPNsense.
- Created firewall aliases for the camera endpoints and used a scoped rule allowing `hch01` to reach the local camera streams.
- Troubleshot the difference between reaching the Frigate web UI and allowing Frigate itself to reach the camera streams.

## Why Docker Compose

Frigate can be started with a long one-line Docker command, but Compose is easier to maintain. The container settings live in one readable file, the config is stored outside the container, and the service can be restarted or rebuilt without losing its setup.

## Current Result

Frigate is running on `hch01` inside VLAN 20. The Frigate web interface is reachable from the main PC through OPNsense, and `hch01` has a controlled firewall path to `cam01` and `cam02` for local stream access.

## Network and Access Notes

The main PC, the Frigate web interface, and the cameras each use different traffic paths:

| Flow | Purpose | Result |
| --- | --- | --- |
| Main PC to `hch01` | Open the Frigate web UI | Uses a persistent route through OPNsense |
| `hch01` to `cam01` / `cam02` | Pull local camera streams | Allowed with an OPNsense rule scoped to the camera aliases |
| Cameras to internet | Cloud/vendor access | Not required for the local Frigate stream path |

This project keeps the camera platform local-first. The cameras are not exposed directly to the internet, and future remote access should use VPN access into the lab rather than public camera access.

## Troubleshooting Notes

- The Frigate UI loading did not prove the camera streams were reachable; the UI path is `main PC -> hch01`, while the stream path is `hch01 -> cameras`.
- A missing Windows route blocked the main PC from reaching VLAN 20 until a persistent route was added through OPNsense.
- A missing OPNsense apply step caused a working firewall rule to remain inactive until the pending change was applied.
- Firewall aliases made the final rules easier to understand than raw IP-only rules.

## Next Steps

- Tune recording, event retention, and detection settings.
- Review storage usage before enabling long retention.
- Keep camera naming consistent: `cam01`, `cam02`, and future cameras in the same format.
- Consider moving cameras to a dedicated camera/IoT VLAN with no direct internet access.
- Tighten the temporary broad camera rule to only the required stream ports after testing is complete.
- Build a separate VPN project so remote access reaches Frigate through OPNsense instead of exposing cameras directly.
