---
context-fork: true
model: claude-sonnet-4-20250514
---

# Client Deliverables

Auto-generate client-facing documentation alongside technical builds.

## Standard Deliverables

Every build produces these client-ready documents:

### 1. Project Brief (project-brief.md)
- Generated during intake
- Plain English overview
- No technical jargon
- Shows what they're getting

### 2. User Guide (USER-GUIDE.md)
- How to use the system day-to-day
- Screenshots/diagrams where helpful
- Step-by-step instructions
- FAQs

### 3. Admin Guide (ADMIN-GUIDE.md)
- How to manage users/settings
- How to handle common issues
- Monitoring and maintenance
- Backup/recovery procedures

### 4. System Overview (ARCHITECTURE.md)
- Plain English + diagram
- What connects to what
- Data flow explanation
- For their IT team

---

## User Guide Template

```markdown
# [System Name] - User Guide

## Welcome
[1-2 sentences about what this system does for them]

---

## Getting Started

### Logging In
1. Go to [URL]
2. Enter your email and password
3. Click "Sign In"

### Your Dashboard
When you log in, you'll see:
- **[Section 1]** - [What it shows]
- **[Section 2]** - [What it shows]

---

## Common Tasks

### [Task 1]: [Descriptive Name]
**When to use:** [Scenario]

**Steps:**
1. [Step with screenshot if complex]
2. [Step]
3. [Step]

**Result:** [What happens when done]

---

### [Task 2]: [Descriptive Name]
...

---

## FAQs

**Q: [Common question]?**
A: [Clear answer]

**Q: [Common question]?**
A: [Clear answer]

---

## Getting Help
- **Issues with the system:** Contact [support method]
- **Questions about features:** [Contact]
- **Training requests:** [Contact]

---

## Quick Reference

| Action | How |
|--------|-----|
| [Action] | [Quick steps] |
| [Action] | [Quick steps] |
```

---

## Admin Guide Template

```markdown
# [System Name] - Administrator Guide

## Overview
This guide covers system administration tasks for [System Name].

---

## User Management

### Adding New Users
1. [Steps]

### Removing Users
1. [Steps]

### Changing User Roles
1. [Steps]

---

## System Settings

### [Setting Category]
**Where:** [Navigation path]
**Options:**
- [Option 1]: [What it does]
- [Option 2]: [What it does]

---

## Monitoring

### Health Checks
**What to monitor:**
- [Metric 1] - Should be [expected range]
- [Metric 2] - Should be [expected range]

**Warning signs:**
- [Sign] indicates [Problem]

### Viewing Logs
[How to access and read logs]

---

## Troubleshooting

### [Common Issue 1]
**Symptoms:** [What user sees]
**Cause:** [Why it happens]
**Fix:** [Step-by-step resolution]

### [Common Issue 2]
...

---

## Maintenance

### Regular Tasks
| Task | Frequency | How |
|------|-----------|-----|
| [Task] | Weekly | [Brief steps] |
| [Task] | Monthly | [Brief steps] |

### Backup & Recovery
**Automatic backups:** [How often, where stored]
**Manual backup:** [Steps if needed]
**Restore procedure:** [Steps]

---

## Security

### Access Control
[How permissions work]

### Audit Trail
[What's logged, how to review]

---

## Support Contacts
- **Technical Issues:** [Contact]
- **Billing:** [Contact]
- **Feature Requests:** [Contact]
```

---

## Generating During Build

Use async sub-agents (Ctrl+B) to generate docs while building:

```
Main task: Implement user management API

Ctrl+B → Sub-agent: "Based on the spec and code I'm writing, 
generate the User Management section of the User Guide. 
Include steps for viewing, adding, and editing users."
```

## Tone Guidelines

**Do:**
- Use "you" and "your"
- Short sentences
- Active voice
- Numbered steps for processes
- Include "why" not just "how"

**Don't:**
- Technical jargon without explanation
- Assume knowledge
- Long paragraphs
- Passive voice
- Skip obvious steps

## Screenshot Guidelines

When to include:
- Complex interfaces
- Multi-step processes
- Important warnings/confirmations
- Settings that affect behavior

Format:
- PNG format
- Highlight relevant area
- Add numbered callouts if needed
- Store in `docs/images/`

## Delivery Checklist

Before sending to client:
- [ ] All [brackets] replaced with actual content
- [ ] Screenshots added where noted
- [ ] Links tested
- [ ] Spell check run
- [ ] Another person reviewed
- [ ] PDF version created (optional)
