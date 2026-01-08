# n8n Workflows Reference

**Load this only when building n8n workflows.**

## Workflow Architecture

### Master + Tool Pattern
```
┌─────────────────────────────────────────────────────────────┐
│                    MASTER WORKFLOW                          │
│                                                             │
│  Webhook/Schedule ──▶ Init ──▶ AI Agent ──▶ Output/Email   │
│                                   │                         │
│                    ┌──────────────┼──────────────┐          │
│                    ▼              ▼              ▼          │
│              ┌─────────┐   ┌─────────┐   ┌─────────┐       │
│              │ Tool 1  │   │ Tool 2  │   │ Tool 3  │       │
│              │(workflow)│   │(workflow)│   │(workflow)│      │
│              └─────────┘   └─────────┘   └─────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tool Workflow Template
```
┌────────────────────────┐
│ Execute Workflow       │  ◄── Trigger (NOT webhook)
│ Trigger                │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│ Validate Input         │  ◄── Check required params
│ (Code Node)            │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│ Core Logic             │  ◄── Your actual work
│ (Multiple nodes)       │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│ Format Output          │  ◄── Standardize response
│ (Code Node)            │
└────────────────────────┘
```

## Node Configurations

### Execute Workflow Trigger (for tool workflows)
```json
{
  "parameters": {},
  "name": "Execute Workflow Trigger",
  "type": "n8n-nodes-base.executeWorkflowTrigger",
  "position": [0, 0]
}
```

### Input Validation Node
```javascript
// Code node at start of every tool workflow
const input = $json;

// Required parameters
const required = ['agency_id', 'date_range_days'];
const missing = required.filter(field => !input[field]);

if (missing.length > 0) {
  throw new Error(`Missing required fields: ${missing.join(', ')}`);
}

// Type validation
if (typeof input.date_range_days !== 'number') {
  throw new Error('date_range_days must be a number');
}

// Defaults
return {
  json: {
    agency_id: input.agency_id,
    date_range_days: input.date_range_days || 30,
    include_archived: input.include_archived ?? false
  }
};
```

### Output Formatting Node
```javascript
// Code node at end of every tool workflow
const startTime = $('Validate Input').first().json._startTime || Date.now();
const data = $json;

return {
  json: {
    success: true,
    data: data,
    metadata: {
      execution_time_ms: Date.now() - startTime,
      records_processed: Array.isArray(data) ? data.length : 1,
      timestamp: new Date().toISOString()
    },
    error: null
  }
};
```

### Error Handling Wrapper
```javascript
// Wrap any risky operation
try {
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
  
  return {
    json: {
      success: false,
      data: null,
      error: {
        message: error.message,
        code: error.code || 'UNKNOWN_ERROR',
        timestamp: new Date().toISOString()
      }
    }
  };
}
```

## AI Agent Configuration

### System Prompt Template
```
You are a [PURPOSE] agent for [CLIENT/SYSTEM].

## Available Tools
- tool_name_1: [DESCRIPTION - when to use, what it returns]
- tool_name_2: [DESCRIPTION]
- tool_name_3: [DESCRIPTION]

## Process
1. First, call [tool] to gather [data type]
2. Analyze the results for [specific criteria]
3. Call [tool] to [action]
4. Format your response as [format]

## Output Format
[Specify exact format expected]

## Rules
- Always [rule 1]
- Never [rule 2]
- If [condition], then [action]
```

### Agent Node Settings
```json
{
  "agent": "conversationalAgent",
  "promptType": "define",
  "text": "={{ $json.request }}",
  "hasOutputParser": true,
  "options": {
    "systemMessage": "[Your system prompt]",
    "maxIterations": 10,
    "returnIntermediateSteps": false
  }
}
```

## Retry & Error Handling

### HTTP Request with Retry
```json
{
  "parameters": {
    "method": "GET",
    "url": "https://api.example.com/data",
    "options": {
      "timeout": 30000,
      "retry": {
        "maxRetries": 3,
        "retryInterval": 1000
      }
    }
  },
  "continueOnFail": true
}
```

### Retry Wrapper Function
```javascript
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
const data = await withRetry(async () => {
  const response = await $http.get('https://api.example.com/data');
  return response.data;
});

return { json: { data } };
```

## Supabase Integration

### Fetch with Agency Filter
```javascript
const { agency_id } = $json;

const response = await $http.request({
  method: 'GET',
  url: `${$env.SUPABASE_URL}/rest/v1/projects`,
  headers: {
    'apikey': $env.SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${$env.SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json'
  },
  qs: {
    'agency_id': `eq.${agency_id}`,
    'select': '*',
    'order': 'created_at.desc'
  }
});

return response.map(item => ({ json: item }));
```

### Insert with Return
```javascript
const response = await $http.request({
  method: 'POST',
  url: `${$env.SUPABASE_URL}/rest/v1/logs`,
  headers: {
    'apikey': $env.SUPABASE_SERVICE_ROLE_KEY,
    'Authorization': `Bearer ${$env.SUPABASE_SERVICE_ROLE_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
  },
  body: {
    agency_id: $json.agency_id,
    workflow_name: $workflow.name,
    status: 'completed',
    data: $json.result
  }
});

return { json: response };
```

## Execution Logging

### Log Every Execution
```javascript
// Add at end of master workflow
const logEntry = {
  workflow_id: $workflow.id,
  workflow_name: $workflow.name,
  execution_id: $execution.id,
  agency_id: $json.agency_id,
  execution_timestamp: new Date().toISOString(),
  execution_time_ms: Date.now() - $json._startTime,
  success: !$json.error,
  input_summary: JSON.stringify($input.first().json).slice(0, 500),
  output_summary: JSON.stringify($json).slice(0, 500),
  error_message: $json.error?.message || null
};

// Insert to Supabase
await $http.request({
  method: 'POST',
  url: `${$env.SUPABASE_URL}/rest/v1/execution_logs`,
  headers: {
    'apikey': $env.SUPABASE_SERVICE_ROLE_KEY,
    'Authorization': `Bearer ${$env.SUPABASE_SERVICE_ROLE_KEY}`,
    'Content-Type': 'application/json'
  },
  body: logEntry
});

return { json: $json };
```

## Testing Workflows

### Test Mode Check
```javascript
// At start of workflow
const isTestMode = $json.test_mode === true;

if (isTestMode) {
  // Return mock data instead of calling real APIs
  return {
    json: {
      success: true,
      data: { mock: true, message: 'Test mode - no real API calls made' }
    }
  };
}

// Continue with real logic...
```

### Test Data Node
```javascript
// For testing, replace trigger with this
return {
  json: {
    agency_id: 'test_client',
    test_mode: true,
    date_range_days: 7,
    request: 'Generate a test report'
  }
};
```
