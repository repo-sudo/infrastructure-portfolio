# Project 007: OPNsense configuration backup

## Goal

Create a repeatable backup habit for the OPNsense firewall/router VM so working firewall, DHCP, VLAN, and access-control settings can be restored after a mistake, reboot issue, or future network change.

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
| Main PC | Admin workstation used to access the GUI |

## Backup procedure

1. Log in to the OPNsense web GUI.
2. Go to **System -> Configuration -> Backups**.
3. Select **Download configuration**.
4. Save the XML file outside the public repository.
5. Name the file with the date and the reason for the backup.

Example local naming pattern:

```text
fw01-config-YYYY-MM-DD-vlan10-web-access-working.xml
fw01-config-YYYY-MM-DD-before-new-firewall-rules.xml
fw01-config-YYYY-MM-DD-after-dhcp-change.xml
```

## Storage decision

The backup file should be stored privately, for example on the admin PC and on the lab backup disk. It should not be committed to GitHub.

The public repository should only include:

- the backup process
- the reason for the backup
- what changed before or after the backup
- restore notes after testing

## Sensitive data warning

An OPNsense configuration export can include internal network details and may include secrets, depending on the configured services. For that reason, the XML export is treated as a private operational backup, not as portfolio documentation.

## Verification checklist

- [x] OPNsense GUI is reachable from the admin PC.
- [x] Configuration backup option identified in the GUI.
- [x] Backup naming convention defined.
- [x] Decision made not to publish XML configuration exports.
- [ ] First backup file downloaded and stored privately.
- [ ] Restore process tested in a safe environment.

## Future improvement

A later version of this project can test restoring the configuration into a separate OPNsense VM. That would verify the backup properly without risking the working firewall.

## AI assistance

AI was used to plan the documentation structure and explain why firewall configuration backups should be treated as sensitive operational files. The backup and restore actions are intended to be performed manually and verified in the lab.
