<#
.SYNOPSIS
  Point this clone's git hooks at automation/hooks (one line, idempotent).
.DESCRIPTION
  This repo is PUBLIC. automation/hooks/pre-commit refuses commits that stage sample
  solutions, the exam, or student data. Hooks are per-clone, so run this once after cloning.
#>
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Push-Location $root
try {
  git config core.hooksPath automation/hooks
  Write-Host "core.hooksPath -> automation/hooks (leak guard active)." -ForegroundColor Green
} finally { Pop-Location }
