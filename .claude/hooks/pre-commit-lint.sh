#!/usr/bin/env bash
# pre-commit-lint.sh — Auto-detect and run linter before git commit
# Hook type: PreToolUse (matcher: Bash matching "git commit")
# Exit 1 to block the commit on lint failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_ROOT"

# --- Detect linter ---

detect_linter() {
  # JavaScript/TypeScript ecosystem
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
  # PHP ecosystem
  elif [ -f "composer.json" ]; then
    if [ -f "pint.json" ] || [ -d "vendor/laravel/pint" ]; then
      echo "pint"
    elif [ -f ".php-cs-fixer.php" ] || [ -f ".php-cs-fixer.dist.php" ]; then
      echo "php-cs-fixer"
    else
      echo "none"
    fi
  # Rust
  elif [ -f "Cargo.toml" ]; then
    echo "clippy"
  # Python
  elif [ -f "pyproject.toml" ] || [ -f "ruff.toml" ]; then
    if command -v ruff &>/dev/null; then
      echo "ruff"
    elif command -v black &>/dev/null; then
      echo "black"
    else
      echo "none"
    fi
  # Go
  elif [ -f "go.mod" ]; then
    echo "gofmt"
  else
    echo "none"
  fi
}

LINTER=$(detect_linter)

# --- Run detected linter ---

case "$LINTER" in
  biome)
    echo "[lint] Running Biome..."
    npx @biomejs/biome check --write .
    ;;
  eslint)
    echo "[lint] Running ESLint..."
    npx eslint --fix .
    ;;
  prettier)
    echo "[lint] Running Prettier..."
    npx prettier --write --check .
    ;;
  npm-lint)
    echo "[lint] Running lint script..."
    if command -v bun &>/dev/null; then
      bun run lint
    else
      npm run lint
    fi
    ;;
  pint)
    echo "[lint] Running Laravel Pint..."
    php vendor/bin/pint --dirty
    ;;
  php-cs-fixer)
    echo "[lint] Running PHP CS Fixer..."
    php vendor/bin/php-cs-fixer fix --dry-run --diff
    ;;
  clippy)
    echo "[lint] Running cargo clippy..."
    cargo clippy --fix --allow-dirty --allow-staged
    ;;
  ruff)
    echo "[lint] Running ruff..."
    ruff check --fix .
    ;;
  black)
    echo "[lint] Running black..."
    black --check .
    ;;
  gofmt)
    echo "[lint] Running gofmt..."
    gofmt -l -w .
    ;;
  none)
    echo "[lint] No linter detected — skipping"
    exit 0
    ;;
esac

LINT_EXIT=$?

if [ $LINT_EXIT -ne 0 ]; then
  echo ""
  echo "[lint] FAILED — fix lint errors before committing"
  exit 1
fi

echo "[lint] passed"
exit 0
