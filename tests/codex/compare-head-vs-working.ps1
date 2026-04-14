[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [string]$CasesFile = "",
    [string]$OutputRoot = (Join-Path $env:TEMP "superpowers-codex-eval"),
    [string]$SkillsNamespace = "superpowers",
    [string]$CodexModel = "",
    [string[]]$CaseId = @(),
    [int]$RetryCount = 2,
    [switch]$KeepArtifacts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section([string]$Message) {
    Write-Host ""
    Write-Host "== $Message =="
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Remove-PathIfExists([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Force -Recurse
    }
}

function Resolve-CasePrompt([string]$CaseFilePath, [string]$PromptFile) {
    $baseDir = Split-Path -Parent $CaseFilePath
    return (Resolve-Path (Join-Path $baseDir $PromptFile)).Path
}

function Backup-SkillInstall([string]$SkillsRoot, [string]$Namespace) {
    Ensure-Directory $SkillsRoot
    $target = Join-Path $SkillsRoot $Namespace
    if (-not (Test-Path -LiteralPath $target)) {
        return $null
    }

    $backup = "$target.backup.$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
    Move-Item -LiteralPath $target -Destination $backup
    return $backup
}

function Restore-SkillInstall([string]$SkillsRoot, [string]$Namespace, [string]$BackupPath) {
    $target = Join-Path $SkillsRoot $Namespace
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Force -Recurse
    }
    if ($BackupPath -and (Test-Path -LiteralPath $BackupPath)) {
        Move-Item -LiteralPath $BackupPath -Destination $target
    }
}

function Install-SkillJunction([string]$SkillsRoot, [string]$Namespace, [string]$RepoPath) {
    Ensure-Directory $SkillsRoot
    $target = Join-Path $SkillsRoot $Namespace
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Force -Recurse
    }

    $skillsPath = Join-Path $RepoPath "skills"
    cmd /c mklink /J "$target" "$skillsPath" | Out-Null
}

function Ensure-BaselineWorktree([string]$RepoPath, [string]$BaselinePath) {
    if (Test-Path -LiteralPath $BaselinePath) {
        return
    }

    $null = & git -C $RepoPath worktree add --detach $BaselinePath HEAD
}

function Remove-BaselineWorktree([string]$RepoPath, [string]$BaselinePath) {
    if (Test-Path -LiteralPath $BaselinePath) {
        & git -C $RepoPath worktree remove --force $BaselinePath | Out-Null
    }
}

function New-EvalWorkspace([string]$WorkspacePath) {
    Remove-PathIfExists $WorkspacePath
    Ensure-Directory $WorkspacePath
    Set-Content -LiteralPath (Join-Path $WorkspacePath "README.txt") -Value "Codex evaluation workspace for superpowers." -NoNewline
}

