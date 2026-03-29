## Testing Policy

### Coverage Expectations

- Every new feature: at least one happy-path test
- Every bug fix: regression test that fails without the fix
- Every API endpoint: request/response test with status code assertions
- Every validation schema: test valid + invalid inputs

### Co-location

Tests live next to the code they test:
```
app/memory/
  memory.service.ts
  memory.service.test.ts     — Tests for this service
```

NOT in a separate `/tests/` tree (unless the framework requires it).

### Naming Convention

```
describe('{Feature}', () => {
  it('should {expected behavior} when {condition}', () => { ... });
});
```

Examples:
- `it('should return 404 when memory not found')`
- `it('should create memory with valid content')`
- `it('should reject empty content with validation error')`

### Test Structure

1. **Arrange** — set up data, mocks, fixtures
2. **Act** — call the function or endpoint
3. **Assert** — verify the result

### What NOT to Test

- Framework internals (trust the framework)
- Private implementation details (test behavior, not methods)
- Third-party library functionality
- Trivial getters/setters with no logic

### Test Runner

Auto-detected by the `pre-push-test.sh` hook. The hook checks for config files in this priority:

| Stack | Detection | Command |
|-------|-----------|---------|
| JS/TS | `vitest.config.*` or `"vitest"` in package.json | `bunx vitest run` |
| JS/TS | `jest.config.*` or `"jest"` in package.json | `bunx jest` |
| JS/TS | `"test"` script in package.json | `bun test` |
| PHP | `phpunit.xml` + `pestphp/pest` in composer.json | `php artisan test` |
| PHP | `phpunit.xml` without Pest | `php vendor/bin/phpunit` |
| Rust | `Cargo.toml` | `cargo test` |
| Python | `pyproject.toml` or `pytest.ini` | `pytest` |
| Go | `go.mod` | `go test ./...` |

To override auto-detection, set your test command in CLAUDE.md's Quick Reference section.
