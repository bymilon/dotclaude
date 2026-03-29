#!/usr/bin/env bash
# preflight.sh — SessionStart hook
# Checks environment prerequisites and injects a system_reminder if blockers detected.
# Always exits 0 — never blocks the session.

WARNINGS=()

# bun — primary package manager for this stack
if ! command -v bun &>/dev/null; then
  WARNINGS+=("bun not found in PATH — JS/TS install/run commands will fail")
fi

# git identity — commits will fail without this
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  if [ -z "$(git config user.email 2>/dev/null)" ]; then
    WARNINGS+=("git user.email not configured — commits will fail. Run: git config user.email 'you@example.com'")
  fi

  # CRLF on Windows — causes .sh scripts to fail with 'bad interpreter' errors
  AUTOCRLF=$(git config core.autocrlf 2>/dev/null || echo "unset")
  if [ "$AUTOCRLF" = "true" ]; then
    WARNINGS+=("git core.autocrlf=true — shell hook scripts may fail with CRLF line endings. Fix: git config core.autocrlf input")
  fi
fi

# codemogger — semantic search requires it in PATH
if [ -d ".codemogger" ] && ! command -v codemogger &>/dev/null; then
  WARNINGS+=("codemogger not in PATH but .codemogger/ exists — /onboard and /status MCP search will not work")
fi

# No warnings — silent exit
if [ ${#WARNINGS[@]} -eq 0 ]; then
  exit 0
fi

# Build and emit system_reminder JSON
# Join warnings into a single escaped string (no jq dependency, no sed pipeline fragility)
MSG="Preflight warnings:"
for W in "${WARNINGS[@]}"; do
  # Escape backslashes and double-quotes for JSON safety
  W_ESC="${W//\\/\\\\}"
  W_ESC="${W_ESC//\"/\\\"}"
  MSG="${MSG}\\n- ${W_ESC}"
done

printf '{"type":"system_reminder","content":"%s"}\n' "$MSG"
exit 0
