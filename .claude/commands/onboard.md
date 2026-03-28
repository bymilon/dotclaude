---
description: Bootstrap understanding of this project — read everything, build mental model, save to memory
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git remote:*), Bash(ls:*), Bash(wc:*)
---

## Onboard — Project Discovery

Explore the codebase systematically and produce a structured overview. Do not modify any files.

### Step 1 — Read Configuration

1. Read `CLAUDE.md` and all `@imported` rule files
2. Read `package.json` / `composer.json` / `Cargo.toml` / `pyproject.toml` (whichever exists)
3. Read `.mcp.json` for active MCP servers
4. Read `.env.example` if present (never read `.env`)

### Step 2 — Map the Codebase

1. List the top-level directory structure (`ls -la`)
2. For vertical slice projects: list all slices in `app/` or `src/`
3. Identify entry points (`app.ts`, `index.ts`, `main.rs`, `artisan`, etc.)
4. Count files by type: `*.ts`, `*.php`, `*.rs`, `*.py`, etc.
5. Check for test infrastructure: test config files, test directories

### Step 3 — Understand History

1. `git log --oneline -20` — recent development activity
2. `git remote -v` — where code is hosted
3. Check for CI/CD config: `.github/workflows/`, `Dockerfile`, etc.

### Step 4 — Check MCP Stack

1. memelord: check if `.memelord/` exists (memory initialized?)
2. codemogger: check if `.codemogger/` exists (code indexed?)
3. cachebro: already active if listed in `.mcp.json`

### Output

Produce a structured summary:

```markdown
# Project Overview: {name}

## Stack
{framework} + {language} + {database} + {runtime}

## Structure
{N} slices: {list slice names}
{N} core modules: {list}
{N} test files ({coverage estimate})

## Entry Points
- {path} — {purpose}

## Key Patterns
- {pattern observed} — {example}

## MCP Status
- cachebro: {active/missing}
- codemogger: {indexed/needs indexing}
- memelord: {initialized/needs init}

## Recommendations
- {any setup steps needed}
- {any conventions that should be documented}
```
