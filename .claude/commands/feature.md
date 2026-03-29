---
description: Implement a feature end-to-end using architect → implement → test flow. Usage: /feature <description>
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(git:*), Bash(ls:*), Bash(bun:*), Bash(bunx:*), Bash(find:*), Bash(wc:*), Agent
---

## Feature — Vertical Slice Implementation

Implement the requested feature. Work through each phase in order. Stop and report if any phase fails.

### Phase 1 — Locate

1. Read `CLAUDE.md` and the relevant rule files (`vertical-slice.md`, `project-conventions.md`)
2. Search for related code: use codemogger or grep to find the closest existing slice
3. Determine: new slice or extend existing? Name it `{feature}` in kebab-case

### Phase 2 — Plan

Before writing any code, define:
- **Route**: method, path, input shape
- **Service contract**: function name, parameters, return type, side effects
- **Data layer**: new table / column / existing query
- **Files to create or modify** (one list, with purpose of each)
- **Cross-slice risk**: does this touch `core/`? If yes, why?

State the plan. If the feature description is ambiguous, ask one clarifying question before proceeding.

### Phase 3 — Implement

Follow the vertical slice layout strictly:

```
app/{feature}/
  {feature}.route.ts     — HTTP handlers, input validation only
  {feature}.service.ts   — business logic, orchestration
  {feature}.repo.ts      — DB queries only (omit if no DB)
  {feature}.schema.ts    — Zod schemas (omit if no validation)
  {feature}.types.ts     — types/interfaces (omit if trivial)
```

Rules:
- Validate at the route layer using the schema; pass clean data to the service
- Service never imports from another slice's service
- Repo never contains business logic

### Phase 4 — Test

Co-locate tests with the slice:

```
app/{feature}/{feature}.service.test.ts
```

Write at minimum:
1. Happy path — the feature works as specified
2. Validation — invalid input is rejected
3. One edge case relevant to the feature

Run the tests: `bun test` or the auto-detected test runner.

### Phase 5 — Wire Up

If this is a new slice, mount it in the entry point (`app.ts` / `index.ts`):
```ts
app.route('/{path}', {feature}Route)
```

### Output

```
Feature: {name}
Slice:   app/{feature}/
Files:   {list of created/modified files}
Tests:   {N} passing
Status:  ready to /ship
```
