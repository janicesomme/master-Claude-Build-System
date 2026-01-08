# Master Build System

A structured, repeatable methodology for building production-ready applications with Claude Code.

## Features

- **Guided Discovery** - Claude asks YOU questions until it understands the project
- **Client-Readable Briefs** - Plain English output before any code
- **Context Protection** - Guardrails to prevent context window bloat
- **Incremental RLS** - Security applied one table at a time
- **Self-Improvement** - System learns from each build

## Quick Start

1. Click "Use this template" on GitHub
2. Clone your new repository
3. Run `.\scripts\new-spec.ps1 "my-feature"`
4. Start Claude Code: `claude`
5. Claude will guide you through the build

## Documentation

- [System Overview](docs/SYSTEM-OVERVIEW.md) - How everything works
- [Quick Reference](docs/QUICK-REFERENCE.md) - Cheat sheet

## Commands

| Command | Purpose |
|---------|---------|
| `/start` | Begin intake (Claude asks questions) |
| `/spec` | Generate technical specification |
| `/plan` | Create implementation plan |
| `/code` | Start coding phase |
| `/qa` | Run QA review |
| `/rls` | Apply RLS incrementally |
| `/status` | Show project status |
| `/compact` | Manage context window |
| `/improve` | Suggest system improvements |

## Build Pipeline

```
/start → /spec → /plan → [NEW SESSION] → /code → /qa → /rls
```

**Important:** Always start a fresh Claude Code session between `/plan` and `/code`.

## Requirements

- Claude Code CLI
- Git
- PowerShell (Windows) or adapt scripts for bash

## License

MIT
