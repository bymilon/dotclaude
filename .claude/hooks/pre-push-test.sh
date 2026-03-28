#!/usr/bin/env bash
# pre-push-test.sh — Auto-detect and run tests before git push
# Hook type: PreToolUse (matcher: Bash matching "git push")
# Exit 1 to block the push on test failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_ROOT"

# --- Detect test runner ---

detect_test_runner() {
  # JavaScript/TypeScript ecosystem
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
  # PHP ecosystem
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
  # Rust
  elif [ -f "Cargo.toml" ]; then
    echo "cargo-test"
  # Python
  elif [ -f "pyproject.toml" ] || [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
    echo "pytest"
  # Go
  elif [ -f "go.mod" ]; then
    echo "go-test"
  else
    echo "none"
  fi
}

TEST_RUNNER=$(detect_test_runner)

# --- Run detected test runner ---

case "$TEST_RUNNER" in
  vitest)
    echo "[test] Running Vitest..."
    npx vitest run
    ;;
  jest)
    echo "[test] Running Jest..."
    npx jest
    ;;
  npm-test)
    echo "[test] Running test script..."
    if command -v bun &>/dev/null; then
      bun test
    else
      npm test
    fi
    ;;
  pest)
    echo "[test] Running Pest..."
    php artisan test
    ;;
  phpunit)
    echo "[test] Running PHPUnit..."
    php vendor/bin/phpunit
    ;;
  cargo-test)
    echo "[test] Running cargo test..."
    cargo test
    ;;
  pytest)
    echo "[test] Running pytest..."
    pytest
    ;;
  go-test)
    echo "[test] Running go test..."
    go test ./...
    ;;
  none)
    echo "[test] No test runner detected — skipping"
    exit 0
    ;;
esac

TEST_EXIT=$?

if [ $TEST_EXIT -ne 0 ]; then
  echo ""
  echo "[test] FAILED — fix failing tests before pushing"
  exit 1
fi

echo "[test] passed"
exit 0
