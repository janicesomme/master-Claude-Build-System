# /compact - Context Compaction

Reduce context window usage by summarizing the current session.

## When to Use

- Context usage above 60%
- Before starting a complex new phase
- When you notice Claude's responses getting slower or less accurate
- Before a long coding session

## Process

### Step 1: Assess Current State

```
Current context usage: [X]%

Key information in this session:
1. [Summary of project state]
2. [Current phase and progress]
3. [Important decisions made]
4. [Outstanding issues]
```

### Step 2: Create Handoff Document

Generate a `HANDOFF.md` that captures everything needed to continue:

```markdown
# Session Handoff

## Project
- **Name:** [Project name]
- **Client:** [Client name]
- **Current Phase:** [Phase]

## Progress Summary
[2-3 sentences on what's been accomplished]

## Current State
- **Last completed:** [Task/subtask]
- **Currently working on:** [Task/subtask]
- **Files modified this session:** [List]

## Key Decisions Made
1. [Decision and rationale]
2. [Decision and rationale]

## Issues Encountered
1. [Issue and resolution/status]

## Next Steps
1. [Immediate next action]
2. [Following action]
3. [Following action]

## Important Context
[Any critical information that would be lost]

## Files to Reference
- specs/current/spec.md
- specs/current/implementation-plan.md
- [Any other relevant files]
```

### Step 3: Provide Instructions

```
Context compacted. To continue:

1. Start a new Claude Code session
2. Run: cat HANDOFF.md
3. Continue with: [specific next step]

Or if you want to continue in this session, I've freed up context by summarizing. Current usage: [X]%
```

## Automatic Triggers

Claude should suggest `/compact` when:
- Context exceeds 60%
- User is about to start a new phase
- Response quality seems to degrade
- Large file reads are needed

## Compaction Strategies

### Strategy 1: Summarize and Continue
- Create summary of session
- Clear conversation history
- Continue with summary as context

### Strategy 2: File-Based Handoff
- Write all context to files
- Start fresh session
- Read files in new session

### Strategy 3: Phase Transition
- Complete current phase
- Output deliverable to file
- Start new session with only that file

## Context-Saving Habits

### Do:
- Output important info to files, not just chat
- Use sub-agents for token-heavy tasks
- Summarize before asking new questions
- Reference files instead of pasting content

### Don't:
- Paste entire files into chat
- Keep old conversation threads alive unnecessarily
- Run commands that produce huge output without truncation
- Load all context at once "just in case"
