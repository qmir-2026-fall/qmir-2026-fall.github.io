<#
.SYNOPSIS
  Render the Quarto website and publish rendered output to the public Pages repo.
.DESCRIPTION
  The monorepo is PRIVATE and holds solutions. Only rendered site output goes public.
  `quarto publish gh-pages` renders website/ and pushes the built _site to the gh-pages
  branch of the configured Pages repo — homework/ and exam/ are never touched.
.PARAMETER DryRun
  Render only; do not publish.
#>
param(
  [string]$SiteDir  = "website",
  [string]$PagesRepo = "qmir-2026-fall/qmir-2026-fall.github.io",  # public Pages repo
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$site = Join-Path $root $SiteDir

Write-Host "Rendering $site ..."
Push-Location $site
try {
  quarto render
  if ($DryRun) {
    Write-Host "[DryRun] Rendered only. Would publish to $PagesRepo (gh-pages)." -ForegroundColor Yellow
  } else {
    # Publishes the rendered _site to the gh-pages branch of $PagesRepo.
    quarto publish gh-pages --no-prompt
    Write-Host "Published to $PagesRepo." -ForegroundColor Green
  }
} finally {
  Pop-Location
}
