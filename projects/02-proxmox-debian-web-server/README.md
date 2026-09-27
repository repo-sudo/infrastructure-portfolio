# Debian web server on Proxmox

A Debian virtual machine running Nginx and serving a static HTML portfolio page on the local network. This project covers the first web server build, a repeatable deployment script, and the first host firewall checkpoint.

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
| Site | A single static HTML file in `/var/www/html/index.html` |
| Administration | SSH from the main PC as `webadmin` |
| Deployment | PowerShell script from the main PC using `scp` and `ssh` |

## What I did

1. Uploaded the Debian installer ISO to Proxmox and created `web01`.
2. Installed Debian with the SSH server and standard system utilities.
3. Installed Nginx and checked that its default page loaded from a browser on the local network.
4. Checked Nginx's configuration to find the document root: `/var/www/html`.
5. Created a custom `index.html` on my Windows PC, transferred it to the VM over SSH, and placed it in the document root.
6. Reloaded the page in the browser and confirmed that the custom site appeared.
7. Installed UFW, enabled the firewall, and allowed only the access needed for this stage: SSH and HTTP.
8. Verified from the main PC that SSH still worked and the website still loaded after the firewall was active.
9. Created a PowerShell deployment script to copy the local HTML file to `web01`, move it into the Nginx document root, and reload Nginx.

## Deployment workflow

At first, I updated the website manually: copy the file, log in to the server, move it into `/var/www/html`, and reload Nginx. I replaced those manual steps with a small PowerShell script on the main PC.

The workflow is:

| Step | Action |
| --- | --- |
| 1 | Edit `index.html` locally on the Windows PC |
| 2 | Use `scp` to upload it to `/tmp/index.html` on `web01` |
| 3 | Use SSH to run a remote command on `web01` |
| 4 | Copy the uploaded file into `/var/www/html/index.html` |
| 5 | Reload Nginx so the latest site is served |
| 6 | Verify the page in a browser at `http://192.168.0.70` |

This made the deployment repeatable and reduced copy-and-paste work. The script currently still requires interactive passwords, including a root password through `su`, so it is a first working version rather than a final production-style deployment process.

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
- The PowerShell deployment script uploaded the local HTML file and refreshed the website successfully.

## What I learned

- A VM can use a bridged virtual network adapter to join the local network.
- Nginx serves files from the configured document root; the name of the default page is not necessarily `index.html`.
- SSH is useful for administration, while file transfer over SSH is a practical way to deploy a small static site.
- Firewall changes should be verified from another session or client so administration access is not accidentally lost.
- A working service is not complete just because it runs; access control and testing are part of the build.
- Even a small script can turn a manual process into a repeatable deployment workflow.

## AI assistance

I used Codex to help interpret command output, suggest Nginx and UFW checks, explain errors, draft the deployment script, and write this documentation. I ran the commands, reviewed the results, and verified the server access myself.

## Next steps

- Improve the deployment process so it does not require full root access for every update.
- Decide how the VM's address will be kept stable long term.
- Add HTTPS when a domain name or local certificate plan is ready.
- Restrict administrative access further, ideally through VPN or a dedicated management network.
