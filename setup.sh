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

command -v bun &>/dev/null || MISSING+=("bun (https://bun.sh)")
command -v memelord  &>/dev/null || OPTIONAL_MISSING+=("memelord")
command -v codemogger &>/dev/null || OPTIONAL_MISSING+=("codemogger")

if [ ${#MISSING[@]} -gt 0 ]; then
  error "Missing required: ${MISSING[*]}. Install Node.js first."
fi

if [ ${#OPTIONAL_MISSING[@]} -gt 0 ]; then
  warn "Optional tools not found: ${OPTIONAL_MISSING[*]}"
  warn "Install with: bun add -g ${OPTIONAL_MISSING[*]}"
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

# ─── Step 4: TypeScript — opensrc (exact-version npm source) ─

if [ -f "package.json" ]; then
  info "Fetching npm package source for AI agent context (opensrc)..."

  TS_PACKAGES=("hono" "zod" "drizzle-orm" "@sveltejs/kit" "@hono/zod-validator" "vite" "vitest")
  FETCHED=()

  for pkg in "${TS_PACKAGES[@]}"; do
    # Check if package is in package.json (strip scope for grep)
    PKG_KEY="${pkg//\//\\/}"
    if grep -q "\"$PKG_KEY\"" package.json 2>/dev/null; then
      if [ -d "opensrc/${pkg##*/}" ]; then
        info "  opensrc/${pkg##*/} already exists — skipping"
      else
        info "  Fetching $pkg source..."
        run bunx opensrc "$pkg" 2>/dev/null \
          && FETCHED+=("$pkg") \
          || warn "  opensrc $pkg failed — skipping (install manually: bunx opensrc $pkg)"
      fi
    fi
  done

  if [ ${#FETCHED[@]} -gt 0 ]; then
    info "Fetched source for: ${FETCHED[*]}"
    info "codemogger will index opensrc/ on next file change."
  else
    info "No matching packages found in package.json — skipping opensrc."
  fi
else
  info "No package.json found — skipping opensrc (TypeScript step)."
fi

# ─── Step 5: Rust — framework source for codemogger indexing ──

if [ -f "Cargo.toml" ]; then
  info "Fetching Rust framework source for codemogger indexing..."

  RUST_CRATES=("gpui" "dioxus" "leptos" "tauri" "axum" "actix-web")
  RUST_SRC_DIR="rust-src"
  RUST_FETCHED=()

  # Ensure crates are in local registry
  run cargo fetch --quiet 2>/dev/null || warn "cargo fetch failed — registry may be incomplete"

  mkdir -p "$RUST_SRC_DIR"

  for crate in "${RUST_CRATES[@]}"; do
    # Check if crate is in Cargo.toml
    if grep -q "\"$crate\"\\|$crate = " Cargo.toml 2>/dev/null; then
      if [ -d "$RUST_SRC_DIR/$crate" ]; then
        info "  rust-src/$crate already exists — skipping"
      else
        # Find exact version in cargo registry cache
        SRC=$(find "$HOME/.cargo/registry/src" -maxdepth 2 \
          -name "${crate}-[0-9]*" -type d 2>/dev/null \
          | sort -V | tail -1)

        if [ -n "$SRC" ]; then
          run cp -r "$SRC" "$RUST_SRC_DIR/$crate"
          RUST_FETCHED+=("$crate")
          info "  Fetched $crate → rust-src/$crate/"
        else
          warn "  $crate not found in cargo registry — run 'cargo fetch' first"
        fi
      fi
    fi
  done

  if [ ${#RUST_FETCHED[@]} -gt 0 ]; then
    info "Rust source fetched: ${RUST_FETCHED[*]}"
    info "Re-indexing codemogger to include rust-src/..."
    if [[ ! " ${OPTIONAL_MISSING[*]} " =~ " codemogger " ]]; then
      run codemogger index . --quiet 2>/dev/null || run codemogger index . || warn "codemogger reindex failed"
    fi
  else
    info "No matching Rust framework crates found in Cargo.toml — skipping."
    rmdir "$RUST_SRC_DIR" 2>/dev/null || true
  fi
else
  info "No Cargo.toml found — skipping Rust source fetch."
fi

# ─── Step 6: Create CLAUDE.local.md ──────────────────────────

if [ -f "CLAUDE.local.md" ]; then
  info "CLAUDE.local.md already exists — skipping"
else
  run cp "CLAUDE.local.md.example" "CLAUDE.local.md"
  info "Created CLAUDE.local.md from example."
fi

# ─── Step 7: Ensure .gitignore entries ───────────────────────

GITIGNORE="$PROJECT_ROOT/.gitignore"
ENTRIES=("CLAUDE.local.md" ".memelord/" ".codemogger/" ".cachebro/" "opensrc/" "rust-src/")

for entry in "${ENTRIES[@]}"; do
  if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
    run bash -c "echo '$entry' >> '$GITIGNORE'"
  fi
done

info ".gitignore verified."

# ─── Step 8: Set hook permissions ────────────────────────────

run chmod +x .claude/hooks/*.sh
info "Hook scripts made executable."

# ─── Done ────────────────────────────────────────────────────

echo ""
info "Setup complete. Your MCP stack is ready:"
echo ""
echo "  Layer 1 — cachebro    Token optimization (passive, always on)"
echo "  Layer 2 — codemogger  Code intelligence (semantic + FTS search)"
echo "  Layer 3 — memelord    Persistent memory (automatic via hooks)"
echo "  Layer 4 — context-mode  Context window management (active)"
echo ""
echo "  Source context:"
echo "    opensrc/   npm package source at exact locked versions (TypeScript)"
echo "    rust-src/  Rust framework source indexed by codemogger"
echo ""
echo "  Commands available:"
echo "    /onboard   — discover this project"
echo "    /kickoff   — start a new feature"
echo "    /feature   — implement a vertical slice"
echo "    /fix       — diagnose and fix a bug"
echo "    /debug     — systematic fault isolation"
echo "    /ship      — lint, test, commit, push"
echo "    /deploy    — environment-first deployment"
echo "    /review    — parallel 3-agent code review"
echo "    /debate    — red/blue adversarial design review"
echo "    /consensus      — stochastic ensemble for architecture decisions"
echo "    /status         — health dashboard"
echo "    /memory-review  — audit and prune both memory layers"
echo ""

if [ ${#OPTIONAL_MISSING[@]} -gt 0 ]; then
  warn "Reminder: install optional tools for full functionality:"
  warn "  bun add -g ${OPTIONAL_MISSING[*]}"
  echo ""
fi
