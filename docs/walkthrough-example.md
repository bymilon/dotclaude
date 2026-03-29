# dotclaude — Practical Walkthrough

## What this is

A Claude Code scaffold you drop into any project. It wires up 4 MCP tools, pre-approved permissions, git hooks, and `/commands` so you spend time shipping, not configuring.

---

## Setup (once per project)

```bash
# Clone your project, then:
git clone https://github.com/bymilon/dotclaude .claude-template
cp -r .claude-template/.claude .
cp .claude-template/.mcp.json .
cp .claude-template/setup.sh .
cp .claude-template/CLAUDE.local.md.example CLAUDE.local.md

# Windows:
.\setup.ps1

# Mac/Linux:
./setup.sh
```

`setup.sh` installs optional tools, indexes the codebase, and verifies your environment. Takes ~30 seconds.

---

## A real session — building a feature

**You open Claude Code. Silently, in the background:**
- `preflight.sh` fires — checks bun in PATH, git identity, CRLF setting
- `memelord` retrieves memories from your last session on this project
- If anything's wrong, a warning appears at the top before you type a word

**You type:**

```
/kickoff add-user-auth
```

Claude creates `feature/add-user-auth` branch, scaffolds the vertical slice:

```
app/auth/
  auth.route.ts
  auth.service.ts
  auth.repo.ts
  auth.schema.ts
  auth.types.ts
```

**You type:**

```
/feature implement JWT login endpoint
```

Claude reads the slice, writes the implementation, co-locates a test file. It doesn't touch anything outside `app/auth/`.

**Behind the scenes — the 4 layers working:**
- `cachebro` — repeated reads of `auth.service.ts` cost ~26% fewer tokens after the first read
- `codemogger` — Claude searched "where is the DB client initialized?" semantically, found `core/db.ts` in one query instead of grepping manually
- `memelord` — recalled from last session: "user prefers terse error messages in dev mode" — applied without you saying it again
- `context-mode` — ran `git log --oneline -20` in the sandbox; only the summary entered context, not 20 lines of raw output

**You type:**

```
/ship
```

Claude runs:
1. Lint (auto-detected: biome / oxlint / eslint — whichever your project has)
2. Tests (`bunx vitest run`)
3. `git add` + `git commit` + `git push`

The pre-commit hook fires automatically on the commit call — covered by the `Bash(git commit:*)` permission, no approval prompt.

---

## When a decision is hard

**Unsure: Redis sessions vs JWT?**

```
/debate Redis sessions vs JWT for this auth flow
```

Three rounds: proposer designs it → challenger attacks it → proposer defends → you get a scored ruling with VALID/PARTIAL/INVALID objections. Confidence score tells you whether to build or re-examine.

**Want a second opinion on architecture:**

```
/consensus how should we structure multi-tenant data isolation
```

Three independent agents propose solutions in parallel. You get an AGREED/MAJORITY/SPLIT map. Split items = stop and decide yourself. Agreed items = implement with confidence.

---

## When something breaks

```
/fix login returns 401 for valid credentials
```

Forces: reproduce → root cause statement → regression test → fix → verify. Claude must state the root cause *before* writing any code. Prevents the "try random things" loop.

---

## Memory across sessions

After a session where you corrected Claude:

> "Don't mock the DB in tests — we got burned when mocked tests passed but the migration failed"

`memelord` stores this. Next session, on a different feature, Claude writes integration tests against a real DB — without you repeating yourself.

Every 3 file edits, `codemogger` re-indexes in the background. By the time you ask "where does validation happen?", the answer reflects the code you just wrote.

---

## For the joining developer

```
/onboard
```

That's it. Claude reads CLAUDE.md, maps the slice structure, counts test coverage, checks MCP tool status, and produces a structured project overview. 5 minutes to context instead of 2 hours of exploration.

---

## The mental model

```
You type a /command
  → memelord injects what Claude remembered about you and this project
  → Claude works inside the vertical slice
  → cachebro makes repeated file reads cheap
  → codemogger answers "where is X?" without full-repo grep
  → context-mode keeps large outputs out of the context window
  → hooks catch lint/test failures before git commit/push
  → session ends → memelord rates what it retrieved → gets smarter next time
```

Every layer is passive or automatic. You just type commands and write code.

---

## Command reference

| Command | When to use |
|---|---|
| `/onboard` | First time in a project — build full mental model |
| `/kickoff` | Start a new feature — branch + slice scaffold |
| `/feature` | Implement a vertical slice |
| `/fix` | Known bug — root cause first, then fix |
| `/debug` | Unknown failure — systematic fault isolation |
| `/ship` | Lint + test + commit + push |
| `/deploy` | Environment-first deployment with preflight validation |
| `/review` | Parallel 3-agent code review |
| `/debate` | Red/blue adversarial design review |
| `/consensus` | Stochastic ensemble for architecture decisions |
| `/status` | Project health dashboard |
| `/memory-review` | Audit and prune both memory layers |
