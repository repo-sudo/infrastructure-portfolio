# Debian web server on Proxmox

A Debian virtual machine running Nginx and serving a simple HTML portfolio page on the local network.

## Why I built it

I wanted a dedicated place to host my portfolio and to practise creating a VM, installing Linux, managing a service, and moving a website from my Windows PC to a server.

## Environment

| Component | Configuration |
| --- | --- |
| Host | HP Z2 workstation running Proxmox VE |
| VM | `web01` (VM 100) |
| Guest OS | Debian 13 |
| VM resources | 2 vCPUs, 2 GiB RAM, 32 GiB virtual disk |
| Networking | VirtIO adapter connected to Proxmox bridge `vmbr0`; address assigned by DHCP |
| Web server | Nginx |
| Site | A single static HTML file |

## What I did

1. Uploaded the Debian installer ISO to Proxmox and created `web01`.
2. Installed Debian with the SSH server and standard system utilities.
3. Installed Nginx and checked that its default page loaded from a browser on the local network.
4. Checked Nginx's configuration to find the document root: `/var/www/html`.
5. Created a custom `index.html` on my Windows PC, transferred it to the VM over SSH, and placed it in the document root.
6. Reloaded the page in the browser and confirmed that the custom site appeared.

## Problem I solved

The default Nginx page was visible, but `/var/www/html/index.html` did not exist when I first tried to edit it. Listing the directory showed `index.nginx-debian.html`, the default page installed by the package. I checked Nginx's configured document root, then added my own `index.html` there. The browser subsequently displayed my page.

I also learned that the Proxmox noVNC console handles clipboard input differently from a local terminal. Connecting to the VM with SSH from PowerShell made copying commands and transferring the HTML file easier.

## How I verified it

- Nginx served its default page after installation.
- The VM accepted an SSH login from my Windows PC.
- A browser on the local network displayed the custom page with the heading **“My first lab website”** and the text **“Hosted on Debian with Nginx.”**

## What I learned

- A VM can use a bridged virtual network adapter to join the local network.
- Nginx serves files from the configured document root; the name of the default page is not necessarily `index.html`.
- SSH is useful for administration, while file transfer over SSH is a practical way to deploy a small static site.

## Next steps

- Add a clearer deployment process for future changes to the page.
- Document how the VM's address is kept stable and how access is managed.
- Add further infrastructure projects as they are completed.
