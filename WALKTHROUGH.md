# Walkthrough

A guided tour of dotclaude's architecture, design decisions, and extension points. Read this before contributing or customizing the template for your organization.

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [How Setup Works](#how-setup-works)
3. [The MCP Stack in Depth](#the-mcp-stack-in-depth)
4. [Hook Lifecycle](#hook-lifecycle)
5. [Agent Design](#agent-design)
6. [Command Anatomy](#command-anatomy)
7. [Team Orchestration](#team-orchestration)
8. [Rules System](#rules-system)
9. [Extending dotclaude](#extending-dotclaude)
10. [Troubleshooting](#troubleshooting)

---

## Design Philosophy

dotclaude is built on four principles:

**1. Convention over configuration.** Drop the scaffold into any project and run setup. Hooks auto-detect your stack. Agents follow a universal output contract. No YAML configuration files to maintain.

**2. Graceful degradation.** Every component handles missing dependencies. Remove codemogger and commands still work. Disable agent spawning and commands fall back to inline execution. The template is useful at every level of adoption.

**3. Single responsibility.** Each agent does one thing. Each hook gates one event. Each rule file covers one concern. This makes the system predictable, testable, and safe to extend.

**4. Global complements project.** Personal preferences and cross-project tools live in `~/.claude/`. Project conventions, quality gates, and team workflows live in `.claude/`. Claude Code merges both layers automatically — no manual wiring.

---

## How Setup Works

The setup script (`setup.sh` / `setup.ps1`) executes six steps. Both scripts implement identical logic — changes to one must be mirrored to the other.

```
Step 1  Check prerequisites
        npx (required), memelord (optional), codemogger (optional)
        Missing optional tools are logged as warnings, not errors.

Step 2  Initialize memelord
        Creates .memelord/ with per-project vector database.
        Skipped if memelord is not installed.

Step 3  Build codemogger index
        Runs tree-sitter chunking + vector/FTS indexing on the codebase.
        Warns on large repos (>10k files). Skipped if codemogger is not installed.

Step 4  Create CLAUDE.local.md
        Copies the example template for personal overrides.
        Skipped if the file already exists.

Step 5  Verify .gitignore
        Ensures CLAUDE.local.md, .memelord/, .codemogger/, and .cachebro/
        are excluded from version control.

Step 6  Set hook permissions
        Makes .claude/hooks/*.sh executable (Unix) or removes read-only flag (Windows).
```

### Dry Run

Both scripts support preview mode:

```bash
./setup.sh --dry-run     # Unix
.\setup.ps1 -DryRun      # Windows
```

Every mutating operation routes through a `run()` / `Run-Command` function that prints `[dry-run] would run: ...` instead of executing.

---

## The MCP Stack in Depth

MCP (Model Context Protocol) servers extend Claude Code with external capabilities. dotclaude composes three servers into a layered stack where each layer addresses a different bottleneck.

### Layer 1: cachebro (Token Optimization)

```
Declared in:  .mcp.json (project-level)
Behavior:     Passive — intercepts file reads, caches content, deduplicates
Impact:       ~26% token savings on file-heavy sessions
Config:       Zero. Works automatically once declared.
```

cachebro sits between Claude Code and the filesystem. When the same file is read multiple times in a session, cachebro serves the cached version, reducing token consumption without any change in behavior.

### Layer 2: codemogger (Code Intelligence)

```
Declared in:  .mcp.json (project-level)
Indexed by:   setup.sh / post-index-update.sh hook
Storage:      .codemogger/ (gitignored)
Tools:        Semantic code search, symbol lookup, dependency tracing
```

codemogger parses your codebase with tree-sitter, chunks it into semantic units, and builds both a vector index (384-dim, MiniLM) and a full-text search index. Agents and commands use these tools to navigate large codebases without reading every file.

The `post-index-update.sh` hook keeps the index fresh: it counts file edits and triggers a background re-index after every 3 changes. A lockfile prevents concurrent re-index operations.

### Layer 3: memelord (Persistent Memory)

```
Declared in:  ~/.claude/settings.json (global hooks)
Database:     .memelord/memory.db (per-project, gitignored)
Tools:        Vector-similarity memory search, reinforcement-weighted recall
```

memelord provides cross-session memory. It runs globally — configured once in your personal `~/.claude/settings.json` hooks — and creates a per-project database during setup. Memories are stored as vector embeddings with reinforcement weights: useful memories are recalled more often, unused memories decay.

**Why global?** memelord needs to fire lifecycle hooks (SessionStart, PostToolUse, Stop) for every project. Declaring it globally means zero per-project hook configuration and no risk of duplication.

---

## Hook Lifecycle

Hooks are registered in `.claude/settings.json` under `PreToolUse` and `PostToolUse` arrays. Each hook is a flat object with a `matcher`, `type`, and `command`.

### How Hooks Fire

```
Claude Code decides to run a tool (e.g., Bash)
  |
  v
PreToolUse hooks run (matcher: "Bash")
  |-- pre-commit-lint.sh receives $TOOL_INPUT
  |   |-- Checks: does input contain "git commit"?
  |   |   No  -> exit 0 (skip silently)
  |   |   Yes -> detect linter -> run -> block on failure
  |
  |-- pre-push-test.sh receives $TOOL_INPUT
  |   |-- Checks: does input contain "git push"?
  |   |   No  -> exit 0 (skip silently)
  |   |   Yes -> detect test runner -> run -> block on failure
  |
  v
Tool executes (if not blocked)
  |
  v
PostToolUse hooks run (matcher: "Write|Edit")
  |-- post-index-update.sh
      |-- Is .codemogger/ present and writable?
      |   No  -> exit 0
      |   Yes -> increment atomic counter -> threshold check -> background re-index
```

### Writing New Hooks

Every hook must:

1. **Guard on tool input** — check `$1` (the tool input) and `exit 0` early if the command is not relevant
2. **Handle missing dependencies** — check if required binaries exist before calling them
3. **Never block unnecessarily** — background long-running operations, use locks to prevent concurrency issues
4. **Exit cleanly** — `exit 0` to allow, `exit 1` to block (PreToolUse only)

---

## Agent Design

Agents follow the [Stripe minions pattern](https://arxiv.org/abs/2501.12996): single-purpose, one-shot execution, scoped permissions, defined output contracts.

### Agent Frontmatter

Every agent file starts with YAML frontmatter:

```yaml
---
description: What this agent does (shown in agent picker)
model: claude-sonnet-4-6
allowed-tools: Read, Glob, Grep  # Scoped permissions
---
```

### Permission Scoping

| Access Level | Tools | Used By |
|-------------|-------|---------|
| Read-only | `Read, Glob, Grep, Bash(git:*)` | architect, reviewer |
| Read + Write | `Read, Write, Edit, Glob, Grep, Bash(*)` | tester, refactorer |

**Read-only agents can never modify files.** This is enforced by the `allowed-tools` frontmatter, not by convention. If an agent attempts to use a tool not in its allowed list, Claude Code blocks the call.

### Output Contracts

Each agent has a defined output format:

- **architect** outputs a structured plan: files to create/modify, dependencies, implementation sequence, risks
- **reviewer** outputs categorized findings: Critical (blocks merge), Warning (should fix), Suggestion (consider)
- **tester** outputs test files and a pass/fail summary
- **refactorer** outputs the diff and a test verification result

### Adding Custom Agents

Create a new `.md` file in `.claude/agents/`:

```yaml
---
description: Reviews database migrations for safety
model: claude-sonnet-4-6
allowed-tools: Read, Glob, Grep, Bash(git diff:*)
---

## Migration Reviewer

[Your agent instructions here]
```

Principle: start with the minimum permission set. Only add tools the agent genuinely needs.

---

## Command Anatomy

Commands are markdown files in `.claude/commands/` with YAML frontmatter. They define multi-step workflows that Claude Code executes when the user types the command name.

### Frontmatter Structure

```yaml
---
description: What this command does. Usage: /command [args]
allowed-tools: Read, Glob, Grep, Bash(git:*), Agent
---
```

### Design Patterns

**Auto-detection**: Commands detect the project stack from manifest files rather than requiring configuration. The detection logic lives in hook scripts — commands reference the hooks as the source of truth.

**Graceful degradation**: Every command that delegates to an agent includes a fallback: "If the agent is not available, perform the task inline." This ensures commands work even when agent spawning is disabled.

**Structured output**: Every command ends with a formatted summary block that gives the user a clear picture of what happened.

---

## Team Orchestration

Team templates in `.claude/teams/` define multi-agent workflows. They are blueprints — JSON files that describe roles, models, and execution sequences.

> Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

### Sequential Workflow (feature-squad)

```
architect         Produces implementation plan
    |
lead              Reviews and gates the plan
    |
implementer       Builds the feature
    |
tester            Writes tests, verifies the suite passes
    |
lead              Final review — approve or request changes
```

Each role completes before the next begins. The lead acts as a quality gate at two checkpoints: after planning and after implementation.

### Parallel Workflow (review-team)

```
lead distributes the diff
    |
    +-- security-reviewer     (OWASP, auth, secrets)
    +-- correctness-reviewer  (logic, nulls, races, edge cases)
    +-- style-reviewer        (naming, VSA, organization)
    |
lead aggregates, deduplicates, produces final verdict
```

Three reviewers run concurrently on the same diff, each examining a different dimension. The lead consolidates findings into a single categorized report.

### Using Teams

```
# Via command
/kickoff my-feature    # Uses feature-squad workflow

# Via TeamCreate (programmatic)
TeamCreate with .claude/teams/feature-squad.json
```

---

## Rules System

Rules files in `.claude/rules/` are imported by `CLAUDE.md` via `@` references. Each file covers a single concern:

| File | Scope |
|------|-------|
| `project-conventions.md` | Naming, imports, error handling, code style |
| `vertical-slice.md` | Directory structure, slice boundaries, no cross-slice imports |
| `git-workflow.md` | Branch naming, conventional commits, merge strategy |
| `testing-policy.md` | Co-located tests, AAA structure, auto-detected runners |
| `mcp-usage.md` | Three-layer MCP composition, when to use each tool |

### Customization Strategy

Rules files use stack-agnostic language with placeholder patterns (e.g., `{FRAMEWORK_ROOT}`). To adapt for your stack:

1. Read the existing rule file
2. Replace placeholders with your conventions
3. Add stack-specific sections where needed
4. Remove sections that don't apply

Don't delete rule files you don't need — comment out irrelevant sections or replace their content. This preserves the structure for future contributors.

---

## Extending dotclaude

### Adding a New Stack

To support a new language ecosystem:

1. **`pre-commit-lint.sh`** — Add detection logic in `detect_linter()` and a case arm for the linter command
2. **`pre-push-test.sh`** — Add detection logic in `detect_test_runner()` and a case arm for the test command
3. **`kickoff.md`** — Add a scaffold template for the new stack's directory layout
4. **`README.md`** — Add a row to the Auto-Detected Ecosystems table

### Adding a New Command

1. Create `.claude/commands/your-command.md` with frontmatter
2. Define steps with clear headings
3. Include an output format section
4. Add graceful degradation for optional dependencies
5. Document in README

### Adding a New Agent

1. Create `.claude/agents/your-agent.md` with frontmatter
2. Scope permissions to the minimum required tool set
3. Define the output contract
4. Reference from relevant commands
5. Document in README

### Creating Custom Skills

Use the template at `.claude/skills/_template/SKILL.md`:

```yaml
---
name: skill-name
description: One-line description
---

## Purpose
## When to Use
## Steps
## Output Format
```

---

## Troubleshooting

### Hooks not firing

1. Verify `.claude/settings.json` has the `hooks` section with `PreToolUse` and `PostToolUse` arrays
2. Check that hook scripts are executable: `ls -la .claude/hooks/`
3. Run a hook manually to test: `bash .claude/hooks/pre-commit-lint.sh "git commit -m test"`

### MCP tools not available

1. Check `.mcp.json` declares the servers
2. Verify `settings.json` has `enableAllProjectMcpServers: true`
3. Run `/status` to see which tools are detected

### codemogger not re-indexing

1. Check `.codemogger/` directory exists and is writable
2. Check `.codemogger/.edit-count` — it should contain dots (one per edit)
3. Check `.codemogger/.reindex-lock` — delete it if a previous index process crashed

### Setup script fails

1. Run with `--dry-run` first to preview actions
2. Check Node.js is installed: `npx --version`
3. On Windows, ensure PowerShell execution policy allows scripts: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

### Agent not spawning

1. Verify the agent file exists in `.claude/agents/`
2. Check frontmatter syntax (YAML between `---` delimiters)
3. Commands fall back to inline execution automatically — check the command output for fallback messages

---

<p align="center">
  <em>For detailed API reference, see the individual files in <code>.claude/</code>.<br>
  Each file is self-documenting with frontmatter and inline instructions.</em>
</p>
