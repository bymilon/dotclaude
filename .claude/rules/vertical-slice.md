## Vertical Slice Architecture

Every feature is a self-contained folder. AI agents read one folder and understand the full feature.

### Directory Layout

```
{FRAMEWORK_ROOT}/
  {feature}/
    {feature}.route.ts       — HTTP handlers, input parsing
    {feature}.service.ts     — Business logic, orchestration
    {feature}.repo.ts        — Database queries only
    {feature}.schema.ts      — Validation schemas (Zod, etc.)
    {feature}.types.ts       — Types and interfaces
    {feature}.test.ts        — Co-located tests
```

Shared infrastructure lives in `core/` only:
```
core/
  db.ts          — Database client
  env.ts         — Environment config
  logger.ts      — Logging
  middleware.ts   — Shared middleware
```

### Rules

- **Feature first, layer second** — `app/memory/memory.service.ts`, NOT `services/memory.ts`
- **No cross-slice imports** — slices never import from another slice's internals. Share via `core/` or events.
- **Flat imports within a slice** — `./memory.repo` not `../../repositories/memory`
- **Split threshold** — if a slice exceeds ~5 files, split into sub-slices
- **Naming** — `{feature}.{layer}.{ext}` — always lowercase, dot-separated

### Agent Navigation

When working on a feature:
1. Read the entire slice folder first
2. Understand the route → service → repo flow
3. Make changes within the slice
4. Only touch `core/` if the change is genuinely shared
