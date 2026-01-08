# Spec Template

Use this template for all technical specifications.

---

```markdown
# [TASK-ID]: [Task Title]

## Metadata
- **Created:** [DATE]
- **Complexity:** [simple | standard | complex]
- **Estimated Subtasks:** [NUMBER]
- **Status:** draft | ready | in-progress | complete

---

## 1. Overview

### 1.1 Problem Statement
[What problem does this solve? Why is it needed?]

### 1.2 Proposed Solution
[High-level description of what will be built]

### 1.3 Success Criteria
[How do we know when this is done correctly?]

---

## 2. Requirements

### 2.1 Functional Requirements
- [ ] FR-1: [Requirement description]
- [ ] FR-2: [Requirement description]
- [ ] FR-3: [Requirement description]

### 2.2 Non-Functional Requirements
- [ ] NFR-1: [Performance/security/scalability requirement]
- [ ] NFR-2: [Constraint or standard to follow]

### 2.3 Out of Scope
- [What this task explicitly does NOT include]

---

## 3. Technical Specification

### 3.1 Architecture
[How does this fit into the existing system?]

```
[ASCII diagram of component relationships]
```

### 3.2 Files to Create/Modify
| File | Action | Purpose |
|------|--------|---------|
| path/to/file.ts | Create | [What it does] |
| path/to/existing.ts | Modify | [What changes] |

### 3.3 Dependencies
- [External packages to install]
- [Internal modules to use]

### 3.4 Data Structures
See: `table-of-tables.md` for full schema

Key interfaces:
```typescript
interface Example {
  id: string;
  name: string;
}
```

### 3.5 API Contracts (if applicable)
```
POST /api/endpoint
Request: { field: string }
Response: { result: boolean }
```

---

## 4. Implementation Notes

### 4.1 Approach
[Step-by-step approach to implementation]

### 4.2 Edge Cases
- [Edge case 1 and how to handle]
- [Edge case 2 and how to handle]

### 4.3 Error Handling
- [How errors should be handled]
- [What error messages to show]

### 4.4 Security Considerations
- [Authentication/authorization needs]
- [Input validation requirements]
- [Data protection needs]

**RLS Note:** Row Level Security will be applied in Phase 5, AFTER all functionality is tested. See RLS Access Matrix below.

---

## 5. Testing Strategy

### 5.1 Unit Tests
- [ ] Test [component/function] does [expected behavior]
- [ ] Test [component/function] handles [edge case]

### 5.2 Integration Tests
- [ ] Test [flow] from [start] to [end]

### 5.3 Manual Testing Checklist
- [ ] [Manual test scenario 1]
- [ ] [Manual test scenario 2]

---

## 6. Acceptance Criteria

**This task is complete when:**
- [ ] AC-1: [Specific, measurable criterion]
- [ ] AC-2: [Specific, measurable criterion]
- [ ] AC-3: [Specific, measurable criterion]
- [ ] All unit tests pass
- [ ] No linting errors
- [ ] Code follows project conventions
- [ ] RLS applied and tested (Phase 5)

---

## 7. RLS Access Matrix

**Note: DO NOT implement during build. This documents INTENT for Phase 5.**

| Table | anon | authenticated | [role] | admin |
|-------|------|---------------|--------|-------|
| [table1] | ❌ | Own only | - | All |
| [table2] | Read | Own only | Org | All |

See `table-of-tables.md` for detailed policies.

---

## 8. Context & References

### 8.1 Related Files
- `path/to/related/file.ts` - [Why it's relevant]

### 8.2 External References
- [Link to docs or examples]

### 8.3 Prior Decisions
- [Any decisions made during spec creation and why]

---

## 9. Open Questions
- [ ] [Question that needs answering before/during implementation]

---

## Revision History
| Date | Author | Changes |
|------|--------|---------|
| [DATE] | Spec Agent | Initial spec |
```
