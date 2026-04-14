---
name: writing-plans
description: Use when the user has given a spec, requirements list, or implementation goal and Codex should produce a concrete step-by-step implementation plan before coding
---

# Writing Plans For Codex

This skill exists for work that is too large to safely improvise in one pass.

The output is a plan that Codex or another agent can execute without needing hidden context from the current conversation.

## When To Use

Use this skill when most of these are true:

- The requirements are already clear
- The work spans multiple files, steps, or checkpoints
- The order of work matters
- Verification will require more than one command
- You want task-by-task execution or delegation
- The user asks to "plan this", "break this down", "write the implementation plan", or gives a spec and says not to code yet

Do not use this skill for small edits that can be implemented directly.

## Activation Cue

If the user provides a spec or requirements block and the right next step is decomposition rather than coding, announce the skill plainly:

`Using writing-plans to turn the requirements into an executable implementation plan.`

## Goal

Produce a compact, executable plan. Do not produce a bloated spec.

The plan should answer:

- What are we building?
- Which files or modules will change?
- In what order should work happen?
- How will each step be verified?
- Where are the risky parts?

## Plan Shape

Save plans to:

`docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

Recommended header:

```md
# <Feature Name> Implementation Plan

**Goal:** <one sentence>
**Scope:** <what is included and excluded>
**Key Files:** <main files/modules>
**Verification:** <main commands or checks>
```

## Task Rules

Each task should be independently understandable.

For each task include:

- Purpose
- Files to create or modify
- Expected output
- Verification command or manual check
- Notes on dependencies, if any

Prefer 3-8 meaningful tasks over dozens of tiny pseudo-steps.

## Codex-Specific Rules

- Write tasks in the order Codex should execute them
- Name exact files when known
- Keep tasks large enough to be useful, small enough to verify
- Do not force TDD boilerplate into the plan for every trivial line item
- Include concrete verification, not "test appropriately"

## Suggested Task Template

```md
## Task N: <name>

**Purpose:** <what this accomplishes>
**Files:** `<path1>`, `<path2>`
**Changes:** <brief description>
**Verification:** `<command>` or `<manual check>`
**Notes:** <dependencies, edge cases, review points>
```

## Self-Review

Before presenting the plan, check:

1. Does every requirement map to at least one task?
2. Are file paths concrete enough to be actionable?
3. Are verification steps real and specific?
4. Can this be executed in order without missing context?

If not, fix the plan before handing it off.

## Handoff

After saving the plan:

- If tasks are independent and delegation will help, use `subagent-driven-development`
- If the work is tightly coupled or easier to keep in one head, execute inline

Present the choice briefly. Do not over-explain.
