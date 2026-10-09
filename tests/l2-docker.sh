#!/usr/bin/env bash
# L2 — the real image, with a stub `claude` mounted in front of the real one.
# Needs Docker; no network at runtime, no real keys.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=tests/lib.sh
. tests/lib.sh

img=pixan-railway-lean:test; c="lean-l2-$$"
trap 'docker rm -f "$c" >/dev/null 2>&1' EXIT
check "image builds" docker build -t "$img" .

out="$(docker run --rm "$img" 2>&1)"; code=$?
check "no keys: exit is not 0" test "$code" -ne 0
check "no keys: says MISSING" grep -q 'MISSING CLAUDE_CODE_OAUTH_TOKEN' <<<"$out"

docker run -d --name "$c" --network none \
  -e CLAUDE_CODE_OAUTH_TOKEN=fake -e TELEGRAM_BOT_TOKEN=fake -e OWNER_TELEGRAM_ID=42 \
  -e AGENT_NAME=l2 -e BOOT_WAIT_SEC=1 -e HEARTBEAT_SEC=1 \
  -e PATH="/stubs:/home/agent/.local/bin:/home/agent/.bun/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  -v "$PWD/tests/stubs:/stubs:ro" "$img" >/dev/null
for _ in $(seq 1 30); do docker logs "$c" 2>&1 | grep -q 'heartbeat OK' && break; sleep 1; done
logs="$(docker logs "$c" 2>&1)"
check "fake keys: reaches tmux and heartbeat" grep -q 'heartbeat OK' <<<"$logs"
check "runs as the agent user, not root" docker exec -u agent "$c" tmux -L l2 has-session -t l2
check "heartbeat file is written on /data" docker exec "$c" test -s /data/config/heartbeat

# Zombie != alive: kill claude and the container must exit 1 saying why.
docker exec -u agent "$c" bash -c 'kill "$(tmux -L l2 list-panes -F "#{pane_pid}")"'
code="$(timeout 20 docker wait "$c")"
check "claude killed: container exits 1" test "$code" = 1
check "claude killed: logs say so" grep -q 'ERROR: claude died' <<<"$(docker logs "$c" 2>&1)"
[ "$fail" -eq 0 ] || docker logs "$c" 2>&1 | tail -20
finish L2
