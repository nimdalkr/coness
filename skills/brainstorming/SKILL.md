---
name: brainstorming
description: Use before implementing a new feature, UX change, or behavior change when requirements are still fuzzy or multiple valid approaches exist
---

# Brainstorming For Codex

Use this skill to get from "idea" to "approved direction" without over-documenting simple work.

Codex strength is momentum. This skill should create clarity fast, not block execution.

## When To Use

Use this skill when at least one of these is true:

- The user wants a new feature and the exact shape is unclear
- The request changes behavior, UX, or architecture
- There are multiple reasonable approaches
- The task spans several moving parts and needs decomposition

Do not use this skill for tiny, explicit edits that can be implemented and verified immediately.

## Outcome

By the end of this skill you should have:

- A clear understanding of the user's goal
- A recommended approach with tradeoffs
- Explicit success criteria
- Enough clarity to either implement directly or write a plan

## Workflow

1. Explore the current project context quickly
2. Ask only the questions needed to remove real ambiguity
3. Offer 2-3 approaches when tradeoffs matter
4. Recommend one approach and explain why
5. Present a compact design
6. Get user approval
7. Decide the next step:
   - Small enough now: implement directly
   - Multi-step or risky: use `writing-plans`

## Questioning Style

- Ask one question at a time when the answer will change the design
- Prefer multiple choice when it speeds decisions
- Skip questions whose answers you can infer safely from code or context
- Do not ask performative questions just because a process says to ask

## Design Format

Keep the design proportional to the task.

**Small feature**
- 3-6 bullets is enough

**Medium feature**
- Goal
- User-visible behavior
- Main files/components involved
- Edge cases
- Verification plan

**Large feature**
- Problem statement
- Recommended architecture
- Alternatives considered
- Data flow and boundaries
- Risks
- Verification strategy

## Codex-Specific Guidance

- Favor shipping a narrow version first over speculative scope
- Follow existing codebase patterns unless they block the work
- Name the exact files or modules likely to change when you can
- If a request is too large, decompose it into separately shippable parts

## Design Gate

Do not start implementation until the user has approved the direction.

The approval can be lightweight:

- "Yes, go with option 2."
- "Looks right."
- "Proceed."

Once approved:

- If the work is small and clear, implementation can start directly
- If the work has several tasks, interfaces, or validation steps, switch to `writing-plans`

## Spec Files

Only write a formal design doc when one of these is true:

- The user asks for documentation
- The feature is large enough that a saved spec will help
- Multiple sessions or collaborators will rely on it

Default path:

`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

For small features, the approved design can stay in chat.
