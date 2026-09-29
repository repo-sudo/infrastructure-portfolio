# Windows Server domain controller migration

**Status:** Complete

## Overview

I moved the domain-controller workload for `elephant.test` from DC01, a VMware Windows Server VM, to DC02 on Proxmox. The migration involved more than promoting a replacement server: the VMs were on different virtual networks, Windows Firewall interfered with connectivity tests, and DNS locator records had to work before Active Directory replication could stay healthy.

The lab models **Elephant SA**, a fictional company, with the Active Directory domain `elephant.test`. Its directory represents company users and security groups, along with the domain computer accounts needed by its client machines. The migration had to preserve access to this directory data while moving the domain-controller role; it did not involve real company or employee data.

## Network topology and reachability

DC01 was attached to VMware's host-only VMnet network (VMnet2). DC02 ran on the Proxmox host and used a Proxmox bridge. A host-only network and a Proxmox bridge are separate network segments unless there is a bridge, route, or other connection between them.

During troubleshooting, the PC selected its Wi-Fi interface and sent traffic for DC02 (10.10.10.20) through the home router instead of VMnet2. That route did not reach the lab subnet. I traced the problem to the network path between the hypervisors and bridged the VM connectivity so the controllers could communicate across the lab. This was a prerequisite for checking domain services; having IP addresses alone did not prove the two VMs could reach each other.

## Firewall and connectivity checks

Windows Firewall also blocked inbound ping during the network checks. I added a scoped inbound ICMPv4 rule for the lab subnet:

```powershell
New-NetFirewallRule -DisplayName "Allow ICMPv4 from VMware Lab" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -RemoteAddress 10.10.10.0/24
```

After the rule was applied, the host at 10.10.10.1 could ping DC01 at 10.10.10.10. This made ping useful as a basic reachability check. ICMP was only a diagnostic check; it did not by itself open DNS or the RPC services Active Directory needs.

## DNS, RPC, and replication troubleshooting

Once there was a network path, I worked through the domain-service failures. Replication reported error 8524, a DNS lookup failure. The DC locator record `7e522019-057f-459f-811e-4599177db012._msdcs.elephant.test` was missing from DNS, so the source controller's name could not be resolved and replication could not proceed. KCC also reported repeated replication failures.

I corrected the DNS and RPC communication issues and rechecked replication. A successful diagnostic run showed 0 of 5 replication failures for both DCs, and `dcdiag` reported that DC02 passed the Replications test. I used `repadmin /replsummary` and `dcdiag` to distinguish directory health from a simple ping test.

## Migration steps

1. Added DC02 as a new domain controller in `elephant.test`.
2. Connected the VMware and Proxmox VMs so they could communicate, then resolved the DNS, RPC, and replication faults.
3. Transferred all five FSMO roles to DC02.
4. Joined a client to the domain and confirmed domain access.
5. Demoted DC01 cleanly.
6. Confirmed DC02 was the only domain controller for `elephant.test`.

## Verification

- `repadmin /replsummary` showed 0 of 5 replication failures for each controller during a successful validation run.
- `dcdiag` reported that DC02 passed the Replications test.
- `netdom query fsmo` showed all five FSMO roles on `dc02.elephant.test`.
- A client joined the domain successfully.
- DC01 was demoted, leaving DC02 as the sole domain controller.

## What I learned

- VMware host-only networking and a Proxmox bridge do not automatically create a shared network. I had to trace the selected route and provide a working path between the VM networks.
- A firewall can make a working network path look broken. A scoped ICMP rule helped test reachability, while DNS and RPC still needed their own troubleshooting.
- Active Directory replication depends on resolvable DNS locator records as well as network connectivity. Error 8524 pointed to the missing DNS record.
- Ping is not proof of healthy AD replication. I checked replication with `repadmin` and `dcdiag` before moving roles and demoting DC01.
- The replacement controller should be validated with a client before the original controller is retired.

## AI assistance

I used Codex to explain commands, interpret diagnostic output, troubleshoot the lab, and help draft this documentation. I ran the commands and performed the configuration and validation in my lab.
