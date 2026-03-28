# dotclaude

The standard `.claude/` folder structure for everyday development.

Drop into any project. Run `setup.sh`. Get a fully instrumented AI-native dev environment with three-layer MCP stack, pre-built agents, quality gates, and team templates.

## Prerequisites

```bash
npm install -g memelord codemogger
# npx (comes with Node.js) — for cachebro
```

## Quick Start

```bash
# Clone into your project
git clone https://github.com/your-org/dotclaude.git /tmp/dotclaude

cd your-project
cp -r /tmp/dotclaude/.claude .
cp /tmp/dotclaude/{CLAUDE.md,CLAUDE.local.md.example,.mcp.json,.gitignore,setup.sh,setup.ps1} .
rm -rf /tmp/dotclaude

# Bootstrap
chmod +x setup.sh
./setup.sh

# On Windows (PowerShell)
.\setup.ps1
```

Then edit `CLAUDE.md` — fill in your project name, stack, and commands.

## Three-Layer MCP Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| 1 - Tokens | **cachebro** | Transparent file caching, ~26% token savings |
| 2 - Code Intel | **codemogger** | Tree-sitter + vector/FTS semantic code search |
| 3 - Memory | **memelord** | Persistent vector memory with reinforcement learning |

cachebro is passive (always on). codemogger indexes your codebase. memelord fires via global hooks — no per-project config needed.

## What's Inside

```
.claude/
  agents/      4 agents (architect, reviewer, tester, refactorer)
  commands/    5 commands (/ship, /onboard, /review, /kickoff, /status)
  hooks/       3 quality gates (lint, test, index)
  rules/       5 rule files (conventions, VSA, git, testing, MCP)
  teams/       2 team templates (feature-squad, review-team)
  skills/      Skill template for custom skills
```

## Commands

| Command | What it does |
|---------|-------------|
| `/onboard` | Explore codebase, build mental model, save to memory |
| `/kickoff <name>` | Create branch, scaffold slice, get architect plan |
| `/ship` | Lint, test, commit, push — full quality pipeline |
| `/review` | Delegate to reviewer agent, categorized findings |
| `/status` | Project health dashboard (git, tests, MCP status) |

## Agents (Stripe Minions Pattern)

Single-purpose, one-shot, clear boundaries:

- **architect** — Plans features. Read-only. Never modifies files.
- **reviewer** — Reviews diffs. Categorized output (Critical/Warning/Suggestion).
- **tester** — Writes and runs co-located tests.
- **refactorer** — Atomic refactoring. Reverts if tests fail.

## Team Templates

- **feature-squad** — Sequential: architect → implementer → tester → lead review
- **review-team** — Parallel: security + correctness + style reviewers → lead aggregation

## Customization

1. **Edit CLAUDE.md** — fill in project-specific details
2. **Edit rules/** — adapt conventions for your stack
3. **Add agents/** — create domain-specific agents
4. **Add commands/** — create workflow shortcuts
5. **Copy CLAUDE.local.md.example → CLAUDE.local.md** — personal overrides (gitignored)

## Global vs Project

This template is **project-level** — it complements your global `~/.claude/` config:

- Global: behavior rules, tool preferences, memory policy, dream system
- Project: conventions, testing, git workflow, agents, commands, hooks

Claude Code merges both layers automatically.

## License

MIT
