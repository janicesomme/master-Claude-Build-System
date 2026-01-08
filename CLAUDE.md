# Master Build System

You are operating within Janice's Master Build System - a structured, repeatable methodology for building production-ready applications.

## Context Window Protection (CRITICAL)

Your context window is precious. Protect it at all costs:

### Core Rules
1. **Check usage frequently** - Run `/context` after each phase
2. **At 60% usage** - Plan a handoff or run `/compact`
3. **Never dump large outputs** - Summarize, truncate, reference files instead
4. **Reset between phases** - ALWAYS clear context between Plan and Code phases
5. **Use sub-agents (Ctrl+B)** - For any task that might be token-heavy
6. **Fork skills** - All skills run in isolated context automatically

### Output Rules
- **Test results:** Show only failures, count passes (e.g., "47 passed, 2 failed: [details of failures only]")
- **Git diffs:** Summarize changes by file, don't paste entire diff unless asked
- **File contents:** Read specific line ranges, not whole files when possible
- **Build logs:** Show only errors and warnings, not full output
- **Database queries:** Show row counts and sample, not full result sets

### Phase Transitions
After completing any phase, ALWAYS:
1. Output the deliverable to a file (not just chat)
2. Run `/context` to check usage
3. If above 60%: Suggest starting fresh session with just the output document
4. If starting Code phase: MUST start fresh session with only implementation-plan.md

## System Overview

This system guides you through a complete build pipeline:
1. **Discovery** - You ask questions until you understand the project
2. **Brief** - You produce a client-readable project brief
3. **Spec** - You create a technical specification
4. **Plan** - You break the spec into implementation subtasks
5. **Build** - You implement the code in isolated worktrees
6. **QA** - You review against acceptance criteria
7. **RLS** - You apply Row Level Security one table at a time
8. **Improve** - You suggest system improvements based on what you learned

## Critical Rules

### RLS Policy
**DO NOT apply RLS policies during build phases.**
- Create tables WITHOUT enabling RLS
- Add comment: `-- RLS: To be configured in security phase`
- Document intended access patterns in spec
- RLS is applied ONE TABLE AT A TIME in Phase 7, with testing between each

### n8n MCP Integration
You have access to n8n via MCP. Use it with these guardrails:
- ✅ READ: Search existing workflows, get workflow details
- ✅ CREATE: New workflows in draft/test state only
- ✅ EXECUTE: Test workflows only, never production
- ❌ NEVER: Modify existing workflows without explicit approval

### Build Quality
- Use `ultrathink` for architecture decisions
- Use async sub-agents (Ctrl+B) for parallel documentation
- Run `/context` at 60% usage to plan handoffs
- Every build produces: code + docs + client brief

## Auto-Imported Context

@specs/current/project-brief.md
@specs/current/spec.md
@specs/current/table-of-tables.md
@specs/current/implementation-plan.md
@BUILD-LOG.md

## Available Commands

| Command | Purpose |
|---------|---------|
| `/start` | Begin intake for new project (Claude asks YOU questions) |
| `/brief` | Show/regenerate project brief |
| `/spec` | Generate technical specification |
| `/plan` | Create implementation plan with subtasks |
| `/code` | Start coding phase |
| `/qa` | Run QA review against spec |
| `/rls` | Apply RLS policies incrementally |
| `/status` | Show current project status |
| `/improve` | Review build log and suggest system improvements |

## On First Contact

If no project-brief.md exists in specs/current/, immediately start the intake process by running the /start command behavior - ask the user questions to understand what they're building.

If project-brief.md exists, greet the user with current project status and ask what they want to work on.

## Skills Loaded

@.claude/skills/n8n-patterns.md
@.claude/skills/supabase-patterns.md
@.claude/skills/rls-testing.md
@.claude/skills/client-deliverables.md

## Reference Documents (Load Only When Needed)

These contain deep context for specific task types. Only read when working on that task:
- API development: @.claude/reference/api-development.md
- Frontend components: @.claude/reference/frontend-components.md
- Database design: @.claude/reference/database-design.md
- n8n workflows: @.claude/reference/n8n-workflows.md
- Deployment: @.claude/reference/deployment.md

## Documentation Standards

Every build MUST produce these deliverables:
1. **project-brief.md** - Client-readable overview (plain English)
2. **spec.md** - Technical specification
3. **table-of-tables.md** - All database tables with dependencies
4. **implementation-plan.md** - Subtask breakdown
5. **README.md** - How to run/deploy
6. **ARCHITECTURE.md** - System diagram and data flow
7. **TROUBLESHOOTING.md** - Common issues and fixes

## Build Log

After each build phase, append to BUILD-LOG.md:
- Issues encountered
- Manual overrides made
- Suggested system improvements

When user runs `/improve`, review BUILD-LOG.md and suggest specific file edits.
