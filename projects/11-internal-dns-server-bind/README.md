# Project 011: Internal DNS server with BIND

## Goal

Create a dedicated internal DNS server so lab services can be reached by clear names instead of memorised IP addresses.

The final goal was to make names such as `web.internal`, `hch.internal`, and `dns.internal` work from the lab servers and from the main PC.

## Environment

| Component | Value |
| --- | --- |
| DNS server | `dns01` |
| Operating system | Debian 13 |
| DNS software | BIND |
| DNS zone | `internal` |
| Firewall/router | OPNsense VM `fw01` |
| Infrastructure network | VLAN 30 |
| Web services network | VLAN 10 |
| Home Control Hub network | VLAN 20 |
| Main clients tested | `dns01`, `web01`, `hch01`, main PC |

## What I Built

- Created `dns01` as a dedicated Debian VM for internal name resolution.
- Placed `dns01` in the infrastructure VLAN.
- Installed and configured BIND.
- Created the `internal` zone.
- Added short records for the main lab services:
  - `dns.internal`
  - `fw.internal`
  - `pve.internal`
  - `web.internal`
  - `hch.internal`
- Configured OPNsense DHCP options so VLAN clients receive `dns01` as their DNS server.
- Added firewall rules allowing selected VLANs and the main PC to query `dns01` on DNS ports.
- Verified browser and SSH access by hostname.

## Final DNS Names

| DNS name | Purpose |
| --- | --- |
| `dns.internal` | Internal DNS server |
| `fw.internal` | OPNsense firewall/router |
| `pve.internal` | Proxmox host |
| `web.internal` | Debian/Nginx portfolio web server |
| `hch.internal` | Home Control Hub / Frigate server |

## Final Traffic Pattern

```text
Client
    |
DHCP-provided DNS server
    |
OPNsense firewall rule
    |
dns01 / BIND
    |
internal zone answer
```

## Configuration Summary

### BIND zone

The `internal` zone is hosted locally on `dns01`.

The zone contains clean service names rather than using every VM's full hostname as the daily-use name. For example, the web server is reached as `web.internal` and the Home Control Hub is reached as `hch.internal`.

### DHCP DNS options

OPNsense Dnsmasq DHCP options were used to hand out `dns01` as the DNS server to lab VLAN clients.

The DHCP DNS option was applied to:

- Web Services VLAN
- Home Control Hub VLAN
- Infrastructure VLAN

### Firewall rules

DNS traffic was allowed intentionally rather than relying on broad inter-VLAN access.

The rule pattern is:

| Field | Value |
| --- | --- |
| Interface | VLAN where the client traffic enters OPNsense |
| Source | That VLAN's network |
| Destination | `dns01` |
| Protocol | TCP/UDP |
| Destination port | DNS |

The same principle was used for the main PC path: the rule belongs on the interface where that traffic enters OPNsense.

## Troubleshooting

### VLAN 30 DHCP did not work at first

`dns01` did not initially receive the expected infrastructure VLAN network settings.

The important finding came from the DHCP logs: DHCP packets were reaching the VLAN interface, but the OPNsense interface did not have an interface address configured.

Once the infrastructure VLAN interface had its static gateway address, DHCP could serve clients correctly.

### VM tagging and network path had to match

The issue was not only inside Debian. The full path had to line up:

- Proxmox bridge VLAN awareness
- VM network tag
- Switch trunk/tagging
- OPNsense VLAN interface
- OPNsense interface address
- DHCP scope

This was a useful reminder that VLAN troubleshooting is end-to-end.

### DHCP DNS option was not enough

Giving a client `dns01` as its DNS server only tells the client where to ask.

Firewall policy still has to allow the packet to reach `dns01`.

The clean process became:

```text
1. Add DHCP DNS option
2. Add firewall rule to dns01
3. Reboot or renew the client
4. Test with the full name or dig +search
```

### dig behaviour was misleading

Plain short-name queries such as `dig hch` can return `NXDOMAIN` even when the DNS server is working.

The correct tests were:

```bash
dig +search dns
dig +search web
dig +search hch
```

or:

```bash
dig dns.internal
dig web.internal
dig hch.internal
```

## Verification

The project was considered working after these checks passed:

- `dns01` resolved records from its own BIND service.
- `web01` received `dns01` through DHCP and resolved internal names.
- `hch01` received `dns01` through DHCP and resolved internal names.
- The main PC resolved `web.internal`, `hch.internal`, and `dns.internal`.
- `http://web.internal` opened the portfolio website.
- `http://hch.internal:5000` opened the Frigate interface.
- SSH by hostname worked for both the web server and Home Control Hub.

## Current Result

Internal DNS is live. Lab services can now be reached by names instead of IP addresses, and DNS access is controlled through OPNsense rules instead of open inter-VLAN access.

## Lessons Learned

- DNS depends on the full network path, not only the DNS server configuration.
- VLAN interface addressing is required before DHCP can serve that VLAN correctly.
- DHCP options and firewall rules solve different problems.
- Firewall rules should be placed on the interface where traffic enters OPNsense.
- `dig +search` or full FQDNs are better tests than plain short-name `dig` queries.
- Internal DNS makes the lab feel more like a real environment and prepares it for future services.

## Next Steps

- Add reverse DNS later if it becomes useful for troubleshooting.
- Consider moving more service access to names instead of IP addresses.
- Decide whether the main PC should permanently use `dns01` as its primary resolver.
- Include future infrastructure services in the `internal` zone.
- Take a fresh OPNsense configuration backup after the DNS rules are stable.

## AI assistance

AI was used to guide the build, troubleshoot the VLAN/DHCP/DNS path, and structure the documentation. The OPNsense, Debian, BIND, Proxmox, and Windows configuration changes were performed manually in the lab and verified through DNS lookups, browser tests, and SSH by hostname.
