# automation/

The scripts that run the term pipeline. All are PowerShell, all support `-DryRun` (nothing
destructive happens without an explicit run). Run them from the repo root.

| Script | Does |
|---|---|
| `publish-site.ps1` | Render `website/` and publish it to this repo's own `gh-pages` branch, which GitHub Pages serves at <https://qmir-2026-fall.github.io/>. Refuses to publish from a dirty tree. |
| `release-homework.ps1 -Week NN` | Create/refresh the public distribution repo `hw-NN` from `homework/hw-NN/` and mark it a **template repo**. Prints the "use this template" link. |
| `release-solution.ps1 -Week NN` | After the due date, render `solutions/hw-NN/solution.qmd` (private submodule) to `website/resources/hw-NN-solution.pdf`. The schedule links it automatically once `due` has passed. |
| `tracking.ps1` | Enumerate `hw-NN-<username>` repos on the org via `gh`, derive submission status, write `tracking/hw_status.csv` (git-ignored). |
| `ai-feedback/run-feedback.ps1 -Week NN` | For opted-in student repos (those containing `license.md`), invoke Claude to draft `FEEDBACK.qmd`, render to PDF, and push into the student repo. |
| `hooks/install-hooks.ps1` | Point this clone's git hooks at `automation/hooks` (the public-repo leak guard). Run once after cloning. |

Prereqs: `gh` (authenticated), `quarto`, R + TinyTeX, and (for feedback) the `claude` CLI.
Defaults such as the org name mirror `course.yml`; override with `-Org` if they ever diverge.

### This repo is public — the guards

`hooks/pre-commit` blocks a commit that stages `solution.*`, anything under `exam/`, a filled
roster, `*.local.csv`, or `tracking/hw_status.csv`. `release-homework.ps1` independently
asserts that no `*solution*` file is in the payload before it pushes. Both are deliberate
redundancy: solutions live in the private `solutions/` submodule and must never reach a public
history, which cannot be undone after the fact.

### Windows PowerShell 5.1 gotchas (baked into the scripts)

**1. Filtering `gh … | ConvertFrom-Json` in one pipeline.** Do **not** chain `Where-Object`
directly onto it — in PS 5.1 the filter is silently bypassed and you get *every* repo back.
Capture the parsed JSON in a variable first, then filter, and wrap in `@()`:

```powershell
$parsed = gh repo list $Org --json name,pushedAt | ConvertFrom-Json
$repos  = @($parsed | Where-Object { $_.name -match "^hw-05-(.+)$" })
```

**2. Redirecting a native command's stderr.** Under `$ErrorActionPreference = "Stop"`,
`gh repo view x 2>$null` raises `NativeCommandError` even on success. Test the exit code
instead:

```powershell
gh repo view "$Org/$slug" *> $null
$exists = ($LASTEXITCODE -eq 0)
```

**3. YAML keys that are booleans.** `n:`, `y:`, `on:`, `off:` parse as booleans under YAML 1.1;
R's `yaml` package then names the list element `FALSE`. `course.yml` uses `count:` for this
reason.

**4. Keep `.ps1` files ASCII-only.** Windows PowerShell 5.1 reads scripts in the system ANSI
codepage unless they carry a UTF-8 BOM, so a stray em dash or curly quote inside a
double-quoted string decodes into bytes that can terminate the string early and produce a
baffling "Missing closing '}'" parse error far from the real line. Use `-` and `"` in scripts;
put the typography in the Markdown and Quarto files, which are read as UTF-8.
