---
context-fork: true
model: claude-sonnet-4-20250514
---

# RLS Testing Helpers

Utilities for testing Row Level Security policies during the RLS phase.

## Setup

Add this file to your project: `lib/test-utils/rls-helpers.ts`

```typescript
import { createClient, SupabaseClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL!;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY!;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!;

/**
 * Service role client - bypasses ALL RLS
 * Use for: Setup, teardown, verifying data exists
 * DO NOT use for: Testing user access
 */
export const adminClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

/**
 * Anonymous client - no authentication
 * Use for: Testing public access
 */
export const anonClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

/**
 * Create a client authenticated as a specific user
 * Use for: Testing user-specific RLS policies
 */
export async function asUser(userId: string): Promise<SupabaseClient> {
  // Get user's JWT (you'll need to implement this based on your auth setup)
  const { data: { session } } = await adminClient.auth.admin.getUserById(userId);
  
  if (!session) {
    throw new Error(`No session found for user ${userId}`);
  }

  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: {
      headers: {
        Authorization: `Bearer ${session.access_token}`,
      },
    },
  });
}

/**
 * Create a test user with a specific role
 */
export async function createTestUser(email: string, role?: string): Promise<string> {
  const { data, error } = await adminClient.auth.admin.createUser({
    email,
    password: 'test-password-123',
    email_confirm: true,
  });

  if (error) throw error;

  if (role) {
    await adminClient.from('user_roles').insert({
      user_id: data.user.id,
      role,
    });
  }

  return data.user.id;
}

/**
 * Clean up test user
 */
export async function deleteTestUser(userId: string): Promise<void> {
  await adminClient.auth.admin.deleteUser(userId);
}

/**
 * Debug helper - compare what different roles can see
 */
export async function debugRLS(
  table: string, 
  userId?: string
): Promise<void> {
  console.log(`\n=== RLS Debug: ${table} ===\n`);

  // What admin sees (all data)
  const adminResult = await adminClient.from(table).select('*');
  console.log(`Service Role sees: ${adminResult.data?.length ?? 0} rows`);

  // What anon sees
  const anonResult = await anonClient.from(table).select('*');
  console.log(`Anonymous sees: ${anonResult.data?.length ?? 0} rows`);

  // What specific user sees
  if (userId) {
    const userClient = await asUser(userId);
    const userResult = await userClient.from(table).select('*');
    console.log(`User ${userId} sees: ${userResult.data?.length ?? 0} rows`);
  }

  // Analysis
  if (adminResult.data?.length && anonResult.data?.length === 0) {
    console.log(`\n✅ Anon correctly blocked from ${table}`);
  }

  if (adminResult.data?.length && userId) {
    const userClient = await asUser(userId);
    const userResult = await userClient.from(table).select('*');
    
    if (userResult.data?.length === 0) {
      console.log(`\n⚠️  WARNING: User sees 0 rows but data exists`);
      console.log(`   This might be intentional, or RLS might be too restrictive`);
    } else if (userResult.data?.length === adminResult.data?.length) {
      console.log(`\n⚠️  WARNING: User sees ALL rows`);
      console.log(`   Check if RLS policy is too permissive`);
    } else {
      console.log(`\n✅ User sees subset of data (${userResult.data?.length}/${adminResult.data?.length})`);
    }
  }

  console.log(`\n=== End RLS Debug ===\n`);
}

/**
 * Test a specific access scenario
 */
export async function testAccess(
  table: string,
  operation: 'select' | 'insert' | 'update' | 'delete',
  role: 'anon' | 'authenticated',
  userId?: string,
  testData?: Record<string, any>,
  expectedResult: 'success' | 'blocked' = 'success'
): Promise<{ pass: boolean; message: string }> {
  
  const client = role === 'anon' 
    ? anonClient 
    : userId 
      ? await asUser(userId)
      : anonClient;

  try {
    let result;

    switch (operation) {
      case 'select':
        result = await client.from(table).select('*').limit(1);
        break;
      case 'insert':
        result = await client.from(table).insert(testData!).select();
        break;
      case 'update':
        result = await client.from(table).update(testData!).eq('id', testData!.id).select();
        break;
      case 'delete':
        result = await client.from(table).delete().eq('id', testData!.id);
        break;
    }

    const wasSuccessful = !result.error && (result.data?.length ?? 0) > 0;
    const wasBlocked = !!result.error || (result.data?.length ?? 0) === 0;

    if (expectedResult === 'success' && wasSuccessful) {
      return { pass: true, message: `✅ ${role} CAN ${operation} on ${table}` };
    } else if (expectedResult === 'blocked' && wasBlocked) {
      return { pass: true, message: `✅ ${role} BLOCKED from ${operation} on ${table}` };
    } else if (expectedResult === 'success' && wasBlocked) {
      return { pass: false, message: `❌ ${role} should be able to ${operation} on ${table} but was blocked` };
    } else {
      return { pass: false, message: `❌ ${role} should be BLOCKED from ${operation} on ${table} but succeeded` };
    }

  } catch (error) {
    if (expectedResult === 'blocked') {
      return { pass: true, message: `✅ ${role} BLOCKED from ${operation} on ${table} (error thrown)` };
    }
    return { pass: false, message: `❌ Unexpected error: ${error}` };
  }
}

/**
 * Run full RLS test suite for a table
 */
export async function testTableRLS(
  table: string,
  testUserId: string,
  otherUserId: string,
  expectedAccess: {
    anon: { select: boolean; insert: boolean; update: boolean; delete: boolean };
    ownData: { select: boolean; insert: boolean; update: boolean; delete: boolean };
    otherData: { select: boolean; insert: boolean; update: boolean; delete: boolean };
  }
): Promise<{ table: string; passed: number; failed: number; results: string[] }> {
  
  const results: string[] = [];
  let passed = 0;
  let failed = 0;

  console.log(`\n🔒 Testing RLS for: ${table}\n`);

  // Test anon access
  for (const [op, allowed] of Object.entries(expectedAccess.anon)) {
    const result = await testAccess(
      table, 
      op as any, 
      'anon', 
      undefined, 
      undefined,
      allowed ? 'success' : 'blocked'
    );
    results.push(result.message);
    if (result.pass) passed++; else failed++;
  }

  // Test user's own data access
  for (const [op, allowed] of Object.entries(expectedAccess.ownData)) {
    const result = await testAccess(
      table,
      op as any,
      'authenticated',
      testUserId,
      undefined,
      allowed ? 'success' : 'blocked'
    );
    results.push(result.message);
    if (result.pass) passed++; else failed++;
  }

  // Test access to other user's data
  for (const [op, allowed] of Object.entries(expectedAccess.otherData)) {
    const result = await testAccess(
      table,
      op as any,
      'authenticated',
      testUserId,
      { id: 'other-user-record-id' }, // Would need actual ID
      allowed ? 'success' : 'blocked'
    );
    results.push(result.message);
    if (result.pass) passed++; else failed++;
  }

  console.log(results.join('\n'));
  console.log(`\n📊 Results: ${passed} passed, ${failed} failed\n`);

  return { table, passed, failed, results };
}
```

## Usage in RLS Phase

```typescript
// When applying RLS to 'properties' table:

import { debugRLS, testTableRLS, createTestUser, deleteTestUser } from './lib/test-utils/rls-helpers';

async function testPropertiesRLS() {
  // Setup test users
  const ownerId = await createTestUser('owner@test.com');
  const otherUser = await createTestUser('other@test.com');

  // Debug what each role sees
  await debugRLS('properties', ownerId);

  // Run full test suite
  const results = await testTableRLS('properties', ownerId, otherUser, {
    anon: { select: false, insert: false, update: false, delete: false },
    ownData: { select: true, insert: true, update: true, delete: false },
    otherData: { select: false, insert: false, update: false, delete: false },
  });

  // Cleanup
  await deleteTestUser(ownerId);
  await deleteTestUser(otherUser);

  return results;
}
```

## Quick Debug Commands

```bash
# In Supabase SQL Editor, check if RLS is enabled:
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

# View all policies:
SELECT * FROM pg_policies WHERE schemaname = 'public';

# View policies for specific table:
SELECT * FROM pg_policies WHERE tablename = 'properties';
```
