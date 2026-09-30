---
last_modified: 2026-09-30
scope: lessons from qmir-2026, scaffolding from the exam, the 8-step workflow, methods voice, non-goals
---

# Course design

Read this before planning what a session or homework teaches, touching the 8-step workflow or
the exam, or writing methods content. How the week is built and shipped is in `workflow.md`.

## Reflection on qmir-2026: what to keep, what to drop

**Keep (worked well)**

- Quarto for everything (site, slides, homeworks, exam, feedback). One toolchain end to end.
- RevealJS decks with speaker notes.
- A **sample solution authored alongside every homework**.
- The **Claude-Code-driven grading/feedback** pattern (used for the exam last term), reused here
  for the opt-in homework feedback (`feedback.md`).
- The **8-step Bayesian workflow** as the graded through-line.

**Drop (caused friction)**

- **Mon/Thu doubling**. Everything was authored twice. This term there is **one weekly session**:
  one template, one solution, one distribution repo per week.
- **Hand-typed tracker**. The old `participants` repo recorded attendance and homework by pasting
  ID vectors and hand-maintaining an ID-to-username `case_when()`. Replaced by a roster CSV plus
  auto-derived homework status (`github.md`).
- **Student clones and build artifacts committed into working trees.** Grading happens in an
  ignored scratch dir, and build output is git-ignored (`workflow.md`).
- **Inconsistent repo names** (`hw-w3`, `hw-04`, `hw-w05`). One convention now (`workflow.md`).
- **Late, copy-pasted 8-step workflow.** Introduced week 1, sourced from one partial (below).
- **Undocumented authoring style.** The "no em dashes" rule lived only in per-week planning
  notes, so 5 of 13 decks followed it. Slide sizing was never written down at all, and the decks
  ended up with 20 different ad-hoc font sizes. Both are now in the style files (`writing.md`,
  `slides.md`) and checked.

## Scaffold backward from the exam, and introduce the 8 steps early

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
stages it exercises, and `course.yml` records which steps each session foregrounds):

| Phase | Weeks | Steps foregrounded |
|---|---|---|
| Foundations, R and Quarto | early | whole skeleton shown, steps 1 and 2 |
| Logic of Bayesian inference | mid | steps 3 to 5 (priors, likelihood, fitting) |
| Applied analysis | late | steps 6 to 8 (diagnostics, PPC, interpretation, limits) |
| Exam | end | all 8, end to end |

## Methods voice

The course teaches the Bayesian framework as the primary inferential approach, deliberately. Do
not add frequentist alternatives, p-values, or null hypothesis tests to methods content unless
explicitly asked. When a student asks about frequentist methods, explain the contrast rather
than substituting one framework for the other. Tools serve the research question, so keep the
voice balanced and non-dogmatic. Priors are philosophical commitments, not computational
conveniences, and should be defended on principled grounds.

Sessions 8 and 13 carry classical statistics deliberately, as contrast rather than substitution
(see the `weeks:` comments in `course.yml`).

## What this repo deliberately does not do

Recorded so the decisions are not relitigated.

- No frequentist framing in methods content. The course is Bayesian by design (above). Contrast
  the two frameworks where that teaches something. Do not substitute one for the other.
- No `.Rmd`. Quarto `.qmd` everywhere.
- No hand-typed schedule, roster or homework status. All of it is built from `course.yml`,
  `meta.yml` and the GitHub API.
- No per-deck duplication of shared YAML, colours, or the workflow table.
