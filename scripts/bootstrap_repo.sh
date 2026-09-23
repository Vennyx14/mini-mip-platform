#!/usr/bin/env bash
set -euo pipefail

# Phase 0 repository foundation bootstrap.
# Run this from the directory where you want the mini-MIP repository created.

REPO_DIR="${1:-mini-mip-platform}"

if [[ -e "$REPO_DIR" ]]; then
  echo "Refusing to overwrite existing path: $REPO_DIR" >&2
  exit 1
fi

mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

git init -b main

mkdir -p \
  apps/api \
  src/mip/{catalog,control,integrations,services,models,storage} \
  configs/{profiles,environments} \
  deployments/{mlflow,kserve,litellm} \
  docs/{decisions,harness/{context,build,code_review}} \
  research/experiments \
  scripts \
  tests/{unit,integration,e2e} \
  .github/workflows

# Track otherwise-empty directories.
find configs deployments docs/decisions docs/harness research/experiments tests -type d \
  -exec sh -c 'touch "$1/.gitkeep"' _ {} \;

touch apps/__init__.py apps/api/__init__.py \
  src/mip/__init__.py src/mip/catalog/__init__.py src/mip/control/__init__.py \
  src/mip/integrations/__init__.py src/mip/services/__init__.py \
  src/mip/models/__init__.py src/mip/storage/__init__.py

cat <<'MSG'
Repository directories created.

Next copy the Phase 0 root files into the repository:
- AGENTS.md
- CLAUDE.md
- README.md
- pyproject.toml
- .env.example
- .gitignore
- tests/test_smoke.py
- apps/api/main.py
- docs/*

Then run:
  python -m pytest
  git status --short
MSG
