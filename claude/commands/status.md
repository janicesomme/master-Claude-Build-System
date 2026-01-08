# /status - Project Status

Show the current state of the project and what phase we're in.

## Output Format

```markdown
# Project Status

## Current Project
**Client:** [Name]
**Project:** [Title]
**Started:** [Date]

## Phase Progress

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Discovery | ✅ Complete | [date] |
| 2. Brief | ✅ Complete | Approved [date] |
| 3. Spec | ✅ Complete | [X] requirements |
| 4. Plan | ✅ Complete | [X] subtasks |
| 5. Build | 🔄 In Progress | Subtask 3/5 |
| 6. QA | ⏳ Pending | |
| 7. RLS | ⏳ Pending | [X] tables |
| 8. Merge | ⏳ Pending | |

## Current Focus
**Phase:** Build
**Subtask:** 3 of 5 - "Create API endpoints"
**Worktree:** `.worktrees/001-project-name`
**Branch:** `auto-claude/001-project-name`

## Files Created
- `specs/current/project-brief.md` ✅
- `specs/current/spec.md` ✅
- `specs/current/table-of-tables.md` ✅
- `specs/current/implementation-plan.md` ✅
- `specs/current/qa-report.md` ⏳
- `specs/current/rls-report.md` ⏳

## Quick Actions
- Continue building: `cd .worktrees/001-project-name && claude`
- Run QA: `/qa`
- Check context: `/context`
- View plan: `cat specs/current/implementation-plan.md`

## Build Log Summary
- Issues encountered: [X]
- Manual overrides: [X]
- Improvements suggested: [X]
```

## How to Determine Status

1. Check which files exist in `specs/current/`
2. Check git worktree status
3. Read BUILD-LOG.md for current phase
4. Count completed subtasks from implementation plan

## Status Indicators

| Icon | Meaning |
|------|---------|
| ✅ | Complete |
| 🔄 | In Progress |
| ⏳ | Pending |
| ❌ | Blocked/Failed |
| ⚠️ | Needs Attention |

## When to Show Status

- On first contact (if project exists)
- When user asks
- After completing a phase
- When resuming after a break
