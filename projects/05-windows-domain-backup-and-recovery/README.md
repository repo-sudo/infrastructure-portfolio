# Windows domain backup and recovery

**Status:** Planned

## Goal

Create and test a dependable backup and recovery process for the Elephant SA Windows domain after its domain-controller migration. The domain is `elephant.test`, and DC02 is currently its sole domain controller.

## Lab environment

- HP Z2 SFF running Proxmox VE on `pve01`
- DC02, a Windows Server virtual machine and the current domain controller
- `elephant.test`, a fictional-company Active Directory lab
- Separate 1 TB HGST hard drive reserved for backup and recovery work

## Planned work

1. Record DC02's current configuration and check the health of Active Directory and DNS before taking a backup.
2. Choose a backup method that covers both the Windows Server system and the directory recovery needs. Document what each backup can and cannot recover.
3. Configure the backup destination on the dedicated HGST drive and set a practical schedule and retention policy.
4. Run a backup and confirm that it completed and can be read from the backup storage.
5. Restore a copy of DC02 into an isolated test environment with its network disconnected from the live lab.
6. Verify that the restored server boots and that the documented Windows Server, Active Directory, and DNS recovery checks succeed.
7. Record the recovery steps, evidence, time taken, and any remaining gaps.

## Safety and scope

DC02 is the only domain controller for `elephant.test`. Any restore test must remain isolated from the live network to avoid introducing a duplicate domain controller. This project will document the supported recovery process used for the selected Windows Server version before performing the test.

The separate backup disk protects against failure of the host's primary storage, but it remains in the same physical host. This project does not claim protection against loss of the whole host or backup disk.

## Current status

The domain-controller migration is complete, and DC02 holds the domain role. This backup project has only been created: no Windows domain backup or restore test has been recorded yet.

## Completion evidence

- Backup job or command and successful completion evidence.
- Backup files visible on the dedicated backup storage.
- Isolated restore test with the network disconnected.
- Successful boot and recorded Active Directory and DNS validation.
- Recovery notes that another person could follow.
