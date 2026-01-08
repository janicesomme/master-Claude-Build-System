# Deployment Reference

**Load this only when deploying or setting up infrastructure.**

## Supabase Deployment

### Environment Setup
```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link to project
supabase link --project-ref your-project-ref
```

### Database Migrations
```bash
# Create new migration
supabase migration new my_migration_name

# Run migrations locally
supabase db reset

# Push to production
supabase db push

# Pull remote schema
supabase db pull
```

### Edge Functions
```bash
# Create function
supabase functions new my-function

# Deploy single function
supabase functions deploy my-function

# Deploy all functions
supabase functions deploy

# View logs
supabase functions logs my-function
```

### Environment Variables
```bash
# Set secret
supabase secrets set MY_SECRET=value

# List secrets
supabase secrets list

# Unset secret
supabase secrets unset MY_SECRET
```

## Vercel Deployment

### Project Setup
```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Link project
vercel link

# Deploy preview
vercel

# Deploy production
vercel --prod
```

### Environment Variables
```bash
# Add variable
vercel env add VARIABLE_NAME

# Pull variables to .env.local
vercel env pull
```

### vercel.json Configuration
```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "regions": ["iad1"],
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL": "@supabase-url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase-anon-key"
  },
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "no-store" }
      ]
    }
  ]
}
```

## n8n Cloud

### Workflow Export/Import
```bash
# Export workflow (via API)
curl -X GET "https://your-instance.app.n8n.cloud/api/v1/workflows/123" \
  -H "X-N8N-API-KEY: your-api-key" > workflow.json

# Import workflow
curl -X POST "https://your-instance.app.n8n.cloud/api/v1/workflows" \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json" \
  -d @workflow.json
```

### Credentials Management
- Never export credentials in workflow JSON
- Use environment variables for sensitive values
- Document required credentials in README

## Environment Configuration

### .env Structure
```bash
# .env.example (commit this)
# Database
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Auth
NEXTAUTH_SECRET=
NEXTAUTH_URL=

# APIs
OPENAI_API_KEY=
ANTHROPIC_API_KEY=

# n8n
N8N_WEBHOOK_URL=
N8N_API_KEY=
```

### Environment Validation
```typescript
// lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
  SUPABASE_URL: z.string().url(),
  SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  NEXTAUTH_SECRET: z.string().min(32),
  NEXTAUTH_URL: z.string().url(),
});

export const env = envSchema.parse(process.env);
```

## Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing
- [ ] No TypeScript errors
- [ ] No ESLint errors
- [ ] Build completes successfully

### Security
- [ ] No secrets in code
- [ ] Environment variables set
- [ ] RLS policies applied and tested
- [ ] API routes authenticated
- [ ] CORS configured correctly

### Database
- [ ] Migrations tested
- [ ] Indexes added for queries
- [ ] RLS policies in place
- [ ] Backup configured

### Performance
- [ ] Images optimized
- [ ] API responses cached where appropriate
- [ ] Database queries optimized
- [ ] Bundle size checked

### Monitoring
- [ ] Error tracking configured (Sentry, etc.)
- [ ] Logging in place
- [ ] Health check endpoint exists
- [ ] Alerts configured

## Rollback Procedures

### Vercel
```bash
# List deployments
vercel ls

# Rollback to previous
vercel rollback [deployment-url]
```

### Supabase Migrations
```sql
-- Always write reversible migrations
-- Up
ALTER TABLE users ADD COLUMN phone TEXT;

-- Down (comment, but document)
-- ALTER TABLE users DROP COLUMN phone;
```

### n8n
- Keep workflow versions (export before major changes)
- Use workflow tags for versioning
- Test in staging workflow before production

## Health Check Endpoint

```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function GET() {
  const checks = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {} as Record<string, string>
  };

  // Check Supabase
  try {
    const supabase = createClient(
      process.env.SUPABASE_URL!,
      process.env.SUPABASE_ANON_KEY!
    );
    await supabase.from('health_check').select('count').single();
    checks.services.database = 'ok';
  } catch (error) {
    checks.services.database = 'error';
    checks.status = 'degraded';
  }

  // Add more service checks as needed

  return NextResponse.json(checks, {
    status: checks.status === 'ok' ? 200 : 503
  });
}
```
