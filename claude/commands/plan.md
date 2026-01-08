# /plan - Implementation Planner Agent

You are now the **Planner Agent**. Break down the specification into ordered, parallelizable subtasks that Coder Agents can execute independently.

## Prerequisites

Before running this command:
- [ ] spec.md must exist in specs/current/
- [ ] table-of-tables.md must exist in specs/current/

If these don't exist, tell the user to run `/spec` first.

## Process

### Step 1: Analyze the Spec
Read the spec and identify:
- All components that need to be built
- Dependencies between components
- Which tasks can run in parallel
- The critical path

### Step 2: Identify Parallelization
Look for tasks that:
- Don't depend on each other's output
- Work on different files
- Can be merged without conflicts

### Step 3: Create Subtasks
Break work into subtasks that are:
- **Atomic** - Can be completed in one session
- **Independent** - Minimal dependencies
- **Testable** - Clear success criteria
- **Sized right** - 30-90 minutes each

### Step 4: Sequence the Work
Order so that:
- Dependencies are respected
- Parallel tasks are grouped
- Database/schema changes come FIRST
- UI components come LAST
- RLS is a SEPARATE FINAL PHASE

## Output Format

```markdown
# Implementation Plan: [Task Title]

## Overview
- **Total Subtasks:** [NUMBER]
- **Parallel Groups:** [NUMBER]
- **Estimated Total Time:** [HOURS]
- **Complexity:** [simple | standard | complex]

## Dependency Graph
```
[ASCII diagram showing task dependencies]
```

## Subtasks

### Group 1: Database Layer (Sequential)

#### Subtask 1.1: Create Database Schema
- **Files:** 
  - `supabase/migrations/001_initial_schema.sql`
- **Description:** Create all tables per table-of-tables.md WITHOUT RLS
- **Dependencies:** None
- **Acceptance Criteria:**
  - [ ] All tables created
  - [ ] All foreign keys in place
  - [ ] All indexes created
  - [ ] NO RLS enabled (that's Phase 7)
- **Estimated Time:** 30 minutes

### Group 2: Backend Layer (Can Parallel)

#### Subtask 2.1: [API/Function Name]
- **Files:** [list]
- **Description:** [what to implement]
- **Dependencies:** Subtask 1.1
- **Acceptance Criteria:**
  - [ ] [Criterion]
- **Estimated Time:** [minutes]

#### Subtask 2.2: [API/Function Name]
- **Files:** [list]
- **Description:** [what to implement]  
- **Dependencies:** Subtask 1.1
- **Acceptance Criteria:**
  - [ ] [Criterion]
- **Estimated Time:** [minutes]

### Group 3: Frontend Layer (After Backend)

#### Subtask 3.1: [Component Name]
...

### Group 4: Integration & Testing

#### Subtask 4.1: Integration Tests
- **Files:** [test files]
- **Description:** Test all components working together
- **Dependencies:** All previous groups
- **Acceptance Criteria:**
  - [ ] All API endpoints return expected data
  - [ ] All UI components render correctly
  - [ ] All workflows complete successfully
- **Estimated Time:** 60 minutes

### Phase 5: RLS Security Layer (SEPARATE - After All Tests Pass)

**⚠️ DO NOT START THIS PHASE UNTIL ALL OTHER TESTS PASS**

#### Subtask 5.1: Apply RLS to [first table in dependency order]
- **Table:** [table_name]
- **Policies to create:** [list from table-of-tables.md]
- **Test after:** Verify [role] can/cannot access as expected

#### Subtask 5.2: Apply RLS to [second table]
...

[Continue for all tables in dependency order from table-of-tables.md]

## Integration Notes
- Merge order: [which branches merge first]
- Potential conflicts: [areas to watch]

## Risk Areas
- [Parts that might be tricky]

## Worktree Setup

For this build, create:
```powershell
# If simple (1-2 subtasks):
.\scripts\setup-worktree.ps1 -TaskId "[ID]" -TaskName "[name]"

# If standard (3-5 subtasks):
.\scripts\setup-worktree.ps1 -TaskId "[ID]" -TaskName "[name]" -Parallel 2

# If complex (6+ subtasks):
.\scripts\setup-worktree.ps1 -TaskId "[ID]" -TaskName "[name]" -Parallel 3
```
```

Save to: `specs/current/implementation-plan.md`

## After Planning

Tell the user:
```
Implementation plan created with [X] subtasks in [Y] parallel groups.

Next steps:
1. Review the plan above
2. Run the worktree setup command shown
3. **IMPORTANT: Start a FRESH Claude Code session for coding**
4. In the new session, run ONLY: cat specs/current/implementation-plan.md
5. Then type `/code` to start building

⚠️ DO NOT continue coding in this session. The context reset between 
planning and coding is critical for code quality.

Ready to proceed?
```

## Context Checkpoint (CRITICAL)

**The transition from Plan → Code MUST include a context reset.**

Why:
- Planning accumulates lots of exploratory context
- Coding needs maximum context for reasoning about code
- Clean context = better code quality

After completing plan:
1. Save implementation-plan.md to `specs/current/`
2. Instruct user to START NEW SESSION
3. New session loads ONLY the implementation plan
4. This is non-negotiable for quality
