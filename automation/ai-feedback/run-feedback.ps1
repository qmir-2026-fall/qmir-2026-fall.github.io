<#
.SYNOPSIS
  Draft opt-in AI feedback for a week's homework and push it to opted-in student repos.
.DESCRIPTION
  For each student repo hw-NN-<username> that contains a `license.md` (the opt-in signal):
    1. clone it into a scratch dir (git-ignored, never committed to this monorepo);
    2. assemble Claude's inputs - the student's submission, the sample solution (from the
       PRIVATE solutions/ submodule), the homework prompt, and the 8-step rubric;
    3. run Claude headless with automation/ai-feedback/FEEDBACK-PROMPT.md;
    4. verify Claude touched NOTHING but FEEDBACK.qmd;
    5. render FEEDBACK.qmd -> FEEDBACK.pdf and push both to the student's repo.
  No Anthropic key ever leaves this machine; nothing runs inside student repos.
.EXAMPLE
  ./automation/ai-feedback/run-feedback.ps1 -Week 05 -DryRun          # just list who opted in
  ./automation/ai-feedback/run-feedback.ps1 -Week 05 -Student someone # one student
  ./automation/ai-feedback/run-feedback.ps1 -Week 05
#>
param(
  [Parameter(Mandatory)][string]$Week,
  [string]$Org = "qmir-2026-fall",
  [string]$Student,                     # optional: run for a single github username
  [int]$MaxTurns = 40,
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "..\_common.ps1")
$here = $PSScriptRoot
$root = Split-Path -Parent (Split-Path -Parent $here)
$slug = "hw-$Week"
$hwDir  = Join-Path $root "homework\$slug"
$solDir = Join-Path $root "solutions\$slug"
if (-not (Test-Path $hwDir))  { throw "No such homework: $hwDir" }
if (-not (Test-Path (Join-Path $solDir "solution.qmd"))) {
  throw "No solution at $solDir. Is the private solutions/ submodule checked out? (git submodule update --init)"
}

$work = Join-Path $here "_work\$slug"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work -Force | Out-Null

# --- find opted-in repos: hw-NN-<username> containing license.md ---
# NOTE: capture parsed JSON in a var, then filter separately. Chaining Where-Object directly
# onto `gh | ConvertFrom-Json` silently returns everything in Windows PowerShell 5.1.
$parsed = gh repo list $Org --limit 1000 --json name | ConvertFrom-Json
$repos  = @($parsed | Where-Object { $_.name -match "^$slug-(.+)$" }) |
          Select-Object -ExpandProperty name
if ($Student) { $repos = @($repos | Where-Object { $_ -eq "$slug-$Student" }) }

$optedIn = @()
foreach ($r in $repos) {
  # Opt-in signal = a license file at the repo root. The trigger is documented as `license.md`,
  # but the GitHub contents API is CASE-SENSITIVE, so match tolerantly (license / LICENSE, with
  # or without .md) - a student shouldn't miss out over a capitalization slip.
  $names = Get-NativeOutput { gh api "repos/$Org/$r/contents" --jq '.[].name' }
  if ($names -and (@($names -split "`n") | Where-Object { $_.Trim() -match '(?i)^license(\.md)?$' })) { $optedIn += $r }
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
  Copy-Item (Join-Path $solDir "solution.qmd")  (Join-Path $case "solution.qmd")
  Copy-Item (Join-Path $hwDir  "README.md")     (Join-Path $case "prompt.md")
  Copy-Item (Join-Path $root "website\slides\_workflow-8step.qmd") (Join-Path $case "rubric.md")
  Copy-Item (Join-Path $here "feedback-template.qmd") (Join-Path $case "FEEDBACK.qmd")

  Push-Location $case
  try {
    # 3. run Claude headless in the case dir; the prompt says FEEDBACK.qmd is the only writable file
    claude -p $prompt --allowedTools "Read,Edit,Write" --permission-mode acceptEdits `
           --max-turns $MaxTurns 2>&1 | Write-Host

    # 4. ENFORCE the "only FEEDBACK.qmd" rule. Student repo content is untrusted input to a
    #    model; never push back anything the model changed in the student's own files.
    Push-Location "submission"
    $touched = @(git status --porcelain)
    Pop-Location
    if ($touched) {
      Write-Host "Claude modified files inside the submission:" -ForegroundColor Red
      $touched | ForEach-Object { Write-Host "  $_" }
      throw "ABORT for $r - refusing to push. Inspect $case, then re-run for this student."
    }

    # 5. render to PDF and push FEEDBACK.qmd + FEEDBACK.pdf into the student's repo
    quarto render "FEEDBACK.qmd" --to pdf
    Copy-Item "FEEDBACK.qmd" "submission\FEEDBACK.qmd" -Force
    Copy-Item "FEEDBACK.pdf" "submission\FEEDBACK.pdf" -Force
    Push-Location "submission"
    try {
      git add FEEDBACK.qmd FEEDBACK.pdf
      git commit -q -m "Add automated feedback (opt-in)"
      git push -q
      Write-Host "  pushed FEEDBACK to $Org/$r" -ForegroundColor Green
    } finally { Pop-Location }
  } finally { Pop-Location }
}

Write-Host "Done. Scratch in $work is git-ignored; delete when finished." -ForegroundColor Green
