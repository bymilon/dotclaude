# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability in dotclaude, please report it responsibly:

1. **Do not** open a public GitHub issue
2. Email the maintainers directly or use GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
3. Include a description of the vulnerability, steps to reproduce, and potential impact

We will acknowledge receipt within 48 hours and provide a timeline for a fix.

## Security Considerations

dotclaude includes shell scripts that execute as Claude Code hooks. Users should be aware of:

- **Hook scripts** run automatically during Claude Code tool execution. Review `.claude/hooks/` before adopting.
- **MCP servers** (cachebro, codemogger) run as child processes. Only enable servers you trust.
- **Agent permissions** are scoped via `allowed-tools` frontmatter. Review agent files before extending permissions.
- **The `/ship` command** stages and commits code. It excludes secrets patterns (`.env*`, `*.key`, `*.pem`) but users should verify their `.gitignore` covers project-specific sensitive files.

## Best Practices

- Always review `.claude/settings.json` hook registrations before use
- Keep `CLAUDE.local.md` in `.gitignore` (it may contain personal preferences)
- Run `setup.sh --dry-run` to preview all actions before executing
- Audit agent `allowed-tools` if extending with custom agents
