<p align="center">
  <strong>dotclaude</strong><br>
  <em>The production-grade <code>.claude/</code> scaffold for AI-native development teams.</em>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> &middot;
  <a href="#architecture">Architecture</a> &middot;
  <a href="docs/walkthrough-example.md">Walkthrough</a> &middot;
  <a href="#contributing">Contributing</a> &middot;
  <a href="#license">License</a>
</p>

---

One command. Every project. A fully instrumented Claude Code environment with a four-layer MCP stack, six single-purpose agents, automated quality gates, compound engineering pipelines, and orchestrated team workflows.

```bash
./setup.sh        # Unix/macOS
.\setup.ps1       # Windows (PowerShell)
```

## Why dotclaude

Claude Code is powerful out of the box. But teams shipping production software need **consistency** — the same quality gates, the same agent boundaries, the same conventions — across every repository. dotclaude provides that foundation:

- **Zero-config quality gates** — linting and testing hooks fire automatically on commit and push, with auto-detection for 7+ language ecosystems
- **Compound engineering pipeline** — planner expands a brief into a full product spec, generator implements, evaluator grades with GAN-inspired quality scoring (PASS/ITERATE/FAIL)
- **Six single-purpose agents** — each with scoped permissions and clear boundaries, following the [Stripe minions pattern](https://arxiv.org/abs/2501.12996)
- **Four-layer MCP composition** — token optimization, semantic code search, persistent vector memory, and context window management working in concert
- **Team orchestration blueprints** — sequential and parallel multi-agent workflows for feature development and code review
- **Cross-platform** — native Bash and PowerShell setup scripts; Windows-safe hooks with `.gitattributes` LF enforcement

## Quick Start

```bash
git clone https://github.com/bymilon/dotclaude.git /tmp/dotclaude
cd your-project

# Copy the scaffold
cp -r /tmp/dotclaude/.claude .
cp /tmp/dotclaude/{CLAUDE.md,CLAUDE.local.md.example,.mcp.json,.gitignore,.gitattributes,setup.sh,setup.ps1} .
rm -rf /tmp/dotclaude

# Preview before committing
chmod +x setup.sh
./setup.sh --dry-run

# Bootstrap
./setup.sh
```

Then open `CLAUDE.md` and replace the `TODO` markers with your project details.
Copy `CLAUDE.local.md.example` to `CLAUDE.local.md` for personal overrides (gitignored).

> **Windows**: Run `.\setup.ps1` or `.\setup.ps1 -DryRun` in PowerShell.

### Prerequisites

| Dependency | Required | Install |
|-----------|----------|---------|
| bun | Yes | [bun.sh](https://bun.sh) |
| bash | Yes (Windows) | [git-scm.com](https://git-scm.com) (Git Bash) |
| memelord | Optional | `bun add -g memelord` |
| codemogger | Optional | `bun add -g codemogger` |

Setup gracefully skips optional dependencies. MCP-dependent features degrade to built-in alternatives.

---

## Architecture

### Directory Structure

```
your-project/
  .claude/
    agents/
      planner.md          Product spec expander — brief → full spec
      architect.md        Read-only implementation planner
      evaluator.md        GAN-inspired quality grader (PASS/ITERATE/FAIL)
      reviewer.md         Diff review with categorized output
      tester.md           Co-located test writer
      refactorer.md       Atomic refactoring with auto-revert
    commands/
      build.md            Compound pipeline: plan → implement → evaluate
      kickoff.md          Feature branch + spec + scaffold + architect plan
      feature.md          Vertical slice implementation
      ship.md             Lint → test → commit → push
      fix.md              Root-cause-first bug fix
      debug.md            Systematic fault isolation
      deploy.md           Environment-first deployment
      review.md           Parallel 3-agent code review
      debate.md           Red/blue adversarial design review
      consensus.md        Stochastic ensemble for architecture decisions
      onboard.md          Codebase discovery and mental model
      status.md           Project health dashboard
      memory-review.md    Audit and prune both memory layers
    hooks/
      preflight.sh        SessionStart environment check (bun, git, CRLF)
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
      feature-squad.json  Sequential 6-role pipeline
      review-team.json    Parallel 3-reviewer pipeline
      debate-team.json    Red/blue adversarial debate
      consensus-team.json Stochastic ensemble
    settings.json         Hook registrations, permissions, agent teams env
  .mcp.json               MCP server declarations
  .gitattributes          LF for .sh/.md/.json, CRLF for .ps1
  CLAUDE.md               Project instructions with @imports
  CLAUDE.local.md.example Personal overrides template
  setup.sh                Bootstrap (Unix/macOS)
  setup.ps1               Bootstrap (Windows)
  docs/
    walkthrough-example.md  Practical onboarding walkthrough
```

### Four-Layer MCP Stack

```
Layer 1: cachebro        Transparent file caching          ~26% token savings
         Passive. Declared in .mcp.json. Always on.

Layer 2: codemogger      Tree-sitter + vector/FTS search   Semantic code intelligence
         Indexes on setup. Re-indexes automatically via post-edit hook.

Layer 3: memelord        Persistent vector memory          Cross-session knowledge
         Configured globally (~/.claude/settings.json).
         Setup creates per-project .memelord/ database.

Layer 4: context-mode    Context window management         Sandboxed analysis
         Keeps large command output out of context. Use ctx_batch_execute,
         ctx_execute_file, ctx_fetch_and_index for all analysis tasks.
```

Each layer is independent. Remove any layer and the system continues to function.

> **Harness review principle:** When a new Claude model ships, re-examine the harness. Strip what's no longer load-bearing, add what's newly possible. Opus 4.6 eliminated the sprint construct — the next model will eliminate something else.

### Quality Gates

Hooks are registered in `.claude/settings.json` and fire automatically.

| Hook | Fires on | Behavior |
|------|----------|----------|
| `preflight.sh` | Session start | Checks bun, git identity, core.autocrlf — injects warning if blockers found |
| `pre-commit-lint.sh` | `git commit` | Auto-detects linter, runs it, blocks on failure |
| `pre-push-test.sh` | `git push` | Auto-detects test runner, runs suite, blocks on failure |
| `post-index-update.sh` | Any file write/edit | Re-indexes codemogger after 3+ edits (background, Windows-safe lock) |

### Auto-Detected Ecosystems

| Manifest | Ecosystem | Linter | Test Runner |
|----------|-----------|--------|-------------|
| `biome.json` | JavaScript / TypeScript | Biome | — |
| `.oxlintrc.json` | JavaScript / TypeScript | oxlint | — |
| `package.json` + `eslint.config.*` | JavaScript / TypeScript | ESLint | Vitest / Jest |
| `composer.json` + `pint.json` | PHP | Pint | Pest / PHPUnit |
| `Cargo.toml` | Rust | Clippy | cargo test |
| `pyproject.toml` | Python | Ruff / Black | pytest |
| `go.mod` | Go | gofmt | go test |

---

## Agents

Six single-purpose agents following the [Stripe minions pattern](https://arxiv.org/abs/2501.12996). Each has scoped tool permissions, a defined output contract, and clear boundaries. All commands fall back to inline execution when agents are unavailable.

| Agent | Access | Responsibility |
|-------|--------|---------------|
| **planner** | Read-only | Expands a 1-4 sentence brief into a full product spec: user stories, features, edge cases, success criteria. Never produces implementation details. |
| **architect** | Read-only | Produces structured implementation plans: files, dependencies, sequence, risks. Never modifies code. |
| **evaluator** | Read + run tests | GAN-inspired quality grading: Correctness (3×), Completeness (2×), Quality (2×), UX Coherence (1×). Calibrated to never self-dismiss findings. Outputs PASS/ITERATE/FAIL. |
| **reviewer** | Read-only | Analyzes diffs against project rules. Categorized findings (Critical / Warning / Suggestion) with `file:line` references. |
| **tester** | Read + Write | Writes co-located tests following `testing-policy.md`. Runs the suite to verify. |
| **refactorer** | Read + Write | Finds all usages before changing. Atomic operations. Auto-reverts if tests fail. |

---

## Commands

| Command | When to use |
|---------|-------------|
| `/build <description>` | Ambitious features — compound pipeline: planner → architect → generator → evaluator |
| `/kickoff <feature>` | Start any feature — branch, expand spec, scaffold slice, architect plan |
| `/feature <description>` | Focused implementation when spec is already clear |
| `/fix <description>` | Known bug — root cause statement required before any code |
| `/debug` | Unknown failure — systematic fault isolation |
| `/ship` | Lint → test → commit → push |
| `/deploy` | Environment-first deployment with preflight validation |
| `/review` | Parallel 3-agent code review (security, correctness, style) |
| `/debate <decision>` | Red/blue adversarial design review — one decision |
| `/consensus <question>` | Three independent agents → AGREED/MAJORITY/SPLIT confidence map |
| `/onboard` | First session — full codebase discovery, MCP status, structured overview |
| `/status` | Project health dashboard — git, codebase metrics, MCP stack |
| `/memory-review` | Audit and prune both memory layers (file-based + memelord DB) |

---

## Team Workflows

Agent teams are enabled automatically via `settings.json` (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

### feature-squad (Sequential)

```
planner → architect → lead (gate) → implementer → tester → evaluator → lead (route)
```

Six roles with clear handoff points. The lead gates spec and plan before work begins, then routes the evaluator's verdict: PASS ships, ITERATE loops back to the implementer, FAIL surfaces to the human.

### review-team (Parallel)

```
                  ┌── security-reviewer ──┐
lead (distribute) ── correctness-reviewer ── lead (aggregate)
                  └── style-reviewer ─────┘
```

Three specialized reviewers run concurrently. The lead deduplicates findings and produces a single categorized report.

### debate-team / consensus-team

Debate: proposer (blue) → challenger (red) → defender → judge ruling with VALID/PARTIAL/INVALID scores.

Consensus: three independent architect agents propose solutions in parallel → synthesizer maps AGREED/MAJORITY/SPLIT. SPLIT items require human decision.

---

## Customization

### Project-Level

1. **`CLAUDE.md`** — Replace `TODO` markers with project name, stack, and commands
2. **`rules/`** — Adapt conventions, testing policy, and git workflow
3. **`agents/`** — Add domain-specific agents (e.g., `migration-reviewer.md`)
4. **`commands/`** — Add workflow shortcuts specific to your stack

### Personal Overrides

```bash
cp CLAUDE.local.md.example CLAUDE.local.md
```

`CLAUDE.local.md` is gitignored. Use it for personal preferences, local environment details, and the session init prompt.

### Global vs Project Layering

| Concern | Global (`~/.claude/`) | Project (`.claude/`) |
|---------|----------------------|---------------------|
| Rules | Behavior, tool preferences, memory policy | Conventions, architecture, git, testing |
| Hooks | memelord lifecycle | Lint gate, test gate, preflight, re-index |
| MCP | context-mode, memelord (global) | cachebro + codemogger (project) |
| Settings | Model, plugins | Hook registrations, permissions, agent teams |

Claude Code merges both layers automatically. Project settings take precedence.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and [docs/walkthrough-example.md](docs/walkthrough-example.md) to understand the architecture.

For security vulnerabilities, see [SECURITY.md](SECURITY.md).

Open issues at [github.com/bymilon/dotclaude/issues](https://github.com/bymilon/dotclaude/issues).

---

## License

MIT. See [LICENSE](LICENSE).

---

<p align="center">
  Built for teams that ship.
</p>
