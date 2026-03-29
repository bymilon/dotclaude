---
description: Diagnose and fix a bug with minimal blast radius. Usage: /fix <description or error message>
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(git:*), Bash(ls:*), Bash(bun:*), Bash(bunx:*), Bash(find:*)
---

## Fix — Bug Diagnosis and Resolution

Fix the described bug. Apply the smallest change that resolves the root cause. Do not refactor surrounding code.

### Phase 1 — Reproduce

1. Locate the relevant code: grep for the error message, symbol, or path mentioned
2. Read the full slice (`route → service → repo`) where the bug lives
3. Check recent changes: `git log -10 --oneline -- {file}` — bugs often live in the last 3 commits

### Phase 2 — Root Cause

Trace the execution path from input to failure:
- Where does the bad data enter?
- Where does the assumption break?
- Is it a missing guard, wrong type, off-by-one, or race condition?

State the root cause in one sentence before writing any fix.

### Phase 3 — Regression Test

If a test can capture this bug, write it first (it should fail before the fix):

```ts
it('should {correct behavior} when {bug condition}', () => {
  // Arrange: reproduce the exact failing scenario
  // Act
  // Assert: the behavior that was broken
});
```

### Phase 4 — Fix

Apply the minimal change. Rules:
- Fix the root cause, not the symptom
- Do not add unrelated improvements to the same commit
- If the fix requires touching more than 2 files, re-examine whether the root cause diagnosis is correct

### Phase 5 — Verify

1. Run the regression test (should now pass)
2. Run the full test suite: `bun test` or auto-detected runner
3. Run the linter

### Output

```
Fixed:       {one-line description}
Root cause:  {one sentence}
Files:       {changed files}
Test:        {test name} — now passing
```
