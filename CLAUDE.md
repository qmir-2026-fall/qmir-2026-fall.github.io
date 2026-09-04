# QMIR 2026-fall — course strategy & workflow

Quantitative Methods (Bayesian, taught in R/Quarto). This file is the operating manual for
the term: how the course is authored, distributed, tracked, and fed back. Keep it skimmable;
prefer conventions and automation over manual steps.

**Golden rules**
- The **website is the single source of truth**. If it's not linked from the site, it doesn't exist.
- **This repo is PUBLIC** (FOSS course materials). Everything students must not see early —
  sample solutions and the exam — lives in the **private `solutions/` submodule**. Never commit
  solution or exam content into this repository: its history is world-readable forever.
- Everything is **Quarto + R**. One naming convention. No hand-typed rosters.

---

## 0. Repo topology (read this before touching anything)

| | |
|---|---|
| **This repo** | `qmir-2026-fall/qmir-2026-fall.github.io` — **public**. Website sources, slides, homework starters, automation, tracking. `main` = sources, `gh-pages` = rendered site. |
| **Live site** | <https://qmir-2026-fall.github.io/> — GitHub Pages serving `gh-pages` at `/`. Published by `automation/publish-site.ps1` (`quarto publish gh-pages` from `website/`). |
| **`solutions/`** | **Private submodule** (`qmir-2026-fall/solutions`): every `hw-NN/solution.qmd` **and the entire exam**. Checked out with `git submodule update --init`. |
| **Distribution** | Public template repos `hw-NN` in the org; students generate `hw-NN-<username>`. |

Because this repo is public, a leak is permanent. Two guards exist and both must stay:
`automation/hooks/pre-commit` (blocks staging solutions / exam / student data — install once
with `automation/hooks/install-hooks.ps1`) and the payload assertion inside
`release-homework.ps1`.

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
  scratch dir; `_site/`, `.quarto/`, `*_cache/`, `*_files/`, `*.tex/.log` are git-ignored.
  (`_freeze/` is the deliberate exception — see §7.)
- **Inconsistent repo names** (`hw-w3` / `hw-04` / `hw-w05`). One convention now (§7).
- **Late, copy-pasted 8-step workflow.** Introduced week 1, sourced from one partial (§3).

---

## 2. Target term pipeline (the repeatable loop)

**Once, at term start**
1. Fix the **exam** first (`solutions/exam/exam.qmd` + `solutions/exam/solution.qmd`). Everything
   else is scaffolded backward from it (§3).
2. Stand up the org + distribution repos (§6).
3. Publish the website skeleton (`automation/publish-site.ps1`).

**Every session**
- Author `website/slides/weekNN.qmd` (copy `_deck-template.qmd`); `include` the 8-step partial
  where relevant. The deck's YAML `title` **is** the topic shown on the schedule.
- `automation/publish-site.ps1` → site is live. The schedule links the deck automatically.

**Every homework week**
1. `cp -r homework/_template homework/hw-NN`; write `hw-NN.qmd` (starter), `README.md`, fill
   `meta.yml` (slug, week, release + due date, which 8-step stages it exercises), drop data.
   Write the sample solution in `solutions/hw-NN/solution.qmd` (private submodule).
2. `automation/release-homework.ps1 -Week NN` → creates/refreshes the **public distribution repo
   `hw-NN`** in the org (starter + data + the mechanical check workflow) and marks it a template.
3. The schedule links the "use this template" flow automatically once `meta.yml` exists.
   Students work in `hw-NN-<username>`.
4. **After the due date:** `automation/release-solution.ps1 -Week NN` renders the sample solution
   to `website/resources/hw-NN-solution.pdf`; the schedule starts linking it by itself.
5. **Opt-in feedback:** `automation/ai-feedback/run-feedback.ps1 -Week NN` (§4).
6. Tracking updates itself (§5).

**End of term**
- Release the take-home **exam** the same way (`exam` distribution repo, built from
  `solutions/exam/`). Grade + give feedback via the Claude-Code workflow
  (`solutions/exam/feedback-template.qmd`, same engine as §4).

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
  deck and by the solution template. Never copy-paste the table again.

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
from this monorepo. Instructor-side on purpose: **no Anthropic API key ever lives in a student
repo**, and it reuses the proven exam-grading pattern.

**Selection.** Enumerate the week's student repos via `gh` (`hw-NN-<username>`); keep only those
containing `license.md` (matched case-insensitively).

**Inputs to Claude, per student.**
- (a) the student's submission — `hw-NN.qmd` (+ rendered PDF if present);
- (b) the instructor sample solution — `solutions/hw-NN/solution.qmd` (private submodule);
- (c) the homework prompt — `homework/hw-NN/README.md`;
- (d) the 8-step rubric — `website/slides/_workflow-8step.qmd`.

**Output.** Claude writes **`FEEDBACK.qmd`** into the case dir (from `feedback-template.qmd`); the
job renders it to **`FEEDBACK.pdf`**; both are committed and pushed to the student's own repo.

**Safety.** Student repo content is untrusted model input. The runner **verifies that nothing
inside `submission/` was modified** before pushing, and stages only `FEEDBACK.*`. If Claude
touched anything else, the run aborts for that student.

