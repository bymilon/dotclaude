---
description: Lint, test, commit, and push in one flow. Usage: /ship [commit message]
allowed-tools: Bash(*), Read, Glob, Grep
---

## Ship — Quality Gate Pipeline

**Branch:** !`git branch --show-current 2>/dev/null`
**Status:** !`git status --short 2>/dev/null`

Execute the following steps in order. Stop at any failure.

### Step 1 — Lint

Auto-detect the linter using the same logic as `.claude/hooks/pre-commit-lint.sh` (detects Biome, ESLint, Prettier, Pint, Clippy, Ruff, Black, gofmt from manifest files).

Run the linter. If it auto-fixes files, stage the fixes. If lint fails after auto-fix, **stop and report**. If no linter detected, **warn and continue**.

### Step 2 — Test

Auto-detect the test runner using the same logic as `.claude/hooks/pre-push-test.sh` (detects Vitest, Jest, Pest, PHPUnit, Cargo, pytest, Go test from manifest files).

Run the test suite. If tests fail, **stop and report** which tests failed. If no test runner detected, **warn and continue**.

### Step 3 — Stage + Commit

1. Stage all modified and new files: `git add -A`
2. Review staged changes: `git diff --staged --stat`
3. Generate a conventional commit message from the diff:
   - Determine type: feat/fix/refactor/docs/test/chore
   - Write concise subject line (imperative, under 72 chars)
   - If a commit message was provided as argument, use it as the subject
4. Commit with the message (include `Co-Authored-By: Claude <noreply@anthropic.com>`)

### Step 4 — Push

1. Push to remote: `git push -u origin HEAD`
2. If push fails (no remote, auth error), report the error

### Output

```
Shipped {branch}
  Lint:   passed
  Tests:  {N} passed, {N} failed
  Commit: {hash} {message}
  Push:   {remote}/{branch}
```
