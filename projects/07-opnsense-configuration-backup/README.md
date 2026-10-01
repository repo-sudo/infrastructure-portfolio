# Project 007: OPNsense config backup + recovery

## Goal

Create a repeatable backup and recovery habit for the OPNsense firewall/router VM so working firewall, DHCP, VLAN, and access-control settings can be restored after a mistake, reboot issue, or future network change.

This project documents the process. The actual OPNsense configuration XML is not stored in this public repository because it may contain sensitive details.

## Why this matters

The firewall has become a core part of the lab. It now controls traffic between the home LAN and the infrastructure VLAN, including access to the web server and the OPNsense GUI. Once a firewall becomes the routing and policy point, its configuration needs to be treated like important infrastructure state.

A configuration backup helps with:

- recovering from a broken firewall rule
- restoring DHCP and VLAN settings
- comparing changes before and after a lab milestone
- keeping a known-good rollback point
- practising real change-control habits

## Environment

| Component | Role |
| --- | --- |
| OPNsense VM | Firewall/router for the lab network |
| Proxmox VE | Hypervisor hosting the firewall VM |
| Managed switch | Carries VLAN traffic for the lab |
| Infrastructure VLAN | Isolated lab network routed by OPNsense |
| Admin workstation | Device used to access the firewall GUI |

## Backup procedure

1. Log in to the OPNsense web GUI.
2. Go to **System -> Configuration -> Backups**.
3. Select **Download configuration**.
4. Encrypt the exported configuration file.
5. Save the XML file outside the public repository.
6. Name the file with the date and the reason for the backup.

Example local naming pattern:

```text
fw01-config-YYYY-MM-DD-vlan10-web-access-working-encrypted.xml
fw01-config-YYYY-MM-DD-before-new-firewall-rules-encrypted.xml
fw01-config-YYYY-MM-DD-after-dhcp-change-encrypted.xml
```

## Current backup

A first encrypted backup was downloaded and stored privately on the admin workstation.

```text
Downloaded file size: 57 KB
Public repository copy: none
```

## Storage decision

The backup file should be stored privately, for example on the admin workstation and on private lab backup storage. It should not be committed to GitHub.

The public repository should only include:

- the backup process
- the reason for the backup
- what changed before or after the backup
- restore notes after testing

## Sensitive data warning

An OPNsense configuration export can include internal network details and may include secrets, depending on the configured services. For that reason, the XML export is treated as a private operational backup, not as portfolio documentation.

## Verification checklist

- [x] OPNsense GUI is reachable from the admin workstation.
- [x] Configuration backup option identified in the GUI.
- [x] Backup naming convention defined.
- [x] Decision made not to publish XML configuration exports.
- [x] First encrypted backup file downloaded and stored privately.
- [ ] Restore process tested in a safe environment.

## Recovery plan

The restore process should be tested later in a separate temporary OPNsense VM, not directly on the working firewall. That allows the backup to be verified without risking the current lab network.

A safe recovery test would confirm:

- the encrypted backup can be selected for restore
- the backup password works
- interface assignments can be reviewed after restore
- firewall, DHCP, and VLAN configuration are present
- the restored VM is kept isolated until verified

## AI assistance

AI was used to plan the documentation structure and explain why firewall configuration backups should be treated as sensitive operational files. The backup and restore actions are intended to be performed manually and verified in the lab.
