<#
.SYNOPSIS
  Create/refresh the public distribution repo hw-NN from homework/hw-NN, stripping solutions.
.DESCRIPTION
  Copies homework/hw-NN/ into a scratch dir MINUS anything named solution.* (so a solution
  physically cannot leak), then pushes it to org repo `hw-NN`, marks it a template, and
  (optionally) registers it as a Classroom 50 assignment. Idempotent: re-running refreshes.
.EXAMPLE
  ./automation/release-homework.ps1 -Week 05
  ./automation/release-homework.ps1 -Week 05 -DryRun
#>
param(
  [Parameter(Mandatory)][string]$Week,          # e.g. 05
  [string]$Org = "qmir-2026-fall",
  [switch]$Classroom,                            # also register as a Classroom 50 assignment
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root  = Split-Path -Parent $PSScriptRoot
$slug  = "hw-$Week"
$src   = Join-Path $root "homework\$slug"
if (-not (Test-Path $src)) { throw "No such homework: $src" }

# --- build the student-facing payload (strip solutions) ---
$work = Join-Path $env:TEMP "qmir-release\$slug"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work -Force | Out-Null

$exclude = @("solution.*", "meta.yml")   # solution + instructor-only metadata never ship
$copied = @()
Get-ChildItem $src -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($src.Length + 1)
  $skip = $false
  foreach ($pat in $exclude) { if ($_.Name -like $pat) { $skip = $true } }
  if ($skip) { return }
  $dest = Join-Path $work $rel
  New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
  Copy-Item $_.FullName $dest
  $copied += $rel
}

Write-Host "Distribution payload for $slug (solution stripped):" -ForegroundColor Cyan
$copied | ForEach-Object { Write-Host "  $_" }
$leaked = $copied | Where-Object { $_ -like "*solution*" }
if ($leaked) { throw "ABORT: solution file in payload: $($leaked -join ', ')" }

if ($DryRun) {
  Write-Host "[DryRun] Would push above to $Org/$slug (template) and NOT publish solution." -ForegroundColor Yellow
  if ($Classroom) { Write-Host "[DryRun] Would register Classroom 50 assignment $slug." -ForegroundColor Yellow }
  return
}

# --- publish to the org distribution repo ---
Push-Location $work
try {
  git init -q; git add -A; git commit -q -m "Release $slug"
  if (-not (gh repo view "$Org/$slug" 2>$null)) {
    gh repo create "$Org/$slug" --public --source . --push --disable-wiki
  } else {
    git remote add origin "https://github.com/$Org/$slug.git" 2>$null
    git push -f origin HEAD:main
  }
  gh repo edit "$Org/$slug" --template   # mark as a template repo
} finally { Pop-Location }

if ($Classroom) {
  gh teacher assignment add $Org qmir $slug --name "Homework $Week" --template "$Org/$slug"
}
Write-Host "Released $Org/$slug." -ForegroundColor Green
