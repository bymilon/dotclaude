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

**MCP Stack**
- cachebro: check if listed in `.mcp.json` → `active` or `missing`
- codemogger: check if `.codemogger/` directory exists → `indexed` or `needs indexing`
- memelord: check if `.memelord/` directory exists → `initialized` or `needs init`

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
  cachebro:   {active/missing}
  codemogger: {indexed/needs indexing} ({N} chunks)
  memelord:   {initialized/needs init} ({N} memories)

{any warnings or recommendations}
```
