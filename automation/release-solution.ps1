<#
.SYNOPSIS
  After the due date, render a homework's sample solution to PDF for publishing.
.DESCRIPTION
  Renders homework/hw-NN/solution.qmd to PDF and copies it to website/resources so the
  schedule can link it. Run ONLY after the due date. Refuses to run early unless -Force.
.EXAMPLE
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
$dir  = Join-Path $root "homework\$slug"
$sol  = Join-Path $dir "solution.qmd"
$meta = Join-Path $dir "meta.yml"
if (-not (Test-Path $sol)) { throw "No solution at $sol" }

# --- due-date guard (parse `due:` from meta.yml) ---
if ((Test-Path $meta) -and (-not $Force)) {
  $due = (Select-String -Path $meta -Pattern '^\s*due:\s*(\S+)').Matches.Groups[1].Value
  if ($due -and ([datetime]$due) -gt (Get-Date)) {
    throw "Due date ($due) is in the future. Use -Force to publish the solution early."
  }
}

if ($DryRun) { Write-Host "[DryRun] Would render $sol -> PDF and copy to website/resources." -ForegroundColor Yellow; return }

$out = Join-Path $root "website\resources\$slug-solution.pdf"
quarto render $sol --to pdf
Copy-Item (Join-Path $dir "solution.pdf") $out -Force
Write-Host "Published solution PDF: $out (link it from schedule.qmd)." -ForegroundColor Green
