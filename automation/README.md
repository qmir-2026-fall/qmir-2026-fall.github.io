# automation/

destructive happens without an explicit run). Run them from the repo root.
destructive happens without an explicit run). Run them from the repo root.

| Script | Does |
|---|---|
| `publish-site.ps1` | Render `website/` and publish it to this repo's own `gh-pages` branch, which GitHub Pages serves at <https://qmir-2026-fall.github.io/>. Refuses to publish from a dirty tree. |
| `release-homework.ps1 -Week NN` | Create/refresh the public distribution repo `hw-NN` from `homework/hw-NN/` and mark it a **template repo**. Prints the "use this template" link. |
| `release-solution.ps1 -Week NN` | After the due date, render `solutions/hw-NN/solution.qmd` (private submodule) to `website/resources/hw-NN-solution.pdf`. The schedule links it automatically once `due` has passed. |
| `tracking.ps1` | Enumerate `hw-NN-<username>` repos on the org via `gh`, derive submission status, write `tracking/hw_status.csv` (git-ignored). |
| `ai-feedback/run-feedback.ps1 -Week NN` | For opted-in student repos (those containing `license.md`), invoke Claude to draft `FEEDBACK.qmd`, render to PDF, and push into the student repo. |
| `check-authoring.ps1` | The style gate. Enforces `STYLE.md` over every `.qmd` and `.md`, and with `-Fit` measures every slide of a deck against the 1050x700 canvas in headless Chrome. `publish-site.ps1` runs the static stage before publishing. |
| `hooks/install-hooks.ps1` | Point this clone's git hooks at `automation/hooks` (the public-repo leak guard). Run once after cloning. |
| `_common.ps1` | Dot-sourced helpers (`Test-NativeOk`, `Invoke-NativeQuiet`, `Get-NativeOutput`, `Get-RscriptPath`). The first three make "does this exist?" probes against `gh` and `git` safe in PS 5.1 (see gotcha 2). The last finds R, which is routinely installed without being on PATH. |

Prereqs: `gh` (authenticated), `quarto`, R and TinyTeX, and for the feedback job the `claude` CLI.
The slide-fit stage of `check-authoring.ps1` also wants the R package `chromote` plus Chrome or
Edge, and skips cleanly without them.
Defaults such as the org name mirror `course.yml`. Override with `-Org` if they ever diverge.

### This repo is public, so there are guards

`hooks/pre-commit` blocks a commit that stages `solution.*`, anything under `exam/`, a filled
roster, `*.local.csv`, or `tracking/hw_status.csv`. `release-homework.ps1` independently
asserts that no `*solution*` file is in the payload before it pushes. Both are deliberate
redundancy: solutions live in the private `solutions/` submodule and must never reach a public
history, which cannot be undone after the fact.

### Windows PowerShell 5.1 gotchas (baked into the scripts)

**1. Filtering `gh … | ConvertFrom-Json` in one pipeline.** Do **not** chain `Where-Object`
directly onto it. In PS 5.1 the filter is silently bypassed and you get *every* repo back.
Capture the parsed JSON in a variable first, then filter, and wrap in `@()`:

```powershell
$parsed = gh repo list $Org --json name,pushedAt | ConvertFrom-Json
$repos  = @($parsed | Where-Object { $_.name -match "^hw-05-(.+)$" })
```

**2. Redirecting a native command's stderr.** Under `$ErrorActionPreference = "Stop"`, a native
command that writes to stderr raises `NativeCommandError`, and **redirecting it does not help**.
`2>$null` and `*>$null` both still abort the script. This bites every "does this repo exist?"
probe, because `gh repo view` on a missing repo is *supposed* to fail. Use the helpers in
`_common.ps1`:

```powershell
. (Join-Path $PSScriptRoot "_common.ps1")

$exists = Test-NativeOk    { gh repo view "$Org/$slug" }              # -> $true / $false
$branch = Get-NativeOutput { gh api "repos/$slug/pages" --jq '.source.branch' }  # -> string / $null
Invoke-NativeQuiet         { git remote remove origin }               # failure is harmless
```

Related: git writes its "LF will be replaced by CRLF" warnings to stderr too, so scripts that run
`git add` in a scratch dir pass `-c core.autocrlf=false` to keep them quiet.

**3. YAML keys that are booleans.** `n:`, `y:`, `on:`, `off:` parse as booleans under YAML 1.1.
R's `yaml` package then names the list element `FALSE`. `course.yml` uses `count:` for this
reason.

**4. Keep `.ps1` files ASCII-only.** Windows PowerShell 5.1 reads scripts in the system ANSI
codepage unless they carry a UTF-8 BOM, so a stray em dash or curly quote inside a
double-quoted string decodes into bytes that can terminate the string early and produce a
baffling "Missing closing brace" parse error far from the real line. Use `-` and `"` in scripts.
put the typography in the Markdown and Quarto files, which are read as UTF-8.
