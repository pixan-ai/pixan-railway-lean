# A Linux box with Claude Code, Bun (required by the Telegram plugin) and tmux.
FROM debian:bookworm-slim@sha256:7c7b2c966bc9ee8cedfeef67e0e279108992c77681fa595db4a9d65c06ccc587
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Base image is pinned by digest; pinning each apt package would break on Debian point releases.
# hadolint ignore=DL3008
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends ca-certificates curl git tmux tzdata unzip \
 && rm -rf /var/lib/apt/lists/*

ENV HOME=/home/agent \
    PATH="/home/agent/.local/bin:/home/agent/.bun/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    TZ=America/Mexico_City \
    CLAUDE_CONFIG_DIR=/data/config \
    TELEGRAM_STATE_DIR=/data/config/channels/telegram

# Claude Code refuses --dangerously-skip-permissions as root: use a normal user.
RUN useradd -m -u 1000 -s /bin/bash agent && mkdir -p /data && chown agent:agent /data

USER agent
RUN curl -fsSL https://claude.ai/install.sh | bash && curl -fsSL https://bun.sh/install | bash \
 && claude --version && bun --version

# Back to root only so the entrypoint can chown the volume; it then drops to `agent`.
# hadolint ignore=DL3002
USER root
COPY --chown=agent:agent workspace/ /opt/seed/workspace/
COPY --chown=agent:agent config/ /opt/seed/config/
COPY --chown=agent:agent entrypoint.sh /opt/seed/entrypoint.sh

ENTRYPOINT ["/opt/seed/entrypoint.sh"]
