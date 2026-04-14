# Codex Evaluation Harness

This directory contains a Codex-first evaluation harness for comparing:

- the clean `HEAD` version of the repo
- the current working tree version

The goal is to measure how Codex actually reacts to the installed skills, not just compare `SKILL.md` text.

## What It Tests

For each prompt case, the harness:

1. Creates a clean `HEAD` worktree as the baseline
2. Temporarily installs the baseline skills into `~/.agents/skills/superpowers`
3. Runs `codex exec --json`
4. Extracts triggered skill names, runtime, and token usage
5. Separates "skill file was loaded" from "skill was explicitly announced in the response"
6. Repeats the same case against the current working tree
7. Writes JSON and Markdown comparison reports

## Files

- `cases.json` - list of evaluation cases
- `prompts/` - Codex prompt fixtures
- `compare-head-vs-working.ps1` - main comparison harness

## Requirements

- Codex CLI installed and logged in
- Git installed
- PowerShell
- Permission to let the script temporarily replace `~/.agents/skills/superpowers`

## Run

From the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\codex\compare-head-vs-working.ps1
```

Optional:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\codex\compare-head-vs-working.ps1 -CodexModel gpt-5.4
```

Run a single case:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\codex\compare-head-vs-working.ps1 -CaseId brainstorming-explicit
```

## Output

By default, reports are written under:

`$env:TEMP\superpowers-codex-eval`

Main outputs:

- `results.json`
- `results.md`
- `runs/` with per-case raw Codex JSONL logs and final messages

## Important Notes

- The harness uses an ASCII temp workspace for `codex exec` to avoid Unicode path issues in Codex session metadata.
- The script temporarily swaps the installed `superpowers` skill junction and restores any prior install at the end.
- This is a behavior harness, not a full product benchmark. It is designed to answer: "Did Codex trigger the intended skill, and how did baseline vs candidate differ?"
