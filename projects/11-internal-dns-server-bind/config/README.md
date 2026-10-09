# BIND reference configuration

These newly authored examples express the zone and service names documented in this project. They are not recovered originals or exports of the running server. The zone addresses are documentation placeholders, not the lab's current addresses.

## Use

1. Replace all five addresses in `db.internal.example` with the intended lab addresses.
2. Compare the zone declaration with your existing `/etc/bind/named.conf.local`; merge it rather than overwriting other zones.
3. Place the customised zone at `/etc/bind/db.internal`.
4. Validate before reloading:

```bash
sudo named-checkconf
sudo named-checkzone internal /etc/bind/db.internal
```

Only after both checks pass, reload BIND using the service name on your installation.

This example intentionally does not replace `named.conf.options`: the running server's listener addresses, recursion ACLs and forwarders were not recovered. Retain your verified settings. Allow intended clients through both BIND's query/recursion policy and OPNsense's TCP/UDP port 53 rules.

## Verify

Query the configured DNS server explicitly from a permitted client:

```bash
dig @<dns01-address> web.internal A
dig @<dns01-address> hch.internal A
dig @<dns01-address> dns.internal A
```

Compare each answer with the configured service address. A syntactically valid zone alone does not demonstrate client connectivity.
