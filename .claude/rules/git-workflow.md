## Git Workflow

### Branch Naming

```
feature/{short-description}     — New functionality
fix/{short-description}         — Bug fixes
refactor/{short-description}    — Code improvements (no behavior change)
docs/{short-description}        — Documentation only
test/{short-description}        — Test additions or fixes
```

### Conventional Commits

```
feat: add user authentication
fix: resolve null pointer in payment flow
refactor: extract validation into schema layer
docs: update API endpoint documentation
test: add edge case coverage for search
chore: update dependencies
```

- Subject line: imperative mood, lowercase, no period, under 72 chars
- Body (optional): explain *why*, not *what* — the diff shows what changed
- Footer: `Co-Authored-By:` when applicable

### Merge Strategy

- **Feature branches** → squash merge to main/develop
- **Never force-push** to main or develop
- **Rebase** feature branches on main before merging (keep history linear)
- **Delete branches** after merge

### Before Committing

1. Run linter (auto-detected by pre-commit hook)
2. Run tests (auto-detected by pre-push hook)
3. Review staged changes: `git diff --staged`
