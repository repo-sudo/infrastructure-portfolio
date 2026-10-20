# AUT-003: Web server configuration and deployment with Ansible

**Status:** Tested on a dedicated Debian VM  
**Build:** 19–20 October 2026  
**Validation completed:** 20 October 2026

## Goal

Configure nginx and deploy the portfolio to an SSH-ready Debian VM from a repeatable Ansible playbook. This extends the [Debian web server project](../../projects/02-proxmox-debian-web-server/README.md) with configuration automation, rather than replacing the existing website updater.

## Environment

| Component | Role |
| --- | --- |
| `admin01`, VLAN 30 | Debian administration VM running Ansible Core 2.19.11 |
| `webtest-01`, VLAN 10 | Fresh Debian 13 test VM running nginx after deployment |
| Admin workstation | SSH access to the control VM and browser verification |
| OPNsense | Scoped access between the workstation, VLANs and external package sources |

Debian and the initial SSH/Python/sudo prerequisites were prepared manually. Ansible ran as `labadmin` on the control VM and connected as `testadmin` on the target, using an Ed25519 key protected by a passphrase. The public key was authorised on the target; the private key stayed on the control VM and was loaded into `ssh-agent`.

The control VM can be powered off between manual runs; the deployed web service runs independently.

## Files

- [deploy-web.yml](deploy-web.yml): the playbook used in the exercise.
- [inventory.example.ini](inventory.example.ini): inventory template; replace the target-address placeholder.
- [Validation record](validation.md): reported deployment, repeatability and recovery results.

## What the playbook does

1. Installs nginx, Git and CA certificates.
2. Checks out the selected website revision under `/opt/infrastructure-portfolio`.
3. Configures nginx to serve only the repository's `website/` directory.
4. Disables the default site and enables the portfolio site.
5. Validates nginx configuration with `nginx -t`.
6. Ensures nginx is running and enabled at boot.
7. Reloads nginx when its configuration changes.
8. Checks that all six website pages return HTTP 200 locally.
9. Prints the checked-out Git commit.

The inventory identifies where and how to connect. The playbook describes the desired state. The `become: true` setting allows administrative tasks through sudo; `-K` prompts for the target user's sudo password.

## Network troubleshooting

During installation, the Debian mirror name resolved, but HTTP requests timed out. OPNsense Live View showed traffic from the VLAN 10 test VM to the mirror on TCP 80 blocked by the default deny/state violation rule. An outbound HTTP allow rule resolved the installation problem.

A later Ansible HTTPS request to GitHub also timed out. Allowing HTTPS on TCP 443 for the target resolved that check. DNS success alone did not establish package-download access.

| Access | Purpose |
| --- | --- |
| Workstation → admin01, TCP 22 | Launch Ansible through SSH |
| admin01 → webtest-01, TCP 22 | Manage the target |
| Target → package sources, TCP 80 | Debian package downloads used in this exercise |
| Target → GitHub, TCP 443 | Retrieve the website repository |
| Workstation → webtest-01, TCP 80 | Browser verification |

The VM's DHCP address changed between installer and installed-system sessions. Firewall and inventory entries must use its current address. DHCP reservations were recommended but were not confirmed during this exercise.

## Run

On `admin01`, as the normal administration user:

```bash
cd ~/ansible-web
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/ansible_lab
ansible-playbook -i inventory.ini deploy-web.yml --syntax-check
ansible-playbook -i inventory.ini deploy-web.yml -K
```

The default revision is `draft`. For the repeatability and recovery tests, the deployed commit was pinned:

```bash
ansible-playbook -i inventory.ini deploy-web.yml -K -e repo_version=d605e91bb38da9cd9e504226cef3608547fdf153
```

A private-key passphrase unlocks the SSH key; the become password is the target user's sudo password. Neither belongs in the repository.

## Verified results

| Test | Result |
| --- | --- |
| Initial deployment | `ok=11 changed=6 unreachable=0 failed=0` |
| Browser check | Website worked from the admin workstation |
| Repeat run, same commit | `ok=10 changed=0 unreachable=0 failed=0` |
| nginx deliberately stopped, then playbook rerun | `ok=10 changed=1 unreachable=0 failed=0` |

All six local page checks passed during the successful runs. The zero-change repeat run demonstrated idempotence for the tested configuration. The recovery test demonstrated restoration of a stopped nginx service.

## Scope and limits

This exercise does not install Debian, create VMs, configure OPNsense, or replace AUT-001/AUT-002. It deploys website files as stored in Git and does not run the homepage generator. HTTP checks confirm responses, not exact file hashes or complete visual correctness. The checked-out commit is reported separately.

Service recovery was tested; a second full rebuild from another fresh VM was not performed. No unattended scheduling, automatic rollback or broader infrastructure recovery is claimed.
