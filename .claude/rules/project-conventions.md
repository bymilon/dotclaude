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
