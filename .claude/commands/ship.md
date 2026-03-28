---
description: Lint, test, commit, and push in one flow. Usage: /ship [commit message]
allowed-tools: Bash(*), Read, Glob, Grep
---

## Ship — Quality Gate Pipeline

**Branch:** !`git branch --show-current 2>/dev/null`
**Status:** !`git status --short 2>/dev/null`

Execute the following steps in order. Stop at any failure.

### Step 1 — Lint

Auto-detect the linter (same logic as `pre-commit-lint.sh`):

| Stack | Detection | Command |
|-------|-----------|---------|
| JS/TS | `biome.json` | `npx @biomejs/biome check --write .` |
| JS/TS | `.eslintrc*` or `eslint.config.*` | `npx eslint --fix .` |
| JS/TS | `"lint"` script in package.json | `bun run lint` / `npm run lint` |
| PHP | `pint.json` or `vendor/laravel/pint` | `php vendor/bin/pint --dirty` |
| Rust | `Cargo.toml` | `cargo clippy --fix --allow-dirty` |
| Python | `pyproject.toml` + ruff installed | `ruff check --fix .` |
| Go | `go.mod` | `gofmt -l -w .` |

Run the linter. If it auto-fixes files, stage the fixes. If lint fails after auto-fix, **stop and report**. If no linter detected, **warn and continue**.

### Step 2 — Test

Auto-detect the test runner (same logic as `pre-push-test.sh`):

| Stack | Detection | Command |
|-------|-----------|---------|
| JS/TS | `vitest.config.*` | `npx vitest run` |
| JS/TS | `jest.config.*` | `npx jest` |
| JS/TS | `"test"` script in package.json | `bun test` / `npm test` |
| PHP | Pest in composer.json | `php artisan test` |
| PHP | PHPUnit only | `php vendor/bin/phpunit` |
| Rust | `Cargo.toml` | `cargo test` |
| Python | `pyproject.toml` / `pytest.ini` | `pytest` |
| Go | `go.mod` | `go test ./...` |

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
