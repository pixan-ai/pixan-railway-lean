# pixan-railway-lean

**English** · [Español](README.es.md)

The **minimum** needed to bring a [Claude Code](https://docs.anthropic.com/claude-code) agent to life
on [Railway](https://railway.com) and have it answer you on Telegram. About 170 lines for the agent itself (tests apart), readable
in 20 minutes. Anything extra is added later, one piece at a time, and only if needed (see [DESIGN.md](DESIGN.md)).

## What's here

```
Dockerfile            The box: Debian + Claude Code + Bun (needed by the Telegram plugin) + tmux
railway.toml          Build with the Dockerfile; if it dies, bring it back up
entrypoint.sh         The 7-step boot (read it: it's commented)
config/settings.json  Claude's rules: Telegram plugin, deny list, Mexico City clock
config/access.json    Who may message the bot: only the owner
workspace/CLAUDE.md   The agent's instructions; imports @SOUL.md and @IDENTITY.md
workspace/SOUL.md     Personality (written once; then it belongs to the owner)
workspace/IDENTITY.md Fixed facts: name, channel, time zone
tests/                Acceptance pipeline L0–L3 (see tests/README.md)
```

## Create a new agent

1. **Claude credential.** On your computer run `claude setup-token`, log in and copy the token
   (valid for one year). Don't paste it into any chat or file.
2. **Telegram bot.** Talk to [@BotFather](https://t.me/BotFather), send `/newbot`, pick a name and
   username, and copy the bot token.
3. **Your Telegram ID.** Message [@userinfobot](https://t.me/userinfobot): it replies with a number.
4. **Railway.** New Project → Deploy from GitHub repo → this repo. On the service:
   - A **volume** mounted at **`/data`** (memory, conversation, soul and allowlist live there).
   - **Variables:**

     | Variable | Value | Required |
     |---|---|---|
     | `CLAUDE_CODE_OAUTH_TOKEN` | token from step 1 | yes |
     | `TELEGRAM_BOT_TOKEN` | token from step 2 | yes |
     | `OWNER_TELEGRAM_ID` | number from step 3 | yes |
     | `AGENT_NAME` | the agent's name, lowercase | no (`agent`) |
     | `AGENT_LANGUAGE` | language it talks in, plain text | no (Spanish from Mexico, *tú*) |
5. **Deploy.** If a key is missing, the log says `MISSING …` and stops. That's on purpose.

Secrets live **only** in Railway Variables, never in this repo.

## Acceptance

`./tests/l0-static.sh` and `./tests/l1-unit.sh` run on any Linux box; CI also runs the Docker layer.
Once deployed, the real proof is the L3 checklist in [tests/README.md](tests/README.md):
**message it and get an answer.** The heartbeat only proves the process exists, not that it's alive.

## License

[MIT](LICENSE). Security issues: see [SECURITY.md](SECURITY.md).
