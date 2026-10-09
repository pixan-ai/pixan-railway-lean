# Security policy

## Reporting a vulnerability

Please **don't open a public issue**. Report it privately through
[GitHub private vulnerability reporting](https://github.com/pixan-ai/pixan-railway-lean/security/advisories/new).
We aim to acknowledge reports within 7 days and will keep you updated until it's resolved.

## Supported versions

Only the latest release and `main` receive fixes.

## Scope notes

- Never include real tokens, Telegram IDs or personal data in reports, issues or PRs.
- The agent runs Claude Code with `--dangerously-skip-permissions` inside its container; the
  container, the deny rules in `config/settings.json` and the owner-only Telegram allowlist are the
  boundary. Reports that cross that boundary are especially welcome.
