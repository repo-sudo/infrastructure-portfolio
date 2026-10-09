# Restore-test evidence

No historical terminal transcripts or measured recovery timings are included here. The project README records the earlier reported outcome; the collector is newly authored and has not been executed on the lab server.

On the isolated restored VM, run:

```bash
sudo bash ../scripts/collect-dns-evidence.sh dns-restore-evidence
```

Use the correct script path for where you copied it. The script writes command output, UTC timestamps and exit codes to a new private directory. It does not change the service or reconnect the VM. Review files before publishing: they may contain internal addresses or host details.

Inspect each DNS response for `status: NOERROR` and the expected A record. A successful `dig` process can still return an unsuccessful DNS response. The loopback checks validate the restored service locally, not the firewall or remote-client path.

Record these separately during the next test:

| Measurement | Actual observation |
| --- | --- |
| Backup date / source VM | Not yet captured here |
| Restore start (UTC) | Not yet measured |
| First successful service validation (UTC) | Not yet measured |
| Total recovery time | Not yet measured |
| Restored VM networking | Describe actual isolation |
| Query answers | Attach reviewed actual output |
| Client-network test | Not performed by this collector |

Do not turn these placeholders into claims until the test has been performed.
