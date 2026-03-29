#!/usr/bin/env bash
# pre-push-test.sh — Auto-detect and run tests before git push
# Hook type: PreToolUse (matcher: Bash)
# Receives tool input via stdin as JSON
# Exit 0 to allow, exit 2 to block

set -euo pipefail

# Read hook input from stdin (Claude Code passes JSON)
HOOK_INPUT=$(cat)

# Extract the bash command from JSON — portable, no jq dependency
COMMAND=$(echo "$HOOK_INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//;s/"$//')

# Only run on git push commands
if [[ "$COMMAND" != *"git push"* ]]; then
  exit 0
fi

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_ROOT"

detect_test_runner() {
  if [ -f "package.json" ]; then
    if [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ] || [ -f "vitest.config.mts" ]; then
      echo "vitest"
    elif grep -q '"vitest"' package.json 2>/dev/null; then
      echo "vitest"
    elif [ -f "jest.config.ts" ] || [ -f "jest.config.js" ] || [ -f "jest.config.mjs" ]; then
      echo "jest"
    elif grep -q '"jest"' package.json 2>/dev/null; then
      echo "jest"
    elif grep -q '"test"' package.json 2>/dev/null; then
      echo "npm-test"
    else
      echo "none"
    fi
  elif [ -f "composer.json" ]; then
    if [ -f "phpunit.xml" ] || [ -f "phpunit.xml.dist" ]; then
      if grep -q '"pestphp/pest"' composer.json 2>/dev/null || [ -d "vendor/pestphp" ]; then
        echo "pest"
      else
        echo "phpunit"
      fi
    else
      echo "none"
    fi
  elif [ -f "Cargo.toml" ]; then
    echo "cargo-test"
  elif [ -f "pyproject.toml" ] || [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
    echo "pytest"
  elif [ -f "go.mod" ]; then
    echo "go-test"
  else
    echo "none"
  fi
}

TEST_RUNNER=$(detect_test_runner)

case "$TEST_RUNNER" in
  vitest)
    echo "[test] Running Vitest..." >&2
    bunx vitest run
    ;;
  jest)
    echo "[test] Running Jest..." >&2
    bunx jest
    ;;
  npm-test)
    echo "[test] Running test script..." >&2
    bun test
    ;;
  pest)
    echo "[test] Running Pest..." >&2
    php artisan test
    ;;
  phpunit)
    echo "[test] Running PHPUnit..." >&2
    php vendor/bin/phpunit
    ;;
  cargo-test)
    echo "[test] Running cargo test..." >&2
    cargo test
    ;;
  pytest)
    echo "[test] Running pytest..." >&2
    pytest
    ;;
  go-test)
    echo "[test] Running go test..." >&2
    go test ./...
    ;;
  none)
    exit 0
    ;;
  *)
    echo "[test] Unknown test runner: $TEST_RUNNER" >&2
    exit 2
    ;;
esac || {
  echo "[test] FAILED — fix failing tests before pushing" >&2
  exit 2
}

echo "[test] passed" >&2
exit 0
