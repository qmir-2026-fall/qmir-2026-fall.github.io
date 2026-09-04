<#
  Shared helpers for the QMIR automation scripts. Dot-source it:

      . (Join-Path $PSScriptRoot "_common.ps1")

  Keep this file ASCII-only (see automation/README.md, gotcha 4).
#>

<#
.SYNOPSIS
  Run a native command that is EXPECTED to fail sometimes, and report success as a boolean.
.DESCRIPTION
  Windows PowerShell 5.1 turns a native command's stderr into a NativeCommandError when
  $ErrorActionPreference is 'Stop' - and redirecting it (2>$null, *>$null) does NOT prevent
  that. So "does this repo exist?" probes blow up the script instead of returning false.
  This helper drops the preference to 'Continue' for the duration of the call, swallows all
  output, and returns whether the exit code was 0.
.EXAMPLE
  if (Test-NativeOk { gh repo view "$Org/$slug" }) { "exists" } else { "does not exist" }
#>
function Test-NativeOk {
  param([Parameter(Mandatory)][scriptblock]$Command)
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    & $Command 2>&1 | Out-Null
    return ($LASTEXITCODE -eq 0)
  } finally {
    $ErrorActionPreference = $prev
  }
}

<#
.SYNOPSIS
  Run a native command, discarding output, without letting stderr abort the script.
.DESCRIPTION
  Same NativeCommandError problem as above, for calls whose failure is harmless and whose
  exit code we do not care about (e.g. `git remote remove origin` when there is no remote).
#>
function Invoke-NativeQuiet {
  param([Parameter(Mandatory)][scriptblock]$Command)
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Command 2>&1 | Out-Null } finally { $ErrorActionPreference = $prev }
}

<#
.SYNOPSIS
  Run a native command and return its stdout, or $null if it failed.
.DESCRIPTION
  For probes that need the OUTPUT rather than just success: same NativeCommandError
  protection, stderr discarded, $null on a non-zero exit so the caller can test it plainly.
.EXAMPLE
  $branch = Get-NativeOutput { gh api "repos/$slug/pages" --jq '.source.branch' }
#>
function Get-NativeOutput {
  param([Parameter(Mandatory)][scriptblock]$Command)
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $out = & $Command 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    return ($out -join "`n").Trim()
  } finally {
    $ErrorActionPreference = $prev
  }
}
