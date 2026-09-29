# Windows domain backup and recovery

**Project:** 005

**Status:** In progress — scheduled backup configured; restore testing pending.

## Goal

Create and verify a dependable backup and recovery process for the Elephant SA Windows domain after its domain-controller migration. The domain is `elephant.test`, and DC02 is its sole domain controller.

## Lab environment

- HP Z2 SFF running Proxmox VE on node `pve01`.
- The live web and Windows Server VMs are stored on the host SSD.
- DC02 is the Windows Server virtual machine and domain controller for `elephant.test`.
- A separate 1 TB HGST hard drive is dedicated to backup storage in Proxmox, mounted as `hdd-backups`.
- A 100 GB virtual disk for Windows Server Backup is stored on that HDD and attached to DC02.

## Backup design

Windows Server Backup runs inside DC02. The scheduled job is configured as a **Full Server** backup with **VSS Full Backup**, including bare-metal recovery, system state, and the server volumes. It writes to the attached 100 GB virtual backup disk and runs daily at **03:00**.

Proxmox-level VM backup files are also stored on the same HDD. The guest-level and Proxmox-level backups provide different recovery options, but they share the same physical disk.

## Work completed

1. Added the 100 GB virtual backup disk from Proxmox storage `hdd-backups` to DC02. Windows Server Backup reports a usable capacity of 99.86 GB.
2. Created the daily Full Server backup schedule. The first scheduled run is shown as 30 September 2026 at 03:00.
3. Ran a manual backup using the scheduled settings on 29 September 2026. Windows Server Backup reported **Successful** at 17:48.
4. The backup transferred **16.08 GB**. The listed EFI system partition, C: volume, system state, and bare-metal recovery items all completed.
5. The Windows Server Backup dashboard shows one copy on the destination, using 16.08 GB of 99.86 GB.

## Protection boundary

The live VMs are on the SSD and the backup destination is on a separate HDD, so the backup should remain available if the SSD fails. The same HDD also holds Proxmox backup files, and both drives are inside the Z2. This setup does not protect against failure or loss of the backup HDD or the whole host.

## Remaining validation

1. Check that the first automatic run on 30 September completes successfully.
2. Perform a controlled restore test in an isolated environment, with the recovered domain controller disconnected from the live network.
3. Record the restore procedure, results, and evidence before marking the project complete.

## Safety

DC02 is currently the only domain controller for `elephant.test`. Any recovered copy must stay disconnected from the live network to avoid introducing a duplicate domain controller.

## AI assistance

I used Codex to discuss backup options, follow the Windows Server Backup GUI workflow, and draft these notes. I performed the configuration and ran the backup in my own lab.
