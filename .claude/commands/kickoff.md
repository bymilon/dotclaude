---
description: Scaffold a new feature — create branch, expand spec, scaffold slice, architect plan. Usage: /kickoff <feature-name> [description]
allowed-tools: Read, Write, Glob, Grep, Bash(git checkout:*), Bash(git branch:*), Bash(mkdir:*), Bash(ls:*), Agent
---

## Kickoff — Start a New Feature

### Step 1 — Parse Input

- First argument: feature name (kebab-case, e.g., `user-auth`)
- Remaining arguments: feature description (optional)
- If no description provided, ask the user for a one-line description

### Step 2 — Create Branch

```bash
git checkout -b feature/{feature-name}
```

### Step 3 — Expand Product Spec

Launch the `planner` agent:

> Expand this brief into a full product spec: "{feature-name}" — {description}.
> Check the existing codebase to understand the project's domain and avoid speccing features that already exist.

The planner produces: vision, user stories, features (core/enhanced/deferred), user flows, edge cases, success criteria, and key decisions. This spec feeds the architect in Step 5.

If the planner agent is not available, produce a minimal spec inline: 3-5 user stories, core features list, and success criteria.

### Step 4 — Scaffold Vertical Slice

Detect the framework root (look for `app/` or `src/` directory). Adapt file extensions and layer names to the detected stack:

**TypeScript/JavaScript** (default):
```
{root}/{feature-name}/
  {feature-name}.route.ts
  {feature-name}.service.ts
  {feature-name}.repo.ts
  {feature-name}.schema.ts
  {feature-name}.types.ts
  {feature-name}.test.ts
```

**PHP/Laravel** (detected via `composer.json`):
```
{root}/{Feature}/
  {Feature}Controller.php
  {Feature}Service.php
  {Feature}Repository.php
  {Feature}Request.php
  {Feature}Resource.php
```

**Rust** (detected via `Cargo.toml`):
```
src/{feature_name}/
  mod.rs
  handler.rs
  service.rs
  model.rs
```

Each file should contain:
- Proper imports for the layer
- A single exported placeholder function with a TODO comment
- Type-correct but minimal implementation

### Step 5 — Architect Plan

Launch the `architect` agent with the planner's spec:

> Design an implementation plan for feature "{feature-name}" using the product spec above.
> The slice has been scaffolded at {slice-path}/.
> Analyze the existing codebase for patterns to follow and dependencies to wire up.

If the architect agent is not available, produce the plan inline: list files to create/modify, dependencies, implementation sequence, and risks.

### Step 6 — Report

```
Feature kickoff complete: {feature-name}

  Branch:    feature/{feature-name}
  Slice:     {root}/{feature-name}/
  Files:     {N} files created
  Spec:      {N} user stories, {N} features

  Pipeline:
  1. Review the product spec and architect plan above
  2. Run /feature or /build to implement
  3. Run /ship when ready
```
