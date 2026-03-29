## Project Conventions

### Naming

- **Files**: kebab-case for directories and filenames (`user-profile/`, `auth-middleware.ts`)
- **Variables/functions**: camelCase
- **Types/interfaces**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Database columns**: snake_case

### Import Ordering

1. External packages (stdlib, npm/composer packages)
2. Internal aliases (`@/`, `~/`, `#/`)
3. Relative imports (parent first, then siblings)
4. Blank line between groups

### Error Handling

- Validate at system boundaries only (user input, API responses, external data)
- Trust internal code and framework guarantees
- Throw early, catch late — let errors propagate to the nearest meaningful handler
- Never swallow errors silently (`catch {}` with no action)

### Code Style

- Prefer explicit over implicit
- Prefer composition over inheritance
- Keep functions under 30 lines — extract when logic branches
- One export per file for primary concerns; co-located helpers are fine

### Framework API Verification

Before writing code that calls a library or framework API:

1. Read the manifest (`package.json` / `Cargo.toml` / `pyproject.toml`) to get the exact installed version
2. Do not assume method signatures, trait bounds, or response shapes — verify against the installed version, not training data
3. **TypeScript**: if `opensrc/<package>/` exists, read the actual source there — it contains the exact installed version fetched by setup.sh
4. **Rust**: if `rust-src/<crate>/` exists, use codemogger to search it — `rust-src/` contains framework source (GPUI, Dioxus, Leptos, Tauri) indexed at setup
5. If neither source directory exists and the version is uncertain, state the assumed version before writing code and ask to confirm

This prevents multi-round fix cycles from API hallucination — the leading cause of wasted sessions on cutting-edge stacks.

### Edit Safety

- Use `ctx_execute_file` for analysis reads (exploring, summarizing, searching) — file content stays in sandbox, not context
- Use `Read` only immediately before `Edit` — never read a file for analysis and later edit it, as hooks or concurrent writes may change it in between
- If an `Edit` fails with "string not found", re-read the file before retrying — the file changed, not your logic
