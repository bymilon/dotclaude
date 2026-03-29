---
description: Audit both memory layers — file-based and memelord DB — surface stale, contradictory, or outdated entries for pruning. Usage: /memory-review
allowed-tools: Read, Glob, Grep, Bash(sqlite3:*), Bash(git log:*), Bash(ls:*)
---

## Memory Review — Audit Both Memory Layers

Surface stale, contradictory, and outdated memories across both the file-based system and memelord. Read-only — flag issues, do not auto-delete. Human confirms each change.

### Layer 1 — File-Based Memory (`memory/`)

1. Read `memory/MEMORY.md` index — check for broken links (entries pointing to non-existent files)
2. For each `memory/*.md` file:
   - Check frontmatter: `name`, `description`, `type` fields present and non-empty
   - Check body: does content still match the description?
   - Check for contradictions: do any two files assert conflicting facts?
   - Check staleness: does any `project` or `decision` type memory reference dates, deadlines, or states that are clearly past?
3. Flag entries that need action — do NOT delete yet

### Layer 2 — memelord DB (`.memelord/memory.db`)

If `.memelord/memory.db` exists, inspect recent entries:

```bash
sqlite3 .memelord/memory.db "SELECT id, memory, created_at FROM memories ORDER BY created_at DESC LIMIT 30;"
```

Check for:
- Duplicate or near-duplicate memories (same fact stored twice)
- Memories that contradict a current file-based memory
- Very old memories (>30 days) that reference a project no longer active

### Output

Produce a triage report in this format:

```
Memory Review
=============

File-based memory: N files
  [OK]    filename.md — {one-line summary}
  [STALE] filename.md — reason (e.g., "project deadline passed 2025-01")
  [CONFLICT] fileA.md ↔ fileB.md — what contradicts
  [BROKEN] MEMORY.md entry "Title" → file does not exist

memelord DB: N memories (last 30 days)
  [OK]    {memory excerpt}
  [DUPE]  {memory A} ≈ {memory B}
  [STALE] {memory excerpt} — reason

Actions needed:
  1. Delete memory/stale-file.md + remove from MEMORY.md
  2. Update memory/outdated.md — {what to change}
  3. Run: memelord contradict <id> — {which memelord memory}

No action needed if all entries are [OK].
```

### After Review

For each flagged item, ask the user to confirm before making any change:
> "Found N items needing attention. Review each? (yes to proceed one by one)"

Only edit files or call `memory_contradict` after explicit user confirmation per item.
