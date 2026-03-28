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

<!-- Configure for your stack -->
<!-- bun test / vitest / jest / phpunit / cargo test / pytest -->
