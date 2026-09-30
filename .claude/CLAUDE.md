# CLAUDE.md

Last modified: 2026-09-30

This is the entry point. It holds only what every task needs. The detail lives in the
context files indexed below, and you should open those only when a task needs them.

## Project

**QMIR 2026-fall**: Quantitative Methods in International Relations, Bayesian, taught in
R/Quarto by Tristan Muno, University of Mannheim. 13 weekly Wednesday sessions of 90 minutes,
9 Sep to 9 Dec 2026, then a take-home exam. Term constants (org, dates, thresholds, the week
plan) live in `course.yml` and nowhere else.

- **Live site:** <https://qmir-2026-fall.github.io/>, published from `website/`.
- **This repo is PUBLIC** (FOSS course materials): `qmir-2026-fall/qmir-2026-fall.github.io`.
- **`solutions/`** is a **private submodule** holding every sample solution and the whole exam.

## Status (as of 2026-09-30)

- Weeks 1 to 4 are live (`website/slides/week01.qmd` to `week04.qmd`).
- Homework 02 to 04 are released (`homework/`, org repos `hw-02` to `hw-04`). Their sample
  solutions are in `solutions/`. The hw-02 and hw-03 solution PDFs are published.
- Weeks 5 to 13 and the later homeworks are **staged**: spring material ported verbatim to
  `website/slides/_weekNN.qmd` and `homework/_import/hw-NN/`, not yet converted to the style
  guide. How a staged week goes live is in `workflow.md`.

## Golden rules

- The **website is the single source of truth**. If it is not linked from the site, it does
  not exist.
- **Never commit solution or exam content into this repository.** Its history is
  world-readable forever. Everything students must not see early lives in `solutions/`. Two
  guards back this up and both must stay (see `workflow.md`).
- Everything is **Quarto and R**. One naming convention. No hand-typed rosters, schedules or
  homework status.
- **Methods voice.** The course is Bayesian by design. Do not add frequentist alternatives,
  p-values or null hypothesis tests unless explicitly asked. Contrast, never substitute. Priors
  are philosophical commitments and are defended on principled grounds (`course-design.md`).

## Rules that break something silently

Repeated here so they are always in context. The full rules, with their checker codes, are in
the style files.

- **Prose:** no em dashes, no en dashes, no semicolons (`E001`, `E002`). Use a comma, a colon,
  parentheses, or `--`. Code, YAML, SCSS and URLs are exempt. (`writing.md`)
- **One sentence per line** in every `.qmd` and every student-facing `README.md`: never
  hard-wrap a sentence, never put two on one line (`E003`, `E004`). The manuals in `.claude/`
  are the exception and stay hard-wrapped at 95 columns. (`writing.md`)
- **Cross-references:** every figure, table, equation and `##`/`###` heading is labelled and
  referenced by label, id first, then classes. (`writing.md`)
- **Callouts:** `note`, `warning`, `important`, `tip`. No `caution`. (`writing.md`)
- **R:** `here()` for every path, `|>` never `%>%`, `theme_pubr()` and `colour =`,
  `case_match()`, `set.seed()`, explicit `prior =` on every `brms` call. (`r-code.md`)
- **Slides:** 1050 x 700 canvas. Ladder `{.smaller}`, then `.small`, then `.xsmall`, then split.
  Inline `font-size` is an error. (`slides.md`)
- **Parsed contracts:** a deck title reads `Week NN: <topic>`, filenames are zero-padded, the
  8-step table is included and never pasted. (`slides.md`, `workflow.md`)

## Working rules

- **Run the style gate before committing:** `./automation/check-authoring.ps1`, and
  `-Week NN -Fit` before publishing a deck. `publish-site.ps1` refuses to publish on failure.
- **Staged material is out of scope** until it is converted. Do not edit `_weekNN.qmd` or
  `homework/_import/` except as part of converting that week.
- **The feedback-policy banner** is reproduced verbatim wherever it appears. Its text is in
  `workflow.md`.
- **Submodule order:** commit and push inside `solutions/` first, then commit the bumped pointer
  in this repo. Explain git operations on the submodule before running them.
- **`.claude/context/` is Tristan's own folder** (git-ignored, because this repo is public). It
  holds his notes and to-dos (`notes.md`). Read a file there only when he points to it. Do not
  edit it.

## Stack and commands

- **Quarto**, **R** (plus TinyTeX for PDF), `brms`, `git`, `gh` (authenticated), and the
  `claude` CLI for the opt-in feedback job. The slide-fit check also wants the R package
  `chromote` and Chrome or Edge, and skips cleanly without them.
- All scripts are PowerShell under `automation/`, and each accepts `-DryRun`.

```powershell
./automation/check-authoring.ps1                 # style gate, whole repo
./automation/check-authoring.ps1 -Week 04 -Fit   # one deck, plus slide-fit measurement
./automation/publish-site.ps1                    # gate, render, publish to gh-pages
./automation/release-homework.ps1 -Week 04       # create/refresh the hw-04 template repo
./automation/release-solution.ps1 -Week 04       # after the due date
./automation/ai-feedback/run-feedback.ps1 -Week 04
./automation/tracking.ps1                        # refresh homework status
```

## Context index

| File | Read when… | Last modified |
|------|-----------|---------------|
| `.claude/workflow.md` | adding or converting a week, releasing homework or solutions, publishing, touching the repo layout, `course.yml`, the submodule or the leak guards (topology, term pipeline, feedback banner, naming, staging, automation contracts) | 2026-09-30 |
| `.claude/course-design.md` | planning what a session or homework teaches, the 8-step workflow, the exam, or methods voice (lessons from qmir-2026, scaffolding backward from the exam, deliberate non-goals) | 2026-09-30 |
| `.claude/writing.md` | authoring or editing any `.qmd`, a student-facing `README.md`, a glossary entry, or any math (prose rules, one sentence per line, cross-references, callouts, notation) | 2026-09-30 |
| `.claude/r-code.md` | writing or editing R code in any `.qmd` or script (paths, tidyverse, setup chunk, figures, tables, `brms`) | 2026-09-30 |
| `.claude/slides.md` | anything under `website/slides/`, or acting on a `check-authoring.ps1` finding (canvas, size ladder, columns, deck grammar and YAML, the two check stages) | 2026-09-30 |
| `.claude/github.md` | the org, template repos, the student link, org permissions, rosters, attendance or progress tracking | 2026-09-30 |
| `.claude/feedback.md` | the opt-in AI feedback job or exam grading (trigger, inputs, output, safety) | 2026-09-30 |

## Maintaining this system

- Every context file starts with `last_modified: YYYY-MM-DD` frontmatter. On any content edit,
  update it and the index row above.
- Each fact lives in one file. CLAUDE.md points to it and doesn't repeat it, apart from the
  silent-breakage digest above, which is deliberately duplicated so it is always in context.
- Other repo files cite a context file by name (`.claude/slides.md`), never by section number,
  so a reorganisation inside a file breaks no pointer.
- Split a file when it passes ~300 lines, or when a topic becomes its own work stream.
- Claude proposes new files or splits, and Tristan approves them. New files go directly in
  `.claude/` and are added to the index above. The manuals are hard-wrapped at 95 columns and
  are linted for dashes and semicolons like everything else.
