# Windows Server domain controller migration

**Status:** Complete

## Overview

I migrated the lab's domain-controller workload from a VMware-based Windows Server VM, DC01, to DC02 running on Proxmox. The domain is `elephant.test`.

The goal was to add the replacement controller, restore healthy replication, transfer the operations roles, verify client access, and retire the original controller cleanly.

## Migration steps

1. Added DC02 as a new domain controller in `elephant.test`.
2. Fixed the replication, DNS, and RPC issues between the controllers.
3. Transferred all five FSMO roles to DC02.
4. Joined a client to the domain.
5. Demoted DC01 cleanly.
6. Confirmed DC02 is now the only domain controller in `elephant.test`.

## Verification

- `netdom query fsmo` showed all five FSMO roles on `dc02.elephant.test`.
- Replication, DNS, and RPC issues were resolved before retiring DC01.
- A client joined the domain successfully.
- DC01 was demoted, leaving DC02 as the sole domain controller.

## What I learned

- Adding the new controller is only the first stage of a migration; replication and name resolution must work before moving roles.
- `netdom query fsmo` confirms role ownership, while replication checks provide separate evidence about directory health.
- Testing with a domain client helps verify the replacement controller in normal use.
- The old controller should be demoted only after the replacement is healthy and its role in the domain has been checked.

## AI assistance

I used Codex to explain commands, interpret diagnostic output, troubleshoot the lab, and help draft this documentation. I ran the commands and performed the configuration and validation in my lab.
