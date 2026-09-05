# QMIR 2026-fall: course strategy and workflow

Quantitative Methods (Bayesian, taught in R/Quarto). This file is the operating manual for
the term: how the course is authored, distributed, tracked, and fed back. Keep it skimmable.
Prefer conventions and automation over manual steps.

**`STYLE.md` is the companion to this file.** It is the manual for the *files* rather than the
term: prose, cross-references, callouts, R code, and slide geometry. **Read `STYLE.md` before
authoring or editing any `.qmd`.** Everything in it is enforced by
`automation/check-authoring.ps1`, so a violation is a build failure, not a matter of taste.

**Golden rules**

- The **website is the single source of truth**. If it is not linked from the site, it does not
  exist.
- **This repo is PUBLIC** (FOSS course materials). Everything students must not see early, which
  means sample solutions and the exam, lives in the **private `solutions/` submodule**. Never
  commit solution or exam content into this repository: its history is world-readable forever.
- Everything is **Quarto and R**. One naming convention. No hand-typed rosters.

---

## 0. Repo topology (read this before touching anything)

| | |
|---|---|
| **This repo** | `qmir-2026-fall/qmir-2026-fall.github.io`, **public**. Website sources, slides, homework starters, automation, tracking. `main` = sources, `gh-pages` = rendered site. |
| **Live site** | <https://qmir-2026-fall.github.io/>, GitHub Pages serving `gh-pages` at `/`. Published by `automation/publish-site.ps1` (`quarto publish gh-pages` from `website/`). |
| **`solutions/`** | **Private submodule** (`qmir-2026-fall/solutions`): every `hw-NN/solution.qmd` **and the entire exam**. Checked out with `git submodule update --init`. |
| **Distribution** | Public template repos `hw-NN` in the org. Students generate `hw-NN-<username>`. |

Because this repo is public, a leak is permanent. Two guards exist and both must stay:
`automation/hooks/pre-commit` (blocks staging solutions, exam, or student data. Install once
with `automation/hooks/install-hooks.ps1`) and the payload assertion inside
`release-homework.ps1`.

---

## 1. Reflection on qmir-2026: what to keep, what to drop

**Keep (worked well)**

- Quarto for everything (site, slides, homeworks, exam, feedback). One toolchain end to end.
- RevealJS decks with speaker notes.
- A **sample solution authored alongside every homework**.
- The **Claude-Code-driven grading/feedback** pattern (used for the exam last term), reused here
  for the opt-in homework feedback.
- The **8-step Bayesian workflow** as the graded through-line.

**Drop (caused friction)**

- **Mon/Thu doubling**. Everything was authored twice. This term there is **one weekly session**:
  one template, one solution, one distribution repo per week.
- **Hand-typed tracker**. The old `participants` repo recorded attendance and homework by pasting
  ID vectors and hand-maintaining an ID-to-username `case_when()`. Replaced by a roster CSV plus
  auto-derived homework status (§5).
- **Student clones and build artifacts committed into working trees.** Grading happens in an
  ignored scratch dir. `_site/`, `.quarto/`, `*_cache/`, `*_files/`, `*.tex/.log` are
  git-ignored. (`_freeze/` is the deliberate exception, see §7.)
- **Inconsistent repo names** (`hw-w3`, `hw-04`, `hw-w05`). One convention now (§7).
- **Late, copy-pasted 8-step workflow.** Introduced week 1, sourced from one partial (§3).
- **Undocumented authoring style.** The "no em dashes" rule lived only in per-week planning
  notes, so 5 of 13 decks followed it. Slide sizing was never written down at all, and the decks
  ended up with 20 different ad-hoc font sizes. Both are now in `STYLE.md` and checked (§8).

---

## 2. Target term pipeline (the repeatable loop)

**Once, at term start**

1. Fix the **exam** first (`solutions/exam/exam.qmd` plus `solutions/exam/solution.qmd`).
   Everything else is scaffolded backward from it (§3).
2. Stand up the org and the distribution repos (§6).
3. Publish the website skeleton (`automation/publish-site.ps1`).

**Every session**

- Author `website/slides/weekNN.qmd` (copy `_deck-template.qmd`) and `include` the 8-step partial
  where relevant. The deck's YAML `title` **is** the topic shown on the schedule, and its shape
  is a parsed contract (§8).
- Run `automation/check-authoring.ps1 -Week NN -Fit`. Fix what it reports.
- `automation/publish-site.ps1` and the site is live. The schedule links the deck automatically.

**Every homework week**

1. `cp -r homework/_template homework/hw-NN`, write `hw-NN.qmd` (starter) and `README.md`, fill
   `meta.yml` (slug, week, release and due date, which 8-step stages it exercises), drop in data.
   Write the sample solution in `solutions/hw-NN/solution.qmd` (private submodule).
