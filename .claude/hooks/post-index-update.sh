#!/usr/bin/env bash
# post-index-update.sh — Re-index codemogger after significant file changes
# Hook type: PostToolUse (matcher: Write|Edit)
# Runs in background — never blocks the session

set -uo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.codemogger/.edit-count"
THRESHOLD=3

# Only proceed if codemogger is initialized
if [ ! -d "$PROJECT_ROOT/.codemogger" ]; then
  exit 0
fi

# Increment edit counter
COUNT=0
if [ -f "$STATE_FILE" ]; then
  COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$STATE_FILE"

# Re-index after threshold edits
if [ "$COUNT" -ge "$THRESHOLD" ]; then
  echo "[codemogger] Re-indexing after $COUNT file changes..."
  cd "$PROJECT_ROOT" && codemogger index . --quiet &
  echo "0" > "$STATE_FILE"
fi

exit 0
