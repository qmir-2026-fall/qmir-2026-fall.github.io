<#
.SYNOPSIS
  Create/refresh the public distribution repo hw-NN from homework/hw-NN.
.DESCRIPTION
  Copies homework/hw-NN/ into a scratch dir (minus instructor-only files), pushes it to the
  org repo `hw-NN`, and marks it a template repo. Students then "Use this template" to get
  hw-NN-<username>. Idempotent: re-running refreshes the distribution repo.

  Sample solutions live in the PRIVATE solutions/ submodule, not under homework/, so there
  is nothing to strip. The solution.* exclusion and the post-copy leak assertion are kept
  anyway as defense in depth — they cost nothing and they are the last line before publish.
.EXAMPLE
  ./automation/release-homework.ps1 -Week 05 -DryRun
  ./automation/release-homework.ps1 -Week 05
#>
param(
  [Parameter(Mandatory)][string]$Week,          # e.g. 05
  [string]$Org = "qmir-2026-fall",
  [switch]$Classroom,                            # INACTIVE: Classroom 50 is not adopted (CLAUDE.md §6)
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root  = Split-Path -Parent $PSScriptRoot
$slug  = "hw-$Week"
$src   = Join-Path $root "homework\$slug"
if (-not (Test-Path $src)) { throw "No such homework: $src" }

# --- build the student-facing payload ---
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

# --- add the files every distribution repo gets, from the template ---
$tpl = Join-Path $root "homework\_template"
foreach ($extra in @(".github\workflows\hw-check.yml", ".gitignore")) {
  $from = Join-Path $tpl $extra
  $to   = Join-Path $work $extra
  if ((Test-Path $from) -and (-not (Test-Path $to))) {
    New-Item -ItemType Directory -Path (Split-Path $to) -Force | Out-Null
    Copy-Item $from $to
    $copied += $extra
  }
}

Write-Host "Distribution payload for $slug :" -ForegroundColor Cyan
$copied | ForEach-Object { Write-Host "  $_" }

# Last line of defense: nothing named *solution* may ever reach a public distribution repo.
$leaked = $copied | Where-Object { $_ -like "*solution*" }
if ($leaked) { throw "ABORT: solution file in payload: $($leaked -join ', ')" }

$templateUrl = "https://github.com/$Org/$slug/generate"
if ($DryRun) {
  Write-Host "[DryRun] Would push the above to $Org/$slug and mark it a template." -ForegroundColor Yellow
  Write-Host "[DryRun] Accept link for schedule.qmd: $templateUrl" -ForegroundColor Yellow
  return
}

# --- publish to the org distribution repo ---
Push-Location $work
try {
  git init -q -b main          # -b main: the push below targets main
  git add -A
  git -c user.name="QMIR" -c user.email="noreply@github.com" commit -q -m "Release $slug"

  # NOTE: do NOT test `gh repo view` by capturing its output — redirecting a native
  # command's stderr under $ErrorActionPreference='Stop' raises NativeCommandError in
  # Windows PowerShell 5.1. Check the exit code instead.
  gh repo view "$Org/$slug" *> $null
  $exists = ($LASTEXITCODE -eq 0)

  if (-not $exists) {
    gh repo create "$Org/$slug" --public --source . --push --disable-wiki `
      --description "QMIR $($slug.ToUpper()) — starter repo. Use this template to create your submission repo."
  } else {
    git remote remove origin *> $null
    git remote add origin "https://github.com/$Org/$slug.git"
    git push -f origin HEAD:main
  }
  gh repo edit "$Org/$slug" --template   # mark as a template repo
} finally { Pop-Location }

if ($Classroom) {
  # Classroom 50 was evaluated and deferred (CLAUDE.md §6). Left here so the path is one
  # uncomment away if it is ever adopted mid-term.
  Write-Host "-Classroom is inactive: Classroom 50 is not in use this term." -ForegroundColor Yellow
  # gh teacher assignment add $Org qmir $slug --name "Homework $Week" --template "$Org/$slug"
}

Write-Host "Released $Org/$slug." -ForegroundColor Green
Write-Host "Accept link for schedule.qmd:  $templateUrl" -ForegroundColor Green
