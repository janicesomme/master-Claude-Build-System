# Database Design Reference

**Load this only when designing database schemas.**

## Naming Conventions

### Tables
- Plural, snake_case: `users`, `order_items`, `user_roles`
- Junction tables: `user_organizations`, `property_amenities`

### Columns
- snake_case: `created_at`, `user_id`, `is_active`
- Foreign keys: `[table_singular]_id` (e.g., `user_id`, `org_id`)
- Booleans: `is_[adjective]` or `has_[noun]` (e.g., `is_active`, `has_verified_email`)

### Indexes
- `idx_[table]_[column(s)]`: `idx_users_email`, `idx_orders_user_status`

### Constraints
- Primary key: `[table]_pkey`
- Foreign key: `[table]_[column]_fkey`
- Unique: `[table]_[column]_key`
- Check: `[table]_[column]_check`

## Standard Columns

Every table should have:
```sql
CREATE TABLE example (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Your columns here
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger for updated_at
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON example
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## Common Patterns

### Soft Delete
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- columns...
  deleted_at TIMESTAMPTZ,  -- NULL = not deleted
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for querying non-deleted
CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL;
```

### Multi-Tenant
```sql
CREATE TABLE resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id),  -- Tenant
  -- columns...
);

-- ALWAYS filter by org_id
CREATE INDEX idx_resources_org_id ON resources(org_id);
```

### Audit Trail
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL,  -- INSERT, UPDATE, DELETE
  old_data JSONB,
  new_data JSONB,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
```

### Enum via Check Constraint
```sql
-- Option 1: Check constraint (simple)
CREATE TABLE orders (
  status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

-- Option 2: Postgres ENUM (stricter)
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
CREATE TABLE orders (
  status order_status NOT NULL DEFAULT 'pending'
);

-- Option 3: Lookup table (most flexible)
CREATE TABLE order_statuses (
  id TEXT PRIMARY KEY,  -- 'pending', 'processing', etc.
  label TEXT NOT NULL,
  sort_order INTEGER
);
CREATE TABLE orders (
  status_id TEXT NOT NULL REFERENCES order_statuses(id)
);
```

### Hierarchical Data (Self-Reference)
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES categories(id),
  name TEXT NOT NULL,
  path TEXT,  -- Materialized path: '/root/parent/child'
  depth INTEGER DEFAULT 0
);

CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_path ON categories(path);
```

### Many-to-Many with Extra Data
```sql
CREATE TABLE user_organizations (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, org_id)
);
```

## Index Strategy

### When to Create Indexes
- ✅ Foreign keys (always)
- ✅ Columns used in WHERE clauses frequently
- ✅ Columns used in ORDER BY
- ✅ Columns used in JOIN conditions
- ❌ Low-cardinality columns (few unique values)
- ❌ Tables with frequent INSERT/UPDATE (indexes slow writes)

### Index Types
```sql
-- B-tree (default, most common)
CREATE INDEX idx_users_email ON users(email);

-- GIN (for JSONB, arrays, full-text)
CREATE INDEX idx_users_metadata ON users USING GIN(metadata);

-- Partial (filtered subset)
CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';

-- Composite (multi-column)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
-- Good for: WHERE user_id = X AND status = Y
-- Good for: WHERE user_id = X (uses leftmost columns)
-- NOT good for: WHERE status = Y (can't use without user_id)
```

## Query Optimization

### Use EXPLAIN ANALYZE
```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = '...' AND status = 'pending';
```

### Avoid N+1
```sql
-- Bad: N+1 queries
SELECT * FROM orders WHERE user_id = '...';
-- Then for each order:
SELECT * FROM order_items WHERE order_id = '...';

-- Good: Single query with JOIN
SELECT o.*, oi.*
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE o.user_id = '...';
```

### Pagination
```sql
-- Offset pagination (simple but slow for large offsets)
SELECT * FROM products ORDER BY created_at DESC LIMIT 20 OFFSET 100;

-- Cursor pagination (better performance)
SELECT * FROM products 
WHERE created_at < $last_created_at
ORDER BY created_at DESC 
LIMIT 20;
```

## Migration Best Practices

1. **One migration per change** - Easy to review and rollback
2. **Include both up and down** - Even if down is just a comment
3. **Test on copy of production data** - Before running in production
4. **Non-blocking migrations** - Avoid locking tables for long periods

```sql
-- migrations/20240115000001_add_users_phone.sql

-- Up
ALTER TABLE users ADD COLUMN phone TEXT;
CREATE INDEX CONCURRENTLY idx_users_phone ON users(phone);

-- Down
-- DROP INDEX idx_users_phone;
-- ALTER TABLE users DROP COLUMN phone;
```
