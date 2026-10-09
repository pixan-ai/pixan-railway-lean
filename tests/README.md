# Acceptance pipeline

Each layer trusts the one below it and checks one thing more. CI runs L0, L1 and L2 on every PR;
`main` only accepts green PRs.

| Layer | Script | Needs | Proves |
|---|---|---|---|
| L0 static | `l0-static.sh` | shellcheck, hadolint, gitleaks, python3 + PyYAML | Scripts and Dockerfile lint clean, JSON/YAML parse, CLAUDE.md imports `@SOUL.md` and `@IDENTITY.md`, no secrets in git history |
| L1 unit | `l1-unit.sh` | bash, tmux | The entrypoint, run here with a stub `claude`: fails fast on missing keys, regenerates CLAUDE.md, seeds SOUL/IDENTITY/allowlist only once, re-imposes settings, stops on a blocking prompt, and the heartbeat exits 1 when claude dies |
| L2 docker | `l2-docker.sh` | Docker | The real image builds, refuses to boot without keys, reaches tmux + heartbeat with fake keys and a stub `claude` (no network), runs as a non-root user, and exits 1 when claude is killed |
| L3 runtime | `l3-railway.sh` + checklist below | Railway CLI linked to the service, a phone | The deployed agent is alive, not a zombie |

The stub (`stubs/claude`) stands in for Claude Code so no test needs a real token.

## L3 checklist (after each deploy that matters)

1. `./tests/l3-railway.sh` from a folder linked to the service: boot reached the heartbeat, recent
   `heartbeat OK`, no `MISSING`, no recent `ERROR`.
2. Message the bot "who are you?". It answers within a minute, with its name and in its language.
   **This is the only proof it's alive and not a zombie**: a frozen Claude still has a heartbeat.
3. From another Telegram account, the bot doesn't answer; it only offers a pairing code.
4. Redeploy, then ask "what were we talking about?". It remembers (`--continue` + the `/data` volume).
