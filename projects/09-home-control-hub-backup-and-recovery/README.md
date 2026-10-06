# Project 009: Home Control Hub backup and recovery test

## Goal

Prove that the Home Control Hub can be recovered from backup, not just backed up. The test used `hch01`, the Debian VM running Docker and Frigate for local camera monitoring.

## Environment

| Component | Value |
| --- | --- |
| Hypervisor | Proxmox VE |
| Source VM | hch01 |
| Restored test VM | hch01-restore-test |
| Workload | Docker + Frigate |
| Frigate path | `/opt/frigate` |
| Network segment | VLAN 20 |
| Backup storage | Proxmox backup storage on the lab backup disk |

## What I Tested

- Confirmed `hch01` was healthy before backup.
- Verified SSH access from the main PC to `hch01`.
- Checked Docker and Frigate were running before the backup.
- Confirmed the Frigate working directory existed under `/opt/frigate`.
- Created a Proxmox backup of `hch01`.
- Restored the backup as a separate VM instead of overwriting the live `hch01`.
- Avoided running both the original and restored VM in a way that could create an IP conflict.
- Booted the restored VM and confirmed the recovered system worked.
- Verified the restored system still contained the Frigate configuration and Docker service state.

## Key Commands Used

```bash
docker ps
cd /opt/frigate
ls
```

These checks confirmed the Frigate container and persistent service files were present after recovery.

## Recovery Result

The recovery test succeeded. The restored VM booted correctly, and the expected Frigate files and Docker state were present. This confirmed that the Home Control Hub can be recovered from a Proxmox backup without relying only on the original VM.

## Lessons Learned

- A backup is only trustworthy after a restore test.
- Restoring into a separate VM is safer than overwriting the live service.
- A cloned VM can create IP or hostname confusion if it is started alongside the original without changes.
- Application data must live outside the container so it survives backup and recovery.
- Recovery notes should document what was verified, not just that a backup job completed.

## Next Steps

- Keep `hch01-restore-test` powered off unless needed for evidence or another recovery check.
- Add a scheduled backup policy for `hch01`.
- Review whether Frigate video storage should be included in every backup or handled with a separate retention plan.
- Repeat the restore test after major Frigate or VLAN changes.

## AI assistance

AI was used to structure the documentation and guide the recovery test checklist. The backup and restore were performed manually in the lab and verified on the restored VM.
