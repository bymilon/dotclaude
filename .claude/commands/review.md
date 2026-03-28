---
description: Review current changes using the reviewer agent. Usage: /review [branch-to-compare]
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Agent
---

## Review — Code Review Pipeline

**Branch:** !`git branch --show-current 2>/dev/null`

### Step 1 — Determine Scope

- If an argument was provided, use it as the base branch for comparison
- Otherwise, detect the default branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null` or fallback to `main`
- Get the diff: `git diff {base}...HEAD`

### Step 2 — Delegate to Reviewer Agent

Launch the `reviewer` agent with this context:

> Review the following changes on branch `{current_branch}` compared to `{base_branch}`.
> Focus on: bugs, security, convention violations, missing tests.
> Use the project rules in `.claude/rules/` as your standard.
> Output categorized findings: Critical / Warning / Suggestion.

### Step 3 — Present Results

Display the reviewer agent's findings directly. Add a summary line:

```
Review complete: {N} critical, {N} warnings, {N} suggestions
Verdict: {APPROVE / REQUEST CHANGES}
```

If there are Critical findings, always output `REQUEST CHANGES`.
