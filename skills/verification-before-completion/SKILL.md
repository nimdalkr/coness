---
name: verification-before-completion
description: Use when the user asks whether work is done, fixed, passing, or ready for review and Codex should verify the current state with fresh evidence before making any completion claim
---

# Verification Before Completion For Codex

Codex should not claim success based on intent, confidence, or a stale test run.

Verify first. Then report the result.

## When To Use

Use this skill before saying any of the following:

- "Done"
- "Fixed"
- "All tests pass"
- "Ready for PR"
- "Build succeeds"
- "This should work now"

Also use it when the user explicitly asks to verify readiness, completion, or review status.

## Core Rule

For every status claim, identify the command or check that proves it, run it, and report what it actually showed.

If you did not run the proof step in the current work cycle, do not make the claim.

## Activation Cue

When this skill applies, say it plainly:

`Using verification-before-completion to check the current state before making any completion claim.`

## Minimal Verification Loop

1. Identify the exact claim
2. Choose the command or check that proves it
3. Run it fresh
4. Read the result, not just the exit code
5. Report the real state

## Examples

**Good**
- Ran `pytest tests/unit/test_api.py -q`; 12 tests passed
- Ran `npm run build`; build completed with exit code 0
- Reproduced the original bug path manually; the failing state no longer occurs

**Bad**
- "Should be fixed now"
- "Looks good"
- "I updated the code so it passes"
- "The agent said it worked"

## Verification Must Match The Claim

| Claim | Required evidence |
|------|-------------------|
| Tests pass | Test output |
| Build succeeds | Build output |
| Bug fixed | Reproduction path or regression test |
| Feature complete | Requirement checklist plus relevant verification |
| Ready for review | Verification plus a quick sanity pass on changed files |

## Codex-Specific Guidance

- Prefer the smallest command that proves the claim
- For larger tasks, run the targeted check first, then broader suite if needed
- If verification is expensive, say so and report what was verified versus what was not
- Never hide gaps; state them plainly

## Reporting Format

Keep it concise:

- What you verified
- What command/check you ran
- What happened
- What remains unverified, if anything

Example:

`Ran pytest tests/unit/test_router.py -q: 18 passed. I verified the router change directly. I did not run the full suite yet.`

## If Verification Fails

Do not soften it. Report the failure plainly and continue from there.

Example:

`Ran npm test -- router tests still fail in 2 cases related to trailing slash handling. The fix is not complete yet.`
