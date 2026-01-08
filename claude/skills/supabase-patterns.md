---
context-fork: true
model: claude-sonnet-4-20250514
---

# Supabase Patterns & Best Practices

Your expertise for building Supabase backends.

## Critical Rule: RLS Timing

**DO NOT apply RLS during initial build.**

```sql
-- During build:
CREATE TABLE my_table (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- columns...
);

-- Add this comment:
-- RLS: To be configured in Phase 5
-- Access: [document intent]
```

RLS is applied in a dedicated phase AFTER all functionality is tested.

---

## Table Design Patterns

### Standard Columns

Every table should have:
```sql
CREATE TABLE example (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Your columns here
  
  -- Timestamps (always include)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-update updated_at
CREATE TRIGGER update_example_updated_at
  BEFORE UPDATE ON example
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### The update_updated_at function:
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Multi-Tenant Pattern

Always include tenant identifier:
```sql
CREATE TABLE resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id),  -- Tenant
  user_id UUID NOT NULL REFERENCES auth.users(id),    -- Owner
  
  -- Your columns
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for tenant queries
CREATE INDEX idx_resources_org_id ON resources(org_id);
CREATE INDEX idx_resources_user_id ON resources(user_id);
```

---

## Foreign Key Patterns

### Required Reference (NOT NULL)
```sql
user_id UUID NOT NULL REFERENCES auth.users(id)
```

### Optional Reference (Nullable)
```sql
manager_id UUID REFERENCES auth.users(id)
```

### Cascade Delete (Child deleted when parent deleted)
```sql
project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE
```

### Restrict Delete (Prevent parent deletion if children exist)
```sql
category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT
```

### Set Null (Set to NULL when parent deleted)
```sql
assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL
```

---

## Index Patterns

### Single Column (Most common)
```sql
CREATE INDEX idx_[table]_[column] ON [table]([column]);
```

### Composite (Multi-column queries)
```sql
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
-- Good for: WHERE user_id = X AND status = Y
```

### Partial (Filtered index)
```sql
CREATE INDEX idx_orders_pending ON orders(created_at)
WHERE status = 'pending';
-- Good for: Frequent queries on pending orders
```

### When to Add Indexes
- ✅ Foreign keys
- ✅ Frequently filtered columns
- ✅ Columns used in ORDER BY
- ✅ Columns used in JOIN conditions
- ❌ Low-cardinality columns (boolean, enum with few values)
- ❌ Rarely queried columns

---

## Edge Function Patterns

### Basic Structure
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // CORS headers
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders })
    }

    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Your logic here
    const { data, error } = await supabaseClient
      .from('table')
      .select('*')

    if (error) throw error

    return new Response(
      JSON.stringify({ data }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```

### With Service Role (Bypass RLS)
```typescript
// Only use when you NEED to bypass RLS
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)
```

---

## Query Patterns

### Safe Pagination
```typescript
const { data, error, count } = await supabase
  .from('items')
  .select('*', { count: 'exact' })
  .range(offset, offset + limit - 1)
  .order('created_at', { ascending: false });
```

### Full-Text Search
```sql
-- Add search column
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Update trigger
CREATE FUNCTION products_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_search_update
  BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION products_search_trigger();

-- Index
CREATE INDEX idx_products_search ON products USING GIN(search_vector);
```

```typescript
// Query
const { data } = await supabase
  .from('products')
  .select('*')
  .textSearch('search_vector', query);
```

### Upsert Pattern
```typescript
const { data, error } = await supabase
  .from('configs')
  .upsert(
    { key: 'setting', value: 'new_value' },
    { onConflict: 'key' }
  );
```

---

## Realtime Patterns

### Subscribe to Changes
```typescript
const subscription = supabase
  .channel('table_changes')
  .on(
    'postgres_changes',
    {
      event: '*',  // INSERT, UPDATE, DELETE, or *
      schema: 'public',
      table: 'messages',
      filter: `room_id=eq.${roomId}`  // Optional filter
    },
    (payload) => {
      console.log('Change received:', payload)
    }
  )
  .subscribe()
```

### Cleanup
```typescript
// Always unsubscribe when done
subscription.unsubscribe()
```

---

## Migration Best Practices

### File Naming
```
supabase/migrations/
├── 20240115000001_create_users.sql
├── 20240115000002_create_organizations.sql
├── 20240115000003_create_properties.sql
└── 20240115000004_add_indexes.sql
```

### Migration Structure
```sql
-- Migration: 20240115000001_create_users.sql
-- Description: Create users table
-- Dependencies: None

-- Up
CREATE TABLE users (
  -- ...
);

-- Note: RLS will be applied in separate security migration
-- RLS: Phase 5 - User access control

-- Down (optional, for rollback)
-- DROP TABLE users;
```

### Run Migrations
```bash
# Local
supabase db reset

# Production
supabase db push
```

---

## Common Pitfalls to Avoid

❌ **Hardcoding IDs**
```typescript
// Bad
.eq('user_id', '123e4567-e89b-12d3-a456-426614174000')

// Good
.eq('user_id', userId)
```

❌ **Missing error handling**
```typescript
// Bad
const { data } = await supabase.from('users').select()

// Good
const { data, error } = await supabase.from('users').select()
if (error) throw error
```

❌ **N+1 queries**
```typescript
// Bad - N+1 queries
for (const user of users) {
  const { data: orders } = await supabase
    .from('orders')
    .select('*')
    .eq('user_id', user.id)
}

// Good - Single query with join
const { data } = await supabase
  .from('users')
  .select(`
    *,
    orders (*)
  `)
```

❌ **Not using transactions for related inserts**
```typescript
// Use Edge Function with service role for transactions
const { data, error } = await supabaseAdmin.rpc('create_order_with_items', {
  order_data: orderData,
  items_data: itemsData
})
```
