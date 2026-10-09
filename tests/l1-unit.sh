#!/usr/bin/env bash
# L1 — the entrypoint on this machine, with a stub `claude` and a temp volume.
# Needs bash and tmux; no Docker, no network, no real keys.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=tests/lib.sh
. tests/lib.sh

tmp="$(mktemp -d)"; trap 'tmux -L "lean-l1-$$" kill-server 2>/dev/null; rm -rf "$tmp"' EXIT
export PATH="$PWD/tests/stubs:$PATH" SEED_DIR="$PWD" DATA_DIR="$tmp/data" TMUX_TMPDIR="$tmp" \
       AGENT_NAME="lean-l1-$$" BOOT_WAIT_SEC=1 HEARTBEAT_SEC=1
keys=(CLAUDE_CODE_OAUTH_TOKEN=fake-claude TELEGRAM_BOT_TOKEN=fake-bot OWNER_TELEGRAM_ID=42)
boot() { env "$@" ./entrypoint.sh > "$tmp/out" 2>&1; }

boot STUB_CLAUDE=exit
check "no keys: fails fast with MISSING" grep -q 'MISSING CLAUDE_CODE_OAUTH_TOKEN' "$tmp/out"
check "no keys: writes nothing" test ! -e "$DATA_DIR/workspace/CLAUDE.md"

boot "${keys[@]}" STUB_CLAUDE=exit
check "dead claude: exits with error" grep -q 'ERROR: claude did not start' "$tmp/out"
check "CLAUDE.md gets the agent name" grep -q "You are \*\*lean-l1-$$\*\*" "$DATA_DIR/workspace/CLAUDE.md"
check "CLAUDE.md gets the default language" grep -q 'Spanish from Mexico' "$DATA_DIR/workspace/CLAUDE.md"
check "SOUL.md seeded" grep -q "SOUL — lean-l1-$$" "$DATA_DIR/workspace/SOUL.md"
check "owner in allowlist" grep -q '"42"' "$DATA_DIR/config/channels/telegram/access.json"
check "bot token file is private" test "$(stat -c %a "$DATA_DIR/config/channels/telegram/.env")" = 600

echo "edited by owner" > "$DATA_DIR/workspace/SOUL.md"
echo "stale" > "$DATA_DIR/workspace/CLAUDE.md"
echo '{"allowFrom":["7"]}' > "$DATA_DIR/config/channels/telegram/access.json"
echo '{}' > "$DATA_DIR/config/settings.json"
boot "${keys[@]}" STUB_CLAUDE=exit AGENT_LANGUAGE=English
check "SOUL.md is not overwritten" grep -qx 'edited by owner' "$DATA_DIR/workspace/SOUL.md"
check "CLAUDE.md is regenerated" grep -q '@SOUL.md' "$DATA_DIR/workspace/CLAUDE.md"
check "AGENT_LANGUAGE is applied" grep -q 'Talk to people in English.' "$DATA_DIR/workspace/CLAUDE.md"
check "access.json is not overwritten" grep -q '"7"' "$DATA_DIR/config/channels/telegram/access.json"
check "settings.json is re-imposed" grep -q 'telegram@claude-plugins-official' "$DATA_DIR/config/settings.json"

boot "${keys[@]}" STUB_CLAUDE=prompt
check "stuck on a prompt: exits with error" grep -q 'stuck waiting for input' "$tmp/out"

# Alive, then killed: the heartbeat must notice (zombie != alive).
env "${keys[@]}" ./entrypoint.sh > "$tmp/out" 2>&1 & pid=$!
for _ in $(seq 1 20); do grep -q 'heartbeat OK' "$tmp/out" && break; sleep 0.5; done
check "alive: heartbeat OK" grep -q 'heartbeat OK' "$tmp/out"
check "alive: heartbeat file is fresh" test $(( $(date +%s) - $(cat "$DATA_DIR/config/heartbeat") )) -le 2
kill "$(tmux -L "$AGENT_NAME" list-panes -F '#{pane_pid}')"
for _ in $(seq 1 20); do kill -0 "$pid" 2>/dev/null || break; sleep 0.5; done
kill "$pid" 2>/dev/null; wait "$pid"; code=$?   # a heartbeat that never notices gets killed here
check "claude killed: exit 1" test "$code" -eq 1
check "claude killed: says so" grep -q 'ERROR: claude died' "$tmp/out"
finish L1
