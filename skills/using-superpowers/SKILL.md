---
name: using-superpowers
description: Use when starting any conversation - establishes Codex-first skill selection rules, favoring direct execution for small scoped tasks and process skills for ambiguous or risky work
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Superpowers In Codex

This fork is optimized for Codex. The goal is not to force a ceremony before every action. The goal is to make good decisions quickly and consistently.

User instructions still override everything in this skill.

## Core Rule

Before acting, classify the request into one of these buckets:

1. **Direct execution** - small, concrete, low-risk change or question
2. **Design first** - ambiguous feature, product decision, or behavior change
3. **Debug first** - bug, failure, regression, or unexpected behavior
4. **Plan first** - multi-step implementation that should be broken into tasks
5. **Review/verify first** - completion, merge, or code review stage

If a bucket clearly matches, use the corresponding skill. If none match, proceed normally.

## Codex-First Decision Table

| Situation | What to do |
|---------|----------|
| User asks a small factual question or tiny code edit | Respond or implement directly |
| User wants a new feature but scope is still fuzzy | Use `brainstorming` |
| User wants a non-trivial implementation with known requirements | Use `writing-plans` |
| User reports a bug, failing test, broken build, or regression | Use `systematic-debugging` |
| You are about to write implementation code for a feature or fix | Use `test-driven-development` |
| You already have a written plan and tasks are independent | Use `subagent-driven-development` |
| You are about to say "done", "fixed", "passing", or open a PR | Use `verification-before-completion` |

## Do Not Over-Apply Skills

This Codex fork intentionally avoids "invoke a skill before every sentence" behavior.

Do not stop for process overhead when all of the following are true:

- The request is specific
- The change is small
- The risk is low
- You can verify it immediately

Examples:

- Rename a variable in one file
- Answer where a setting lives
- Fix a typo in documentation
- Adjust one test assertion with clear intent

In those cases, work directly and verify the result.

## Do Apply Skills Early When Risk Is Real

Use process skills early when any of these are true:

- The user is asking for a new feature, workflow, or behavior change
- Requirements are unclear
- Multiple files or systems are involved
- The task affects architecture, APIs, or UX
- The task has already gone wrong once
- You are tempted to "just try something"

## Priority

When more than one skill could apply, use this order:

1. `systematic-debugging`
2. `brainstorming`
3. `writing-plans`
4. `test-driven-development`
5. `subagent-driven-development`
6. `verification-before-completion`

Reason: first decide whether the work is broken, unclear, or simply ready to implement.

## Codex Operating Style

- Prefer direct execution over ceremony for small tasks
- Prefer short plans over long documents unless the work is large
- Prefer local verification over claims
- Prefer one strong next step over a long lecture about process
- Prefer subagents only when the tasks are genuinely separable

## What To Say

When you activate a skill, announce it briefly and move on:

- "Using brainstorming to pin down the feature before coding."
- "Using systematic-debugging to find the root cause before changing code."
- "Using verification-before-completion to confirm the current state."

Keep it short. Codex works best when the process is explicit but lightweight.
