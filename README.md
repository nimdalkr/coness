# Coness

Coness is a Codex-first remake of the Superpowers skill workflow, originally tuned for Claude Code.

The core idea is simple:

- keep the useful skill-based workflow from `superpowers`
- rewrite the trigger logic and instructions so Codex uses it more naturally
- ship a built-in harness so you can verify the remake against real Codex runs

This repository is not just a benchmark. The main product is the Codex-friendly distribution. The `coness` runner exists to prove that the remake actually changes Codex behavior.

## What Coness Is

Coness takes the original Superpowers workflow and adapts it for Codex.

That means:

- skill prompts are shorter and more direct
- small tasks can execute immediately instead of always forcing a long process
- planning, debugging, verification, and subagent usage are rewritten around Codex behavior
- installation is simplified for Codex users

If you want the shortest description:

> Coness is a Codex-first remake of a Claude-oriented skill pack, with a built-in Codex verification harness.

## Quick Install

Requirements:

- OpenAI Codex CLI
- Git
- Node.js
- PowerShell on Windows

Install:

```powershell
git clone https://github.com/nimdalkr/coness.git
cd coness
npm install
```

`npm install` does three things:

1. installs the local `coness` entrypoint
2. links this repo's skills into `~/.agents/skills/superpowers`
3. runs the default `quick` Codex check once

## Basic Usage

Quick check:

```powershell
npm run coness -- quick
```

Full suite:

```powershell
npm run coness -- full
```

Single case:

```powershell
node .\scripts\coness.js case writing-plans-natural
```

Reports are written to:

- `.\.coness\latest\results.md`
- `.\.coness\latest\results.json`

## Core Features

### 1. Codex-first skill distribution

This repo includes a rewritten version of the original workflow so Codex can use it more predictably.

Key skills already tuned for Codex include:

- `using-superpowers`
- `brainstorming`
- `systematic-debugging`
- `writing-plans`
- `subagent-driven-development`
- `verification-before-completion`

### 2. One-command installation

`coness install` links the skills into Codex's native skill directory and runs a default smoke check.

Manual install:

```powershell
node .\scripts\coness.js install
```

### 3. Built-in Codex verification harness

Coness can compare:

- the clean repository `HEAD`
- your current working tree

against the same prompt cases in Codex, then report:

- which skill was triggered
- whether the expected behavior matched
- runtime
- input and output token usage

## Third-Party Explanation

### Short version

Coness is a Codex-friendly remake of the original Superpowers workflow, which was designed mainly around Claude Code.

### Longer version

Coness keeps the useful skill system from Superpowers, but rewrites it for Codex's actual behavior. It also includes a built-in runner that checks whether those rewritten skills really trigger as intended in Codex.

## Docs

- [Codex guide](./docs/README.codex.md)
- [Coness commands](./docs/coness.md)
- [Codex harness details](./tests/codex/README.md)

## License

MIT License - see [LICENSE](./LICENSE)
