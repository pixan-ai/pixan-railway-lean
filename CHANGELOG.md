# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-08

### Added
- Minimal agent: Dockerfile, `entrypoint.sh` (7-step boot), Claude Code in tmux with the Telegram
  channel, owner-only allowlist, deny rules, Mexico City clock hook and a 30 s heartbeat.
- `CLAUDE.md` imports `@SOUL.md` and `@IDENTITY.md`; SOUL/IDENTITY are seeded once and kept.
- `AGENT_LANGUAGE` sets the conversation language (default: Spanish from Mexico, *tú*).
- Acceptance pipeline: L0 static, L1 unit (stub `claude`), L2 Docker, L3 runtime checklist.
- README in English and Spanish, DESIGN, security policy, contributing guide, code of conduct,
  issue forms, PR template, CODEOWNERS and Dependabot.

[Unreleased]: https://github.com/pixan-ai/pixan-railway-lean/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/pixan-ai/pixan-railway-lean/releases/tag/v0.1.0
