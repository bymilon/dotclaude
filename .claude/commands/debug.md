---
description: Systematic diagnosis of an unknown bug or error. Usage: /debug <error message or symptom>
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(ls:*), Bash(find:*), Bash(bun:*), Bash(bunx:*), Bash(cat:*)
---

## Debug — Systematic Fault Isolation

Diagnose the problem before touching any code. Work through each phase in order. Do not fix anything until Phase 4.

### Phase 1 — Capture

Gather everything known about the failure:
1. Exact error message and stack trace (read logs if needed)
2. What was expected vs what happened
3. When it started — `git log --oneline -10` on affected files
4. Environment: OS, runtime version, relevant env vars (names only, not values)

### Phase 2 — Locate

Find where in the code the failure originates:
1. Search for the error string/symbol: grep the codebase
2. Identify the slice it lives in — read the full slice (route → service → repo)
3. Trace the execution path from entry point to failure site
4. Check if the failure is in your code, a dependency, or the environment

### Phase 3 — Isolate

Narrow to the exact cause:
- Is it data? (bad input, wrong shape, nil/null)
- Is it logic? (wrong condition, off-by-one, missing await)
- Is it environment? (missing dep, wrong version, wrong config)
- Is it a regression? (`git log -5 --oneline -- {file}` — what changed recently)

**State the root cause hypothesis in one sentence before proceeding.**

If the cause is environmental (missing tool, wrong version, config):
- Fix the environment first
- Do not modify application code for an environment problem

### Phase 4 — Verify Hypothesis

Before writing a fix, confirm the hypothesis is correct:
1. Can you predict exactly what value/state is wrong?
2. Add a temporary log or trace to confirm — read the output
3. If the hypothesis is wrong, return to Phase 3

### Phase 5 — Fix

Once root cause is confirmed:
- Apply the minimal change
- If it's a code bug: write a regression test first (should fail), then fix
- If it's an environment bug: document the fix in a comment or README addition
- Run the full test suite

### Output

```
Symptom:     {error or unexpected behavior}
Located at:  {file:line}
Root cause:  {one sentence — precise}
Type:        {code bug | environment | dependency | regression}
Fix applied: {what changed}
Verified:    {how you confirmed it works}
```
