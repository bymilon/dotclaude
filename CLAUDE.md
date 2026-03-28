# Project Instructions

@.claude/rules/project-conventions.md
@.claude/rules/vertical-slice.md
@.claude/rules/git-workflow.md
@.claude/rules/testing-policy.md
@.claude/rules/mcp-usage.md

## Project

- **Name**: `TODO` — replace with your project name
- **Description**: `TODO` — one-line description of your project
- **Stack**: `TODO` — e.g., Bun + Hono + libSQL / SvelteKit + Cloudflare / Laravel + Livewire
- **Repo**: `TODO` — e.g., https://github.com/org/repo

## Quick Reference

```bash
# Development
# TODO: replace with your dev command — e.g., bun run dev / composer run dev / cargo run

# Tests
# TODO: replace with your test command — e.g., bun test / php artisan test / cargo test

# Lint
# TODO: replace with your lint command — e.g., bun run lint / php vendor/bin/pint / cargo clippy

# Build (if applicable)
# TODO: replace with your build command — e.g., bun run build
```

> **Setup**: After cloning, fill in the TODOs above and run `./setup.sh` (or `.\setup.ps1` on Windows).

## Communication Protocol

- Do not output code here or provide explanations. Once complete, simply respond with **DONE**.
- Pay attention to whether you are asked *HOW* to do something, compared with actually doing something. For example, if I ask, "How do I revert my last commit?", DO NOT REVERT THE LAST COMMIT. I am only asking how, not for you to do it. If I want you to do it, I will say "Revert the last commit."

## Development Principles

- In all code implementations, strictly follow the YAGNI, KISS, and DRY principles to maintain clean, simple, and maintainable architecture.

## Running the Application

- NEVER RUN THE APP YOURSELF. I WILL DO THIS SEPARATELY.
- DO NOT run `bun run dev` ever.
- DO NOT run `pnpm run dev` ever.
- DO NOT run `npm run dev` ever.

## Package Management

- **JavaScript/TypeScript**: Always use **bun** — never npm or pnpm
- **Scaffolding**: New SvelteKit project → `bun x sv create .`
- **Install**: `bun add`, `bun install`

### Python Projects

- **MANDATORY**: Astral UV with `pyproject.toml`
- **FORBIDDEN**: `pip` for any package operations
- **COMMANDS**: `uv add`, `uv sync`, `uv remove`

## No Configuration Changes Without Permission

- Do not modify any existing configuration files without explicit permission
- This includes: package.json, svelte.config.js, vite.config.ts, app.css, etc.
