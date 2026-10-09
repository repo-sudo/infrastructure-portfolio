# Debian web server on Proxmox

A Debian virtual machine running Nginx and serving a small static HTML portfolio on the local network. This project covers the first web server build, host firewall setup, multi-page static site deployment, SSH key-based authentication, and a repeatable deployment workflow from Windows.

## Why I built it

I wanted a dedicated place to host my portfolio and to practise creating a VM, installing Linux, managing a service, moving a website from my Windows PC to a server, and securing only the access the server needs.

## Environment

| Component | Configuration |
| --- | --- |
| Host | HP Z2 workstation running Proxmox VE |
| VM | `web01` (VM 100) |
| Guest OS | Debian 13 |
| VM resources | 2 vCPUs, 2 GiB RAM, 32 GiB virtual disk |
| Networking | VirtIO adapter connected to Proxmox bridge `vmbr0`; LAN address `192.168.0.70` |
| Web server | Nginx |
| Site | Static HTML pages served from `/var/www/html/` |
| Administration | SSH from the main PC as `webadmin` |
| Deployment | PowerShell script and clickable `.bat` launcher using `scp` over SSH |

## What I did

1. Uploaded the Debian installer ISO to Proxmox and created `web01`.
2. Installed Debian with the SSH server and standard system utilities.
3. Installed Nginx and checked that its default page loaded from a browser on the local network.
4. Checked Nginx's configuration to find the document root: `/var/www/html`.
5. Created a custom `index.html` on my Windows PC, transferred it to the VM over SSH, and placed it in the document root.
6. Reloaded the page in the browser and confirmed that the custom site appeared.
7. Installed UFW, enabled the firewall, and allowed only the access needed for this stage: SSH and HTTP.
8. Verified from the main PC that SSH still worked and the website still loaded after the firewall was active.
9. Created a PowerShell deployment script to copy the local HTML files to the Nginx document root.
10. Split the site into separate static pages for Projects, Lab Notes, and About.
11. Created an ED25519 SSH key pair and added the public key to `web01` for passwordless deployment.
12. Created a clickable `.bat` launcher so the deployment can be run from Windows without typing the command each time.

## Deployment workflow

At first, I updated the website manually: copy the file, log in to the server, move it into `/var/www/html`, and reload Nginx. I replaced those manual steps with a PowerShell deployment script from the main PC.

The current workflow is:

| Step | Action |
| --- | --- |
| 1 | Update and commit the HTML files in this repository's `website/` directory |
| 2 | Run `update-and-deploy-web01.bat` to download the pages and invoke `deploy-web01.ps1` |
| 3 | Use `scp` over SSH to copy all `.html` files to `/var/www/html/` |
| 4 | Verify the homepage and subpages in a browser |

Because this is a static Nginx site, replacing the HTML files does not require a service reload. SSH key-based authentication is now configured, so deployment runs without entering the `webadmin` password.

## Firewall configuration

The server is reachable on the LAN, so I added a basic host firewall instead of leaving every service exposed by default.

| Rule | Purpose |
| --- | --- |
| `OpenSSH` | Remote administration from the main PC |
| `Nginx HTTP` | Serving the website over HTTP on port 80 |

After enabling UFW, `ufw status` showed the firewall as active with `OpenSSH` and `Nginx HTTP` allowed for IPv4 and IPv6. I then confirmed that a new SSH session from the main PC could still connect and that the website was still reachable in a browser at `http://192.168.0.70`.

## Problems I solved

The default Nginx page was visible, but `/var/www/html/index.html` did not exist when I first tried to edit it. Listing the directory showed `index.nginx-debian.html`, the default page installed by the package. I checked Nginx's configured document root, then added my own `index.html` there. The browser subsequently displayed my page.

I also learned that the Proxmox noVNC console handles clipboard input differently from a local terminal. Connecting to the VM with SSH from PowerShell made copying commands and transferring the HTML file easier.

While configuring UFW, some administrative commands were not found from the root shell because `/usr/sbin` was not in the current `PATH`. Running the commands with their full path, such as `/usr/sbin/ufw`, allowed the configuration to continue.

PowerShell also blocked the deployment script at first because script execution was restricted. I ran it with a one-time execution policy bypass rather than changing the system policy permanently.

## How I verified it

- Nginx served its default page after installation.
- The VM accepted an SSH login from my Windows PC.
- A browser on the local network displayed the custom portfolio page.
- UFW reported `Status: active`.
- SSH and HTTP remained reachable after the firewall was enabled.
- The PowerShell deployment script uploaded all local HTML pages successfully.
- SSH key-based login worked from the Windows PC to `web01`.
- The clickable `.bat` launcher successfully ran the deployment script.

## What I learned

- A VM can use a bridged virtual network adapter to join the local network.
- Nginx serves files from the configured document root; the name of the default page is not necessarily `index.html`.
- SSH is useful for administration, while file transfer over SSH is a practical way to deploy a small static site.
- Firewall changes should be verified from another session or client so administration access is not accidentally lost.
- A working service is not complete just because it runs; access control and testing are part of the build.
- Even a small script can turn a manual process into a repeatable deployment workflow.
- SSH keys improve the deployment workflow by removing repeated password prompts while avoiding password-based automation.
- A static site can grow from one file into a small multi-page portfolio without needing a framework or database.

## AI assistance

I used Codex to help interpret command output, suggest Nginx and UFW checks, explain errors, draft the deployment scripts, add the separate HTML pages, and write this documentation. I ran the commands, reviewed the results, and verified the server access myself.

## Project status

Complete for local LAN hosting.

The VM is running, Nginx is active, the static pages are present in `/var/www/html/`, the host firewall allows only the required access for this stage, and deployment from the Windows PC is automated through SSH keys, PowerShell, and a clickable launcher.

This project is intentionally closed at the local hosting stage. Public DNS, HTTPS, remote access hardening, and publishing the site beyond the LAN will be treated as a separate follow-up project.

## Next steps

- Start a separate public hosting phase when DNS, HTTPS, and remote access design are ready.
- Keep the deployment scripts under review as the site grows.
- Decide how the VM's address will be kept stable long term.

## Published deployment scripts

[Sanitised copies of the original scripts and run instructions](scripts/README.md) are committed alongside this project. Personal connection details are placeholders. The earlier LAN addressing above describes the initial build stage; configure the scripts with your current target. The instructions also describe the original scripts' error-handling limitations.
