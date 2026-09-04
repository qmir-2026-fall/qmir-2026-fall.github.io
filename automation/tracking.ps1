<#
.SYNOPSIS
  Derive homework submission status from the org - no hand entry.
.DESCRIPTION
  Enumerates hw-NN-<username> repos on the org via `gh` and writes tracking/hw_status.csv
  (github_username, week, submitted, on_time, last_push), which tracking/progress.qmd reads.
  With Classroom 50 not adopted, this is the PRIMARY homework tracking path.

  HEURISTIC. A repo generated from the hw-NN template always has a commit, and its pushedAt
  is always after the release date - so "pushed after release" marks EVERYONE as submitted.
  What distinguishes a submission is work *after* the template import:

    default   pushedAt > createdAt (+2 min slack)   - free, no extra API calls
    -Strict   commit count > 1                      - exact, costs 1 API call per repo

  `on_time` additionally compares the last push against `due:` in homework/hw-NN/meta.yml.
.EXAMPLE
  ./automation/tracking.ps1
  ./automation/tracking.ps1 -Week 05 -Strict
#>
param(
  [string]$Org  = "qmir-2026-fall",
  [string]$Week,                       # optional: restrict to one week, e.g. 05
  [switch]$Strict,                     # exact commit-count check (1 API call per repo)
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# which weeks to check = those with a homework/hw-NN folder
$hwDirs = @(Get-ChildItem (Join-Path $root "homework") -Directory |
            Where-Object { $_.Name -match '^hw-\d+$' })
if ($Week) { $hwDirs = @($hwDirs | Where-Object { $_.Name -eq "hw-$Week" }) }
if (-not $hwDirs) { throw "No homework folders found (looked for homework/hw-NN)." }

# One org listing for all weeks (was: one call per week).
# NOTE: capture parsed JSON in a var, then filter in a SEPARATE statement. Chaining
# Where-Object directly onto `gh | ConvertFrom-Json` silently returns everything in
# Windows PowerShell 5.1 (streaming quirk). See automation/README.md.
$parsed  = gh repo list $Org --limit 1000 --json name,pushedAt,createdAt | ConvertFrom-Json
$allRepos = @($parsed)

$rows = @()
foreach ($d in $hwDirs) {
  $slug = $d.Name                       # hw-05
  $wk   = [int]($slug -replace 'hw-', '')

  $metaPath = Join-Path $d.FullName "meta.yml"
  $due = $null
  if (Test-Path $metaPath) {
    $m = Select-String -Path $metaPath -Pattern '^\s*due:\s*(\S+)' | Select-Object -First 1
    if ($m) { $due = [datetime]$m.Matches.Groups[1].Value }
  }

  $repos = @($allRepos | Where-Object { $_.name -match "^$slug-(.+)$" })

  foreach ($r in $repos) {
    # GitHub usernames are case-insensitive; lowercase so the join against the roster
    # in progress.qmd cannot miss on capitalisation.
    $user    = ($r.name -replace "^$slug-", "").ToLower()
    $pushed  = [datetime]$r.pushedAt
    $created = [datetime]$r.createdAt

    if ($Strict) {
      $n = gh api "repos/$Org/$($r.name)/commits?per_page=100" --jq 'length'
      $submitted = if ([int]$n -gt 1) { 1 } else { 0 }
    } else {
      # Work beyond the template import: a push at least 2 minutes after creation.
      $submitted = if ($pushed -gt $created.AddMinutes(2)) { 1 } else { 0 }
    }

    $onTime = if ($submitted -eq 0) { 0 } elseif ($due) { if ($pushed -le $due.AddDays(1)) { 1 } else { 0 } } else { 1 }

    $rows += [pscustomobject]@{
      github_username = $user
      week            = $wk
      submitted       = $submitted
      on_time         = $onTime
      last_push       = $pushed.ToString('yyyy-MM-dd')
    }
  }
}

Write-Host "Homework status derived from $Org ($(if ($Strict) {'strict'} else {'fast'}) check):" -ForegroundColor Cyan
$rows | Group-Object week | Sort-Object Name | ForEach-Object {
  $sub = @($_.Group | Where-Object { $_.submitted -eq 1 }).Count
  $late = @($_.Group | Where-Object { $_.submitted -eq 1 -and $_.on_time -eq 0 }).Count
  Write-Host ("  week {0}: {1} submitted / {2} repos ({3} late)" -f $_.Name, $sub, $_.Count, $late)
}

$outfile = Join-Path $root "tracking\hw_status.csv"
if ($DryRun) {
  Write-Host "[DryRun] Would write $($rows.Count) rows to $outfile" -ForegroundColor Yellow
} else {
  $rows | Sort-Object week, github_username | Export-Csv $outfile -NoTypeInformation -Encoding UTF8
  Write-Host "Wrote $outfile ($($rows.Count) rows). Render tracking/progress.qmd to view." -ForegroundColor Green
  Write-Host "NOTE: hw_status.csv is git-ignored (student usernames) - it is a local artifact." -ForegroundColor DarkGray
}
