#!/usr/bin/env bash
# dotclaude setup — bootstrap the three-layer MCP stack for this project
# Usage: ./setup.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[dotclaude]${NC} $1"; }
warn()  { echo -e "${YELLOW}[dotclaude]${NC} $1"; }
error() { echo -e "${RED}[dotclaude]${NC} $1"; exit 1; }

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo ""
echo "  dotclaude setup"
echo "  ==============="
echo ""

# ─── Step 1: Check prerequisites ────────────────────────────

info "Checking prerequisites..."

MISSING=()
command -v memelord  &>/dev/null || MISSING+=("memelord")
command -v codemogger &>/dev/null || MISSING+=("codemogger")
command -v npx       &>/dev/null || MISSING+=("npx (Node.js)")

if [ ${#MISSING[@]} -gt 0 ]; then
  error "Missing: ${MISSING[*]}. Install them first:\n  npm install -g memelord codemogger\n  (npx comes with Node.js)"
fi

info "All prerequisites found."

# ─── Step 2: Initialize memelord ─────────────────────────────

if [ -d ".memelord" ]; then
  info "memelord already initialized — skipping"
else
  info "Initializing memelord (per-project vector memory)..."
  memelord init
  info "memelord initialized."
fi

# ─── Step 3: Build codemogger index ──────────────────────────

if [ -d ".codemogger" ]; then
  info "codemogger index exists — rebuilding..."
else
  info "Building codemogger index (tree-sitter + vector search)..."
fi

FILE_COUNT=$(find . -type f -not -path './.git/*' -not -path './.memelord/*' -not -path './.codemogger/*' -not -path './node_modules/*' -not -path './vendor/*' | wc -l)

if [ "$FILE_COUNT" -gt 10000 ]; then
  warn "Large repo ($FILE_COUNT files) — indexing may take a moment..."
fi

codemogger index . --verbose 2>/dev/null || codemogger index . || warn "codemogger index failed — you can re-run manually"

info "codemogger index built."

# ─── Step 4: Create CLAUDE.local.md ──────────────────────────

if [ -f "CLAUDE.local.md" ]; then
  info "CLAUDE.local.md already exists — skipping"
else
  cp "CLAUDE.local.md.example" "CLAUDE.local.md" 2>/dev/null || true
  info "Created CLAUDE.local.md from example."
fi

# ─── Step 5: Ensure .gitignore entries ───────────────────────

GITIGNORE="$PROJECT_ROOT/.gitignore"
ENTRIES=("CLAUDE.local.md" ".memelord/" ".codemogger/" ".cachebro/")

for entry in "${ENTRIES[@]}"; do
  if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
    echo "$entry" >> "$GITIGNORE"
  fi
done

info ".gitignore updated."

# ─── Step 6: Set hook permissions ────────────────────────────

chmod +x .claude/hooks/*.sh 2>/dev/null || true
info "Hook scripts made executable."

# ─── Done ────────────────────────────────────────────────────

echo ""
info "Setup complete. Your three-layer MCP stack is ready:"
echo ""
echo "  Layer 1 — cachebro    Token optimization (passive, always on)"
echo "  Layer 2 — codemogger  Code intelligence (semantic search)"
echo "  Layer 3 — memelord    Persistent memory (automatic via hooks)"
echo ""
echo "  Commands available:"
echo "    /onboard   — discover this project"
echo "    /kickoff   — start a new feature"
echo "    /ship      — lint, test, commit, push"
echo "    /review    — code review pipeline"
echo "    /status    — health dashboard"
echo ""
