# qmir-2026-fall (private authoring monorepo)

Source of the QMIR course, next iteration. **Private** — this repo holds sample solutions.
The public world sees only the rendered website and the solution-stripped distribution repos.

- Read **`CLAUDE.md`** first — it is the full operating manual (pipeline, feedback policy,
  tracking, migration, conventions).
- Author in `website/`, `homework/`, `exam/`. Run the pipeline from `automation/`.

## Quick start (per week)

```powershell
# new homework
cp -r homework/_template homework/hw-05      # edit hw-05.qmd, solution.qmd, meta.yml, data/
./automation/release-homework.ps1 -Week 05   # publish distribution repo (solution stripped)
# after due date
./automation/release-solution.ps1 -Week 05   # publish sample solution PDF
./automation/ai-feedback/run-feedback.ps1 -Week 05   # opt-in feedback
./automation/tracking.ps1                    # refresh progress table

# site
./automation/publish-site.ps1
```

All scripts accept `-DryRun` (or `-WhatIf`) and do nothing destructive without it.
