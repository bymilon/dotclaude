#!/usr/bin/env bash
# pre-commit-lint.sh — Auto-detect and run linter before git commit
# Hook type: PreToolUse (matcher: Bash)
# Receives tool input via stdin as JSON
# Exit 0 to allow, exit 2 to block

set -euo pipefail

# Read hook input from stdin (Claude Code passes JSON)
HOOK_INPUT=$(cat)

# Extract the bash command from JSON — portable, no jq dependency
COMMAND=$(echo "$HOOK_INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//;s/"$//')

# Only run on git commit commands
if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_ROOT"

detect_linter() {
  if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
    echo "biome"
  elif [ -f "package.json" ]; then
    if [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.cjs" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ] || [ -f "eslint.config.ts" ]; then
      echo "eslint"
    elif grep -q '"eslint"' package.json 2>/dev/null; then
      echo "eslint"
    elif grep -q '"prettier"' package.json 2>/dev/null; then
      echo "prettier"
    elif grep -q '"lint"' package.json 2>/dev/null; then
      echo "npm-lint"
    else
      echo "none"
    fi
  elif [ -f "composer.json" ]; then
    if [ -f "pint.json" ] || [ -d "vendor/laravel/pint" ]; then
      echo "pint"
    elif [ -f ".php-cs-fixer.php" ] || [ -f ".php-cs-fixer.dist.php" ]; then
      echo "php-cs-fixer"
    else
      echo "none"
    fi
  elif [ -f "Cargo.toml" ]; then
    echo "clippy"
  elif [ -f "pyproject.toml" ] || [ -f "ruff.toml" ]; then
    if command -v ruff &>/dev/null; then
      echo "ruff"
    elif command -v black &>/dev/null; then
      echo "black"
    else
      echo "none"
    fi
  elif [ -f "go.mod" ]; then
    echo "gofmt"
  else
    echo "none"
  fi
}

LINTER=$(detect_linter)

case "$LINTER" in
  biome)
    echo "[lint] Running Biome..." >&2
    npx @biomejs/biome check --write .
    ;;
  eslint)
    echo "[lint] Running ESLint..." >&2
    npx eslint --fix .
    ;;
  prettier)
    echo "[lint] Running Prettier..." >&2
    npx prettier --write --check .
    ;;
  npm-lint)
    echo "[lint] Running lint script..." >&2
    if command -v bun &>/dev/null; then
      bun run lint
    else
      npm run lint
    fi
    ;;
  pint)
    echo "[lint] Running Laravel Pint..." >&2
    php vendor/bin/pint --dirty
    ;;
  php-cs-fixer)
    echo "[lint] Running PHP CS Fixer..." >&2
    php vendor/bin/php-cs-fixer fix --dry-run --diff
    ;;
  clippy)
    echo "[lint] Running cargo clippy..." >&2
    cargo clippy --fix --allow-dirty --allow-staged
    ;;
  ruff)
    echo "[lint] Running ruff..." >&2
    ruff check --fix .
    ;;
  black)
    echo "[lint] Running black..." >&2
    black --check .
    ;;
  gofmt)
    echo "[lint] Running gofmt..." >&2
    gofmt -l -w .
    ;;
  none)
    exit 0
    ;;
  *)
    echo "[lint] Unknown linter: $LINTER" >&2
    exit 2
    ;;
esac || {
  echo "[lint] FAILED — fix lint errors before committing" >&2
  exit 2
}

echo "[lint] passed" >&2
exit 0
