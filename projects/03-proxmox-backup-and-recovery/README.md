# Proxmox backup and recovery test

I set up backup storage for a Proxmox virtual machine and tested a restore of my Debian web server. The goal was to verify that a backup could start and serve the website, rather than rely on a successful backup task alone.

## What I did

1. Identified a separate disk for backups and checked its health before preparing it. I reserved part of its capacity for future lab projects.
2. Created a filesystem and a persistent mount, then registered it as backup storage in the Proxmox interface. I checked that the storage was active.
3. Created a compressed backup of the Debian web server. The task completed successfully and the archive appeared in Proxmox.
4. Scheduled recurring backups with a retention policy for this VM.
5. Restored the archive as a separate test VM. I disconnected the test VM's virtual network adapter to avoid a conflict with the live server, then started it and logged in.
6. Confirmed that Nginx was active and that a request from inside the restored VM returned the portfolio site's HTML. I removed the temporary test VM after checking it; the backup archive remains available.

## What the test showed

The backup produced a bootable Debian VM with a working local web service. It did not test recovery after loss of the Proxmox host or the backup disk. Keeping the backup on a second disk in the same host helps with failure of the primary storage, but a copy outside this host is still needed for wider protection.

## What I learned

- A restore test gives more useful evidence than a completed backup task alone.
- A restored VM may inherit the live VM's network identity; isolating it prevents a conflict while testing.
- Proxmox needs both a persistent filesystem mount and a storage entry to use a disk for scheduled backups.

## AI assistance

I used Codex to help plan the work, suggest and explain Linux and Proxmox commands, interpret command output, and troubleshoot setup errors. Codex also helped draft this documentation. I ran the commands, configured the backups in the Proxmox interface, performed the restore test, and verified the results myself.

## Next steps

- Confirm that scheduled backups complete and retention works as intended.
- Make another copy outside the host and test recovery from it.
- Decide how to use the space reserved for future projects.
