## MCP Tool Composition — Three-Layer Stack

This project uses three MCP tools that compose without conflict:

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
- **Declared in**: GLOBAL `~/.claude/settings.json` hooks (NOT project .mcp.json)

### How They Compose

```
Request flow:
  cachebro reduces token cost (passive, always on)
    → codemogger finds relevant code (active, for search queries)
      → memelord recalls context from past sessions (automatic, via hooks)
```

No conflicts — each layer operates at a different level:
- cachebro = I/O optimization
- codemogger = code discovery
- memelord = episodic memory
