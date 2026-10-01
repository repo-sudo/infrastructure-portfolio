# Infrastructure portfolio

I am documenting hands-on infrastructure and cloud projects as I build them. Current work covers Proxmox, Linux, Windows Server, OPNsense, VLANs, and backup/recovery, with Azure projects planned as the lab grows. My focus is networking, security, AI, and automation.

## Projects

1. [HP Z2 infrastructure host and Proxmox installation](projects/01-hp-z2-proxmox-host/README.md)  set up the dedicated host, installed Proxmox VE, and prepared the platform for virtual machines.
2. [Debian web server on Proxmox](projects/02-proxmox-debian-web-server/README.md)  created a Debian VM, installed Nginx, and published a static site on my local network.
3. [Proxmox backup and recovery test](projects/03-proxmox-backup-and-recovery/README.md)  configured backup storage and verified recovery with an isolated restore.
4. [Windows Server domain controller migration](projects/04-windows-server-domain-controller-migration/README.md)  completed the move to DC02, resolved replication, DNS, and RPC issues, transferred all FSMO roles, joined a client, and demoted DC01.
5. [Windows domain backup and recovery](projects/05-windows-domain-backup-and-recovery/README.md)  configured daily Windows Server Backup for DC02 and verified the first full-server backup; the scheduled run and restore test remain to be verified.
6. [Managed switch, VLAN, and OPNsense firewall lab](projects/06-managed-switch-vlan-lab/README.md)  installed a managed switch, created a tagged infrastructure VLAN, routed it with OPNsense, configured DHCP and firewall rules, and troubleshot web access from the home LAN.
7. [OPNsense configuration backup](projects/07-opnsense-configuration-backup/README.md)  documented the firewall configuration backup process, backup naming convention, sensitive-data handling, and future restore-test plan.

More project documentation will be added as the lab grows.
