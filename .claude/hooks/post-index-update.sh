#!/usr/bin/env bash
# post-index-update.sh — Re-index codemogger after significant file changes
# Hook type: PostToolUse (matcher: Write|Edit)
# Runs in background — never blocks the session

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_DIR="$PROJECT_ROOT/.codemogger"
STATE_FILE="$STATE_DIR/.edit-count"
LOCK_FILE="$STATE_DIR/.reindex-lock"
THRESHOLD=3

# Only proceed if codemogger is initialized and directory is writable
if [ ! -d "$STATE_DIR" ] || [ ! -w "$STATE_DIR" ]; then
  exit 0
fi

# Increment edit counter (atomic append + count to avoid race conditions)
echo -n "." >> "$STATE_FILE"
COUNT=$(wc -c < "$STATE_FILE" 2>/dev/null || echo 0)

# Re-index after threshold edits
if [ "$COUNT" -ge "$THRESHOLD" ]; then
  # Skip if a reindex is already running
  if [ -f "$LOCK_FILE" ] && kill -0 "$(cat "$LOCK_FILE" 2>/dev/null)" 2>/dev/null; then
    exit 0
  fi

  echo "[codemogger] Re-indexing after $COUNT file changes..."
  : > "$STATE_FILE"
  cd "$PROJECT_ROOT" && codemogger index . --quiet &
  echo $! > "$LOCK_FILE"
fi

exit 0
