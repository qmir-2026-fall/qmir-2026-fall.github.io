# QMIR 2026-fall — course strategy & workflow

Quantitative Methods (Bayesian, taught in R/Quarto). This file is the operating manual for
the term: how the course is authored, distributed, tracked, and fed back. Keep it skimmable;
prefer conventions and automation over manual steps.

**Golden rules**
- The **website is the single source of truth**. If it's not linked from the site, it doesn't exist.
- **This repo is private** and holds solutions. The public world only ever sees *rendered* site
  output and *solution-stripped* distribution repos.
- Everything is **Quarto + R**. One naming convention. No hand-typed rosters.

---

## 1. Reflection on qmir-2026 — what to keep, what to drop

**Keep (worked well)**
- Quarto for everything (site, slides, homeworks, exam, feedback) — one toolchain end to end.
- RevealJS decks with speaker notes.
- A **sample solution authored alongside every homework**.
- The **Claude-Code-driven grading/feedback** pattern (used for the exam last term) — reused here
  for the opt-in homework feedback.
- The **8-step Bayesian workflow** as the graded through-line.

**Drop (caused friction)**
- **Mon/Thu doubling** — everything was authored twice. This term there is **one weekly session**:
  one template, one solution, one distribution repo per week.
- **Hand-typed tracker** — the old `participants` repo recorded attendance/HW by pasting ID
  vectors and hand-maintaining an ID→username `case_when()`. Replaced by a roster CSV + auto-derived
  HW status (§5).
- **Student clones + build artifacts committed into working trees.** Grading happens in an ignored
  scratch dir; `_site/`, `_freeze/`, `*_cache/`, `*_files/`, `*.tex/.log` are git-ignored.
- **Inconsistent repo names** (`hw-w3` / `hw-04` / `hw-w05`). One convention now (§7).
- **Late, copy-pasted 8-step workflow.** Introduced week 1, sourced from one partial (§3).

---

## 2. Target term pipeline (the repeatable loop)

**Once, at term start**
1. Fix the **exam** first (`exam/exam.qmd` + `exam/solution.qmd`). Everything else is scaffolded
   backward from it (§3).
2. Stand up distribution + tracking on the org (§6): Classroom 50 config repo + roster.
3. Publish the website skeleton (`automation/publish-site.ps1`).

**Every session**
- Author `website/slides/weekNN.qmd`; `include` the 8-step partial where relevant.
- `automation/publish-site.ps1` → site is live; link the deck from `website/schedule.qmd`.

**Every homework week**
1. `cp homework/_template homework/hw-NN`; write `hw-NN.qmd` (starter), `solution.qmd`, drop data,
   fill `meta.yml` (slug, week, due date, which 8-step stages it exercises).
2. `automation/release-homework.ps1 -Week NN` → creates/refreshes the **public distribution repo
   `hw-NN`** in the org with the starter + data, **solution stripped**. Registers it as a
   Classroom 50 assignment.
3. `website/schedule.qmd` links the accept flow. Students work in `hw-NN-<username>`.
4. **After the due date:** `automation/release-solution.ps1 -Week NN` publishes the sample-solution
   PDF (linked from the schedule).
5. **Opt-in feedback:** `automation/ai-feedback/run-feedback.ps1 -Week NN` (§4) for students who
   opted in.
6. Tracking updates itself (§5).

**End of term**
- Release the take-home **exam** the same way (`exam` distribution repo). Grade + give feedback via
  the Claude-Code workflow (`exam/feedback-template.qmd`, same engine as §4).

### Feedback policy — state it everywhere, verbatim
> **A sample solution is published for every homework. Individual feedback is NOT provided by
> default.** The only individual feedback available is the **optional AI feedback** you can opt
> into by adding an open-source `license.md` to your submission repo.

This banner appears in `website/syllabus.qmd`, every homework `README.md`, and the schedule page.
Consistency is the point — no student should be surprised.

---

## 3. Scaffold backward from the exam; introduce the 8 steps early

The exam is a **complete 8-step Bayesian analysis** of a dataset. Because that target is known on
day one, teach toward it deliberately:

- **Week 1:** show the *whole* 8-step skeleton (from `website/slides/_workflow-8step.qmd`) and say
  plainly: "this is the exam." Every later week deepens one or two steps; every homework runs the
  steps introduced so far, cumulatively.
- **Single source for the workflow:** `website/slides/_workflow-8step.qmd` is `include`d by every
  deck and by `_template/solution.qmd`. Never copy-paste the table again.

**The 8 steps** (canonical order): (1) DAG + estimand, (2) data summary, (3) formal model,
(4) prior predictive check, (5) fit (`brms`), (6a) MCMC diagnostics, (6b) posterior predictive
check, (7) interpretation, (8) limitations.

**Suggested introduction map** (adjust to the calendar; `meta.yml` in each homework records which
stages it exercises):

| Phase | Weeks | Steps foregrounded |
|---|---|---|
| Foundations / R + Quarto | early | whole skeleton shown; steps 1–2 |
| Logic of Bayesian inference | mid | steps 3–5 (priors, likelihood, fitting) |
| Applied analysis | late | steps 6–8 (diagnostics, PPC, interpretation, limits) |
| Exam | end | all 8, end to end |

---

## 4. Opt-in open-license AI feedback — full spec

**Trigger.** A student adds an open-source `license.md` to their submission repo. Presence = opt-in.
Absence = no processing (the default; no individual feedback).

