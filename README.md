# QMIR 2026-fall

Source of the QMIR course (Quantitative Methods in International Relations — Bayesian, in
R/Quarto). **Public**: the site, the slides, the homework starters, and the automation that
runs the term are all here, openly licensed.

- **Live site:** <https://qmir-2026-fall.github.io/>
- Read **`CLAUDE.md`** first — it is the full operating manual (pipeline, feedback policy,
  tracking, distribution, conventions).
- Licences: course content **CC BY-SA 4.0**, code **MIT**. See [`LICENSE`](LICENSE).

## What is *not* here

Sample solutions and the exam live in a **private submodule** at `solutions/`. Nothing in this
repository's history contains them, and a pre-commit hook exists to keep it that way. If you
are a student: the sample solution for each homework is published as a PDF on the schedule
after its due date.

## Setup (instructor, once per clone)

```powershell
git clone https://github.com/qmir-2026-fall/qmir-2026-fall.github.io.git
cd qmir-2026-fall.github.io
git submodule update --init          # private solutions/ (instructor access only)
./automation/hooks/install-hooks.ps1 # leak guard for this public repo
```

Requirements: `quarto`, R (+ TinyTeX for PDF), `git`, `gh` (authenticated), and the `claude`
CLI for the opt-in feedback job.

## Quick start (per week)

```powershell
# new homework
cp -r homework/_template homework/hw-05      # edit hw-05.qmd, README.md, meta.yml, data/
#                                             ... and write solutions/hw-05/solution.qmd
./automation/release-homework.ps1 -Week 05   # publish the hw-05 template repo

# after the due date
./automation/release-solution.ps1 -Week 05   # publish the sample-solution PDF
./automation/ai-feedback/run-feedback.ps1 -Week 05   # opt-in feedback
./automation/tracking.ps1                    # refresh homework status

# site
./automation/publish-site.ps1
```

Every script accepts `-DryRun` and does nothing destructive without an explicit run.
Term-level constants (org, dates, thresholds) live in **`course.yml`** — change them there,
never in the consumers.
