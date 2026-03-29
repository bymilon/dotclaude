## MCP Tool Composition — Four-Layer Stack

This project uses four MCP tools that compose without conflict:

### Layer 1 — cachebro (Token Optimization)

- **What**: Transparent file caching with diff tracking
- **How**: Intercepts file reads, returns `[unchanged]` or compact diffs instead of full content
- **Savings**: ~26% fewer tokens on repeated file reads
- **Usage**: Automatic — no explicit calls needed. Just read files normally.
- **Declared in**: project `.mcp.json`

### Layer 2 — codemogger (Code Intelligence)

- **What**: Tree-sitter code chunking + vector/FTS semantic search
- **How**: Indexes codebase into `.codemogger/` database, provides search MCP tools
- **Usage**: Prefer over grep for "where is X implemented?" or "find all usages of Y"
- **Index**: Built by `setup.sh`, refreshed by `post-index-update` hook after significant changes
- **Declared in**: project `.mcp.json`

### Layer 3 — memelord (Persistent Memory)

- **What**: Agentic memory system with vector search and reinforcement learning
- **How**: Hooks fire at session lifecycle events (start, tool use, stop, end)
- **Usage**: Automatic via global hooks. Memories persist across sessions.
  - `memory_start_task` — retrieves relevant memories at task start
  - `memory_report` — stores corrections, insights, user preferences
  - `memory_end_task` — rates retrieved memories, records outcome
  - `memory_contradict` — flags wrong memories for deletion
- **Database**: per-project `.memelord/memory.db` (initialized by setup.sh)
- **Inspect DB**: `sqlite3 .memelord/memory.db "SELECT memory, created_at FROM memories ORDER BY created_at DESC LIMIT 20;"`
- **Audit both layers**: run `/memory-review` to surface stale/contradictory entries across memelord + file-based memory
- **Declared in**: GLOBAL `~/.claude/settings.json` hooks (NOT project .mcp.json)

### Layer 4 — context-mode (Context Window Management)

- **What**: Sandboxed execution, FTS indexing, and context-safe file analysis
- **How**: Keeps large outputs (bash, file reads, web fetches) in a sandbox — only summaries enter context
- **Key tools**: `ctx_batch_execute`, `ctx_execute_file`, `ctx_search`, `ctx_fetch_and_index`
- **Usage**: Always prefer over raw Bash/Read for analysis. See `rules/tools.md` for hierarchy.
- **Declared in**: GLOBAL `~/.claude/settings.json` MCP servers

### Source Context Directories

Built by `setup.sh` / `setup.ps1` — indexed by codemogger for exact-version API verification:

- **`opensrc/`** — npm package source at exact locked versions (TypeScript). Use before calling any hono/zod/drizzle/etc. API.
- **`rust-src/`** — Rust framework crate source (GPUI, Dioxus, Leptos, Tauri, Axum). Use before calling any framework API.

See `rules/project-conventions.md` → Framework API Verification for usage rules.

### How They Compose

```
Request flow:
  cachebro reduces token cost (passive, always on)
    → codemogger finds relevant code (active, for search queries)
      → memelord recalls context from past sessions (automatic, via hooks)
        → context-mode keeps large outputs sandboxed (active, for analysis)
```

No conflicts — each layer operates at a different level:
- cachebro = I/O optimization
- codemogger = code discovery
- memelord = episodic memory
- context-mode = context window protection

### Harness Review Principle

When a new Claude model ships, re-examine the harness: strip what's no longer load-bearing, add what's newly possible. Run `/debate` on the current scaffold to surface candidates.

> Opus 4.6 eliminated the sprint construct (model handles coherence natively).
> The next model will eliminate something else — or unlock a pattern not yet viable.
