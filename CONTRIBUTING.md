# Contributing to dotclaude

Thank you for your interest in contributing. This guide will help you get started.

## Getting Started

1. Fork the repository
2. Clone your fork and create a branch: `git checkout -b feat/your-feature`
3. Run setup: `./setup.sh` (Unix) or `.\setup.ps1` (Windows)

## Development

### Adding a New Stack

To support a new language ecosystem, update these files:

1. `.claude/hooks/pre-commit-lint.sh` — add detection in `detect_linter()` and a case arm
2. `.claude/hooks/pre-push-test.sh` — add detection in `detect_test_runner()` and a case arm
3. `.claude/commands/kickoff.md` — add a scaffold template
4. `README.md` — add a row to the Auto-Detected Ecosystems table

### Adding a New Agent

1. Create `.claude/agents/your-agent.md` with YAML frontmatter
2. Scope `allowed-tools` to the minimum required set
3. Define an output contract
4. Document in README

### Adding a New Command

1. Create `.claude/commands/your-command.md` with YAML frontmatter
2. Include graceful degradation for optional dependencies
3. Document in README

## Code Standards

- **Shell scripts**: `set -euo pipefail`, handle missing dependencies gracefully, output to stderr
- **Hooks**: Guard on tool input early, never block unnecessarily, use exit 0 (allow) or exit 2 (block)
- **Agents**: Single-purpose, minimum permissions, defined output contract
- **Documentation**: Keep README and WALKTHROUGH in sync with code changes

## Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add Deno test runner detection
fix: handle missing package.json in lint hook
docs: update ecosystem table for Ruby support
```

## Pull Requests

1. One concern per PR — don't mix features with refactors
2. Update documentation if you change behavior
3. Test on both Unix and Windows if modifying shell scripts
4. Keep `setup.sh` and `setup.ps1` in sync — changes to one must be mirrored

## Reporting Issues

Use GitHub Issues. Include:
- Your OS and shell version
- Claude Code version
- Steps to reproduce
- Expected vs actual behavior

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
