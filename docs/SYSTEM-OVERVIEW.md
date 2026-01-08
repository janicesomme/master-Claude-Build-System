# Master Build System - Overview

A structured, repeatable methodology for building production-ready applications with Claude Code.

## What This System Does

1. **Guided Discovery** - Claude asks YOU questions until it fully understands the project
2. **Client-Readable Briefs** - Plain English output before any code
3. **Technical Specs** - Detailed requirements that prevent ambiguity
4. **Incremental RLS** - Security applied one table at a time, tested between each
5. **Context Protection** - Guardrails to prevent context window bloat
6. **Self-Improvement** - System learns from each build

## Quick Start

```powershell
# 1. Clone this template for a new project
# (Use GitHub's "Use this template" button)

# 2. Navigate to your project
cd your-new-project

# 3. Create your first spec
.\scripts\new-spec.ps1 "my-feature"

# 4. Start Claude Code
claude

# 5. Begin the intake process
# (Claude will automatically start asking questions)
```

## The Build Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                         BUILD PIPELINE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  /start ──▶ /spec ──▶ /plan ──▶ [RESET] ──▶ /code ──▶ /qa ──▶ /rls │
│     │         │         │          │          │        │       │    │
│     ▼         ▼         ▼          │          ▼        ▼       ▼    │
│  project   spec.md   impl-plan    NEW      code    qa-rpt   rls-rpt│
│  brief.md            .md        SESSION    files    .md      .md   │
│                                                                     │
│                         [CONTEXT RESET POINT]                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Key Concepts

### Context Protection
Your context window is precious. The system protects it by:
- Running skills in isolated context (`context-fork: true`)
- Requiring fresh sessions between Plan and Code phases
- Truncating large outputs (test results, git diffs)
- Suggesting `/compact` at 60% usage

### Modular Architecture
Everything is a separate file that can be edited independently:
- Commands in `.claude/commands/`
- Skills in `.claude/skills/`
- Reference docs in `.claude/reference/`
- Templates in `templates/`

### Self-Annealing
After each build:
1. Issues are logged to `BUILD-LOG.md`
2. Run `/improve` to review patterns
3. System suggests specific file edits
4. You approve changes in batch

## File Structure

```
your-project/
├── CLAUDE.md                    # Main system instructions
├── BUILD-LOG.md                 # Build history for self-improvement
├── .claude/
│   ├── commands/                # Slash commands
│   │   ├── start.md            # /start - Intake questionnaire
│   │   ├── spec.md             # /spec - Technical specification
│   │   ├── plan.md             # /plan - Implementation planning
│   │   ├── code.md             # /code - Coding phase
│   │   ├── qa.md               # /qa - QA review
│   │   ├── rls.md              # /rls - RLS security phase
│   │   ├── status.md           # /status - Project status
│   │   ├── compact.md          # /compact - Context management
│   │   └── improve.md          # /improve - System improvement
│   ├── skills/                  # Reusable expertise (run in forked context)
│   │   ├── n8n-patterns.md
│   │   ├── supabase-patterns.md
│   │   ├── rls-testing.md
│   │   └── client-deliverables.md
│   └── reference/               # Deep context (loaded only when needed)
│       ├── api-development.md
│       ├── frontend-components.md
│       ├── database-design.md
│       ├── n8n-workflows.md
│       └── deployment.md
├── templates/                   # Document templates
│   ├── project-brief.md
│   ├── spec-template.md
│   └── table-of-tables.md
├── scripts/                     # PowerShell automation
│   ├── new-spec.ps1
│   ├── setup-worktree.ps1
│   └── cleanup-worktree.ps1
├── specs/                       # Project-specific specs
│   ├── current/                # Symlink to active spec
│   └── 001-my-feature/
│       ├── project-brief.md
│       ├── spec.md
│       ├── table-of-tables.md
│       ├── implementation-plan.md
│       ├── qa-report.md
│       └── rls-report.md
└── docs/
    ├── SYSTEM-OVERVIEW.md      # This file
    └── QUICK-REFERENCE.md      # Cheat sheet
```

## Commands Reference

| Command | Purpose | Output |
|---------|---------|--------|
| `/start` | Begin intake (Claude asks questions) | project-brief.md |
| `/spec` | Generate technical specification | spec.md, table-of-tables.md |
| `/plan` | Create implementation subtasks | implementation-plan.md |
| `/code` | Implement code (fresh session!) | Code files |
| `/qa` | Review against acceptance criteria | qa-report.md |
| `/rls` | Apply RLS one table at a time | rls-report.md |
| `/status` | Show current project status | Status summary |
| `/compact` | Reduce context, create handoff | HANDOFF.md |
| `/improve` | Suggest system improvements | Improvement suggestions |

## Critical Rules

1. **Always reset context between Plan and Code** - Non-negotiable
2. **RLS is applied ONE table at a time** - Test between each
3. **Skills run in forked context** - Don't eat main context
4. **Output to files, not chat** - Preserve important information
5. **Check `/context` at 60%** - Compact or handoff before problems

## Customization

### Adding a New Skill
1. Create `.claude/skills/my-skill.md`
2. Add frontmatter: `context-fork: true`
3. Document the expertise
4. Reference in CLAUDE.md if always needed

### Adding a New Command
1. Create `.claude/commands/my-command.md`
2. Define the behavior
3. Include context checkpoint at end

### Adding Reference Context
1. Create `.claude/reference/my-topic.md`
2. Add deep, task-specific information
3. Reference in CLAUDE.md with load condition

## Troubleshooting

**Claude doesn't follow the system:**
- Check CLAUDE.md is in project root
- Restart Claude Code session

**Context filling up too fast:**
- Run `/compact`
- Start fresh session more often
- Check skills have `context-fork: true`

**RLS blocking everything:**
- Check you're applying ONE table at a time
- Use RLS testing helpers
- Review the specific policy that was just applied

**Worktree issues:**
- `git worktree remove .worktrees/name --force`
- `git worktree prune`
