#!/usr/bin/env bash
# pre-push-test.sh — Auto-detect and run tests before git push
# Hook type: PreToolUse (matcher: Bash matching "git push")
# Exit 1 to block the push on test failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

run_tests() {
  if [ -f "$PROJECT_ROOT/package.json" ]; then
    if grep -q '"test"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      echo "[test] Running package.json test script..."
      cd "$PROJECT_ROOT" && bun test 2>/dev/null || npx vitest run 2>/dev/null || npx jest 2>/dev/null
    else
      echo "[test] No test script in package.json — skipping"
      exit 0
    fi
  elif [ -f "$PROJECT_ROOT/composer.json" ]; then
    echo "[test] Running PHP tests..."
    cd "$PROJECT_ROOT" && php artisan test 2>/dev/null || php vendor/bin/phpunit 2>/dev/null
  elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
    echo "[test] Running cargo test..."
    cd "$PROJECT_ROOT" && cargo test
  elif [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
    echo "[test] Running pytest..."
    cd "$PROJECT_ROOT" && pytest
  else
    echo "[test] No test runner detected — skipping"
    exit 0
  fi
}

run_tests
TEST_EXIT=$?

if [ $TEST_EXIT -ne 0 ]; then
  echo "[test] FAILED — fix failing tests before pushing"
  exit 1
fi

echo "[test] passed"
exit 0
