# Windows Server domain controller migration

**Status:** The FSMO role transfer is complete. Post-migration DNS and replication validation remains open.

## Overview

I moved the lab's domain-controller workload from a VMware-based Windows Server VM to a replacement Windows Server VM on Proxmox. The goal was to introduce the new controller into the existing lab domain, transfer the operations roles, and check directory, DNS, and replication health afterward.

## Work completed

- Built the replacement Windows Server VM on Proxmox and joined it to the lab domain.
- Promoted it as a domain controller with Active Directory Domain Services and DNS.
- Transferred all five FSMO roles to the replacement controller.
- Connected remotely to run post-migration checks.
- Ran `netdom query fsmo`, `repadmin /replsummary`, and `dcdiag`.

The FSMO check confirmed that all five roles were held by the replacement controller.

## Validation findings

The role transfer completed, but the latest health checks did not show a clean migration:

- Replication checks reported DNS resolution failures between the controllers.
- Domain-controller diagnostics flagged replication, DNS-related events, and other system events for follow-up.
- The replacement controller passed several core checks, including connectivity, advertising, SYSVOL, Netlogons, and object replication in the captured run.

A successful role transfer is only one milestone. The old controller should remain available until DNS and replication are healthy and fresh validation checks pass.

## What I learned

- A domain-controller migration has separate stages: adding the replacement, transferring FSMO roles, validating DNS and replication, and retiring the old controller.
- `netdom query fsmo` confirms role ownership; it does not confirm replication health.
- `repadmin /replsummary` and `dcdiag` provide useful post-migration evidence and can expose issues that a successful role-transfer command does not.
- DNS is essential to domain-controller discovery and Active Directory replication.

## Next steps

1. Review DNS configuration and domain-controller locator records on both controllers.
2. Confirm that both controllers can resolve each other and their required DNS records.
3. Re-run `repadmin /replsummary` and `dcdiag` after correcting DNS.
4. Verify client logon, Group Policy, and DNS resolution against the replacement controller.
5. Retire the old controller only after replication is healthy and remaining domain services have been checked.

## AI assistance

I used Codex to explain commands, interpret diagnostic output, troubleshoot the lab, and help draft this documentation. I ran the commands and performed the configuration and validation in my lab.
