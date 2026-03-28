#!/usr/bin/env bash
# dotclaude setup — bootstrap the three-layer MCP stack for this project
# Mirror of setup.ps1 — keep both scripts in sync
# Usage: ./setup.sh [--dry-run]

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

# ─── Parse flags ────────────────────────────────────────────

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      echo "Usage: ./setup.sh [--dry-run]"
      echo "  --dry-run  Preview actions without executing them"
      exit 0
      ;;
    *) error "Unknown flag: $1. Usage: ./setup.sh [--dry-run]" ;;
  esac
done

run() {
  if [ $DRY_RUN -eq 1 ]; then
    echo -e "  ${YELLOW}[dry-run]${NC} would run: $*"
  else
    "$@"
  fi
}

echo ""
echo "  dotclaude setup"
echo "  ==============="
if [ $DRY_RUN -eq 1 ]; then
  echo "  (dry-run mode — no changes will be made)"
fi
echo ""

# ─── Step 1: Check prerequisites ────────────────────────────

info "Checking prerequisites..."

MISSING=()
OPTIONAL_MISSING=()

command -v npx &>/dev/null || MISSING+=("npx (Node.js)")
command -v memelord  &>/dev/null || OPTIONAL_MISSING+=("memelord")
command -v codemogger &>/dev/null || OPTIONAL_MISSING+=("codemogger")

if [ ${#MISSING[@]} -gt 0 ]; then
  error "Missing required: ${MISSING[*]}. Install Node.js first."
fi

if [ ${#OPTIONAL_MISSING[@]} -gt 0 ]; then
  warn "Optional tools not found: ${OPTIONAL_MISSING[*]}"
  warn "Install with: npm install -g ${OPTIONAL_MISSING[*]}"
  warn "Continuing without them — the template still works, MCP features will be limited."
fi

info "Prerequisites checked."

# ─── Step 2: Initialize memelord ─────────────────────────────

if [[ ! " ${OPTIONAL_MISSING[*]} " =~ " memelord " ]]; then
  if [ -d ".memelord" ]; then
    info "memelord already initialized — skipping"
  else
    info "Initializing memelord (per-project vector memory)..."
    run memelord init
    info "memelord initialized."
  fi
else
  info "memelord not installed — skipping (memory features unavailable)"
fi

# ─── Step 3: Build codemogger index ──────────────────────────

if [[ ! " ${OPTIONAL_MISSING[*]} " =~ " codemogger " ]]; then
  if [ -d ".codemogger" ]; then
    info "codemogger index exists — rebuilding..."
  else
    info "Building codemogger index (tree-sitter + vector search)..."
  fi

  FILE_COUNT=$(find . -type f \
    -not -path './.git/*' \
    -not -path './.memelord/*' \
    -not -path './.codemogger/*' \
    -not -path './node_modules/*' \
    -not -path './vendor/*' \
    -not -path './.cachebro/*' | wc -l | tr -d ' ')

  if [ "$FILE_COUNT" -gt 10000 ]; then
    warn "Large repo ($FILE_COUNT files) — indexing may take a moment..."
  fi

  run codemogger index . --verbose 2>/dev/null || run codemogger index . || warn "codemogger index failed — you can re-run manually"

  info "codemogger index built."
else
  info "codemogger not installed — skipping (code intelligence unavailable)"
fi

# ─── Step 4: Create CLAUDE.local.md ──────────────────────────

if [ -f "CLAUDE.local.md" ]; then
  info "CLAUDE.local.md already exists — skipping"
else
  run cp "CLAUDE.local.md.example" "CLAUDE.local.md"
  info "Created CLAUDE.local.md from example."
fi

# ─── Step 5: Ensure .gitignore entries ───────────────────────

GITIGNORE="$PROJECT_ROOT/.gitignore"
ENTRIES=("CLAUDE.local.md" ".memelord/" ".codemogger/" ".cachebro/")

for entry in "${ENTRIES[@]}"; do
  if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
    run bash -c "echo '$entry' >> '$GITIGNORE'"
  fi
done

info ".gitignore verified."

# ─── Step 6: Set hook permissions ────────────────────────────

run chmod +x .claude/hooks/*.sh
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

if [ ${#OPTIONAL_MISSING[@]} -gt 0 ]; then
  warn "Reminder: install optional tools for full functionality:"
  warn "  npm install -g ${OPTIONAL_MISSING[*]}"
  echo ""
fi
