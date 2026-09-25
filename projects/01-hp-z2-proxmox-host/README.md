# HP Z2 infrastructure host and Proxmox installation

I set up an HP Z2 workstation as a dedicated virtualization host and installed Proxmox VE directly on it. This is the foundation for the VMs and services documented in the rest of this portfolio.

## Goal

Move my lab onto a dedicated machine that can run multiple isolated systems while I practise virtualization, Linux and Windows Server administration, networking, and service hosting.

## Hardware and platform

| Component | Recorded detail |
| --- | --- |
| Host | HP Z2 workstation |
| Processor | Intel Core i7-9700 |
| Hypervisor | Proxmox VE 9.2.2, installed on the host |
| Proxmox node | `pve01` |
| Network bridge | `vmbr0` |
| Storage shown in Proxmox | `local` and `local-lvm` |

The installed RAM capacity, host disk layout, firmware settings, and installation media are not recorded here yet; I will add them when I check them on the host.

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

- Proxmox is the hypervisor managing the host; each VM has its own guest operating system and allocated resources.
- A network bridge such as `vmbr0` connects a VM's virtual network adapter to the host's network.
- Proxmox storage entries serve different purposes: the installer ISO was uploaded to `local`, while a VM also needs a virtual disk for its operating system.

## Next documentation

- Record and verify the Z2's installed RAM, physical disks, and Proxmox disk layout.
- Add the exact installation and recovery steps once I have checked them.
- Document host updates, backups, and network configuration as I configure them.
