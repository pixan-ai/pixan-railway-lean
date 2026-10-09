# Contributing

Thanks for helping. This repo's whole point is to stay **minimal and readable**, so:

1. **Open an issue first** for anything beyond a small fix, and explain why it's needed.
2. **Smallest change that works.** No speculative features, no refactors on the side.
3. **Tests by layer** (see [tests/README.md](tests/README.md)): run `./tests/l0-static.sh` and
   `./tests/l1-unit.sh` locally; CI runs L2 with Docker. A behavior change comes with a test.
4. **English** in code, comments, logs, commits and PRs. The agent's conversation language is set
   with `AGENT_LANGUAGE`.
5. **No secrets** or personal data, ever. Gitleaks runs in CI; GitHub push protection is on.
6. Add a line to `CHANGELOG.md` under `Unreleased` if users would notice.

`main` is protected: changes land through pull requests with green CI.
By contributing you agree your work is licensed under the [MIT License](LICENSE) and you follow the
[Code of Conduct](CODE_OF_CONDUCT.md).