function Invoke-CodexCase {
    param(
        [string]$VariantName,
        [string]$VariantRepo,
        [pscustomobject]$Case,
        [string]$CaseFilePath,
        [string]$RunRoot,
        [string]$WorkspacePath,
        [string]$SkillsRoot,
        [string]$Namespace,
        [string]$CodexModel
    )

    $caseDir = Join-Path $RunRoot "$VariantName-$($Case.id)"
    Ensure-Directory $caseDir

    $promptPath = Resolve-CasePrompt -CaseFilePath $CaseFilePath -PromptFile $Case.prompt_file
    $promptText = Get-Content -LiteralPath $promptPath -Raw
    $logPath = Join-Path $caseDir "codex-output.jsonl"
    $lastMessagePath = Join-Path $caseDir "last-message.txt"
    $promptInputPath = Join-Path $caseDir "prompt-input.txt"
    $stdoutPath = Join-Path $caseDir "stdout.log"
    $stderrPath = Join-Path $caseDir "stderr.log"

    Install-SkillJunction -SkillsRoot $SkillsRoot -Namespace $Namespace -RepoPath $VariantRepo
    New-EvalWorkspace -WorkspacePath $WorkspacePath
    Set-Content -LiteralPath $promptInputPath -Value $promptText

    $codexArgs = @(
        "exec",
        "--json",
        "--skip-git-repo-check",
        "--sandbox", "read-only",
        "--output-last-message", $lastMessagePath,
        "--cd", $WorkspacePath,
        "-"
    )

    if ($CodexModel) {
        $codexArgs = @("exec", "--json", "--skip-git-repo-check", "--sandbox", "read-only", "--output-last-message", $lastMessagePath, "--cd", $WorkspacePath, "--model", $CodexModel, "-")
    }

    $escapedArgs = $codexArgs | ForEach-Object {
        if ($_ -match '\s') {
            '"' + $_.Replace('"', '\"') + '"'
        } else {
            $_
        }
    }
    $cmdLine = 'type "' + $promptInputPath + '" | codex ' + ($escapedArgs -join ' ')

    $attempt = 0
    $exitCode = 1
    $stdoutText = ""
    $stderrText = ""
    $combined = ""
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    do {
        $attempt += 1
        Remove-PathIfExists $stdoutPath
        Remove-PathIfExists $stderrPath
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $cmdLine) -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -NoNewWindow -Wait -PassThru
        $exitCode = $process.ExitCode
        $stdoutText = if (Test-Path -LiteralPath $stdoutPath) { Get-Content -LiteralPath $stdoutPath -Raw } else { "" }
        $stderrText = if (Test-Path -LiteralPath $stderrPath) { Get-Content -LiteralPath $stderrPath -Raw } else { "" }
        $combined = @($stdoutText, $stderrText) -join [Environment]::NewLine
    } while ($exitCode -ne 0 -and $attempt -lt $RetryCount)
    $stopwatch.Stop()

    Set-Content -LiteralPath $logPath -Value $combined
    $logText = $combined
    $lastMessage = if (Test-Path -LiteralPath $lastMessagePath) { Get-Content -LiteralPath $lastMessagePath -Raw } else { "" }

    $rawSkills = New-Object System.Collections.Generic.List[string]
    $announcedSkills = New-Object System.Collections.Generic.List[string]
    $loadedSkills = New-Object System.Collections.Generic.List[string]

    foreach ($match in [regex]::Matches($logText, '"skill":"([^"]+)"')) {
        $rawSkills.Add($match.Groups[1].Value)
    }
    foreach ($match in [regex]::Matches($logText, '(using|used|loaded) `([^`]+)`(?: skill)?', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $announcedSkills.Add($match.Groups[2].Value)
    }
    foreach ($match in [regex]::Matches($logText, '\b(?:using|used|loaded|load(?:ing)?)\s+([a-z]+(?:-[a-z]+)+)\b', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $announcedSkills.Add($match.Groups[1].Value)
    }
    foreach ($match in [regex]::Matches($logText, '(using|used|loaded) the `([^`]+)` skill', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $announcedSkills.Add($match.Groups[2].Value)
    }
    foreach ($match in [regex]::Matches($logText, 'using the `([^`]+)` skill', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $announcedSkills.Add($match.Groups[1].Value)
    }
    foreach ($match in [regex]::Matches($logText, 'skills\\\\([^\\\\]+)\\\\SKILL\.md', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $loadedSkills.Add($match.Groups[1].Value)
    }
    foreach ($match in [regex]::Matches($logText, '"name":"Skill"')) {
        if ($rawSkills.Count -eq 0) {
            $rawSkills.Add("Skill")
        }
    }

    $uniqueSkills = @($rawSkills + $announcedSkills + $loadedSkills | Sort-Object -Unique)
    $uniqueAnnounced = @($announcedSkills | Sort-Object -Unique)
    $uniqueLoaded = @($loadedSkills | Sort-Object -Unique)
    $expected = [string]$Case.expected_skill
    $expectedMatched = $false
    $expectedSignal = "none"
    if ($expected) {
        if ($uniqueAnnounced | Where-Object { $_ -eq $expected -or $_ -eq "${Namespace}:$expected" } | Select-Object -First 1) {
            $expectedMatched = $true
            $expectedSignal = "announced"
        } elseif ($uniqueLoaded | Where-Object { $_ -eq $expected -or $_ -eq "${Namespace}:$expected" } | Select-Object -First 1) {
            $expectedMatched = $true
            $expectedSignal = "loaded"
        } else {
            $expectedMatched = $uniqueSkills | Where-Object { $_ -eq $expected -or $_ -eq "${Namespace}:$expected" } | ForEach-Object { $true } | Select-Object -First 1
            $expectedMatched = [bool]$expectedMatched
            if ($expectedMatched) {
                $expectedSignal = "raw"
            }
        }
        $expectedMatched = [bool]$expectedMatched
    }

    $usageInput = $null
    $usageOutput = $null
    foreach ($line in (Get-Content -LiteralPath $logPath -ErrorAction SilentlyContinue)) {
        if ($line -like '*"type":"turn.completed"*') {
            try {
                $obj = $line | ConvertFrom-Json
                if ($obj.usage) {
                    $usageInput = $obj.usage.input_tokens
                    $usageOutput = $obj.usage.output_tokens
                }
            } catch {
            }
        }
    }

    return [pscustomobject]@{
        variant = $VariantName
        case_id = $Case.id
        expected_skill = $expected
        triggered_skills = $uniqueSkills
        loaded_skills = $uniqueLoaded
        announced_skills = $uniqueAnnounced
        expected_matched = $expectedMatched
        expected_signal = $expectedSignal
        exit_code = $exitCode
        duration_ms = [int]$stopwatch.ElapsedMilliseconds
        input_tokens = $usageInput
        output_tokens = $usageOutput
        last_message_length = $lastMessage.Length
        attempts = $attempt
        artifacts_dir = $caseDir
    }
}

function Write-MarkdownReport([object[]]$Results, [string]$ReportPath) {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Codex Skill Trigger Comparison")
    $lines.Add("")
    $lines.Add("| Case | Variant | Expected | Matched | Signal | Exit | Attempts | Duration ms | Input tokens | Output tokens | Announced | Loaded |")
    $lines.Add("|------|---------|----------|---------|--------|------|----------|-------------|--------------|---------------|-----------|--------|")

    foreach ($result in $Results) {
        $announced = if ($result.announced_skills.Count -gt 0) { ($result.announced_skills -join ", ") } else { "(none)" }
        $loaded = if ($result.loaded_skills.Count -gt 0) { ($result.loaded_skills -join ", ") } else { "(none)" }
        $matched = if ($result.expected_skill) { if ($result.expected_matched) { "yes" } else { "no" } } else { "n/a" }
        $lines.Add("| $($result.case_id) | $($result.variant) | $($result.expected_skill) | $matched | $($result.expected_signal) | $($result.exit_code) | $($result.attempts) | $($result.duration_ms) | $($result.input_tokens) | $($result.output_tokens) | $announced | $loaded |")
    }

    Set-Content -LiteralPath $ReportPath -Value $lines
}

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

if (-not $CasesFile) {
    $CasesFile = (Resolve-Path (Join-Path $PSScriptRoot "cases.json")).Path
} else {
    $CasesFile = (Resolve-Path $CasesFile).Path
}

if ($CaseId.Count -gt 0) {
    $CaseId = @(
        $CaseId |
        ForEach-Object { $_ -split "," } |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
    )
}

$OutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)
$SkillsRoot = Join-Path $env:USERPROFILE ".agents\skills"
$BaselinePath = Join-Path $OutputRoot "baseline-head"
$WorkspacePath = Join-Path $OutputRoot "workspace"
$RunRoot = Join-Path $OutputRoot "runs"

Write-Section "Preparing output directories"
Remove-PathIfExists $RunRoot
Ensure-Directory $OutputRoot
Ensure-Directory $RunRoot

Write-Section "Preparing clean HEAD worktree"
Ensure-BaselineWorktree -RepoPath $RepoRoot -BaselinePath $BaselinePath

$backupPath = $null
try {
    Write-Section "Preparing skill installation"
    $backupPath = Backup-SkillInstall -SkillsRoot $SkillsRoot -Namespace $SkillsNamespace

    $cases = Get-Content -LiteralPath $CasesFile -Raw | ConvertFrom-Json
    if ($CaseId.Count -gt 0) {
        $cases = @($cases | Where-Object { $CaseId -contains $_.id })
    }

    if ($cases.Count -eq 0) {
        throw "No matching cases found."
    }
    $results = New-Object System.Collections.Generic.List[object]

    foreach ($case in $cases) {
        Write-Host "Running case: $($case.id)"

        $baselineResult = Invoke-CodexCase `
            -VariantName "baseline" `
            -VariantRepo $BaselinePath `
            -Case $case `
            -CaseFilePath $CasesFile `
            -RunRoot $RunRoot `
            -WorkspacePath $WorkspacePath `
            -SkillsRoot $SkillsRoot `
            -Namespace $SkillsNamespace `
            -CodexModel $CodexModel

        $candidateResult = Invoke-CodexCase `
            -VariantName "candidate" `
            -VariantRepo $RepoRoot `
            -Case $case `
            -CaseFilePath $CasesFile `
            -RunRoot $RunRoot `
            -WorkspacePath $WorkspacePath `
            -SkillsRoot $SkillsRoot `
            -Namespace $SkillsNamespace `
            -CodexModel $CodexModel

        $results.Add($baselineResult)
        $results.Add($candidateResult)
    }

    $jsonPath = Join-Path $OutputRoot "results.json"
    $mdPath = Join-Path $OutputRoot "results.md"
    $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath
    Write-MarkdownReport -Results $results -ReportPath $mdPath

    Write-Section "Complete"
    Write-Host "JSON report: $jsonPath"
    Write-Host "Markdown report: $mdPath"
} finally {
    Restore-SkillInstall -SkillsRoot $SkillsRoot -Namespace $SkillsNamespace -BackupPath $backupPath
    if (-not $KeepArtifacts) {
        Remove-BaselineWorktree -RepoPath $RepoRoot -BaselinePath $BaselinePath
    }
}
