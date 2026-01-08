# /improve - Self-Annealing Review

Review the build log and suggest improvements to the Master Build System.

## When This Runs

After each build completes (or on demand), this command:
1. Reviews BUILD-LOG.md for issues and patterns
2. Identifies repeated problems
3. Suggests specific file edits
4. Presents suggestions for user approval

## Process

### Step 1: Read Build Log
```bash
cat BUILD-LOG.md
```

Look for:
- Repeated issues across builds
- Questions you had to ask mid-build (should be in intake)
- Workarounds you had to implement
- RLS policies that consistently broke
- Patterns you reused multiple times

### Step 2: Categorize Improvements

**Intake Questions**
- Questions that should have been asked upfront
- Industry-specific info that was missing
- Technical requirements that weren't captured

**Templates**
- Sections that needed editing every time
- Missing standard fields
- Format improvements

**Skills**
- Patterns used repeatedly (should be codified)
- New integrations learned
- Error handling improvements

**Process**
- Steps that should be reordered
- Phases that could be parallelized
- Checks that should be added

### Step 3: Generate Suggestions

```markdown
# System Improvement Suggestions

Based on recent builds, I recommend the following updates:

---

## Suggestion 1: Add Intake Question
**Category:** Intake
**File:** `.claude/commands/start.md`
**Reason:** Last 2 builds required asking about [X] mid-build

**Proposed Addition:**
```markdown
### Category 2: System Scope
- [ ] [NEW] Does the system need [X] capability?
```

**Apply this change?** [Yes/No]

---

## Suggestion 2: Add Pattern to Skills
**Category:** Skills
**File:** `.claude/skills/n8n-patterns.md`
**Reason:** Used [pattern] in 3 consecutive builds

**Proposed Addition:**
```javascript
// [Pattern name]
[Code block]
```

**Apply this change?** [Yes/No]

---

## Suggestion 3: Update Template
**Category:** Templates
**File:** `templates/table-of-tables.md`
**Reason:** Always had to add [section] manually

**Proposed Addition:**
[Specific template change]

**Apply this change?** [Yes/No]

---

## Summary
- **3 suggestions** ready for review
- Run `/improve apply` to apply approved changes
- Run `/improve skip` to dismiss until next build
```

### Step 4: Apply Approved Changes

When user approves a suggestion:
1. Edit ONLY the specified file
2. Make ONLY the specified change
3. Confirm the change was made
4. Log the improvement to BUILD-LOG.md

```markdown
## System Improvement Applied
- **Date:** [timestamp]
- **File:** [filename]
- **Change:** [description]
- **Reason:** [why it was needed]
```

## What Gets Logged to BUILD-LOG.md

After each build phase, automatically append:

```markdown
---

## Build: [DATE] - [Project Name]

### Phase Completed: [Phase Name]

### Issues Encountered
- [ ] [Issue description] - [How it was resolved]

### Questions Asked Mid-Build
- [Question] - [Answer received]
- (These should become intake questions)

### Manual Overrides
- [What was changed from default/template]

### Patterns Reused
- [Pattern name] from [previous build]

### New Patterns Discovered
- [Description] - Consider adding to skills

### Suggested System Updates
- [ ] [Specific suggestion]
```

## Self-Annealing Rules

1. **Never auto-apply changes** - Always get user approval
2. **Be specific** - Show exact file and exact change
3. **Explain why** - Reference the builds that triggered suggestion
4. **One change per suggestion** - Easy to approve/reject individually
5. **Log everything** - Track what was improved and why
6. **Batch suggestions** - Present after build, not during

## Triggering Improvement Review

Automatic prompts:
- After `/rls` phase completes (build done)
- After 3 builds without running `/improve`

Manual trigger:
- User types `/improve`

## Example Improvement Cycle

**Build 1:** RLS on `leases` table blocked tenant access. Fixed by adding org_id check.

**Build 2:** RLS on `bookings` table blocked tenant access. Fixed by adding org_id check.

**Build 3:** `/improve` notices the pattern

```
I've noticed that RLS policies for tenant-accessible tables have 
caused issues in the last 2 builds. Both times, the fix was adding 
an org_id check.

**Suggestion:** Add a note to the RLS phase about tenant-accessible tables:

File: `.claude/commands/rls.md`

Add to "Common RLS Mistakes to Avoid":
```
- Forgetting org_id check for tenant-accessible tables
  Pattern: USING (org_id IN (SELECT org_id FROM user_orgs WHERE user_id = auth.uid()))
```

Apply this change? [Yes/No]
```
