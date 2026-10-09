#!/usr/bin/env bash
# Boot: volume → check keys → seed files → Claude in tmux → heartbeat.
set -euo pipefail
NAME="${AGENT_NAME:-agent}"
LANGUAGE="${AGENT_LANGUAGE:-Spanish from Mexico, using tú (never voseo: vos, tenés, querés, decime)}"
DATA="${DATA_DIR:-/data}"; SEED="${SEED_DIR:-/opt/seed}"
WS="$DATA/workspace"; CFG="$DATA/config"
log() { printf '[%s] %s\n' "$NAME" "$*"; }
t() { tmux -L "$NAME" "$@"; }   # own tmux server per agent: never touches anyone else's
fill() { sed -e "s|{{AGENT_NAME}}|$NAME|g" -e "s|{{AGENT_LANGUAGE}}|$LANGUAGE|g" "$1"; }

# 1. Railway mounts the volume as root; the agent runs as a normal user.
if [ "$(id -u)" -eq 0 ]; then
  mkdir -p "$WS" "$CFG/channels/telegram" && chown -R agent:agent "$DATA"
  exec runuser -u agent -- "$0"
fi
mkdir -p "$WS" "$CFG/channels/telegram"

# 2. No agent without these three. Only presence is checked; values are never printed.
for v in CLAUDE_CODE_OAUTH_TOKEN TELEGRAM_BOT_TOKEN OWNER_TELEGRAM_ID; do
  [ -n "${!v:-}" ] || { log "MISSING $v"; exit 1; }
done

# 3. Instructions: CLAUDE.md is rewritten every boot; SOUL and IDENTITY only if missing.
fill "$SEED/workspace/CLAUDE.md" > "$WS/CLAUDE.md"
for f in SOUL.md IDENTITY.md; do
  [ -f "$WS/$f" ] || fill "$SEED/workspace/$f" > "$WS/$f"
done

# 4. Rules: the image imposes settings.json every boot (the agent can't loosen its own fence).
cp -f "$SEED/config/settings.json" "$CFG/settings.json"
# Nobody is at the screen to accept "Do you trust this folder?", so it is pre-accepted.
[ -f "$CFG/.claude.json" ] || printf '{"hasCompletedOnboarding":true,"projects":{"%s":{"hasTrustDialogAccepted":true,"hasCompletedProjectOnboarding":true}}}\n' "$WS" > "$CFG/.claude.json"

# 5. Telegram: bot token, and who may talk to the bot (only the owner, first boot only).
umask 077
printf 'TELEGRAM_BOT_TOKEN=%s\n' "$TELEGRAM_BOT_TOKEN" > "$CFG/channels/telegram/.env"
[ -f "$CFG/channels/telegram/access.json" ] || sed "s|{{OWNER}}|$OWNER_TELEGRAM_ID|" "$SEED/config/access.json" > "$CFG/channels/telegram/access.json"

# 6. Claude inside tmux (it needs a terminal). --continue resumes the previous conversation.
cd "$WS"
start() {
  t kill-server 2>/dev/null || true
  t new-session -d -s "$NAME" claude "$@" --dangerously-skip-permissions --channels plugin:telegram@claude-plugins-official
  sleep "${BOOT_WAIT_SEC:-10}"; t has-session -t "$NAME" 2>/dev/null
}
start --continue || start || { log "ERROR: claude did not start"; exit 1; }
if t capture-pane -t "$NAME" -p | grep -Eq 'Do you want|Press Enter|/login|\(Y/n\)'; then
  log "ERROR: claude is stuck waiting for input on screen"; exit 1
fi

# 7. Heartbeat: check Claude is alive. If it died, exit 1 and Railway restarts the container.
log "started — heartbeat every ${HEARTBEAT_SEC:-30}s"
while sleep "${HEARTBEAT_SEC:-30}"; do
  [ "$(t list-panes -t "$NAME" -F '#{pane_dead}' 2>/dev/null)" = "0" ] || { log "ERROR: claude died"; exit 1; }
  date +%s > "$CFG/heartbeat"
  log "heartbeat OK"
done
