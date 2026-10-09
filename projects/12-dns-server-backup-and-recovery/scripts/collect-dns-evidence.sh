#!/usr/bin/env bash
# Newly authored evidence collector; does not modify BIND or networking.
set -uo pipefail
umask 077
if [[ $# -gt 1 ]]; then
  echo "Usage: bash collect-dns-evidence.sh [output-directory]" >&2
  exit 2
fi
out="${1:-dns-evidence-$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -- "$out" || exit 1
failed=0
run_check() {
  local label="$1"
  shift
  {
    printf 'Timestamp (UTC): '
    date -u +%FT%TZ
    printf 'Command:'
    printf ' %q' "$@"
    printf '\n'
    "$@"
    result=$?
    printf '\nExit code: %s\n' "$result"
    exit "$result"
  } > "$out/$label.txt" 2>&1
  local result=$?
  if (( result != 0 )); then
    printf 'FAILED: %s (exit %s)\n' "$label" "$result" >&2
    failed=1
  fi
}
run_check service systemctl status bind9 --no-pager
run_check configuration named-checkconf
run_check zone named-checkzone internal /etc/bind/db.internal
for name in web hch dns; do
  run_check "query-$name" dig +time=2 +tries=1 @127.0.0.1 "$name.internal" A
done
printf 'Evidence saved in: %s\n' "$out"
printf 'Inspect DNS status and answers: dig exit code alone does not prove correctness.\n'
exit "$failed"
