# automation/

The scripts that run the term pipeline. All are PowerShell, all support `-DryRun` (nothing
destructive happens without an explicit run). Run them from the repo root.

| Script | Does |
|---|---|
| `publish-site.ps1` | Render `website/` and publish rendered output to the public `qmir-2026-fall.github.io` Pages repo. |
| `release-homework.ps1 -Week NN` | Create/refresh the public distribution repo `hw-NN` from `homework/hw-NN/`, **stripping `solution.*`**. Optionally register it as a Classroom 50 assignment. |
| `release-solution.ps1 -Week NN` | After the due date, render `homework/hw-NN/solution.qmd` and publish the PDF for linking on the schedule. |
| `tracking.ps1` | Enumerate `hw-NN-<username>` repos on the org via `gh`, derive submission status, write `tracking/hw_status.csv`. Fallback/archival companion to the Classroom 50 dashboard. |
| `ai-feedback/run-feedback.ps1 -Week NN` | For opted-in student repos (those containing `license.md`), invoke Claude to draft `FEEDBACK.qmd`, render to PDF, and push into the student repo. |

Prereqs: `gh` (authenticated), `quarto`, R + TinyTeX, and (for feedback) the `claude` CLI.
These are **working drafts** — read the header of each before first use and set `-Org`.

### Windows PowerShell 5.1 gotcha (baked into the scripts)

Do **not** chain `Where-Object` directly onto `gh … --json … | ConvertFrom-Json` in one
pipeline — in PS 5.1 the filter is silently bypassed and you get *every* repo back. Always
capture the parsed JSON in a variable first, then filter, and wrap in `@()`:

```powershell
$parsed = gh repo list $Org --json name,pushedAt | ConvertFrom-Json
$repos  = @($parsed | Where-Object { $_.name -match "^hw-05-(.+)$" })
```
