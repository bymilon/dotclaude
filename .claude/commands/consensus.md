---
description: Stochastic consensus — 3 independent agents propose solutions, synthesizer maps agreement. Usage: /consensus <problem>
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(ls:*), Agent
---

## Consensus — Stochastic Ensemble for High-Confidence Decisions

Run the same problem through 3 independent reasoning paths. Consensus = confidence. Divergence = ambiguity that needs human input.

### When to Use

- Irreversible decisions: database schema, API contracts, auth flows, core data models
- You're unsure which of several approaches is right
- Previous architecture decisions caused expensive rework
- The problem has hidden constraints you might not have considered

### Why It Works

LLMs are stochastic — different calls on the same prompt traverse different reasoning paths. Three independent agents on the same problem will agree on the obvious parts and diverge on the genuinely ambiguous parts. That divergence is the signal: it marks exactly the decisions that need human judgment, not more AI reasoning.

### Setup

1. Read CLAUDE.md, the relevant slice, and any existing contracts (schemas, API definitions)
2. State the problem precisely: what needs to be designed, what constraints are fixed, what the system already does
3. Reference the `consensus-team` blueprint: `.claude/teams/consensus-team.json`

### Orchestration (run as synthesizer)

**Round 1 — Independent Proposals (parallel)**
Spawn three architect instances with identical context and NO cross-visibility:
> "Design a solution for: {problem}. Context: {constraints}. Produce: approach, files, interfaces, sequence. Be specific."

Each instance produces a complete, independent proposal.

**Round 2 — Consensus Mapping**
As synthesizer, map every decision point across the three proposals:

| Decision point | A | B | C | Status |
|---|---|---|---|---|
| {e.g., "store sessions in Redis or DB"} | Redis | Redis | DB | MAJORITY |
| {e.g., "JWT or server sessions"} | JWT | JWT | JWT | AGREED |
| {e.g., "schema structure"} | {A's shape} | {B's shape} | {C's shape} | SPLIT |

### Output

```
Problem:    {what was evaluated}

Consensus Map:
  AGREED   (3/3): {list — implement with confidence}
  MAJORITY (2/3): {list — implement, document minority view}
  SPLIT    (1/1/1): {list — STOP. Escalate to human decision}

Recommended action:
  - Implement AGREED items immediately
  - For MAJORITY items: go with majority, add a code comment explaining the trade-off
  - For SPLIT items: {present the 3 options with their rationale for human choice}

Confidence score: {AGREED count} / {total decisions} = {%}
```

A confidence score above 70% means implement. Below 50% means the problem needs more constraints before building.
