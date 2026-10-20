# AUT-003 validation record

Results below were supplied from the user's lab execution on 20 October 2026.

Website revision: `d605e91bb38da9cd9e504226cef3608547fdf153`  
Control: `admin01`, Ansible Core 2.19.11  
Target: `webtest-01`, Debian 13

| Check | Evidence |
| --- | --- |
| Ansible privilege escalation | Ad hoc `whoami` returned `root` |
| Target GitHub connectivity | Initial HTTPS timeout; successful after a scoped TCP 443 allow rule |
| First deployment | `ok=11 changed=6 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0` |
| HTTP verification | index, projects, automation, topology, lab-notes and about returned HTTP 200 locally |
| Workstation browser verification | User confirmed the test website worked |
| Same-commit repeatability | `ok=10 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0` |
| Service recovery | nginx stopped through SSH; rerun returned `ok=10 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0` |

The first run included a notified nginx reload handler; the unchanged second run did not. Service recovery changed only the service-start task.

A reconnect initially left the terminal in the home directory, so Ansible could not find `deploy-web.yml`. Returning to `~/ansible-web` and reloading the SSH key allowed the test to continue.

Not verified: a second fresh-VM rebuild, DHCP reservations, rollback, exact served-file hash matching or automated visual checks.
