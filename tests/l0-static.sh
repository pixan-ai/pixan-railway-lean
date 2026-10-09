#!/usr/bin/env bash
# L0 — static checks. Nothing runs; files are only read.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=tests/lib.sh
. tests/lib.sh

check "shellcheck: shell scripts" shellcheck -x entrypoint.sh tests/*.sh tests/stubs/claude
check "hadolint: Dockerfile" hadolint --failure-threshold warning Dockerfile
for f in config/*.json; do check "valid JSON: $f" python3 -m json.tool "$f"; done
for f in $(git ls-files -co --exclude-standard '*.yml' '*.yaml'); do
  check "valid YAML: $f" python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' "$f"
done
check "CLAUDE.md imports @SOUL.md"     grep -qx '@SOUL.md' workspace/CLAUDE.md
check "CLAUDE.md imports @IDENTITY.md" grep -qx '@IDENTITY.md' workspace/CLAUDE.md
check "gitleaks: no secrets in history" gitleaks git --no-banner --redact .
finish L0
