#!/usr/bin/env bash
# Pruebas que corren sin secretos. Las de "vivo de verdad" están en README (paso 3).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== L1: el script de arranque está bien escrito =="
bash -n entrypoint.sh && shellcheck entrypoint.sh tests/aceptacion.sh
for f in config/*.json; do python3 -m json.tool "$f" >/dev/null || { echo "JSON roto: $f"; exit 1; }; done

echo "== L1: CLAUDE.md sí carga el alma =="
grep -qx '@SOUL.md' workspace/CLAUDE.md && grep -qx '@IDENTITY.md' workspace/CLAUDE.md

echo "== L1: no hay secretos en el repo =="
git grep -nE '[0-9]{8,10}:[A-Za-z0-9_-]{35}|sk-ant-' -- . ':!tests/aceptacion.sh' && { echo 'posible secreto'; exit 1; }

if command -v docker >/dev/null; then
  echo "== L2: la imagen se construye y se niega a arrancar sin llaves =="
  docker build -t lean:ci .
  set +e; out="$(docker run --rm lean:ci 2>&1)"; code=$?; set -e
  echo "$out (exit=$code)"
  [ "$code" -ne 0 ] && grep -q FALTA <<<"$out"
fi
echo "aceptación OK"