2. `automation/release-homework.ps1 -Week NN` creates or refreshes the **public distribution repo
   `hw-NN`** in the org (starter, data, and the mechanical check workflow) and marks it a
   template.
3. The schedule links the "use this template" flow automatically once `meta.yml` exists.
   Students work in `hw-NN-<username>`.
4. **After the due date:** `automation/release-solution.ps1 -Week NN` renders the sample solution
   to `website/resources/hw-NN-solution.pdf`, and the schedule starts linking it by itself.
5. **Opt-in feedback:** `automation/ai-feedback/run-feedback.ps1 -Week NN` (§4).
6. Tracking updates itself (§5).

**End of term**

- Release the take-home **exam** the same way (`exam` distribution repo, built from
  `solutions/exam/`). Grade and give feedback through the Claude-Code workflow
  (`solutions/exam/feedback-template.qmd`, the same engine as §4).

### Feedback policy: state it everywhere, verbatim

> **A sample solution is published for every homework. Individual feedback is NOT provided by
> default.** The only individual feedback available is the **optional AI feedback** you can opt
> into by adding an open-source `license.md` to your submission repo.

This banner appears in `website/syllabus.qmd`, every homework `README.md`, and the schedule page.
Consistency is the point. No student should be surprised.

---

## 3. Scaffold backward from the exam, and introduce the 8 steps early

The exam is a **complete 8-step Bayesian analysis** of a dataset. Because that target is known on
day one, teach toward it deliberately:

- **Week 1:** show the *whole* 8-step skeleton (from `website/slides/_workflow-8step.qmd`) and
  say plainly: "this is the exam." Every later week deepens one or two steps, and every homework
  runs the steps introduced so far, cumulatively.
- **Single source for the workflow:** `website/slides/_workflow-8step.qmd` is included by every
  deck and by the solution template. Never copy-paste the table again.

**The 8 steps** (canonical order): (1) estimand, (2) data summary, (3) formal model,
(4) prior predictive check, (5) fit (`brms`), (6a) MCMC diagnostics, (6b) posterior predictive
check, (7) interpretation, (8) limitations.

**Suggested introduction map** (adjust to the calendar. `meta.yml` in each homework records which
stages it exercises):

| Phase | Weeks | Steps foregrounded |
|---|---|---|
| Foundations, R and Quarto | early | whole skeleton shown, steps 1 and 2 |
| Logic of Bayesian inference | mid | steps 3 to 5 (priors, likelihood, fitting) |
| Applied analysis | late | steps 6 to 8 (diagnostics, PPC, interpretation, limits) |
| Exam | end | all 8, end to end |

**Methods voice.** The course teaches the Bayesian framework as the primary inferential approach,
deliberately. Do not add frequentist alternatives, p-values, or null hypothesis tests to methods
content unless explicitly asked. When a student asks about frequentist methods, explain the
contrast rather than substituting one framework for the other. Tools serve the research question,
so keep the voice balanced and non-dogmatic. Priors are philosophical commitments, not
computational conveniences, and should be defended on principled grounds.

---

## 4. Opt-in open-license AI feedback: full spec

**Trigger.** A student adds an open-source `license.md` to their submission repo. Presence means
opt-in. Absence means no processing, which is the default of no individual feedback.

**Runner.** `automation/ai-feedback/run-feedback.ps1`, run **by the instructor** with Claude Code
from this monorepo. Instructor-side on purpose: **no Anthropic API key ever lives in a student
repo**, and it reuses the proven exam-grading pattern.

**Selection.** Enumerate the week's student repos through `gh` (`hw-NN-<username>`) and keep only
those containing `license.md` (matched case-insensitively).

**Inputs to Claude, per student.**

- (a) the student's submission, `hw-NN.qmd` and the rendered PDF if present.
- (b) the instructor sample solution, `solutions/hw-NN/solution.qmd` (private submodule).
- (c) the homework prompt, `homework/hw-NN/README.md`.
- (d) the 8-step rubric, `website/slides/_workflow-8step.qmd`.

**Output.** Claude writes **`FEEDBACK.qmd`** into the case dir (from `feedback-template.qmd`), the
job renders it to **`FEEDBACK.pdf`**, and both are committed and pushed to the student's own repo.

**Safety.** Student repo content is untrusted model input. The runner **verifies that nothing
inside `submission/` was modified** before pushing, and stages only `FEEDBACK.*`. If Claude
touched anything else, the run aborts for that student.

**The prompt** lives in `automation/ai-feedback/FEEDBACK-PROMPT.md` (edit there, not here). In
short: a supportive TA reads the submission and the sample solution and writes about one page of
specific, actionable feedback **organized by the 8 steps**. Per relevant step: what went well,
what is missing or wrong, one concrete improvement. Reference the solution as the standard and
never paste it. Write **only** `FEEDBACK.qmd` and touch nothing else. The feedback obeys
`STYLE.md` §1 as well, since it is student-facing prose.

