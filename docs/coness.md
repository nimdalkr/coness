# Coness

`coness` is the Codex evaluation harness for this repo.

It compares the clean `HEAD` version of the skills against your current working tree and reports how Codex responds to the same scenario prompts.

## Commands

Install and run the default quick check:

```powershell
node .\scripts\coness.js install
```

If someone runs `npm install`, this install step also runs automatically by default.

Quick run:

```powershell
node .\scripts\coness.js quick
```

With npm script:

```powershell
npm run coness -- quick
```

Single case:

```powershell
node .\scripts\coness.js case writing-plans-natural
```

Full suite:

```powershell
node .\scripts\coness.js full
```

## What It Prints

- per-case baseline vs candidate pass/fail
- matched expected skill counts
- artifact locations for the full reports

Reports are written to:

`.\.coness\latest\results.md`

and

`.\.coness\latest\results.json`

## Notes

- Requires Codex CLI and Git
- Temporarily swaps the installed `superpowers` skill junction under `~/.agents/skills/`
- Restores the prior skill install after the run finishes
- Uses the PowerShell comparison harness under `tests/codex/`
- `install` mode links the repo into `~/.agents/skills/superpowers` and then runs `quick` unless `-SkipQuickRun` is passed
