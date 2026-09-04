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
  [string]$Org     = "qmir-2026-fall",
  [string]$Repo    = "qmir-2026-fall.github.io",
  [string]$SiteUrl = "https://qmir-2026-fall.github.io/",
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")
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

# --- one-time bootstrap: `quarto publish gh-pages --no-prompt` refuses to CREATE the branch ---
# It only pushes to a gh-pages branch that already exists on origin. Create an empty orphan
# commit for it the first time (4b825dc... is git's well-known empty-tree object).
if (-not $DryRun) {
  Push-Location $root
  try {
    if (-not (Test-NativeOk { git ls-remote --exit-code --heads origin gh-pages })) {
      Write-Host "No gh-pages branch on origin - creating it ..." -ForegroundColor Cyan
      $empty  = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
      $commit = (git commit-tree $empty -m "Initialize gh-pages").Trim()
      git push origin "${commit}:refs/heads/gh-pages"
      if ($LASTEXITCODE -ne 0) { throw "Could not create the gh-pages branch on origin." }
    }

    # GitHub auto-enables Pages on `main` when a repo is named <org>.github.io, which then
    # fails to build. Point it at gh-pages/root if it is not there already.
    $slug = "$($Org)/$($Repo)"
    $branch = Get-NativeOutput { gh api "repos/$slug/pages" --jq '.source.branch' }
    if ($branch -ne "gh-pages") {
      Write-Host "Pointing GitHub Pages at gh-pages / ..." -ForegroundColor Cyan
      $body = '{"source":{"branch":"gh-pages","path":"/"}}'
      # PUT updates an existing Pages site; POST creates one that does not exist yet.
      if (-not (Test-NativeOk { $body | gh api -X PUT "repos/$slug/pages" --input - })) {
        Invoke-NativeQuiet { $body | gh api -X POST "repos/$slug/pages" --input - }
      }
    }
  } finally { Pop-Location }
}

Write-Host "Rendering $site ..." -ForegroundColor Cyan
Push-Location $site
try {
  if ($DryRun) {
    quarto render
    if ($LASTEXITCODE -ne 0) { throw "quarto render failed (exit $LASTEXITCODE)." }
    Write-Host "[DryRun] Rendered only. Would publish _site to the gh-pages branch -> $SiteUrl" -ForegroundColor Yellow
  } else {
    # Renders, then force-pushes _site to gh-pages of this repo's origin.
    quarto publish gh-pages --no-prompt --no-browser
    # A native command's failure does NOT stop PowerShell, not even under
    # $ErrorActionPreference='Stop' - without this check the script cheerfully reports
    # success over a failed publish.
    if ($LASTEXITCODE -ne 0) { throw "quarto publish failed (exit $LASTEXITCODE) - nothing was published." }
    Write-Host "Published. Live (after Pages rebuilds, ~1 min): $SiteUrl" -ForegroundColor Green
  }
} finally { Pop-Location }
