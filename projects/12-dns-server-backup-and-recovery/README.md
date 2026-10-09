# Project 012: DNS server backup and recovery test

## Goal

Prove that the internal DNS server can be restored from backup without risking the live `dns01` service.

This project tested the recovery path for the BIND-based DNS server created in Project 011.

## Environment

| Component | Value |
| --- | --- |
| Hypervisor | Proxmox VE |
| Source VM | `dns01` |
| Restored test VM | `dns01-restore-test` |
| Operating system | Debian 13 |
| DNS software | BIND |
| DNS zone | `internal` |
| Network segment | Infrastructure VLAN |
| Backup storage | Proxmox backup storage on the lab backup disk |

## What I Tested

- Confirmed the live `dns01` server was healthy before backup.
- Checked that BIND was running.
- Validated the BIND configuration.
- Validated the `internal` zone file.
- Confirmed local DNS resolution from `dns01`.
- Created a Proxmox backup of `dns01`.
- Restored the backup as a separate VM instead of overwriting the live server.
- Kept the restored VM network disconnected to avoid an IP conflict.
- Booted the restored VM.
- Re-ran the BIND and DNS validation checks on the restored system.

## Key Commands Used

```bash
systemctl status bind9
named-checkconf
named-checkzone internal /etc/bind/db.internal
dig @127.0.0.1 web.internal
dig @127.0.0.1 hch.internal
dig @127.0.0.1 dns.internal
```

These checks proved that the restored system still had a working BIND service, a valid configuration, a valid zone file, and usable internal DNS records.

## Recovery Result

The recovery test succeeded. The restored VM booted, BIND started, the `internal` zone loaded correctly, and local DNS queries returned the expected records.

The restored VM was isolated from the network during testing, which avoided duplicate-address risk while still proving the DNS service could be recovered.

## Scheduled Backup Standard

This project also established the standard Proxmox backup pattern for important lab servers:

| Setting | Standard |
| --- | --- |
| Mode | Snapshot |
| Compression | ZSTD |
| Storage | Lab backup disk |
| Schedule | Weekly |
| Retention | Keep the last 3 backups |

This pattern is suitable for small infrastructure and service VMs such as `dns01`, `web01`, and `hch01`.

OPNsense remains a separate case: its configuration export should be saved after meaningful firewall, VLAN, VPN, or DNS rule changes.

## Lessons Learned

- A backup is only proven after a restore test.
- DNS is critical infrastructure, so its recovery path needs to be tested early.
- Restoring into a separate VM is safer than overwriting the live server.
- A restored VM should stay disconnected until IP and hostname conflicts are controlled.
- Validating the service inside the restored machine proves more than just checking that the VM boots.
- Scheduled backups should have retention limits so the backup disk does not fill silently.

## Next Steps

- Keep `dns01-restore-test` powered off unless needed for future recovery checks.
- Use this backup pattern for other important lab VMs.
- Add monitoring so DNS availability can be checked automatically.
- Repeat the restore test after major DNS or VLAN changes.

## AI assistance

AI was used to guide the recovery checklist and structure the documentation. The Proxmox backup, restore, and BIND validation were performed manually in the lab and verified on the restored VM.

## Repository materials

[Evidence capture instructions](evidence/README.md) and a [read-only collector](scripts/collect-dns-evidence.sh) support the next restore test. No historical output or recovery timings have been invented.
