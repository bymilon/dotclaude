---
description: Red/Blue adversarial debate on a design decision. Usage: /debate <decision to make>
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(ls:*), Agent
---

## Debate — Adversarial Design Review

Run a structured red-team/blue-team debate on the stated decision before committing to it.
Use this for: API contracts, authentication design, data model choices, caching strategies, anything irreversible.

### When to Use

- You have a solution in mind but haven't stress-tested it
- The decision involves trade-offs where you're unsure which matters more
- A previous similar decision caused rework — prevent it with adversarial testing
- The feature involves security, data integrity, or external contracts

### Setup

1. Read CLAUDE.md and relevant slice code to understand the current system
2. State the decision clearly: what are you choosing between, what constraints apply, what success looks like
3. Reference the `debate-team` blueprint: `.claude/teams/debate-team.json`

### Orchestration (run as debate judge)

**Round 1 — Proposal**
Assign the proposer role: "Design a concrete solution for: {decision}. Be specific about files, interfaces, and data shapes."

**Round 2 — Challenge**
Pass the proposal to the challenger: "Here is a proposed solution. You are red team. Find at least 3 specific failure scenarios, attack assumptions, and identify what the proposer hasn't considered."

**Round 3 — Defense**
Pass the objections back to the proposer: "Here are the challenger's objections. Address each one: concede and revise, or defend with concrete evidence."

**Round 4 — Ruling**
As judge: score each objection (VALID / PARTIAL / INVALID), produce the final design incorporating all VALID and PARTIAL findings.

### Output

```
Decision:   {what was debated}

Proposal:   {blue team's approach — 2-3 sentences}

Challenges:
  [VALID]   {objection} → Revision: {what changed}
  [PARTIAL] {objection} → Note: {risk to document}
  [INVALID] {objection} → Defense: {why it holds}

Final Design:
  {revised proposal incorporating valid challenges}

Confidence: {HIGH if 0-1 valid objections | MEDIUM if 2-3 | LOW if 4+ — needs re-debate or human input}
```
