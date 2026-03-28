<p align="center">
  <strong>dotclaude</strong><br>
  <em>The production-grade <code>.claude/</code> scaffold for AI-native development teams.</em>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> &middot;
  <a href="#architecture">Architecture</a> &middot;
  <a href="WALKTHROUGH.md">Walkthrough</a> &middot;
  <a href="#contributing">Contributing</a> &middot;
  <a href="#license">License</a>
</p>

---

One command. Every project. A fully instrumented Claude Code environment with a three-layer MCP stack, single-purpose agents, automated quality gates, and orchestrated team workflows.

```bash
./setup.sh        # Unix/macOS
.\setup.ps1       # Windows
```

## Why dotclaude

Claude Code is powerful out of the box. But teams shipping production software need **consistency** — the same quality gates, the same agent boundaries, the same conventions — across every repository. dotclaude provides that foundation:

- **Zero-config quality gates** — linting and testing hooks fire automatically on commit and push, with auto-detection for 6+ language ecosystems
- **Single-purpose agents** — four agents following the [Stripe minions pattern](https://arxiv.org/abs/2501.12996), each with scoped permissions and clear boundaries
- **Three-layer MCP composition** — token optimization, semantic code search, and persistent vector memory working in concert
- **Team orchestration blueprints** — sequential and parallel multi-agent workflows for feature development and code review
- **Cross-platform** — native Bash and PowerShell setup scripts with `--dry-run` support

## Quick Start

```bash
git clone https://github.com/bymilon/dotclaude.git /tmp/dotclaude
cd your-project

# Copy the scaffold
cp -r /tmp/dotclaude/.claude .
cp /tmp/dotclaude/{CLAUDE.md,CLAUDE.local.md.example,.mcp.json,.gitignore,setup.sh,setup.ps1} .
rm -rf /tmp/dotclaude

# Preview before committing
chmod +x setup.sh
./setup.sh --dry-run

# Bootstrap
./setup.sh
```

Then open `CLAUDE.md` and replace the `TODO` markers with your project details.

> **Windows**: Run `.\setup.ps1` or `.\setup.ps1 -DryRun` in PowerShell.

### Prerequisites

| Dependency | Required | Install |
|-----------|----------|---------|
| Node.js (npx) | Yes | [nodejs.org](https://nodejs.org) |
| memelord | No | `npm i -g memelord` |
| codemogger | No | `npm i -g codemogger` |

Setup gracefully skips optional dependencies. MCP-dependent features degrade to built-in alternatives.

---

## Architecture

### Directory Structure

```
your-project/
  .claude/
    agents/
      architect.md        Read-only planning agent
      reviewer.md         Diff review with categorized output
      tester.md           Test writer with full tool access
      refactorer.md       Atomic refactoring with auto-revert
    commands/
      ship.md             Lint -> test -> commit -> push pipeline
      onboard.md          Codebase discovery and mental model
      review.md           Delegated code review pipeline
      kickoff.md          Feature scaffolding with architect plan
      status.md           Project health dashboard
    hooks/
      pre-commit-lint.sh  Blocks commit on lint failure
      pre-push-test.sh    Blocks push on test failure
      post-index-update.sh  Background re-index after edits
    rules/
      project-conventions.md
      vertical-slice.md
      git-workflow.md
      testing-policy.md
      mcp-usage.md
    teams/
      feature-squad.json  Sequential multi-agent workflow
      review-team.json    Parallel multi-agent workflow
    skills/
      _template/SKILL.md
    settings.json         Hook registrations + MCP config
  .mcp.json               MCP server declarations
  CLAUDE.md               Project instructions with @imports
  CLAUDE.local.md.example Personal overrides template
  setup.sh                Bootstrap (Unix/macOS)
  setup.ps1               Bootstrap (Windows)
```

### Three-Layer MCP Stack

```
Layer 1: cachebro      Transparent file caching          ~26% token savings
         Passive. Declared in .mcp.json. Always on.

Layer 2: codemogger    Tree-sitter + vector/FTS search    Semantic code intelligence
         Indexes on setup. Re-indexes automatically via post-edit hook.

Layer 3: memelord      Persistent vector memory           Cross-session knowledge
         Configured globally (~/.claude/settings.json).
         Setup creates per-project .memelord/ database.
```

Each layer is independent. Remove any layer and the system continues to function.

### Quality Gates

Hooks are registered in `.claude/settings.json` and fire automatically. Each hook inspects the tool input and runs only when relevant.

| Hook | Fires on | Behavior |
|------|----------|----------|
| `pre-commit-lint.sh` | `git commit` | Detects linter from manifest files, runs it, blocks on failure |
| `pre-push-test.sh` | `git push` | Detects test runner from manifest files, runs suite, blocks on failure |
| `post-index-update.sh` | Any file write/edit | Increments counter, re-indexes codemogger after 3+ edits (background) |

### Auto-Detected Ecosystems

Hooks and commands detect your stack automatically. No configuration required.

| Manifest | Ecosystem | Linter | Test Runner |
|----------|-----------|--------|-------------|
| `biome.json` | JavaScript / TypeScript | Biome | -- |
| `package.json` + `eslint.config.*` | JavaScript / TypeScript | ESLint | Vitest / Jest |
| `composer.json` + `pint.json` | PHP | Pint | Pest / PHPUnit |
| `Cargo.toml` | Rust | Clippy | cargo test |
| `pyproject.toml` | Python | Ruff / Black | pytest |
| `go.mod` | Go | gofmt | go test |

---

## Agents

Four single-purpose agents following the [Stripe minions pattern](https://arxiv.org/abs/2501.12996). Each agent has scoped tool permissions, a defined output contract, and clear boundaries. All are optional — commands fall back to inline execution when agents are unavailable.

| Agent | Access | Responsibility |
|-------|--------|---------------|
| **architect** | Read-only | Produces structured implementation plans: files, dependencies, sequence, risks. Never modifies code. |
| **reviewer** | Read-only | Analyzes diffs against project rules. Outputs categorized findings (Critical / Warning / Suggestion) with `file:line` references. |
| **tester** | Read + Write | Writes co-located tests following `testing-policy.md`. Runs the suite to verify. |
| **refactorer** | Read + Write | Finds all usages before changing. Atomic operations. Auto-reverts if tests fail after refactoring. |

---

## Commands

| Command | Purpose |
|---------|---------|
| `/onboard` | Systematically explore the codebase and produce a structured overview with MCP status |
| `/kickoff <feature>` | Create branch, scaffold vertical slice directory, launch architect for implementation plan |
| `/ship` | Full pipeline: lint, test, stage, commit (conventional), push |
| `/review` | Delegate to reviewer agent, present categorized findings with verdict |
| `/status` | Dashboard: git state, codebase metrics, MCP stack health |

All commands handle missing tools gracefully — they warn and continue with built-in alternatives.

---

## Team Workflows

> Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your environment or `settings.json`.

### feature-squad (Sequential)

```
architect ──> lead (gate) ──> implementer ──> tester ──> lead (review)
```

Four roles with clear handoff points. The lead gates the architect's plan before implementation begins, and reviews the final output before merge.

### review-team (Parallel)

```
                ┌── security-reviewer ──┐
lead (distribute) ── correctness-reviewer ── lead (aggregate)
                └── style-reviewer ─────┘
```

Three specialized reviewers run concurrently. The lead deduplicates findings and produces a single categorized report with a final verdict.

---

## Customization

### Project-Level

1. **`CLAUDE.md`** — Replace `TODO` markers with your project name, stack, and commands
2. **`rules/`** — Adapt conventions, testing policy, and git workflow for your stack
3. **`agents/`** — Add domain-specific agents (e.g., `migration-reviewer.md`, `api-designer.md`)
4. **`commands/`** — Add workflow shortcuts (e.g., `/deploy`, `/migrate`, `/benchmark`)

### Personal Overrides

```bash
cp CLAUDE.local.md.example CLAUDE.local.md
```

`CLAUDE.local.md` is gitignored. Use it for personal preferences, local environment details, and machine-specific paths.

### Global vs Project Layering

dotclaude is **project-level** configuration. It complements your global `~/.claude/` setup:

| Concern | Global (`~/.claude/`) | Project (`.claude/`) |
|---------|----------------------|---------------------|
| Rules | Behavior, tool preferences, memory policy | Conventions, architecture, git, testing |
| Hooks | memelord lifecycle, dream system | Lint gate, test gate, re-index |
| MCP | cachebro (global) | cachebro + codemogger (project) |
| Settings | Model, plugins, environment | Hook registrations, MCP servers, permissions |

Claude Code merges both layers automatically. Project settings take precedence.

---

## Contributing

We welcome contributions. Please read [WALKTHROUGH.md](WALKTHROUGH.md) to understand the architecture before submitting changes.

### Guidelines

- Follow the conventions in `.claude/rules/` — they apply to this repo too
- Every new hook must include tool-input guards and handle missing dependencies
- Every new agent must have scoped tool permissions and a defined output contract
- Test setup scripts on both Unix and Windows before submitting

### Reporting Issues

Open an issue at [github.com/bymilon/dotclaude/issues](https://github.com/bymilon/dotclaude/issues).

---

## License

MIT. See [LICENSE](LICENSE).

---

<p align="center">
  Built for teams that ship.
</p>
