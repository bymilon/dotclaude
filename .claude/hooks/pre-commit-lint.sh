#!/usr/bin/env bash
# pre-commit-lint.sh — Auto-detect and run linter before git commit
# Hook type: PreToolUse (matcher: Bash matching "git commit")
# Exit 1 to block the commit on lint failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

run_lint() {
  if [ -f "$PROJECT_ROOT/package.json" ]; then
    if grep -q '"lint"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      echo "[lint] Running npm/bun lint script..."
      cd "$PROJECT_ROOT" && npx --yes eslint --fix . 2>/dev/null || bun run lint 2>/dev/null
    elif command -v prettier &>/dev/null; then
      echo "[lint] Running prettier..."
      cd "$PROJECT_ROOT" && npx prettier --write --check .
    fi
  elif [ -f "$PROJECT_ROOT/composer.json" ]; then
    echo "[lint] Running Laravel Pint..."
    cd "$PROJECT_ROOT" && php vendor/bin/pint --dirty
  elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
    echo "[lint] Running cargo clippy..."
    cd "$PROJECT_ROOT" && cargo clippy --fix --allow-dirty --allow-staged
  elif [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
    echo "[lint] Running ruff..."
    cd "$PROJECT_ROOT" && ruff check --fix .
  else
    echo "[lint] No linter detected — skipping"
    exit 0
  fi
}

run_lint
LINT_EXIT=$?

if [ $LINT_EXIT -ne 0 ]; then
  echo "[lint] FAILED — fix lint errors before committing"
  exit 1
fi

echo "[lint] passed"
exit 0
