# Project 013: Lab monitoring with Uptime Kuma

## Goal

Add a lightweight monitoring service so the lab can show whether important systems, gateways, DNS records, and web services are reachable.

The goal was not to add another isolated project for its own sake. The goal was to make the existing lab easier to operate and troubleshoot before adding more services.

## Environment

| Component | Value |
| --- | --- |
| Monitoring server | `mon01` |
| Operating system | Debian 13 |
| Monitoring software | Uptime Kuma |
| Container runtime | Docker |
| Network segment | VLAN 30 / Infrastructure |
| Internal DNS name | Internal monitoring hostname |
| Web interface | Internal Uptime Kuma web interface |
| Firewall/router | OPNsense VM `fw01` |

## What I Built

- Created `mon01` as a dedicated Debian VM in the infrastructure VLAN.
- Installed Docker and deployed Uptime Kuma as a persistent container.
- Added a Docker volume so Uptime Kuma data survives container replacement.
- Added firewall and routing access so the main PC can reach the monitoring dashboard.
- Added an internal DNS record for the monitoring dashboard on `dns01`.
- Created monitoring checks for core services and network paths.

## Monitors Added

| Monitor | Type | Purpose |
| --- | --- | --- |
| `web01 portfolio website` | HTTP | Confirms the portfolio site is reachable |
| `hch01 Frigate` | HTTP | Confirms the Home Control Hub web service is reachable |
| `mon01 Uptime Kuma` | HTTP | Confirms the monitoring dashboard itself is reachable |
| `internet reachability` | Ping | Confirms the lab has upstream connectivity |
| `fw01 VLAN10 gateway` | Ping | Confirms the web-services VLAN gateway is reachable |
| `fw01 VLAN20 gateway` | Ping | Confirms the Home Control Hub VLAN gateway is reachable |
| `fw01 VLAN30 gateway` | Ping | Confirms the infrastructure VLAN gateway is reachable |
| `OPNsense home/WAN-side interface` | Ping | Confirms the firewall interface on the home LAN side is reachable |
| `dns01 internal DNS - web.internal` | DNS | Confirms internal lab name resolution works |
| `dns01 external DNS - google.com` | DNS | Confirms `dns01` can resolve external names |

## Key Commands Used

```bash
apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
```

```bash
docker volume create uptime-kuma
docker run -d \
  --restart=always \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  --name uptime-kuma \
  louislam/uptime-kuma:2
```

## DNS Addition

The `internal` zone on `dns01` was updated with a new record for the monitoring dashboard.

After updating the zone serial number, BIND was validated and reloaded:

```bash
named-checkzone internal /etc/bind/db.internal
systemctl reload bind9
nslookup <monitoring-hostname> <dns-server>
```

## Troubleshooting

### SSH to mon01 timed out at first

`mon01` had a VLAN 30 address and could reach the internet, but the main PC could not SSH to it.

The persistent route for VLAN 30 already existed. The missing piece was the OPNsense firewall rule allowing the main PC path to reach `mon01` for SSH and the Uptime Kuma web port.

### Firewall rules still mattered

Routing alone was not enough. OPNsense still needed an explicit rule for the allowed management traffic to the monitoring server.

This reinforced the same lesson from earlier VLAN projects: routing decides where traffic goes, but firewall policy decides whether it is allowed.

### DNS monitoring had to be split

At first, one DNS monitor could have been misleading. Internal DNS might resolve `web.internal` even when internet access is down, while external DNS forwarding would fail.

The final design separates the checks:

- Internal DNS: `web.internal` through `dns01`
- External DNS: `google.com` through `dns01`

This makes DNS failures easier to understand.

## Current Result

Uptime Kuma is live on `mon01` and reachable through the internal monitoring hostname.

The dashboard now gives a quick view of core lab availability, including service reachability, VLAN gateway reachability, DNS health, and upstream internet connectivity.

## Lessons Learned

- Monitoring is part of core infrastructure, not an optional extra.
- A service being "up" is not enough; the relevant path to that service also needs to be tested.
- Internal DNS and external DNS should be monitored separately because they prove different things.
- Gateway checks for each VLAN give better visibility than only pinging the firewall's home-side interface.
- Docker is useful for lightweight infrastructure tools when persistent data is handled properly.
- Warnings from applications matter; the Uptime Kuma v1 warning led to replacing the container with the maintained v2 image.

## Next Steps

- Add notifications after deciding the best alert destination.
- Consider adding a public status page for internal use only.
- Monitor scheduled backup jobs when a reliable check method is available.
- Add deeper metrics later with Prometheus and Grafana only if simple availability checks are no longer enough.

## AI assistance

AI was used to guide the installation sequence, firewall troubleshooting, monitor selection, DNS naming, and documentation structure. The Debian install, Docker installation, DNS update, OPNsense changes, and Uptime Kuma setup were performed manually in the lab and verified through browser access and monitoring checks.
