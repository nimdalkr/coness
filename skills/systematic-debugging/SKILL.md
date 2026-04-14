---
name: systematic-debugging
description: Use immediately when a user reports a bug, failing test, broken build, regression, or unexpected behavior and Codex should investigate root cause before proposing a fix
---

# Systematic Debugging For Codex

Use this skill when something is broken and the cause is not yet proven.

The goal is simple: understand the failure first, then change code.

## When To Use

Use this skill when the user says or implies any of these:

- a test is failing
- a bug appeared
- a build broke
- behavior regressed
- an error message needs explaining
- "figure out what's wrong"

Do not skip this skill just because you think the fix is obvious.

## Outcome

By the end of this skill you should have:

- a clear reproduction or failure signal
- the most likely root cause, backed by evidence
- the smallest next fix to test

## Codex Debug Loop

1. Restate the failure in one sentence
2. Gather the exact evidence:
   - failing command
   - stack trace
   - error location
   - recent code or config changes
3. Reproduce it consistently
4. Form one concrete hypothesis
5. Run the smallest check that can disprove or confirm it
6. Only then edit code
7. Verify the original failure is gone

## Rules

- Do not propose multiple speculative fixes at once
- Do not patch symptoms before tracing the cause
- Do not say "probably" when evidence is missing
- If you cannot reproduce, say that clearly and keep gathering data

## Codex-Specific Guidance

- Prefer direct inspection of the failing files and tests over abstract theorizing
- Prefer one tight feedback loop over long debugging essays
- If a targeted regression test can capture the issue, switch into `test-driven-development` before implementing the fix
- If the issue spans multiple systems, identify the failing boundary before changing anything

## What To Say

Keep the opening concise:

`Using systematic-debugging to identify the root cause before changing code.`

Then move straight into evidence gathering.
