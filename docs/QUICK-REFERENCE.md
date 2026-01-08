# Quick Reference Card

Print this or keep it open while working.

---

## Build Pipeline

```
/start ──▶ /spec ──▶ /plan ──▶ [NEW SESSION] ──▶ /code ──▶ /qa ──▶ /rls
   │          │         │            │              │        │       │
   ▼          ▼         ▼            │              ▼        ▼       ▼
 brief     spec.md    plan.md    FRESH         code     qa-rpt   secure
                                SESSION        files
```

**⚠️ ALWAYS start fresh session between /plan and /code**

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/start` | Claude asks YOU questions |
| `/spec` | Creates technical spec |
| `/plan` | Breaks into subtasks |
| `/code` | Implements code |
| `/qa` | Reviews against spec |
| `/rls` | Applies security (1 table at a time) |
| `/status` | Shows project state |
| `/compact` | Saves context, creates handoff |
| `/improve` | Suggests system updates |

---

## Context Management

| Usage | Action |
|-------|--------|
| < 50% | Continue normally |
| 50-60% | Plan upcoming handoff |
| > 60% | Run `/compact` or start new session |
| > 80% | STOP - Start fresh immediately |

**Check with:** `/context`

---

## Worktree Commands

```powershell
# Create new spec
.\scripts\new-spec.ps1 "feature-name"

# Setup worktree (single agent)
.\scripts\setup-worktree.ps1 -TaskId "001" -TaskName "feature"

# Setup worktrees (parallel)
.\scripts\setup-worktree.ps1 -TaskId "001" -TaskName "feature" -Parallel 3

# Merge and cleanup
.\scripts\cleanup-worktree.ps1 -Spec "001-feature" -Action merge

# Discard work
.\scripts\cleanup-worktree.ps1 -Spec "001-feature" -Action discard
```

---

## RLS Phase Rules

1. ✅ Apply to ONE table
2. ✅ Test that table
3. ✅ If pass → next table
4. ❌ If fail → fix before continuing
5. ✅ Repeat until all tables secure

**Order:** Parent tables before child tables

---

## File Locations

| What | Where |
|------|-------|
| Commands | `.claude/commands/` |
| Skills | `.claude/skills/` |
| Reference docs | `.claude/reference/` |
| Templates | `templates/` |
| Current spec | `specs/current/` |
| Build history | `BUILD-LOG.md` |

---

## Output Truncation Rules

| Output Type | Rule |
|-------------|------|
| Test results | Failures only, count passes |
| Git diffs | Summarize by file |
| Build logs | Errors and warnings only |
| Lint output | Errors only, count warnings |
| Query results | Count + sample rows |

---

## Session Transitions

| From | To | Action |
|------|-----|--------|
| /start | /spec | Same session OK if < 60% |
| /spec | /plan | Same session OK if < 50% |
| /plan | /code | **NEW SESSION (required)** |
| /code | /qa | Same session OK if < 60% |
| /qa | /rls | Fresh session recommended |

---

## Emergency Commands

```powershell
# Force remove stuck worktree
git worktree remove .worktrees/name --force

# Clean up orphaned worktrees
git worktree prune

# Abort merge
git merge --abort

# Check what's using context
/context
```

---

## Complexity Guide

| Level | Subtasks | Parallel Agents | Approx Time |
|-------|----------|-----------------|-------------|
| Simple | 1-2 | 1 | < 2 hours |
| Standard | 3-5 | 2 | 2-8 hours |
| Complex | 6+ | 3 | 1+ days |

---

## Self-Improvement Cycle

1. Complete a build
2. Review `BUILD-LOG.md`
3. Run `/improve`
4. Approve/reject suggestions
5. System gets better

---

## Key Principles

1. **Context is precious** - Protect it
2. **Files over chat** - Output to files
3. **Reset between phases** - Fresh context = better code
4. **One RLS at a time** - Isolate security issues
5. **Log everything** - Future you will thank you