**The prompt** lives in `automation/ai-feedback/FEEDBACK-PROMPT.md` (edit there, not here). In short:
a supportive TA reads the submission and the sample solution and writes ~1 page of specific,
actionable feedback **organized by the 8 steps** — per relevant step: what went well, what's missing
or wrong, one concrete improvement. Reference the solution as the standard; never paste it. Write
**only** `FEEDBACK.qmd`; touch nothing else.

---

## 5. Cheap progress tracking

The old tracker's failure mode: attendance *and* homework status were typed by hand, and the
ID↔username map was hand-maintained. Fix both.

- **One roster** — `tracking/students.csv` is the single ID↔username source of truth. Only the
  **header** is committed (this repo is public); the real roster lives in
  `tracking/students.local.csv`, which is git-ignored and preferred automatically when present.
- **Homework status is auto-derived, never typed** — `automation/tracking.ps1` enumerates
  `hw-NN-<username>` repos on the org and writes `tracking/hw_status.csv` (git-ignored: it lists
  usernames). **The submission test is work *after* the template import**, not "pushed after
  release" — every generated repo is pushed after release, so that older heuristic marked
  everyone as submitted. Default check: **commit count > 1** (exact; one API call per repo per
  week). `-Fast` uses `pushedAt > createdAt + 2 min` instead — free, but it misses a student who
  pushes within two minutes of generating their repo, which was observed in testing, so it is
  opt-in only. `on_time` compares the last push against `due:`.
- **Attendance** cannot come from GitHub → keep exactly **one** small hand-kept file,
  `tracking/attendance.csv`, in **long** format (`github_username, week, present`), one row per
  student per session attended. Real data goes in `attendance.local.csv`. This is the *only*
  hand-kept datum.
- **Output** — `tracking/progress.qmd` renders the report, fully data-driven. Thresholds and
  counts come from `course.yml`; it also flags submission repos whose username is not on the
  roster (usually a typo'd repo name). The rendered `progress.html` is git-ignored.

---

## 6. Distribution: plain GitHub template repos

GitHub Classroom is gone (management site down 2026-08-28; metadata deleted 2026-09-04 — the
export window has **closed**; last term's roster survives only as the local
`qmir-2026/exam-registrations/*.xlsx` and the repos in the `qmir-2026` org).

**Decision (2026-09-04): plain GitHub, no classroom service.**
- `release-homework.ps1` creates the public repo `hw-NN`, pushes the starter payload, and marks
  it a **template repo**. The schedule links `.../hw-NN/generate`; students click "use this
  template" and name their repo `hw-NN-<username>`.
- Tracking is `tracking.ps1` + `progress.qmd` (§5) — the primary path, not a fallback.
- Autograding stays **mechanical only** (`homework/_template/.github/workflows/hw-check.yml`
  ships inside each distribution repo and only checks that the submission renders). Substantive
  assessment is always the sample solution + opt-in AI feedback.

**Classroom 50 (Fifty Foundation, GPL-3.0) — evaluated and deferred.** It is a thin wrapper over
exactly this (template repos + Actions + `gh`), so adopting it later is cheap: `gh extension
install foundation50/gh-teacher`, put the org on the Team plan (free via GitHub Education), and
re-enable the `-Classroom` branch in `release-homework.ps1`. As of 2026-09-04 it is days old with
almost no adoption — not something a live course should depend on. Notes in `classroom50/`.

---

## 7. Repository layout & conventions

**Naming (enforced):** homework distribution repo `hw-NN` (zero-padded, no day suffix); exam repo
`exam`; student repos `hw-NN-<username>` and `exam-<username>`; this repo (public, and the Pages
repo) `qmir-2026-fall.github.io`; the private solutions repo `solutions`.

| Path | Purpose |
|---|---|
| `CLAUDE.md` | This strategy file. |
| `course.yml` | **Single source** for term constants: org, site URL, session dates/count, homework count, pass thresholds. Read by `schedule.qmd`, `progress.qmd`, and the scripts. Never hardcode these elsewhere. |
| `website/` | Quarto site sources — the student-facing hub (`schedule.qmd` is the spine, and is **built**, not typed). |
| `website/slides/_workflow-8step.qmd` | The one canonical 8-step workflow partial, `include`d everywhere. |
| `website/slides/_deck-template.qmd` | Copy this to start a week's deck. |
| `website/_freeze/` | **Committed on purpose** — frozen renders so the site rebuilds identically anywhere without re-running models. |
| `homework/_template/` | Skeleton copied to start each `hw-NN`, including the `.github/workflows/hw-check.yml` that ships to students. |
| `homework/hw-NN/` | Per-week **student-facing** sources (starter, README, meta.yml, data). No solutions here. |
| `solutions/` | **Private submodule**: `hw-NN/solution.qmd` and the whole `exam/`. |
| `automation/` | The scripts that run the pipeline (publish, release, track, feedback). |
| `automation/hooks/` | The public-repo leak guard. Install once per clone. |
| `tracking/` | `students.csv` + `attendance.csv` (headers only; real data as `*.local.csv`) and the data-driven `progress.qmd`. |
| `classroom50/` | Notes on the deferred Classroom 50 option. |

**Solution safety (three layers):** solutions are not in this repo at all (private submodule);
the pre-commit hook refuses to stage them; and `release-homework.ps1` excludes `solution.*` and
asserts the payload is clean before pushing.

**YAML gotcha:** in `course.yml`, never use `n:`, `y:`, `on:`, or `off:` as keys — YAML 1.1
parses them as booleans and R's `yaml` package turns the key into `FALSE`. Hence `count:`.
