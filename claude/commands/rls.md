# /rls - Row Level Security Phase

You are now applying **Row Level Security** to the database. This happens AFTER all other testing passes.

## Critical Rules

1. **One table at a time** - Apply RLS to ONE table, test, then move to next
2. **Follow dependency order** - Parent tables before child tables (from table-of-tables.md)
3. **Test between each** - Verify access works correctly before proceeding
4. **Document everything** - Note what was applied and test results

## Prerequisites

Before starting RLS:
- [ ] All code implementation complete
- [ ] QA report shows PASS
- [ ] All tests passing WITHOUT RLS
- [ ] table-of-tables.md has RLS intent documented

## Process

### Step 1: Review RLS Application Order

From table-of-tables.md, get the dependency-ordered list:
```
1. organizations (no dependencies)
2. users (depends on organizations)
3. properties (depends on users, organizations)
4. leases (depends on properties)
... etc
```

### Step 2: Apply RLS to First Table

```sql
-- 1. Enable RLS
ALTER TABLE [table_name] ENABLE ROW LEVEL SECURITY;

-- 2. Create policies (from table-of-tables.md RLS Intent section)
CREATE POLICY "[descriptive_name]" ON [table_name]
  FOR [SELECT|INSERT|UPDATE|DELETE|ALL]
  TO [role]
  USING ([condition])
  WITH CHECK ([condition]);  -- for INSERT/UPDATE

-- 3. Add comment
COMMENT ON POLICY "[policy_name]" ON [table_name] 
  IS '[What this policy does in plain English]';
```

### Step 3: Test This Table

Run these tests BEFORE moving to next table:

```typescript
// Use the RLS testing helpers from skills/rls-testing.md

// Test 1: Admin should see all
const adminResult = await asRole('admin').from('[table]').select('*');
console.log(`Admin sees ${adminResult.data?.length} rows`);

// Test 2: User should see only their own
const userResult = await asRole('authenticated', userId).from('[table]').select('*');
console.log(`User sees ${userResult.data?.length} rows`);

// Test 3: Anon should see nothing (or public only)
const anonResult = await asRole('anon').from('[table]').select('*');
console.log(`Anon sees ${anonResult.data?.length} rows`);

// Test 4: Verify user can't see other user's data
const otherUserData = await asRole('authenticated', userId)
  .from('[table]')
  .select('*')
  .eq('owner_id', differentUserId);
console.log(`User trying to access other's data: ${otherUserData.data?.length} rows`);
// Should be 0
```

### Step 4: Record Result

```markdown
## RLS Application Log

### Table: [table_name]
- **Applied:** [timestamp]
- **Policies Created:**
  - `[policy_name]`: [description]
- **Test Results:**
  - Admin access: ✅ PASS
  - User access (own data): ✅ PASS  
  - User access (other's data): ✅ BLOCKED
  - Anon access: ✅ BLOCKED
- **Status:** ✅ COMPLETE
```

### Step 5: Proceed to Next Table

Only after current table passes all tests:
```
Table [X] RLS complete and tested. ✅

Proceeding to next table: [Y]
[X] of [Total] tables secured.
```

## RLS Policy Patterns

### User can access own data
```sql
CREATE POLICY "Users can view own records" ON [table]
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);
```

### User can access organization data
```sql
CREATE POLICY "Users can view org records" ON [table]
  FOR SELECT
  TO authenticated
  USING (
    org_id IN (
      SELECT org_id FROM user_organizations
      WHERE user_id = auth.uid()
    )
  );
```

### Role-based access
```sql
CREATE POLICY "Managers can view all" ON [table]
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'manager'
    )
  );
```

### Public read access
```sql
CREATE POLICY "Anyone can view published" ON [table]
  FOR SELECT
  TO anon, authenticated
  USING (status = 'published');
```

### Insert with ownership
```sql
CREATE POLICY "Users can insert own records" ON [table]
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);
```

## Common RLS Mistakes to Avoid

❌ `USING (true)` on sensitive tables - allows all access
❌ Forgetting `WITH CHECK` on INSERT/UPDATE policies
❌ Policies that leak data via JOINs
❌ Using client-provided IDs instead of `auth.uid()`
❌ Not testing with actual role tokens

## Output: RLS Report

After all tables are secured:

```markdown
# RLS Security Report

## Summary
- **Tables Secured:** [X] of [X]
- **Total Policies:** [Y]
- **Completion Time:** [timestamp]

## Per-Table Status

| Table | Policies | Tests | Status |
|-------|----------|-------|--------|
| organizations | 3 | ✅ All pass | ✅ Complete |
| users | 4 | ✅ All pass | ✅ Complete |
| properties | 5 | ✅ All pass | ✅ Complete |

## Security Checklist

- [x] All tables have RLS enabled
- [x] No `USING (true)` on sensitive tables
- [x] All roles tested
- [x] Cross-user access blocked
- [x] Anon access appropriate

## Ready for Production

All RLS policies applied and tested. System is secure.
```

Save to: `specs/current/rls-report.md`

## After RLS Complete

```
RLS Security Phase Complete ✅

All [X] tables secured with [Y] policies.
All access tests passing.

The build is now complete. Run `/status` for summary.
Ready to merge? Use: .\scripts\cleanup-worktree.ps1 -Spec "[spec]" -Action merge
```
