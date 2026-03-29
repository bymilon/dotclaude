---
description: Validate environment and deploy to production. Usage: /deploy [target] — target defaults to detecting from project config
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(ls:*), Bash(find:*), Bash(bun:*), Bash(bunx:*), Bash(node:*), Bash(wrangler:*), Bash(cat:*)
---

## Deploy — Environment-First Deployment

Validate before deploying. A failed deploy that was preventable wastes more time than the validation takes.

### Phase 1 — Detect Target

Auto-detect deployment target from project config:
- `wrangler.toml` or `wrangler.json` → **Cloudflare Workers**
- `dokploy.yml` or `dokploy.json` → **Dokploy**
- `Dockerfile` + no wrangler → **Docker/generic**
- `fly.toml` → **Fly.io**
- Argument provided → use that target

If no target detected and no argument, ask before proceeding.

### Phase 2 — Preflight Validation

Check all requirements before touching the deploy command:

**Git state**
- Clean working tree? (`git status --short`)
- On correct branch? (`git branch --show-current`)
- Up to date with remote? (`git remote -v` + `git status -b`)

**Environment**
- Required CLI tools installed? (wrangler / docker / flyctl — whichever applies)
- Authenticated? (run the tool's auth check command — do not expose tokens)
- Environment variables set? (check `.env.example` for required keys, report which are missing by name only)

**Build**
- Run `bun run build` (or detected build command) — stop if it fails
- Report build output size if available

If any preflight check fails: **stop and report the specific blocker with the fix command.**

### Phase 3 — Deploy

Run the deploy command for the detected target:

| Target | Command |
|---|---|
| Cloudflare Workers | `bunx wrangler deploy` |
| Cloudflare Pages | `bunx wrangler pages deploy ./dist` |
| Dokploy | follow project deploy script |
| Docker | `docker build . && docker push` |
| Fly.io | `flyctl deploy` |

Stream output. If the deploy fails:
1. Read the full error output
2. Identify whether it's: auth, missing secret, build artifact, network, or platform issue
3. Suggest the specific fix — do not retry blindly

### Phase 4 — Verify

After deploy completes:
1. Check the deploy URL/endpoint responds (if accessible)
2. Report the deployed version/commit hash
3. Note any warnings from the deploy output

### Output

```
Target:    {Cloudflare Workers | Dokploy | ...}
Branch:    {branch} @ {commit hash}
Preflight: {passed | failed: {reason}}
Deploy:    {success | failed: {error}}
URL:       {deployed endpoint if available}
```
