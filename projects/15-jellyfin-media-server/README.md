# LAB-015: Jellyfin media server

Status: deployed; phone access and TV casting tested. Built 20–21 October 2026.

## Purpose and result

I built `media01` as a Debian 13 media server in VLAN 40 on the HP Z2 / Proxmox host. Jellyfin runs through Docker Compose with configuration on SSD and a separate 400 GiB virtual media disk on HDD. Movies, shows, and podcasts libraries are configured. On 21 October I uploaded a movie, verified the file inside the container, and confirmed phone app access and casting to the TV.

## Storage and deployment

| Layer | Configuration |
| --- | --- |
| VM | `media01`, Debian 13, VLAN 40 |
| OS disk | 32 GiB virtual disk on SSD |
| Proxmox media storage | Existing second HDD partition, formatted ext4, mounted persistently and registered as `hdd-media` |
| Guest media disk | Separate 400 GiB virtual disk, ext4, mounted by UUID at `/srv/media` |
| Configuration | `/opt/jellyfin/compose.yml`, `.env`, and persistent `config` and `cache` directories on SSD |
| Container identity | UID/GID of the Debian `mediaadmin` account |
| Container media mount | `/srv/media:/media:ro` |

The media libraries use `/media/movies`, `/media/shows`, and `/media/podcasts` inside Jellyfin. The Debian account uploads to the corresponding `/srv/media` directories. Jellyfin receives read access to media, while its configuration and cache remain writable.

The Proxmox storage mount has an `is_mountpoint` check, preventing it being treated as available storage when the HDD filesystem is not mounted. The media storage and existing backup storage are separate partitions on the same physical HDD; this is storage separation, not protection against that HDD failing.

An [example Compose configuration](compose.example.yml) records the deployed layout. Set the two UID/GID variables from `id -u mediaadmin` and `id -g mediaadmin`, and prepare directory ownership before deploying. The image used during the build was `jellyfin/jellyfin:latest`; a pinned image version and a tested update process remain follow-up work.

## Network access

VLAN 40 uses a /28 subnet. OPNsense provides its gateway, DHCP, DNS access to `dns01`, HTTP/HTTPS access and automatic outbound NAT coverage. A DHCP reservation ties the media server address to its VM network adapter.

The admin PC reaches the media VLAN through a Windows route and a scoped firewall rule. Home Wi-Fi clients do not inherit that Windows route. For phone access, I configured destination NAT on OPNsense’s home-facing WAN address, TCP 8096, redirecting to `media01` on TCP 8096, with an associated firewall rule. The rule was initially scoped to the phone. Phone access and TV casting were then confirmed; the final casting-device source rules were not independently captured in this record.

This is forwarding from the home network into the lab. No Jellyfin internet port forward was added on the Virgin Hub. Existing WireGuard access remains documented for the Home Control Hub; remote Jellyfin access is not claimed as tested. The full VLAN 40 isolation policy still needs review: allowing HTTP/HTTPS to any destination alone does not demonstrate isolation from other private networks.

## Troubleshooting and validation

| Check | Observed result |
| --- | --- |
| Debian package mirror | Initially failed name resolution; succeeded after BIND ACL update and confirmed reload |
| Docker | `hello-world` completed successfully |
| Compose | Version command succeeded |
| Jellyfin container | `docker compose ps` showed running and healthy |
| Media mount | Guest filesystem mounted at `/srv/media`, initially about 373 GiB available |
| File upload | SCP uploaded a 1.3 GiB movie; directory listings confirmed it on the guest and inside `/media/movies` |
| Library scan | User confirmed the movie appeared in Jellyfin |
| Home access | Phone app access and TV casting confirmed after local forwarding setup and correcting a port typo |

The DNS incident involved two permission layers. The firewall allowed DNS traffic toward `dns01`, but BIND’s `allow-recursion` list omitted VLAN 40. I added the subnet, checked syntax with `named-checkconf`, and reloaded `named`. A diagnostic query through loopback returned `REFUSED` because the explicit ACL also omitted loopback; testing through the permitted VLAN address avoided that misleading check.

For the phone connection, Live View showed attempts to port 8097 while the forwarding rule used 8096. Correcting the client port resolved the mismatch. Brave’s Media Router setting was also enabled during desktop casting investigation; the final reported successful playback path was casting from the phone app.

## Remaining work

- Add a media hostname to the BIND internal zone and verify it.
- Add Uptime Kuma monitoring and verify the required cross-VLAN access.
- Confirm the media disk’s backup exclusion, schedule OS/configuration backups, and test recovery.
- Define a separate backup policy for media files. The same-HDD backup partition cannot protect media against physical disk failure.
- Verify mounts and container recovery after a controlled reboot.
- Record the exact casting-device rules and reserve client addresses where rules depend on them.
- Inspect playback mode and resource usage; hardware acceleration has not been configured or validated.

Sonarr, Radarr, a download client and an outbound VPN were discussed but have not been deployed as part of this project.

## References

- [Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
- [Jellyfin container installation](https://jellyfin.org/docs/general/installation/container/)
- [Current lab topology](../../docs/network-topology.md)

Public examples omit live addressing, device identifiers, account secrets, and media titles.
