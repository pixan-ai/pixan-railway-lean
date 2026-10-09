# Una caja Linux con Claude Code, Bun (lo pide el plugin de Telegram) y tmux.
FROM debian:bookworm-slim

RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends ca-certificates curl git tmux tzdata unzip \
 && rm -rf /var/lib/apt/lists/*

# Claude Code no corre como root con --dangerously-skip-permissions: usuario propio.
RUN useradd -m -u 1000 -s /bin/bash agente && mkdir -p /data && chown agente:agente /data

USER agente
RUN curl -fsSL https://claude.ai/install.sh | bash && curl -fsSL https://bun.sh/install | bash

USER root
COPY --chown=agente:agente workspace/ /opt/semilla/workspace/
COPY --chown=agente:agente config/ /opt/semilla/config/
COPY --chown=agente:agente entrypoint.sh /opt/semilla/entrypoint.sh

ENV HOME=/home/agente \
    PATH="/home/agente/.local/bin:/home/agente/.bun/bin:/usr/local/bin:/usr/bin:/bin" \
    TZ=America/Mexico_City \
    CLAUDE_CONFIG_DIR=/data/config \
    TELEGRAM_STATE_DIR=/data/config/channels/telegram

ENTRYPOINT ["/opt/semilla/entrypoint.sh"]
