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
| Access | Local network only |

## What I Built

- Created a dedicated Debian VM named `hch01` for home control and camera services.
- Installed Docker and Docker Compose to run Frigate as a containerised service.
- Created persistent Frigate folders under `/opt/frigate` for configuration and storage.
- Deployed Frigate using a `docker-compose.yml` file.
- Added `cam01` and `cam02` to Frigate.
- Reserved DHCP addresses for the Frigate server and both cameras so the service remains stable after reboots or lease changes.

## Why Docker Compose

Frigate can be started with a long one-line Docker command, but Compose is easier to maintain. The container settings live in one readable file, the config is stored outside the container, and the service can be restarted or rebuilt without losing its setup.

## Current Result

Frigate is running on `hch01`, with `cam01` and `cam02` visible in the Frigate web interface.

## Next Steps

- Tune recording, event retention, and detection settings.
- Review storage usage before enabling long retention.
- Keep camera naming consistent: `cam01`, `cam02`, and future cameras in the same format.
- Move cameras to a dedicated camera/IoT VLAN with no direct internet access.
- Allow only the Frigate server to reach the camera service.
