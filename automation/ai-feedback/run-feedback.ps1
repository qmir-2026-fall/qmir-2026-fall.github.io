<#
.SYNOPSIS
  Draft opt-in AI feedback for a week's homework and push it to opted-in student repos.
.DESCRIPTION
  For each student repo hw-NN-<username> that contains a `license.md` (the opt-in signal):
    1. clone it into a scratch dir (git-ignored, never committed to this monorepo);
    2. assemble Claude's inputs — the student's submission, the sample solution, the prompt,
       and the 8-step rubric — plus the FEEDBACK.qmd template;
    3. run Claude (headless) with automation/ai-feedback/FEEDBACK-PROMPT.md;
    4. render FEEDBACK.qmd -> FEEDBACK.pdf;
    5. commit + push FEEDBACK.qmd and FEEDBACK.pdf back to the student's repo.
  No Anthropic key ever leaves this machine; nothing runs in student repos.
.EXAMPLE
  ./automation/ai-feedback/run-feedback.ps1 -Week 05 -DryRun   # just list who opted in
  ./automation/ai-feedback/run-feedback.ps1 -Week 05
#>
param(
  [Parameter(Mandatory)][string]$Week,
  [string]$Org = "qmir-2026-fall",
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$root = Split-Path -Parent (Split-Path -Parent $here)
$slug = "hw-$Week"
$hwDir = Join-Path $root "homework\$slug"
if (-not (Test-Path $hwDir)) { throw "No such homework: $hwDir" }

$work = Join-Path $here "_work\$slug"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work -Force | Out-Null

# --- find opted-in repos: hw-NN-<username> containing license.md ---
# NOTE: capture parsed JSON in a var, then filter separately. Chaining Where-Object directly
# onto `gh | ConvertFrom-Json` silently returns everything in Windows PowerShell 5.1.
$parsed = gh repo list $Org --limit 1000 --json name | ConvertFrom-Json
$repos  = @($parsed | Where-Object { $_.name -match "^$slug-(.+)$" }) |
          Select-Object -ExpandProperty name

$optedIn = @()
foreach ($r in $repos) {
  # Opt-in signal = a license file at the repo root. The trigger is documented as `license.md`,
  # but the GitHub contents API is CASE-SENSITIVE, so match tolerantly (license / LICENSE, with
  # or without .md) — a student shouldn't miss out over a capitalization slip.
  $names = gh api "repos/$Org/$r/contents" --jq '.[].name' 2>$null
  if ($names -and ($names | Where-Object { $_ -match '(?i)^license(\.md)?$' })) { $optedIn += $r }
}

Write-Host "$slug : $($optedIn.Count) opted-in / $($repos.Count) submissions." -ForegroundColor Cyan
$optedIn | ForEach-Object { Write-Host "  opted in: $_" }

if ($DryRun) { Write-Host "[DryRun] No cloning, no Claude, no pushes." -ForegroundColor Yellow; return }

$prompt = Get-Content (Join-Path $here "FEEDBACK-PROMPT.md") -Raw

foreach ($r in $optedIn) {
  Write-Host "== $r ==" -ForegroundColor Cyan
  $case = Join-Path $work $r
  New-Item -ItemType Directory -Path $case -Force | Out-Null

  # 1. clone the student submission
  gh repo clone "$Org/$r" (Join-Path $case "submission") -- -q

  # 2. assemble Claude's inputs alongside the submission
  Copy-Item (Join-Path $hwDir "solution.qmd") (Join-Path $case "solution.qmd")
  Copy-Item (Join-Path $hwDir "README.md")    (Join-Path $case "prompt.md")
  Copy-Item (Join-Path $root "website\slides\_workflow-8step.qmd") (Join-Path $case "rubric.md")
  Copy-Item (Join-Path $here "feedback-template.qmd") (Join-Path $case "FEEDBACK.qmd")

  # 3. run Claude headless, working in the case dir; it writes only FEEDBACK.qmd
  Push-Location $case
  try {
    claude -p $prompt --allowedTools "Read,Edit,Write" 2>&1 | Write-Host

    # 4. render to PDF
    quarto render "FEEDBACK.qmd" --to pdf

    # 5. push FEEDBACK.qmd + FEEDBACK.pdf into the student's repo
    Copy-Item "FEEDBACK.qmd" "submission\FEEDBACK.qmd" -Force
    Copy-Item "FEEDBACK.pdf" "submission\FEEDBACK.pdf" -Force
    Push-Location "submission"
    git add FEEDBACK.qmd FEEDBACK.pdf
    git commit -q -m "Add automated feedback (opt-in)"
    git push -q
    Pop-Location
    Write-Host "  pushed FEEDBACK to $Org/$r" -ForegroundColor Green
  } finally { Pop-Location }
}

Write-Host "Done. Scratch in $work is git-ignored; delete when finished." -ForegroundColor Green
