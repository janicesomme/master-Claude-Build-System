# API Development Reference

**Load this only when building API endpoints.**

## REST API Conventions

### URL Structure
```
GET    /api/v1/resources          # List all
GET    /api/v1/resources/:id      # Get one
POST   /api/v1/resources          # Create
PUT    /api/v1/resources/:id      # Full update
PATCH  /api/v1/resources/:id      # Partial update
DELETE /api/v1/resources/:id      # Delete
```

### Nested Resources
```
GET    /api/v1/users/:userId/orders           # User's orders
POST   /api/v1/users/:userId/orders           # Create order for user
```

### Query Parameters
```
?page=1&limit=20                  # Pagination
?sort=created_at&order=desc       # Sorting
?filter[status]=active            # Filtering
?include=user,comments            # Related data
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "User-friendly message",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

### HTTP Status Codes
| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Valid auth, no permission |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate, version conflict |
| 422 | Unprocessable | Validation failed |
| 500 | Server Error | Unexpected error |

## Input Validation

### Zod Schema Example
```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['user', 'admin']).default('user'),
  org_id: z.string().uuid().optional(),
});

// In handler
const result = createUserSchema.safeParse(req.body);
if (!result.success) {
  return res.status(422).json({
    success: false,
    error: {
      code: 'VALIDATION_ERROR',
      message: 'Invalid input',
      details: result.error.flatten().fieldErrors
    }
  });
}
```

## Authentication Middleware

```typescript
// middleware/auth.ts
export async function requireAuth(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'Missing token' }
    });
  }

  try {
    const { data: { user }, error } = await supabase.auth.getUser(token);
    if (error || !user) throw new Error('Invalid token');
    
    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'Invalid token' }
    });
  }
}
```

## Error Handling

```typescript
// utils/api-error.ts
export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: any
  ) {
    super(message);
  }
}

// Usage
throw new ApiError(404, 'NOT_FOUND', 'User not found');

// Global error handler
app.use((err, req, res, next) => {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        details: err.details
      }
    });
  }
  
  // Unexpected error
  console.error(err);
  return res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' }
  });
});
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    error: { code: 'RATE_LIMITED', message: 'Too many requests' }
  }
});

app.use('/api/', apiLimiter);
```

## Testing APIs

```typescript
// tests/api/users.test.ts
describe('POST /api/v1/users', () => {
  it('creates user with valid data', async () => {
    const res = await request(app)
      .post('/api/v1/users')
      .set('Authorization', `Bearer ${testToken}`)
      .send({ email: 'test@example.com', name: 'Test User' });
    
    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.email).toBe('test@example.com');
  });

  it('rejects invalid email', async () => {
    const res = await request(app)
      .post('/api/v1/users')
      .set('Authorization', `Bearer ${testToken}`)
      .send({ email: 'not-an-email', name: 'Test' });
    
    expect(res.status).toBe(422);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```
