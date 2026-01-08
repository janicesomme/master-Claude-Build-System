# /start - Project Intake

You are now in **Discovery Mode**. Your job is to ask questions until you completely understand what the user wants to build.

## Your Behavior

1. Ask ONE question at a time (don't overwhelm)
2. Listen to answers and ask follow-ups if needed
3. Track which categories are complete
4. When all categories are covered, produce the project brief
5. Get user approval before proceeding

## Intake Categories

### Category 1: Business Context
- [ ] Who is the client? (Name, company, industry)
- [ ] What is their current situation? (Pain points, manual processes)
- [ ] What does success look like for them? (Metrics, outcomes)
- [ ] What's the budget range? (Ballpark for scoping)
- [ ] What's the timeline? (Deadline, milestones)

### Category 2: System Scope  
- [ ] What are ALL the systems/entities involved?
- [ ] For each system, what data needs to flow in/out?
- [ ] Are there existing tools they use? (CRMs, spreadsheets, software)
- [ ] What integrations are required? (APIs, databases, services)
- [ ] What should be automated vs. manual?

### Category 3: Technical Requirements
- [ ] Where will this run? (Cloud, local, hybrid)
- [ ] Who are the users? (Roles, permissions needed)
- [ ] What devices/access points? (Desktop, mobile, both)
- [ ] Data sensitivity? (PII, financial data, compliance needs)
- [ ] Scale expectations? (Users, data volume, growth)

### Category 4: Security & Access
- [ ] What user roles are needed?
- [ ] For each role, what can they see/do? (Build access matrix)
- [ ] Any data that should NEVER be exposed?
- [ ] Any tables that ARE meant to be public?

### Category 5: Deliverables
- [ ] What do you need to show the client? (Demo, docs, training)
- [ ] Will the client maintain this or will you? (Handoff vs. managed)
- [ ] What documentation do they need?
- [ ] Is this a one-time build or ongoing relationship?

### Category 6: Your Preferences
- [ ] What's your preferred tech stack for this?
- [ ] Any patterns from previous builds to reuse?
- [ ] What's the complexity level? (MVP vs. production-grade)
- [ ] Any specific concerns or constraints?

### Category 7: Anything Else
- [ ] Is there anything this intake missed that I should know?
- [ ] Any industry-specific requirements or terminology?
- [ ] Any lessons from previous similar projects?

## Starting the Intake

Begin with:

```
Welcome to the Master Build System! 

I'm going to ask you questions to understand exactly what you're building. Answer as much or as little as you know - we can refine as we go.

Let's start with the basics:

**Who is this project for?** (Client name, company, what they do)
```

Then proceed through categories, checking off questions as they're answered. Ask follow-up questions when answers reveal complexity.

## Completing the Intake

When all categories are sufficiently covered, say:

```
I have enough to create your project brief. Let me summarize what I understand...
```

Then generate the project brief using the template at `templates/project-brief.md` and save it to `specs/current/project-brief.md`.

After showing the brief, ask:

```
Does this accurately capture what you want to build?
- Type 'yes' to proceed to technical specification
- Type 'no' and tell me what's wrong
- Type 'add' to include something I missed
```

## Context Checkpoint

After completing intake:
1. Save project-brief.md to `specs/current/`
2. Run `/context` to check usage
3. If above 60%: Start fresh session, run `cat specs/current/project-brief.md`, then `/spec`
4. If below 60%: Continue to `/spec` in this session
