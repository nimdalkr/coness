# Coness for Codex

Coness is the Codex-first distribution of the Superpowers workflow.

Use this repo if you want:

- the Superpowers-style skill workflow
- prompts and trigger rules tuned for Codex instead of Claude Code
- a built-in way to verify the skills against real Codex runs

## Quick Start

Clone and install:

```powershell
git clone https://github.com/nimdalkr/coness.git
cd coness
npm install
```

On install, Coness:

1. links `skills/` into `~/.agents/skills/superpowers`
2. makes the local `coness` entrypoint available
3. runs the default `quick` evaluation once

## What Gets Installed

Codex discovers skills from `~/.agents/skills/`. Coness installs this repo's skill set there through a junction or symlink:

```text
~/.agents/skills/superpowers/ -> <this-repo>/skills/
```

After that, Codex can pick up the rewritten skills in new sessions.

## Main Commands

Install or reinstall the skill link:

```powershell
node .\scripts\coness.js install
```

Run a quick Codex check:

```powershell
npm run coness -- quick
```

Run the full suite:

```powershell
npm run coness -- full
```

Run one scenario:

```powershell
node .\scripts\coness.js case writing-plans-natural
```

## What Coness Changes

Compared with the original Superpowers repo, this distribution focuses on Codex behavior:

- shorter trigger descriptions
- less Claude-style process rigidity
- more direct execution for small tasks
- Codex-oriented planning, debugging, and verification instructions
- simpler install and evaluation flow

## Reports

Coness writes reports to:

- `.\.coness\latest\results.md`
- `.\.coness\latest\results.json`

These compare the clean repository `HEAD` with your current working tree on the same prompt cases.

## Requirements

- OpenAI Codex CLI
- Git
- Node.js
- PowerShell on Windows

## Manual Skill Link

If you need to create the link yourself on Windows:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\superpowers" "<repo-path>\skills"
```

Using `coness install` is preferred because it also handles the default smoke check.

## Related Docs

- [Project README](../README.md)
- [Coness command reference](./coness.md)
- [Harness details](../tests/codex/README.md)
