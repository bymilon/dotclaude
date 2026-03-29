---
description: Project health dashboard — git, tests, lint, and MCP tool status
allowed-tools: Read, Glob, Grep, Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(ls:*), Bash(wc:*), Bash(memelord:*), Bash(codemogger:*)
---

## Status — Project Health Dashboard

Gather project health information and present a formatted dashboard. Read-only — do not modify anything.

### Checks

**Git**
- Current branch: `git branch --show-current`
- Uncommitted changes: `git status --short`
- Recent commits: `git log --oneline -5`
- Remote status: `git remote -v`

**Codebase**
- File count by type: glob for `*.ts`, `*.tsx`, `*.php`, `*.rs`, `*.py`
- Slice count: list directories in `app/` or `src/`
- Test file count: glob for `*.test.*`, `*.spec.*`, `*Test.php`

**MCP Stack** (all optional — report status without failing)
- cachebro: check if listed in `.mcp.json` → `active` or `not configured`
- codemogger: if command exists, check `.codemogger/` → `indexed` / `needs indexing`. If command not found → `not installed`
- memelord: if command exists, check `.memelord/` → `initialized` / `needs init`. If command not found → `not installed`
- context-mode: check if `ctx_batch_execute` MCP tool is available → `active` or `not configured`

**Source Context** (built by setup.sh — improves AI API accuracy)
- opensrc/: check if directory exists → `present (N packages)` or `not fetched`
- rust-src/: check if directory exists → `present (N crates)` or `not fetched`

> If any MCP tool or source directory is missing, report it as a suggestion, not an error.

### Output Format

```
Project Status Dashboard
========================

Git
  Branch:     {branch}
  Changes:    {N} modified, {N} untracked
  Last commit: {hash} {message} ({time ago})

Codebase
  Files:      {N} source, {N} tests
  Slices:     {list}

MCP Stack
  cachebro:     {active/missing}
  codemogger:   {indexed/needs indexing} ({N} chunks)
  memelord:     {initialized/needs init} ({N} memories)
  context-mode: {active/not configured}

Source Context
  opensrc/:  {present (N packages)/not fetched}
  rust-src/: {present (N crates)/not fetched}

{any warnings or recommendations}
```
