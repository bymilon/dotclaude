# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Four single-purpose agents: architect, reviewer, tester, refactorer
- Five commands: /ship, /onboard, /review, /kickoff, /status
- Three quality-gate hooks: pre-commit-lint, pre-push-test, post-index-update
- Three-layer MCP stack: cachebro, codemogger, memelord
- Two team workflow templates: feature-squad (sequential), review-team (parallel)
- Five rule files: project-conventions, vertical-slice, git-workflow, testing-policy, mcp-usage
- Cross-platform setup: setup.sh (Unix) + setup.ps1 (Windows) with --dry-run
- Auto-detection for 6+ language ecosystems (JS/TS, PHP, Rust, Python, Go)
- Enterprise governance: CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
- Comprehensive WALKTHROUGH.md architecture guide
