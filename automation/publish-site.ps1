<#
.SYNOPSIS
  Render the Quarto website and publish it to GitHub Pages.
.DESCRIPTION
  This monorepo IS the Pages repo: it is public and named <org>/<org>.github.io, so
  `quarto publish gh-pages` (run from website/) renders the site and force-pushes the
  built _site to this repo's own gh-pages branch, which Pages serves at the apex URL.
  main holds the sources; gh-pages holds only rendered output. Nothing else moves.

  Only website/ is rendered. homework/ is public but is not part of the site project,
  and solutions/ is a private submodule that is never rendered here.
.PARAMETER DryRun
  Render only; do not publish.
.EXAMPLE
  ./automation/publish-site.ps1 -DryRun
  ./automation/publish-site.ps1
#>
param(
  [string]$SiteDir = "website",
  [string]$SiteUrl = "https://qmir-2026-fall.github.io/",
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$site = Join-Path $root $SiteDir

# --- guard: publishing from a dirty tree makes the live site untraceable to a commit ---
Push-Location $root
try {
  $dirty = @(git status --porcelain)
  if ($dirty -and -not $DryRun) {
    Write-Host "Uncommitted changes in the working tree:" -ForegroundColor Yellow
    $dirty | ForEach-Object { Write-Host "  $_" }
    throw "Commit (or stash) before publishing, so the live site maps to a commit."
  }
} finally { Pop-Location }

Write-Host "Rendering $site ..." -ForegroundColor Cyan
Push-Location $site
try {
  if ($DryRun) {
    quarto render
    Write-Host "[DryRun] Rendered only. Would publish _site to the gh-pages branch -> $SiteUrl" -ForegroundColor Yellow
  } else {
    # Renders, then force-pushes _site to gh-pages of this repo's origin.
    quarto publish gh-pages --no-prompt --no-browser
    Write-Host "Published. Live (after Pages rebuilds, ~1 min): $SiteUrl" -ForegroundColor Green
  }
} finally { Pop-Location }
