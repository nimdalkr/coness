[CmdletBinding()]
param(
    [ValidateSet("install", "quick", "full", "case", "help")]
    [string]$Mode = "quick",
    [string[]]$CaseId = @(),
    [string]$CodexModel = "",
    [switch]$KeepArtifacts,
    [switch]$SkipQuickRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Harness = Join-Path $RepoRoot "tests\codex\compare-head-vs-working.ps1"
$OutputRoot = Join-Path $RepoRoot ".coness\latest"

$quickCases = @(
    "brainstorming-explicit",
    "systematic-debugging-natural",
    "writing-plans-natural",
    "verification-before-completion-explicit"
)

$SkillsRoot = Join-Path $env:USERPROFILE ".agents\skills"
$InstalledSkillPath = Join-Path $SkillsRoot "superpowers"

function Test-CommandAvailable([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Install-ConessSkillLink {
    Ensure-Directory $SkillsRoot
    if (Test-Path -LiteralPath $InstalledSkillPath) {
        try {
            $existing = (Get-Item -LiteralPath $InstalledSkillPath).Target
            if ($existing -and ($existing -contains (Join-Path $RepoRoot "skills"))) {
                Write-Host "Skill link already points to this repo."
                return
            }
        } catch {
        }

        Remove-Item -LiteralPath $InstalledSkillPath -Force -Recurse
    }

    $skillsPath = Join-Path $RepoRoot "skills"
    cmd /c mklink /J "$InstalledSkillPath" "$skillsPath" | Out-Null
    Write-Host "Installed skills at $InstalledSkillPath"
}

function Show-Help {
    Write-Host "coness - Codex skill evaluation harness"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  coness install"
    Write-Host "  coness quick"
    Write-Host "  coness full"
    Write-Host "  coness case <case-id> [<case-id> ...]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -CodexModel <model>    Override Codex model"
    Write-Host "  -KeepArtifacts         Keep baseline worktree artifacts"
    Write-Host "  -SkipQuickRun          With install mode, do not auto-run quick evaluation"
    Write-Host ""
    Write-Host "Output:"
    Write-Host "  .coness\latest\results.md"
    Write-Host "  .coness\latest\results.json"
}

if ($Mode -eq "help") {
    Show-Help
    exit 0
}

if ($Mode -eq "install") {
    Write-Host "Installing coness..."

    if (-not (Test-CommandAvailable "git")) {
        Write-Warning "Git is not available. Skipping coness install."
        exit 0
    }

    if (-not (Test-CommandAvailable "codex")) {
        Write-Warning "Codex CLI is not available. Skill link was not installed."
        exit 0
    }

    Install-ConessSkillLink
    Write-Host "Coness install complete."
    Write-Host "Restart Codex if it was already running."

    if (-not $SkipQuickRun) {
        Write-Host "Running default quick evaluation..."
        $quickArgs = @("-ExecutionPolicy", "Bypass", "-File", $PSCommandPath, "quick")
        if ($CodexModel) {
            $quickArgs += @("-CodexModel", $CodexModel)
        }
        & powershell @quickArgs
        exit $LASTEXITCODE
    }

    exit 0
}

if ($Mode -eq "case" -and $CaseId.Count -eq 0) {
    throw "Mode 'case' requires at least one case id."
}

$invokeArgs = @(
    "-ExecutionPolicy", "Bypass",
    "-File", $Harness,
    "-OutputRoot", $OutputRoot
)

if ($CodexModel) {
    $invokeArgs += @("-CodexModel", $CodexModel)
}

if ($KeepArtifacts) {
    $invokeArgs += "-KeepArtifacts"
}

switch ($Mode) {
    "quick" {
        $invokeArgs += @("-CaseId", ($quickCases -join ","))
    }
    "case" {
        $invokeArgs += @("-CaseId", ($CaseId -join ","))
    }
}

Write-Host "Running coness in '$Mode' mode..."
& powershell @invokeArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$resultsPath = Join-Path $OutputRoot "results.json"
if (-not (Test-Path -LiteralPath $resultsPath)) {
    throw "Expected results file not found at $resultsPath"
}

$results = Get-Content -LiteralPath $resultsPath -Raw | ConvertFrom-Json
$grouped = $results | Group-Object case_id

$baselinePass = 0
$candidatePass = 0

Write-Host ""
Write-Host "Coness Summary"
Write-Host "=============="

foreach ($group in $grouped) {
    $baseline = $group.Group | Where-Object { $_.variant -eq "baseline" } | Select-Object -First 1
    $candidate = $group.Group | Where-Object { $_.variant -eq "candidate" } | Select-Object -First 1
    if ($baseline.expected_matched) { $baselinePass += 1 }
    if ($candidate.expected_matched) { $candidatePass += 1 }

    $baselineState = if ($baseline.expected_matched) { "pass" } else { "fail" }
    $candidateState = if ($candidate.expected_matched) { "pass" } else { "fail" }

    Write-Host "- $($group.Name): baseline=$baselineState, candidate=$candidateState"
}

Write-Host ""
Write-Host "Matched expected skill:"
Write-Host "- baseline: $baselinePass / $($grouped.Count)"
Write-Host "- candidate: $candidatePass / $($grouped.Count)"
Write-Host ""
Write-Host "Artifacts:"
Write-Host "- $(Join-Path $OutputRoot 'results.md')"
Write-Host "- $(Join-Path $OutputRoot 'results.json')"
