# Project 010: Remote VPN access to Home Control Hub with WireGuard

## Goal

Create secure remote access from a phone on mobile data to the Home Control Hub in VLAN 20 using OPNsense WireGuard, without exposing Frigate, cameras, or internal web interfaces directly to the internet.

The final target was limited access from `phone01` to the Home Control Hub service on `hch01`.

## Environment

| Component | Value |
| --- | --- |
| Firewall/router | OPNsense VM `fw01` |
| Upstream router | Virgin Media Hub 3 |
| OPNsense WAN endpoint | `fw01` WAN-side address behind the Virgin Hub |
| VPN technology | WireGuard |
| WireGuard instance | `wg_lab_remote` |
| WireGuard interface | `wg0` |
| WireGuard listen port | UDP `51820` |
| VPN network | Dedicated WireGuard tunnel network |
| OPNsense tunnel endpoint | `fw01` WireGuard tunnel address |
| Phone peer | `phone01` |
| Phone tunnel endpoint | `phone01` WireGuard tunnel address |
| Target service | `hch01` Frigate |
| Target endpoint | `hch01` Frigate web interface |
| Target network | VLAN 20 - Home Control Hub |

## What I Built

- Enabled WireGuard on OPNsense using a dedicated server instance.
- Created a phone peer named `phone01`.
- Configured the phone with a QR-generated WireGuard profile.
- Added a Virgin Hub port forward for UDP `51820` to `fw01`.
- Created an OPNsense WAN rule to allow inbound WireGuard traffic to the `fw01` WAN endpoint.
- Used split-tunnel routing so the phone only sends selected lab traffic through the VPN.
- Added an internal VPN firewall rule allowing `phone01` to reach Frigate on `hch01`.
- Verified the phone could open Frigate from mobile data.

## Final Traffic Path

```text
Phone on mobile data
    |
WireGuard tunnel
    |
Public IP / Virgin Hub
    |
UDP 51820 port forward
    |
fw01 WAN endpoint
    |
WireGuard tunnel on fw01
    |
VLAN 20
    |
hch01 Frigate web interface
```

## Working Rules

### Virgin Hub port forward

| Field | Value |
| --- | --- |
| Protocol | UDP |
| External port | `51820` |
| Internal address | `fw01` WAN endpoint |
| Internal port | `51820` |

### OPNsense WAN rule

| Field | Value |
| --- | --- |
| Interface | WAN |
| Protocol | UDP |
| Source | Any |
| Destination | `fw01` WAN endpoint |
| Destination port | `51820` |
| Purpose | Allow the WireGuard handshake to reach OPNsense |

The destination is the `fw01` WAN endpoint because the Virgin Hub forwards the incoming WireGuard packet to OPNsense's WAN-side address.

### OPNsense WireGuard rule

| Field | Value |
| --- | --- |
| Interface | `wg0` / WireGuard |
| Protocol | TCP |
| Source | `phone01` tunnel endpoint |
| Destination | `hch01` |
| Destination port | Frigate web interface |
| Purpose | Allow `phone01` to reach Frigate on `hch01` |

This rule is separate from the WAN rule. The WAN rule builds the VPN tunnel; the WireGuard rule controls what the VPN client can access after the tunnel is up.

## Troubleshooting

### Wrong WAN destination

The WAN rule initially used the wrong destination. The correct destination in this lab is the `fw01` WAN-side address behind the Virgin Hub.

Firewall logs confirmed when UDP `51820` traffic from the phone reached OPNsense and matched the allow rule.

### Wrong peer key

The first phone peer configuration did not match the key expected by OPNsense. WireGuard requires the peer public key on OPNsense to match the private key used by the phone profile.

Generating a fresh peer and scanning a new QR code fixed the key mismatch and produced a successful handshake.

### Missing internal VPN rule

After the handshake worked, Frigate still did not open from the phone. OPNsense logs showed traffic arriving on `wg0` from `phone01` to `hch01`, but being blocked by the default deny rule.

Adding a scoped pass rule on the WireGuard interface fixed the final access problem.

## Current Result

Remote access works from the phone over mobile data. The phone can establish a WireGuard tunnel to OPNsense and reach Frigate on `hch01` in VLAN 20 without exposing Frigate directly to the internet.

## Lessons Learned

- Port forwarding, WAN firewall rules, WireGuard peer identity, and internal VPN rules are separate parts of the same remote-access path.
- The WAN destination is the firewall endpoint receiving the WireGuard packet, not the final internal service.
- WireGuard peer keys must match exactly; a fresh QR code can be the cleanest fix when the peer state becomes confusing.
- A successful WireGuard handshake proves the tunnel is up, but it does not prove the client can reach internal services.
- Split-tunnel Allowed IPs are safer than routing all phone traffic through the VPN when only one internal service is needed.
- Firewall logs are the fastest way to separate handshake problems from internal access-rule problems.

## Next Steps

- Keep the WAN rule limited to UDP `51820`.
- Keep the phone peer limited to the internal services it needs.
- Consider adding a second peer for another trusted device instead of sharing the same phone peer.
- Export a fresh OPNsense configuration backup now that the VPN is working.
- Document any future remote-access services as separate rules rather than broad VPN access.

## AI assistance

AI was used to guide the troubleshooting process, explain the difference between WAN and WireGuard rules, and structure the documentation. The firewall, port-forwarding, WireGuard, and phone configuration changes were performed manually in the lab and verified from a phone on mobile data.
