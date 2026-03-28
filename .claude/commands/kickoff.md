---
description: Scaffold a new feature — create branch, slice directory, and architect plan. Usage: /kickoff <feature-name> [description]
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

### Step 3 — Scaffold Vertical Slice

Detect the framework root (look for `app/` or `src/` directory).

Create the slice directory with starter files:

```
{root}/{feature-name}/
  {feature-name}.route.ts
  {feature-name}.service.ts
  {feature-name}.repo.ts
  {feature-name}.schema.ts
  {feature-name}.types.ts
  {feature-name}.test.ts
```

Each file should contain:
- Proper imports for the layer
- A single exported placeholder function with a TODO comment
- Type-correct but minimal implementation

### Step 4 — Architect Plan

Launch the `architect` agent:

> Design an implementation plan for feature "{feature-name}": {description}.
> The slice has been scaffolded at {slice-path}/.
> Analyze the existing codebase for patterns to follow and dependencies to wire up.

### Step 5 — Report

```
Feature kickoff complete: {feature-name}

  Branch:    feature/{feature-name}
  Slice:     {root}/{feature-name}/
  Files:     {N} files created

  Next steps:
  1. Review the architect's plan above
  2. Implement the service layer first
  3. Run /ship when ready
```
