<#
.SYNOPSIS
  After the due date, render a homework's sample solution to PDF and publish it on the site.
.DESCRIPTION
  Renders solutions/hw-NN/solution.qmd (PRIVATE submodule) to PDF and copies the PDF into
  website/resources/, from where schedule.qmd links it automatically once the due date has
  passed. Only the rendered PDF becomes public - the solution source stays in the private
  submodule. Refuses to run before the due date unless -Force.
.EXAMPLE
  ./automation/release-solution.ps1 -Week 05 -DryRun
  ./automation/release-solution.ps1 -Week 05
#>
param(
  [Parameter(Mandatory)][string]$Week,
  [switch]$Force,
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$slug = "hw-$Week"
$sol  = Join-Path $root "solutions\$slug\solution.qmd"
$meta = Join-Path $root "homework\$slug\meta.yml"     # meta stays with the public homework
if (-not (Test-Path $sol)) {
  throw "No solution at $sol. Is the private solutions/ submodule checked out? (git submodule update --init)"
}

# --- due-date guard (parse `due:` from meta.yml) ---
if ((Test-Path $meta) -and (-not $Force)) {
  $m = Select-String -Path $meta -Pattern '^\s*due:\s*(\S+)' | Select-Object -First 1
  if (-not $m) {
    Write-Host "No 'due:' in $meta - cannot verify the due date has passed." -ForegroundColor Yellow
    throw "Add a due: date to meta.yml, or pass -Force."
  }
  $due = [datetime]$m.Matches.Groups[1].Value
  if ($due -gt (Get-Date)) {
    throw "Due date ($($due.ToString('yyyy-MM-dd'))) is in the future. Use -Force to publish early."
  }
}

$out = Join-Path $root "website\resources\$slug-solution.pdf"
if ($DryRun) {
  Write-Host "[DryRun] Would render $sol -> $out" -ForegroundColor Yellow
  return
}

# Render into scratch so no build artifacts are left beside the solution source.
$work = Join-Path $env:TEMP "qmir-solution\$slug"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work -Force | Out-Null
Copy-Item (Join-Path $root "solutions\$slug\*") $work -Recurse -Force

quarto render (Join-Path $work "solution.qmd") --to pdf
New-Item -ItemType Directory -Path (Split-Path $out) -Force | Out-Null
Copy-Item (Join-Path $work "solution.pdf") $out -Force

Write-Host "Published solution PDF: $out" -ForegroundColor Green
Write-Host "schedule.qmd links it automatically once due < today. Run publish-site.ps1 to push." -ForegroundColor Green
