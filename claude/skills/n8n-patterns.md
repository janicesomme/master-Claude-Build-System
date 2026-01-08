---
context-fork: true
model: claude-sonnet-4-20250514
---

# n8n Patterns & Best Practices

Your expertise for building n8n workflows. This skill includes patterns from the Modular AI System Framework.

## MCP Integration Guardrails

You have access to n8n via MCP. Follow these rules:

### ✅ ALLOWED
```
- Search existing workflows for patterns to reuse
- Get workflow details to understand structure
- Execute TEST workflows only
- Create NEW workflows (draft state)
```

### ❌ NOT ALLOWED
```
- Modify existing production workflows without explicit approval
- Execute production workflows
- Delete workflows
- Change workflow settings/credentials
```

### Before Modifying Existing Workflow
Always ask:
```
I found an existing workflow that I could modify: [workflow name]
This would [describe change].

Should I:
A) Modify the existing workflow
B) Create a new workflow based on it
C) Leave it alone

Please confirm before I proceed.
```

---

## Core Architecture Patterns

### Pattern 1: Agent-as-Orchestrator ⭐

One master AI agent coordinates multiple tool workflows.

**Traditional (Rigid):**
```
Trigger → Node 1 → Node 2 → Node 3 → Output
```

**Agentic (Flexible):**
```
Trigger → Init → [AI Agent] → Output
                     ↓
         ┌──────┬────┴────┬──────┐
         Tool1  Tool2  Tool3  Tool4
```

**When to Use:**
- ✅ Multi-step workflows with decision points
- ✅ Process varies based on input
- ✅ Need to add capabilities frequently
- ❌ Simple linear 2-3 step workflows (overkill)
- ❌ High-volume batch processing (cost)

---

### Pattern 2: Tool Workflow Pattern ⭐

Each capability is a separate workflow called by the master agent.

**Structure:**
```
┌─────────────────────┐
│ Execute Workflow    │ (Trigger)
│ Trigger             │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Extract Input       │ (Code Node)
│ - Parse JSON        │
│ - Validate params   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Core Logic          │ (Your actual work)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Format Output       │ (Code Node)
│ - Standardize JSON  │
└─────────────────────┘
```

**Standard Input/Output Contract:**
```javascript
// INPUT
{
  "param1": "value",
  "param2": 123,
  "agency_id": "client_name"
}

// OUTPUT
{
  "success": true,
  "data": { /* results */ },
  "metadata": {
    "execution_time_ms": 1234,
    "records_processed": 50
  },
  "error": null
}
```

**Tool Workflow Checklist:**
- [ ] Use Execute Workflow Trigger (not Webhook)
- [ ] Remove any "Respond to Webhook" nodes
- [ ] Validate inputs at start
- [ ] Handle errors gracefully
- [ ] Return standardized JSON format
- [ ] Log execution metadata
- [ ] Add timeout handling
- [ ] Include retry logic for API calls

---

### Pattern 3: Configuration-Driven Behavior ⭐

Control behavior via database, not hardcoded values.

**Bad (Hardcoded):**
```javascript
{
  agency_id: 'gatorworks',
  email: 'brian@gatorworks.net',
  model: 'claude-opus-20240229'
}
```

**Good (Config-Driven):**
```javascript
// Fetch from Supabase
const config = await supabase
  .from('system_configs')
  .select('*')
  .eq('agency_id', agency_id)
  .single();
```

**What Should Be Configurable:**
- ✅ Client-specific settings
- ✅ AI model selection
- ✅ Feature flags
- ✅ Rate limits
- ✅ Notification recipients
- ❌ Core business logic
- ❌ Security policies

---

## Error Handling Pattern

```javascript
// In every Code node that might fail:

try {
  // Your logic here
  const result = await someOperation();
  
  return {
    json: {
      success: true,
      data: result,
      error: null
    }
  };
} catch (error) {
  // Log for debugging
  console.error('Operation failed:', error.message);
  
  // Return structured error
  return {
    json: {
      success: false,
      data: null,
      error: {
        message: error.message,
        code: error.code || 'UNKNOWN',
        timestamp: new Date().toISOString()
      }
    }
  };
}
```

---

## Retry Pattern

```javascript
// Retry wrapper for flaky APIs
async function withRetry(fn, maxRetries = 3, delayMs = 1000) {
  let lastError;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      console.log(`Attempt ${attempt} failed: ${error.message}`);
      
      if (attempt < maxRetries) {
        await new Promise(r => setTimeout(r, delayMs * attempt));
      }
    }
  }
  
  throw lastError;
}

// Usage
const result = await withRetry(() => 
  $http.get('https://flaky-api.com/data')
);
```

---

## Multi-Client Pattern

Always pass `agency_id` through the entire workflow:

```javascript
// Init node
const agency_id = $json.agency_id || $input.first().json.agency_id;

if (!agency_id) {
  throw new Error('agency_id is required');
}

// Pass to all subsequent nodes
return {
  json: {
    agency_id,
    // ... other data
  }
};
```

---

## Execution Logging

```javascript
// Log every execution for self-annealing
const logEntry = {
  workflow_name: $workflow.name,
  workflow_id: $workflow.id,
  execution_id: $execution.id,
  agency_id: agency_id,
  execution_timestamp: new Date().toISOString(),
  input_summary: JSON.stringify($json).slice(0, 500),
  execution_time_ms: Date.now() - startTime,
  success: true,
  error_message: null
};

await supabase.from('execution_logs').insert(logEntry);
```

---

## Common Node Configurations

### HTTP Request with Error Handling
```json
{
  "authentication": "predefinedCredentialType",
  "options": {
    "timeout": 30000,
    "retry": {
      "maxRetries": 3
    }
  },
  "continueOnFail": true
}
```

### Supabase Query
```javascript
// Always filter by agency_id for multi-tenant
const { data, error } = await supabase
  .from('table_name')
  .select('*')
  .eq('agency_id', agency_id)
  .order('created_at', { ascending: false });

if (error) throw error;
return data;
```

---

## Workflow Organization

```
workflows/
├── master/
│   └── orchestrator.json       # Main agent workflow
├── tools/
│   ├── fetch-data.json         # Tool workflows
│   ├── analyze.json
│   ├── format-report.json
│   └── send-notification.json
├── scheduled/
│   └── daily-report.json       # Cron-triggered
└── webhooks/
    └── incoming-webhook.json   # External triggers
```

---

## Testing Workflows

Before deploying:
1. Test with mock data
2. Test error paths
3. Test rate limits
4. Test timeout handling
5. Verify logging works
6. Check multi-tenant isolation

```javascript
// Test data node
return {
  json: {
    agency_id: 'test_client',
    test_mode: true,
    // ... mock data
  }
};
```
