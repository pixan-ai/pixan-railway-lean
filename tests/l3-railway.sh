#!/usr/bin/env bash
# L3 — optional helper for the runtime checklist (tests/README.md).
# Run it from a folder linked with `railway link` to the agent's service.
set -uo pipefail
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

logs="$(railway logs 2>&1 | tail -n 200)"
check "boot reached the heartbeat"  grep -q 'started — heartbeat every' <<<"$logs"
check "recent heartbeat OK"         grep -q 'heartbeat OK' <<<"$(tail -n 20 <<<"$logs")"
check "no MISSING key"              absent MISSING "$logs"
check "no ERROR in recent logs"     absent ERROR "$(tail -n 50 <<<"$logs")"
echo "Now do the human checks in tests/README.md (L3): only a real reply proves it is alive."
finish L3
