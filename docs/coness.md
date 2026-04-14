# Coness

`coness` is the command-line entrypoint for this Codex-first remake.

Its job is not only to run evaluations. It is the simplest way to install, re-link, and verify the Codex-friendly Superpowers distribution in this repository.

## What It Does

`coness` covers two practical jobs:

1. install this repo's rewritten skills into Codex's skill directory
2. verify that Codex actually responds to those skills as expected

So the main product is still the Codex-friendly skill pack. The harness is how you check that the pack is working.

## Common Commands

Install the skills and run the default quick check:

```powershell
node .\scripts\coness.js install
```

`npm install` runs this automatically by default.

Quick verification:

```powershell
npm run coness -- quick
```

Full verification suite:

```powershell
npm run coness -- full
```

Single scenario:

```powershell
node .\scripts\coness.js case writing-plans-natural
```

## Default Install Flow

When you run `npm install`, Coness:

1. links this repo's `skills/` into `~/.agents/skills/superpowers`
2. keeps the Codex skill path ready for new sessions
3. runs the default `quick` check to make sure the setup is alive

This is meant to remove the manual setup most users would otherwise have to do.

## What The Reports Mean

Coness compares:

- baseline: clean repository `HEAD`
- candidate: your current working tree

It then reports:

- whether the expected skill was matched
- execution time
- input tokens
- output tokens

Reports are written to:

- `.\.coness\latest\results.md`
- `.\.coness\latest\results.json`

## Notes

- Requires Codex CLI, Git, and Node.js
- Uses the PowerShell harness under `tests/codex/`
- Temporarily switches the installed `superpowers` link during comparisons
- Restores the previous state after the run
- `install` mode accepts `-SkipQuickRun` if you only want the link setup
