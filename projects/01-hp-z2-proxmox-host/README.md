# HP Z2 infrastructure host and Proxmox installation

I set up an HP Z2 workstation bought in Ebay as a dedicated virtualization host and installed Proxmox VE directly on it. This is the foundation for the VMs and services documented in the rest of this portfolio.

## Goal

Set up my lab in a dedicated machine that can run multiple isolated systems while I practise virtualization, Linux and Windows Server administration, networking, and service hosting.

## Hardware and platform

| Component | Recorded detail |
| --- | --- |
| System model | HP Z2 SFF G4 Workstation |
| Processor | Intel Core i7-8700 @ 3.20 GHz; 6 cores, 12 logical processors |
| Installed RAM | 24 GB |
| Storage |  Samsung SSD 860 EVO 500 GB and an HGST HDD of approximately 1 TB.|
| Hypervisor | Proxmox VE 9.2.2, installed on the host |
| Proxmox node | `pve01` |
| Network bridge | `vmbr0` |
| Storage shown in Proxmox | `local` and `local-lvm` |

## What I set up

1. Installed Proxmox VE on the HP Z2 and accessed its web management interface from a computer on my local network.
2. Confirmed that node `pve01`, storage `local` and `local-lvm`, and network bridge `vmbr0` were available.
3. Uploaded a Debian installer ISO to the `local` storage.
4. Created VM 100 (`web01`) using that ISO, with a VirtIO network adapter on `vmbr0`.
5. Started the VM and installed Debian. The web server running on this VM is documented separately in [project 02](../02-proxmox-debian-web-server/README.md).

## How I checked it worked

- The Proxmox web interface displayed node `pve01` and the available storage.
- The Debian ISO appeared in the `local` storage's ISO Images view.
- The task list showed VM 100 being created successfully.
- VM 100 booted the Debian installer and later ran Debian and Nginx on the local network.

## What I learned

- **Virtualization and resources:** Proxmox runs directly on the HP Z2 and lets me create separate computers in software. For `web01`, I allocated 2 virtual CPUs, 2 GiB of RAM, and a 32 GiB virtual disk. Debian runs inside that VM independently of the Proxmox host. A virtual CPU is scheduled on the host’s processor; it does not mean a physical core is reserved exclusively for the VM.

- **Bridged networking:** I connected `web01`’s VirtIO network adapter to `vmbr0`, the network bridge on the Proxmox host. This let the VM communicate on my local network, where DHCP gave Debian its own IP address. I could then reach the Nginx page from another computer. The bridge provides the network connection; DHCP provides the address.

- **Installation media and VM storage:** I uploaded the Debian ISO to `local` so the VM could boot the installer. Debian was then installed onto the VM’s virtual disk. The ISO is installation media, while the virtual disk holds the operating system and its files after installation. Proxmox also shows `local-lvm` as a storage option; I still need to verify the exact placement of this VM’s disk before documenting it.

## Next documentation

- Add the exact installation and recovery steps once I have checked them.
- Document host updates, backups, and network configuration as I configure them.
