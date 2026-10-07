#!/usr/bin/env bash
# Gera dist/kronos-implementation.zip para upload no claude.ai e no ChatGPT.
# O zip contém a pasta kronos-implementation/ na raiz, com SKILL.md e references/.
set -euo pipefail

SKILL_NAME="kronos-implementation"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_PARENT="$REPO_ROOT/plugins/$SKILL_NAME/skills"
OUT_DIR="$REPO_ROOT/dist"
OUT_FILE="$OUT_DIR/$SKILL_NAME.zip"

if [ ! -f "$SKILL_PARENT/$SKILL_NAME/SKILL.md" ]; then
  echo "Erro: SKILL.md não encontrado em $SKILL_PARENT/$SKILL_NAME" >&2
  echo "Rode antes: bash scripts/sync-from-crm.sh" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
rm -f "$OUT_FILE"

(cd "$SKILL_PARENT" && zip -r -q "$OUT_FILE" "$SKILL_NAME" -x '*.DS_Store' -x '*/evals/*')

echo "Gerado: $OUT_FILE"
unzip -l "$OUT_FILE"
