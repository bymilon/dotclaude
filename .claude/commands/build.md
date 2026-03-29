---
description: Full compound build pipeline — planner expands spec, generator implements, evaluator grades. Usage: /build <description>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(ls:*), Bash(bun:*), Bash(bunx:*), Bash(rg:*), Bash(mkdir:*), Agent
---

## Build — Compound Engineering Pipeline

Three-agent architecture inspired by Anthropic's harness design research.
Runs planner → generator → evaluator as one continuous flow.

Use `/build` for ambitious features that benefit from spec expansion and quality evaluation.
Use `/feature` for focused implementation tasks where the spec is already clear.

### Phase 1 — Plan (Planner Agent)

Launch the `planner` agent:

> Expand this brief into a full product spec: $ARGUMENTS
> Check the existing codebase to understand the project's domain.

The planner produces: vision, user stories, features, user flows, edge cases, success criteria.

Save the spec output — the generator and evaluator both need it.

### Phase 2 — Architect (Architect Agent)

Launch the `architect` agent with the planner's spec:

> Design an implementation plan for this product spec.
> Analyze the existing codebase for patterns to follow and dependencies to wire up.

The architect produces: affected slices, files to create/modify, dependency order, sequence, risks, tests needed.

### Phase 3 — Generate (Implementation)

Using the architect's plan, implement the feature end-to-end:

1. Scaffold any new vertical slices (following the stack-appropriate template)
2. Implement in dependency order — build what other files depend on first
3. Write co-located tests for each slice
4. Wire up entry points (route mounting, middleware, etc.)
5. Run the test suite: auto-detect runner and execute

Do NOT cut corners on edge cases or error handling at system boundaries — the evaluator will catch it.

### Phase 4 — Evaluate (Evaluator Agent)

Launch the `evaluator` agent:

> Evaluate the implementation against the product spec from Phase 1.
> The architect plan from Phase 2 defines what was supposed to be built.
> Grade on: Correctness (3x), Completeness (2x), Quality (2x), UX Coherence (1x).
> Run tests. Grep for TODOs. Check system boundary validation.

The evaluator produces a scored report with Critical/Important/Minor findings.

### Phase 5 — Iterate or Ship

**Based on the evaluator's verdict:**

- **PASS (64-80/80):** Report results. Ready for `/ship`.
- **ITERATE (40-63/80):** Fix all Critical findings from the evaluation. Re-run only the evaluator (not the full pipeline) to verify fixes. Repeat until PASS or 2 iterations max.
- **FAIL (0-39/80):** Report the evaluation. Do NOT auto-fix — present findings to the user and ask for direction. Something fundamental needs rethinking.

### Output

```
Build complete: {feature name}

  Spec:       {N} user stories, {N} features
  Plan:       {N} files created, {N} modified
  Tests:      {passed}/{total} passing
  Evaluation: {score}/80 — {PASS/ITERATE/FAIL}
  Iterations: {N}

  {if PASS}
  Ready to ship. Run /ship to lint, commit, and push.

  {if ITERATE}
  Fixed {N} critical findings. Evaluator re-scored: {new score}/80.

  {if FAIL}
  Evaluation failed. Review findings above before proceeding.
```