**Runner.** `automation/ai-feedback/run-feedback.ps1`, run **by the instructor** with Claude Code
from this monorepo (optionally a weekly scheduled agent). Instructor-side on purpose: **no Anthropic
API key ever lives in a student repo**, and it reuses the proven exam-grading pattern.

**Selection.** Enumerate the week's student repos via `gh` (roster × `hw-NN-<username>`); keep only
those containing `license.md`.

**Inputs to Claude, per student.**
- (a) the student's submission — `hw-NN.qmd` (+ rendered PDF if present);
- (b) the instructor sample solution — `homework/hw-NN/solution.qmd`;
- (c) the homework prompt — `homework/hw-NN/README.md`;
- (d) the 8-step rubric — `website/slides/_workflow-8step.qmd`.

**Output.** Claude writes **`FEEDBACK.qmd`** into the student's repo (from `feedback-template.qmd`);
the job renders it to **`FEEDBACK.pdf`**; both are committed and pushed to the student's own repo.

**The prompt** lives in `automation/ai-feedback/FEEDBACK-PROMPT.md` (edit there, not here). In short:
a supportive TA reads the submission and the sample solution and writes ~1 page of specific,
actionable feedback **organized by the 8 steps** — per relevant step: what went well, what's missing
or wrong, one concrete improvement. Reference the solution as the standard; never paste it. Write
**only** `FEEDBACK.qmd`; touch nothing else.

---

## 5. Cheap progress tracking

The old tracker's failure mode: attendance *and* homework status were typed by hand, and the
ID↔username map was hand-maintained. Fix both.

- **One roster** — `tracking/students.csv` is the single ID↔username source of truth, seeded from
  the Classroom 50 roster (`gh teacher roster ...`). No more `case_when()`.
- **Homework status is auto-derived, never typed** — `automation/tracking.ps1` (and `progress.qmd`)
  join the roster against the org: a `hw-NN-<username>` repo that exists with a commit **after the
  release date** counts as submitted. Classroom 50's dashboard / `scores.json` is the primary live
  view; this script is the fallback + archival record.
- **Attendance** cannot come from GitHub → keep exactly **one** small `tracking/attendance.csv`
  (rows = sessions, cols = usernames, `0/1`). It joins on the stable roster key. This is the *only*
  hand-kept datum.
- **Output** — `tracking/progress.qmd` renders the report (like last term) but fully data-driven.
  Pass thresholds live as config constants at the top of that file.

---

## 6. Migration off GitHub Classroom → Classroom 50 (+ fallback)

GitHub Classroom is retiring: sign-ups already closed; management/website gone **2026-08-28**;
metadata deleted **2026-09-04** (the repositories themselves survive in the org).

**Primary: Classroom 50 (Fifty Foundation, GPL-3.0, GitHub-native).**
1. **Before 2026-08-28:** run GitHub Classroom's **Export Utility** to archive last term's
   roster/submission metadata locally.
2. **Stand up Classroom 50:** create the org `classroom50` config repo;
   `gh extension install foundation50/gh-teacher` (students use `foundation50/gh-student`);
   `gh teacher classroom add ...`; seed the roster → `tracking/students.csv`. Org must be on the
   Team plan (free via GitHub Education).
3. **Distribution:** each `hw-NN` is a template repo generated by `release-homework.ps1`; students
   accept via Classroom 50 (or a plain "use this template" link). `schedule.qmd` carries the links.
4. **Tracking:** Classroom 50 dashboard (`scores.json` / `scores.csv`) primary; `tracking.ps1`
   fallback.

**Fallback (insurance — Classroom 50 is young): plain GitHub.** Template repo + a small GitHub
Action that checks the submission renders / `renv` restores and emits JSON + a `gh` enumeration
script. This *is* what Classroom 50 wraps, so switching directions is cheap. Autograding stays
**mechanical only** (renders? files present? object exists?); substantive assessment is always the
sample solution + opt-in AI feedback. Notes: `submit50` is CS50-infra-locked (skip); `compare50`
is optional for exam similarity *if* it supports R (unverified — check before relying on it).

---

## 7. Repository layout & conventions

**Naming (enforced):** homework distribution repo `hw-NN` (zero-padded, no day suffix); exam repo
`exam`; student repos `hw-NN-<username>` and `exam-<username>`; the website Pages repo
`qmir-2026-fall.github.io`; the Classroom 50 config repo `classroom50`.

**Local monorepo (`qmir-2026-fall/`, private):**

| Path | Purpose |
|---|---|
| `CLAUDE.md` | This strategy file. |
| `website/` | Quarto site sources — the student-facing hub (`schedule.qmd` is the spine). |
| `website/slides/_workflow-8step.qmd` | The one canonical 8-step workflow partial, `include`d everywhere. |
| `homework/_template/` | Skeleton copied to start each `hw-NN`. |
| `homework/hw-NN/` | Per-week sources **with** `solution.qmd` (private; never published as-is). |
| `exam/` | Exam paper, sample solution, data, and the feedback template. |
| `automation/` | The scripts that run the pipeline (publish, release, track, feedback). |
| `automation/ai-feedback/` | The opt-in feedback job + prompt + feedback template. |
| `tracking/` | `students.csv`, `attendance.csv`, and the data-driven `progress.qmd`. |
| `classroom50/` | Notes + config mirror for the org `classroom50` repo. |
| `.github/workflows/` | Optional CI: site deploy; mechanical homework checks. |

**Solution safety:** `release-homework.ps1` copies `hw-NN/` **minus `solution.*`** into the public
distribution repo, so a solution physically cannot leak. Never publish `homework/` or `exam/`
directly.
