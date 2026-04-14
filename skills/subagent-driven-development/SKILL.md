---
name: subagent-driven-development
description: Use when the user explicitly asks for subagent-driven-development or provides a written implementation plan that Codex should execute by delegating independent tasks to subagents
---

# Subagent-Driven Development For Codex

Use subagents as a force multiplier, not as ceremony.

Codex should delegate only when delegation is faster and safer than staying in one session.

## When To Use

Use this skill when all of the following are true:

- You already have a written plan
- Tasks are mostly independent
- Write scopes are separated or easy to coordinate
- You can keep the parent session focused on orchestration
- The user has asked to use subagents or to execute a plan task-by-task with delegation

Do not use this skill when:

- The work is tightly coupled
- Every step depends on the previous one
- You would spend more time coordinating than implementing
- The next action is blocked on immediate local reasoning

## Activation Cue

When this skill applies, announce it directly:

`Using subagent-driven-development to execute the plan with targeted delegation.`

If the user asks for the skill by name but no plan exists yet, say that the skill is loaded and ask for the plan or task list needed to drive delegation.

## Codex Delegation Rules

- Keep the blocking task local when you need the answer immediately
- Delegate sidecar work that can run in parallel
- Give each subagent one concrete outcome
- Give explicit file ownership when code changes are involved
- Do not ask multiple subagents to edit the same files at once

## Per-Task Flow

1. Read the plan and choose the next delegable task
2. Provide only the context needed for that task
3. Tell the subagent what files it owns
4. Ask it to report changed files and verification performed
5. Review the result locally
6. Fix, refine, or request follow-up only if needed
7. Mark the task complete and move on

## Review Standard

Each delegated task should be checked for:

- Requirement match
- Obvious regressions
- Reasonable verification
- Clean integration with surrounding code

You do not need a formal two-review ritual for every tiny task. Match review depth to risk.

## Suggested Subagent Prompt Shape

Include:

- Task name
- Desired outcome
- Relevant files and context
- Owned write scope
- Verification expected
- Instruction not to revert unrelated changes

## Model Guidance

- Cheap/fast model for isolated mechanical edits
- Standard model for multi-file implementation
- Strongest model for review, design, or hard debugging

## Fallback

If delegation stops helping:

- Stop spawning more subagents
- Pull the work back into the main session
- Continue inline

This skill is optional acceleration, not the default answer to every plan.