---

## 5. Cheap progress tracking

The old tracker's failure mode: attendance *and* homework status were typed by hand, and the
ID-to-username map was hand-maintained. Fix both.

- **One roster.** `tracking/students.csv` is the single ID-to-username source of truth. Only the
  **header** is committed (this repo is public). The real roster lives in
  `tracking/students.local.csv`, which is git-ignored and preferred automatically when present.
- **Homework status is auto-derived, never typed.** `automation/tracking.ps1` enumerates
  `hw-NN-<username>` repos on the org and writes `tracking/hw_status.csv` (git-ignored, because it
  lists usernames). **The submission test is work *after* the template import**, not "pushed after
  release": every generated repo is pushed after release, so that older heuristic marked everyone
  as submitted. Default check: **commit count greater than 1** (exact, one API call per repo per
  week). `-Fast` uses `pushedAt > createdAt + 2 min` instead, which is free but misses a student
  who pushes within two minutes of generating their repo. That was observed in testing, so it is
  opt-in only. `on_time` compares the last push against `due:`.
- **Attendance** cannot come from GitHub, so keep exactly **one** small hand-kept file,
  `tracking/attendance.csv`, in **long** format (`github_username, week, present`), one row per
  student per session attended. Real data goes in `attendance.local.csv`. This is the *only*
  hand-kept datum.
- **Output.** `tracking/progress.qmd` renders the report, fully data-driven. Thresholds and
  counts come from `course.yml`. It also flags submission repos whose username is not on the
  roster, usually a typo'd repo name. The rendered `progress.html` is git-ignored.

---

## 6. Distribution: plain GitHub template repos

GitHub Classroom is gone (management site down 2026-08-28, metadata deleted 2026-09-04). The
export window has **closed**, and last term's roster survives only as the local
`qmir-2026/exam-registrations/*.xlsx` and the repos in the `qmir-2026` org.

**Decision (2026-09-04): plain GitHub, no classroom service.**

- `release-homework.ps1` creates the public repo `hw-NN`, pushes the starter payload, and marks
  it a **template repo**. The schedule links `.../hw-NN/generate`, students click "use this
  template" and name their repo `hw-NN-<username>`.
- Tracking is `tracking.ps1` plus `progress.qmd` (§5), the primary path rather than a fallback.
- Autograding stays **mechanical only**. `homework/_template/.github/workflows/hw-check.yml`
  ships inside each distribution repo and only checks that the submission renders. Substantive
  assessment is always the sample solution plus the opt-in AI feedback.

**Classroom 50 (Fifty Foundation, GPL-3.0): evaluated and deferred.** It is a thin wrapper over
exactly this (template repos, Actions, `gh`), so adopting it later is cheap: `gh extension
install foundation50/gh-teacher`, put the org on the Team plan (free through GitHub Education),
and re-enable the `-Classroom` branch in `release-homework.ps1`. As of 2026-09-04 it is days old
with almost no adoption, which is not something a live course should depend on. Do not revisit
this unless asked: the decision is recorded here, so the `classroom50/` notes folder is gone.

---

## 7. Repository layout and conventions

**Naming (enforced):** homework distribution repo `hw-NN` (zero-padded, no day suffix), exam repo
`exam`, student repos `hw-NN-<username>` and `exam-<username>`, this repo (public, and the Pages
repo) `qmir-2026-fall.github.io`, the private solutions repo `solutions`.

| Path | Purpose |
|---|---|
| `CLAUDE.md` | This strategy file. |
| `STYLE.md` | **Authoring and coding conventions.** Read before writing any `.qmd`. |
| `course.yml` | **Single source** for term constants: org, site URL, session dates and count, homework count, pass thresholds. Read by `schedule.qmd`, `progress.qmd`, and the scripts. Never hardcode these elsewhere. |
| `website/` | Quarto site sources, the student-facing hub. `schedule.qmd` is the spine, and is **built**, not typed. |
| `website/slides/_metadata.yml` | Shared deck options. A deck's own YAML carries only its `title`. |
| `website/slides/theme.scss` | Deck theme and the `.small` / `.xsmall` size ladder. |
| `website/slides/_workflow-8step.qmd` | The one canonical 8-step workflow partial, included everywhere. |
| `website/slides/_deck-template.qmd` | Copy this to start a week's deck. It is also the worked example of every slide convention. |
| `website/slides/_weekNN.qmd` | **Staging.** The 2026 spring deck for that week, ported verbatim, not yet converted to `STYLE.md`. See below. |
| `website/slides/images/`, `website/slides/data/` | Deck assets, carried over from the spring course. The paths a `_weekNN.qmd` body already expects. |
| `website/_freeze/` | **Committed on purpose.** Frozen renders so the site rebuilds identically anywhere without re-running models. |
| `homework/_template/` | Skeleton copied to start each `hw-NN`, including the `.github/workflows/hw-check.yml` that ships to students. |
| `homework/_import/hw-NN/` | **Staging.** Ported spring homework in `hw-NN` shape. Provenance and known gaps are in `homework/_import/README.md`. |
| `homework/hw-NN/` | Per-week **student-facing** sources (starter, README, meta.yml, data). No solutions here. |
| `solutions/` | **Private submodule**: `hw-NN/solution.qmd` and the whole `exam/`. |
| `automation/` | The scripts that run the pipeline (publish, release, track, feedback, check). |
| `automation/check-authoring.ps1` | The style gate. Enforces `STYLE.md`, including real slide-fit measurement. |
| `automation/hooks/` | The public-repo leak guard. Install once per clone. |
| `tracking/` | `students.csv` and `attendance.csv` (headers only, real data as `*.local.csv`) and the data-driven `progress.qmd`. |

