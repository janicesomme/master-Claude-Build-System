# Table of Tables Template

Use this template to document all database tables, their columns, and relationships.

---

```markdown
# Table of Tables

**Project:** [Project Name]
**Generated:** [DATE]
**Database:** Supabase PostgreSQL

---

## Overview

| Table | Purpose | Row Count Est. | RLS Status |
|-------|---------|----------------|------------|
| [table_name] | [brief purpose] | [estimate] | ⏳ Pending |

---

## Detailed Schema

### [table_name]

**Purpose:** [What this table stores]

| Column | Type | Nullable | Default | References | Notes |
|--------|------|----------|---------|------------|-------|
| id | uuid | NO | gen_random_uuid() | - | Primary key |
| created_at | timestamptz | NO | now() | - | |
| updated_at | timestamptz | NO | now() | - | |
| [column] | [type] | [YES/NO] | [default] | [table.column] | [notes] |

**Indexes:**
- `idx_[table]_[column]` on ([column]) - [reason]

**Depends on:** [list tables this references]
**Depended on by:** [list tables that reference this]

**RLS Intent (Phase 7):**
| Role | SELECT | INSERT | UPDATE | DELETE |
|------|--------|--------|--------|--------|
| anon | ❌ | ❌ | ❌ | ❌ |
| authenticated | [scope] | [scope] | [scope] | [scope] |
| [custom_role] | [scope] | [scope] | [scope] | [scope] |
| service_role | All | All | All | All |

---

## Dependency Graph

```
[ASCII diagram showing table relationships]

Example:
organizations
    │
    ├──→ users (org_id)
    │       │
    │       ├──→ user_roles (user_id)
    │       │
    │       └──→ properties (owner_id)
    │               │
    │               ├──→ leases (property_id)
    │               │
    │               └──→ maintenance_requests (property_id)
    │
    └──→ properties (org_id)
```

---

## RLS Application Order

Based on dependencies - parent tables first:

1. [ ] `organizations` - No dependencies
2. [ ] `users` - Depends on organizations
3. [ ] `user_roles` - Depends on users
4. [ ] `properties` - Depends on users, organizations
5. [ ] `leases` - Depends on properties
6. [ ] `maintenance_requests` - Depends on properties

**Note:** Apply RLS one table at a time. Test after each. See `/rls` command.

---

## Junction Tables

| Table | Connects | Purpose |
|-------|----------|---------|
| [junction_table] | [table_a] ↔ [table_b] | [purpose] |

---

## Enums / Lookup Values

### [enum_name]
```sql
CREATE TYPE [enum_name] AS ENUM (
  'value_1',
  'value_2',
  'value_3'
);
```

---

## Migration Notes

- [ ] Create tables in dependency order
- [ ] Add foreign keys after all tables exist
- [ ] Create indexes after data population
- [ ] RLS applied in Phase 7 (after testing)

---

## SQL Preview

```sql
-- Run in this order:

-- 1. Enums
CREATE TYPE [enum] AS ENUM (...);

-- 2. Tables (in dependency order)
CREATE TABLE organizations (...);
CREATE TABLE users (...);
-- etc.

-- 3. Indexes
CREATE INDEX idx_... ON ...;

-- 4. RLS (Phase 7 - NOT NOW)
-- ALTER TABLE [table] ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY ...
```
```

---

## Usage Notes

When generating Table of Tables:

1. **List ALL tables** - Don't miss any
2. **Show dependencies clearly** - Foreign keys, references
3. **Document RLS intent** - But mark as "Phase 7"
4. **Include the dependency graph** - Visual helps debugging
5. **Specify application order** - For both creation and RLS

Save to: `specs/current/table-of-tables.md`
