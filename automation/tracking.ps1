<#
.SYNOPSIS
  Derive homework submission status from the org — no hand entry.
.DESCRIPTION
  Enumerates hw-NN-<username> repos on the org via `gh`, and marks a submission when the repo
  has activity after the assignment's release date (from homework/hw-NN/meta.yml). Writes
  tracking/hw_status.csv (github_username, week, submitted) which progress.qmd reads.
  This is the fallback / archival companion to the Classroom 50 dashboard.

  Heuristic: a student repo whose last push (pushedAt) is after the release date = submitted.
  Template creation happens at/after release with an initial commit; a later push means work.
  Tighten if needed with a commit-count check (see comment below).
.EXAMPLE
  ./automation/tracking.ps1
  ./automation/tracking.ps1 -Week 05
#>
param(
  [string]$Org  = "qmir-2026-fall",
  [string]$Week,                       # optional: restrict to one week, e.g. 05
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# which weeks to check = those with a homework/hw-NN/meta.yml
$hwDirs = Get-ChildItem (Join-Path $root "homework") -Directory |
          Where-Object { $_.Name -match '^hw-\d+$' }
if ($Week) { $hwDirs = $hwDirs | Where-Object { $_.Name -eq "hw-$Week" } }

$rows = @()
foreach ($d in $hwDirs) {
  $slug = $d.Name                       # hw-05
  $wk   = ($slug -replace 'hw-', '')
  $metaPath = Join-Path $d.FullName "meta.yml"
  $released = if (Test-Path $metaPath) {
    ($m = Select-String -Path $metaPath -Pattern '^\s*released:\s*(\S+)') | Out-Null
    if ($m) { [datetime]$m.Matches.Groups[1].Value } else { [datetime]"1900-01-01" }
  } else { [datetime]"1900-01-01" }

  # all student repos for this week: hw-05-<username>
  # NOTE: capture parsed JSON in a var, then filter in a SEPARATE statement. Chaining
  # Where-Object directly onto `gh | ConvertFrom-Json` silently returns everything in
  # Windows PowerShell 5.1 (streaming quirk). See automation/README.md.
  $parsed = gh repo list $Org --limit 1000 --json name,pushedAt | ConvertFrom-Json
  $repos  = @($parsed | Where-Object { $_.name -match "^$slug-(.+)$" })

  foreach ($r in $repos) {
    $user = $r.name -replace "^$slug-", ""
    $submitted = if (([datetime]$r.pushedAt) -gt $released) { 1 } else { 0 }
    # Stricter alternative (costs 1 API call/repo):
    #   $n = (gh api "repos/$Org/$($r.name)/commits?per_page=100" --jq 'length')
    #   $submitted = if ([int]$n -gt 1) { 1 } else { 0 }
    $rows += [pscustomobject]@{ github_username = $user; week = [int]$wk; submitted = $submitted }
  }
}

$summary = $rows | Group-Object week | ForEach-Object {
  "  week $($_.Name): $((($_.Group | Where-Object submitted -eq 1).Count)) submitted / $($_.Count) repos"
}
Write-Host "Homework status derived from $Org :" -ForegroundColor Cyan
$summary | ForEach-Object { Write-Host $_ }

$outfile = Join-Path $root "tracking\hw_status.csv"
if ($DryRun) {
  Write-Host "[DryRun] Would write $($rows.Count) rows to $outfile" -ForegroundColor Yellow
} else {
  $rows | Sort-Object week, github_username | Export-Csv $outfile -NoTypeInformation
  Write-Host "Wrote $outfile ($($rows.Count) rows). Render tracking/progress.qmd to view." -ForegroundColor Green
}
