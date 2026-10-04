# Home control camera server with Frigate

## Goal

Build a Linux-based home control server for local camera monitoring and future smart-home services. This project starts with Frigate as the first workload and uses Docker Compose so the service can be backed up, changed, and restarted cleanly.

## Environment

| Component | Value |
| --- | --- |
| Hypervisor | Proxmox VE |
| VM name | hcc01 |
| OS | Debian Linux |
| Runtime | Docker + Docker Compose |
| Application | Frigate |
| Camera | cam01 |
| Access | Local network only |

## What I Built

- Created a dedicated Debian VM named `hcc01` for home control and camera services.
- Installed Docker and Docker Compose to run Frigate as a containerised service.
- Created persistent Frigate folders under `/opt/frigate` for configuration and storage.
- Deployed Frigate using a `docker-compose.yml` file.
- Added `cam01` to Frigate.
- Reserved DHCP addresses for the Frigate server and camera so the service remains stable after reboots or lease changes.

## Why Docker Compose

Frigate can be started with a long one-line Docker command, but Compose is easier to maintain. The container settings live in one readable file, the config is stored outside the container, and the service can be restarted or rebuilt without losing its setup.

## Current Result

Frigate is running on `hcc01` and `cam01` is visible in the Frigate web interface.

## Next Steps

- Tune recording, event retention, and detection settings.
- Review storage usage before enabling long retention.
- Keep camera naming consistent, starting with `cam01`.
- Move cameras to a dedicated camera/IoT VLAN with no direct internet access.
- Allow only the Frigate server to reach the camera service.