**Solution safety (three layers):** solutions are not in this repo at all (private submodule),
the pre-commit hook refuses to stage them, and `release-homework.ps1` excludes `solution.*` and
asserts the payload is clean before pushing.

**Staging, and how a week goes live.** Every 2026 spring deck and homework is in this repo
already, ported verbatim and parked one rename away from its real home. Staged material is
outside the style gate (`check-authoring.ps1` skips both paths), is not rendered by Quarto, and
is invisible to `schedule.qmd`, so a half-converted week cannot reach a student. Converting a
week means moving it back into scope, which is what makes the conversion checkable:

- **A deck.** Convert the body to `STYLE.md`, then
  `git mv website/slides/_week07.qmd website/slides/week07.qmd` and run
  `./automation/check-authoring.ps1 -Week 07 -Fit`. Nothing else moves: `images/`, `data/`,
  `theme.scss` and the bibliography are already at the paths the body expects, and the YAML is
  already reduced to the `title:` that E040 and E041 require. **The moment the file is named
  `weekNN.qmd`, the schedule links it**, so rename last.
- **A homework.** `cp -r homework/_import/hw-07 homework/hw-07`, convert it, then
  `./automation/release-homework.ps1 -Week 07`. The homework link is gated on `released:` in
  `meta.yml` as well, so the folder can land before the session.

**YAML gotcha:** in `course.yml`, never use `n:`, `y:`, `on:`, or `off:` as keys. YAML 1.1
parses them as booleans and R's `yaml` package turns the key into `FALSE`. Hence `count:`.

---

## 8. Authoring conventions (the short version)

The full guide is `STYLE.md`. These are the rules that break something silently if ignored, so
they are repeated here where they will always be in context.

**Prose.** No em dashes or en dashes, and no semicolons, in prose (`E001`, `E002`). Use a comma,
a colon, parentheses, or `--`. Code, YAML, SCSS and URLs are exempt. One sentence per line.

**Cross-references.** Every figure, table, equation and heading is labelled and referenced by
label: `#| label: fig-x` **with** `#| fig-cap:`, `#| label: tbl-x` with `#| tbl-cap:`,
`$$ ... $$ {#eq-x}`, and `{#sec-x}` on every `##` and `###`. Attribute order is id first, then
classes.

**Callouts.** Exactly four, each with one job. `note` for further context and background,
`warning` for common mistakes and pitfalls, `important` for what students must not get wrong,
`tip` for advice and best practice. No `caution`.

**R code.** `here()` for every path. Tidyverse with `|>`, never `%>%`. `ggplot2` with
`theme_pubr()` and `colour =`. `kable()` for computed tables. `case_match()`, not `recode()`.
`set.seed()` wherever there is randomness. One commented `library()` per line. Explicit `prior =`
on every `brms` call.

**Slides.** The canvas is 1050 x 700. The size ladder is `{.smaller}` on the heading, then
`::: {.small}`, then `::: {.xsmall}`, then **split the slide**. Inline `style="font-size:"` is an
error. Columns use the `:::: {.columns}` idiom only.

**Parsed contracts.** A deck title must read `Week NN: <topic>`, because `schedule.qmd` strips
that prefix to build the Topic column. Filenames are zero-padded. The 8-step table is included,
never pasted.

**The check.** Run `automation/check-authoring.ps1` before committing, and
`-Week NN -Fit` before publishing a deck. `publish-site.ps1` runs the static stage as a gate and
refuses to publish on failure. Stage B (slide fit) renders the deck and measures every slide in
headless Chrome, so overflow is a measurement rather than a guess. It needs the R package
`chromote` and skips cleanly without it.
