#!/usr/bin/env bash
# Arranque: volumen → revisar llaves → sembrar archivos → Claude en tmux → latido.
set -euo pipefail
NAME="${AGENT_NAME:-agente}"
WS=/data/workspace; CFG=/data/config; SEED=/opt/semilla
log() { printf '[%s] %s\n' "$NAME" "$*"; }

# 1. Railway monta /data como root; el agente corre como usuario normal.
if [ "$(id -u)" -eq 0 ]; then
  mkdir -p "$WS" "$CFG/channels/telegram" && chown -R agente:agente /data
  exec runuser -u agente -- "$0"
fi

# 2. Sin estas tres no hay agente. Solo se revisa que existan; nunca se imprimen.
for v in CLAUDE_CODE_OAUTH_TOKEN TELEGRAM_BOT_TOKEN OWNER_TELEGRAM_ID; do
  [ -n "${!v:-}" ] || { log "FALTA $v"; exit 1; }
done

# 3. Instrucciones: CLAUDE.md se recopia siempre; SOUL e IDENTITY solo si no existen.
sed "s/{{AGENT_NAME}}/$NAME/g" "$SEED/workspace/CLAUDE.md" > "$WS/CLAUDE.md"
for f in SOUL.md IDENTITY.md; do
  [ -f "$WS/$f" ] || sed "s/{{AGENT_NAME}}/$NAME/g" "$SEED/workspace/$f" > "$WS/$f"
done

# 4. Reglas: settings.json lo impone la imagen (el agente no afloja su perímetro).
cp -f "$SEED/config/settings.json" "$CFG/settings.json"
# Sin pantalla nadie acepta el "¿confías en esta carpeta?": se marca aceptado.
[ -f "$CFG/.claude.json" ] || printf '{"hasCompletedOnboarding":true,"projects":{"%s":{"hasTrustDialogAccepted":true,"hasCompletedProjectOnboarding":true}}}\n' "$WS" > "$CFG/.claude.json"

# 5. Telegram: token del bot y lista de quién puede hablarle (solo el dueño).
umask 077
printf 'TELEGRAM_BOT_TOKEN=%s\n' "$TELEGRAM_BOT_TOKEN" > "$CFG/channels/telegram/.env"
[ -f "$CFG/channels/telegram/access.json" ] || sed "s/{{OWNER}}/$OWNER_TELEGRAM_ID/" "$SEED/config/access.json" > "$CFG/channels/telegram/access.json"

# 6. Claude dentro de tmux (necesita una terminal). --continue retoma la plática anterior.
cd "$WS"
arrancar() {
  tmux kill-server 2>/dev/null || true
  tmux new-session -d -s "$NAME" claude "$@" --dangerously-skip-permissions --channels plugin:telegram@claude-plugins-official
  sleep 10; tmux has-session -t "$NAME" 2>/dev/null
}
arrancar --continue || arrancar || { log "ERROR: claude no arrancó"; exit 1; }
if tmux capture-pane -t "$NAME" -p | grep -Eq 'Do you want|Press Enter|/login|\(Y/n\)'; then
  log "ERROR: Claude se quedó esperando una respuesta en pantalla"; exit 1
fi

# 7. Latido: cada 30 s comprueba que Claude siga vivo. Si murió, exit 1 y Railway reinicia.
log "arrancó — latido cada 30s"
while sleep 30; do
  [ "$(tmux list-panes -t "$NAME" -F '#{pane_dead}' 2>/dev/null)" = "0" ] || { log "ERROR: claude murió"; exit 1; }
  date +%s > "$CFG/latido"
  log "latido OK"
done
