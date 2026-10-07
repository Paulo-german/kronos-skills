#!/usr/bin/env bash
# Espelha a skill kronos-implementation do repositório privado kronos-crm
# para dentro do plugin. A fonte da verdade é o kronos-crm; não edite a skill aqui.
#
# Uso: bash scripts/sync-from-crm.sh
# Variável opcional: KRONOS_CRM_DIR (padrão: /Users/paulororiz/Dev/kronos-crm)
set -euo pipefail

KRONOS_CRM_DIR="${KRONOS_CRM_DIR:-/Users/paulororiz/Dev/kronos-crm}"
SKILL_NAME="kronos-implementation"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$KRONOS_CRM_DIR/skills/$SKILL_NAME"
DEST="$REPO_ROOT/plugins/$SKILL_NAME/skills/$SKILL_NAME"

if [ ! -f "$SRC/SKILL.md" ]; then
  echo "Erro: skill não encontrada em $SRC" >&2
  echo "Defina KRONOS_CRM_DIR com o caminho do repositório kronos-crm." >&2
  exit 1
fi

mkdir -p "$DEST"

echo "Origem:  $SRC"
echo "Destino: $DEST"
echo "---"

rsync -a --delete --itemize-changes \
  --exclude 'evals/' \
  --exclude '.DS_Store' \
  "$SRC/" "$DEST/"

echo "---"
echo "Sincronização concluída. Revise com: git status"
