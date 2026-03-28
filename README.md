# dotclaude

The standard `.claude/` folder structure for everyday development.

Drop into any project. Run `setup.sh`. Get a fully instrumented AI-native dev environment with three-layer MCP stack, pre-built agents, quality gates, and team templates.

## Prerequisites

```bash
# Required
node.js (for npx)

# Optional — enhances but not required
npm install -g memelord codemogger
```

The template works without memelord and codemogger — setup will skip them gracefully and MCP-dependent features will degrade to built-in alternatives.

## Quick Start

```bash
# Clone into your project
git clone https://github.com/bymilon/dotclaude.git /tmp/dotclaude

cd your-project
cp -r /tmp/dotclaude/.claude .
cp /tmp/dotclaude/{CLAUDE.md,CLAUDE.local.md.example,.mcp.json,.gitignore,setup.sh,setup.ps1} .
rm -rf /tmp/dotclaude

# Preview what setup will do
chmod +x setup.sh
./setup.sh --dry-run

# Bootstrap
./setup.sh

# On Windows (PowerShell)
.\setup.ps1            # or: .\setup.ps1 -DryRun
```

Then edit `CLAUDE.md` — replace the `TODO` placeholders with your project name, stack, and commands.

## Three-Layer MCP Stack

| Layer | Tool | Purpose | Required? |
|-------|------|---------|-----------|
| 1 - Tokens | **cachebro** | Transparent file caching, ~26% token savings | Included via `.mcp.json` |
| 2 - Code Intel | **codemogger** | Tree-sitter + vector/FTS semantic code search | Optional (`npm i -g codemogger`) |
| 3 - Memory | **memelord** | Persistent vector memory with reinforcement learning | Optional (`npm i -g memelord`) |

cachebro is passive (always on via `.mcp.json`). codemogger indexes your codebase locally. memelord provides persistent memory — it's configured globally in `~/.claude/settings.json` hooks, so it fires across all projects automatically. The setup script only creates the per-project `.memelord/` database.

## What's Inside

```
.claude/
  agents/      4 agents (architect, reviewer, tester, refactorer)
  commands/    5 commands (/ship, /onboard, /review, /kickoff, /status)
  hooks/       3 quality gates (lint, test, index) — wired in settings.json
  rules/       5 rule files (conventions, VSA, git, testing, MCP)
  teams/       2 team templates (feature-squad, review-team)
  skills/      Skill template for custom skills
  settings.json  Hook registrations + MCP server config
```

## Commands

| Command | What it does |
|---------|-------------|
| `/onboard` | Explore codebase, build mental model, check MCP status |
| `/kickoff <name>` | Create branch, scaffold vertical slice, get architect plan |
| `/ship` | Lint, test, commit, push — full quality pipeline |
| `/review` | Delegate to reviewer agent, categorized findings |
| `/status` | Project health dashboard (git, tests, MCP status) |

All commands gracefully handle missing MCP tools — they'll warn and continue with built-in alternatives.

## Quality Gate Hooks

Hooks are registered in `.claude/settings.json` and fire automatically:

| Hook | Trigger | What it does |
|------|---------|-------------|
| `pre-commit-lint.sh` | `git commit` | Auto-detects linter (ESLint, Biome, Pint, Clippy, Ruff, gofmt), blocks on failure |
| `pre-push-test.sh` | `git push` | Auto-detects test runner (Vitest, Jest, Pest, PHPUnit, Cargo, pytest, Go), blocks on failure |
| `post-index-update.sh` | File write/edit | Re-indexes codemogger after 3+ edits (background, non-blocking) |

## Agents (Stripe Minions Pattern)

Single-purpose, one-shot, clear boundaries. All agents are optional — commands fall back to inline execution if agents can't be spawned.

- **architect** — Plans features. Read-only. Never modifies files. Produces structured plans with files, deps, sequence, risks.
- **reviewer** — Reviews diffs. Outputs categorized findings (Critical/Warning/Suggestion) with file:line references.
- **tester** — Writes and runs co-located tests. Full write access. Follows testing-policy.md.
- **refactorer** — Atomic refactoring. Finds all usages before changing. Reverts if tests fail.

## Team Templates

> **Requires**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your shell or `settings.json` env section.

- **feature-squad** — Sequential: architect → lead gate → implementer → tester → lead review
- **review-team** — Parallel: lead distributes → [security + correctness + style] → lead aggregates

These are blueprints for `TeamCreate` — not runtime configs. Reference them from `/kickoff` or create teams manually.

## Auto-Detected Stacks

The hooks and commands auto-detect your project stack by checking for manifest files:

| Detection File | Stack | Linter | Test Runner |
|---------------|-------|--------|-------------|
| `biome.json` | JS/TS | Biome | — |
| `package.json` + `eslint.config.*` | JS/TS | ESLint | Vitest/Jest/npm test |
| `composer.json` + `pint.json` | PHP | Pint | Pest/PHPUnit |
| `Cargo.toml` | Rust | Clippy | cargo test |
| `pyproject.toml` | Python | Ruff/Black | pytest |
| `go.mod` | Go | gofmt | go test |

## Customization

1. **Edit CLAUDE.md** — fill in project-specific TODOs
2. **Edit rules/** — adapt conventions for your stack
3. **Add agents/** — create domain-specific agents
4. **Add commands/** — create workflow shortcuts
5. **Copy CLAUDE.local.md.example → CLAUDE.local.md** — personal overrides (gitignored, created by setup)

## Global vs Project

This template is **project-level** — it complements your global `~/.claude/` config:

| Concern | Global (`~/.claude/`) | Project (`.claude/`) |
|---------|----------------------|---------------------|
| Rules | Behavior, tool prefs, stack, memory policy | Conventions, VSA, git, testing, MCP usage |
| Hooks | memelord lifecycle, dream system | Lint gate, test gate, codemogger re-index |
| MCP | cachebro (global) | cachebro + codemogger (project `.mcp.json`) |
| Settings | Model, plugins, env vars | MCP enablement, hook registrations, permissions |

Claude Code merges both layers automatically. Project settings override global where they overlap.

## License

MIT
