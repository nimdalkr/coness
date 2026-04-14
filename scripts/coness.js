#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const scriptPath = path.join(__dirname, "coness.ps1");

const args = process.argv.slice(2);
const isWindows = process.platform === "win32";
const shell = isWindows ? "powershell.exe" : "pwsh";

const result = spawnSync(
  shell,
  ["-ExecutionPolicy", "Bypass", "-File", scriptPath, ...args],
  { stdio: "inherit" }
);

if (result.error) {
  console.error(`Failed to launch ${shell}: ${result.error.message}`);
  process.exit(1);
}

process.exit(result.status ?? 1);
