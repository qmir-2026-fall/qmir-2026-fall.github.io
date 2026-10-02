---
last_modified: 2026-10-02
scope: repo topology, term pipeline, feedback policy, naming, layout, staging, automation contracts
---

# Workflow

Read this before adding or converting a week, releasing homework or solutions, publishing the
site, or touching the repo layout, `course.yml` or the `solutions/` submodule. How the files
themselves are written is in `writing.md`, `r-code.md` and `slides.md`.

## Repo topology

Read this before touching anything.

| | |
|---|---|
| **This repo** | `qmir-2026-fall/qmir-2026-fall.github.io`, **public**. Website sources, slides, homework starters, automation, tracking. `main` = sources, `gh-pages` = rendered site. |
| **Live site** | <https://qmir-2026-fall.github.io/>, GitHub Pages serving `gh-pages` at `/`. Published by `automation/publish-site.ps1` (`quarto publish gh-pages` from `website/`). |
| **`solutions/`** | **Private submodule** (`qmir-2026-fall/solutions`): every `hw-NN/solution.qmd` **and the entire exam**. Checked out with `git submodule update --init`. |
| **Distribution** | Public template repos `hw-NN` in the org. Students create `hw-NN-<username>` **in the org**, never on their personal account (`github.md`). |

Because this repo is public, a leak is permanent. Two guards exist and both must stay:
`automation/hooks/pre-commit` (blocks staging solutions, exam, or student data. Install once
with `automation/hooks/install-hooks.ps1`) and the payload assertion inside
`release-homework.ps1`.

## Term pipeline (the repeatable loop)

**Once, at term start**

1. Fix the **exam** first (`solutions/exam/exam.qmd` plus `solutions/exam/solution.qmd`).
   Everything else is scaffolded backward from it (`course-design.md`).
2. Stand up the org and the distribution repos (`github.md`).
3. Publish the website skeleton (`automation/publish-site.ps1`).

**Every session**

- Author `website/slides/weekNN.qmd` (copy `_deck-template.qmd`) and `include` the 8-step partial
  where relevant. The deck's YAML `title` **is** the topic shown on the schedule, and its shape
  is a parsed contract (`slides.md`).
- Run `automation/check-authoring.ps1 -Week NN -Fit`. Fix what it reports.
- `automation/publish-site.ps1` and the site is live. The schedule links the deck automatically.

**Every homework week**

1. `cp -r homework/_template homework/hw-NN`, write `hw-NN.qmd` (starter) and `README.md`, fill
   `meta.yml` (slug, week, release and due date, which 8-step stages it exercises), drop in data.
   Write the sample solution in `solutions/hw-NN/solution.qmd` (private submodule).
2. `automation/release-homework.ps1 -Week NN` creates or refreshes the **public distribution repo
   `hw-NN`** in the org (starter, data, and the mechanical check workflow) and marks it a
   template.
3. The schedule links the create-from-template flow automatically once `meta.yml` exists.
   Students work in `hw-NN-<username>` **on the org** (`github.md` has the canonical link shape).
4. **After the due date:** `automation/release-solution.ps1 -Week NN` renders the sample solution
   to `website/resources/hw-NN-solution.pdf`, and the schedule starts linking it by itself.
5. **Opt-in feedback:** `automation/ai-feedback/run-feedback.ps1 -Week NN` (`feedback.md`).
6. Tracking updates itself (`github.md`).

**End of term**

- Release the take-home **exam** the same way (`exam` distribution repo, built from
  `solutions/exam/`). Grade and give feedback through the Claude-Code workflow
  (`solutions/exam/feedback-template.qmd`, the same engine as `feedback.md`).

### Feedback policy: state it everywhere, verbatim

> **A sample solution is published for every homework.
> Individual feedback is NOT provided by default.**
> The only individual feedback available is the **optional AI feedback** you can opt into by adding an open-source `license.md` to your submission repo.

This banner appears in `website/syllabus.qmd`, every homework `README.md`, and the schedule page.
Consistency is the point. No student should be surprised. Do not reword it.

## Naming (enforced)

Homework distribution repo `hw-NN` (zero-padded, no day suffix), exam repo `exam`, student repos
`hw-NN-<username>` and `exam-<username>`, this repo (public, and the Pages repo)
`qmir-2026-fall.github.io`, the private solutions repo `solutions`.

## Repository layout

| Path | Purpose |
|---|---|
| `.claude/` | The manuals: `CLAUDE.md` (entry point and index) and the context files it lists. `.claude/context/` is Tristan's own git-ignored folder. |
| `course.yml` | **Single source** for term constants: org, site URL, session dates and count, homework count, pass thresholds. Read by `schedule.qmd`, `progress.qmd`, and the scripts. Never hardcode these elsewhere. |
| `website/` | Quarto site sources, the student-facing hub. `schedule.qmd` is the spine, and is **built**, not typed. |
| `website/slides/_metadata.yml` | Shared deck options. A deck's own YAML carries only its `title`. |
| `website/slides/theme.scss` | Deck theme and the `.small` / `.xsmall` size ladder. |
| `website/slides/_workflow-8step.qmd` | The one canonical 8-step workflow partial, included everywhere. |
| `website/slides/_deck-template.qmd` | Copy this to start a week's deck. It is also the worked example of every slide convention. |
| `website/slides/_weekNN.qmd` | **Staging.** The 2026 spring deck for that week, ported verbatim, not yet converted to the style guide. See below. |
| `website/slides/images/`, `website/slides/data/` | Deck assets, carried over from the spring course. The paths a `_weekNN.qmd` body already expects. |
| `website/_freeze/` | **Committed on purpose.** Frozen deck renders so the site rebuilds identically anywhere without re-running models. **Decks only**: pages always re-render, because they read files and dates their own source does not contain, and a frozen schedule silently stops updating. |
| `homework/_template/` | Skeleton copied to start each `hw-NN`, including the `.github/workflows/hw-check.yml` that ships to students. |
| `homework/_import/hw-NN/` | **Staging.** Ported spring homework in `hw-NN` shape. Provenance and known gaps are in `homework/_import/README.md`. |
| `homework/hw-NN/` | Per-week **student-facing** sources (starter, README, meta.yml, data). No solutions here. |
| `solutions/` | **Private submodule**: `hw-NN/solution.qmd` and the whole `exam/`. |
| `automation/` | The scripts that run the pipeline (publish, release, track, feedback, check). |
| `automation/check-authoring.ps1` | The style gate. Enforces the style files, including real slide-fit measurement. |
| `automation/hooks/` | The public-repo leak guard. Install once per clone. |
| `tracking/` | `students.csv` and `attendance.csv` (headers only, real data as `*.local.csv`) and the data-driven `progress.qmd`. |

**Solution safety (three layers):** solutions are not in this repo at all (private submodule),
the pre-commit hook refuses to stage them, and `release-homework.ps1` excludes `solution.*` and
asserts the payload is clean before pushing.

**Git-ignored build output.** Grading happens in an ignored scratch dir. `_site/`, `.quarto/`,
`*_cache/`, `*_files/`, `*.tex/.log` are git-ignored. `_freeze/` is the deliberate exception.

## Staging, and how a week goes live

Every 2026 spring deck and homework is in this repo already, ported verbatim and parked one
rename away from its real home. Staged material is outside the style gate
(`check-authoring.ps1` skips both paths), is not rendered by Quarto, and is invisible to
`schedule.qmd`, so a half-converted week cannot reach a student. Converting a week means moving
it back into scope, which is what makes the conversion checkable:

- **A deck.** Convert the body to the style guide, then
  `git mv website/slides/_week07.qmd website/slides/week07.qmd` and run
  `./automation/check-authoring.ps1 -Week 07 -Fit`. Nothing else moves: `images/`, `data/`,
  `theme.scss` and the bibliography are already at the paths the body expects, and the YAML is
  already reduced to the `title:` that E040 and E041 require. **The moment the file is named
  `weekNN.qmd`, the schedule links it**, so rename last.
- **A homework.** `cp -r homework/_import/hw-07 homework/hw-07`, convert it, then
  `./automation/release-homework.ps1 -Week 07`. The homework link is gated on `released:` in
  `meta.yml` as well, so the folder can land before the session.
- **The glossary.** Add every concept from the week's slides and homework that is new to a
  beginner to `website/glossary.yml`, and link related entries with `#gl-` anchors. Concepts
  only, never an entry for a single R function. Software entries follow the official
  documentation and carry a `docs:` link. The rules are in the file's header comment.

## `course.yml` gotcha

Never use `n:`, `y:`, `on:`, or `off:` as keys. YAML 1.1 parses them as booleans and R's `yaml`
package turns the key into `FALSE`. Hence `count:`.

## Contracts that automation depends on

Breaking one of these does not raise an error. It silently produces a wrong website. All of them
are checked.

| Contract | Consumer |
|---|---|
| Deck title is `Week NN: <topic>` | `schedule.qmd` builds the Topic column from it |
| Filenames zero-padded (`week03.qmd`, `hw-03/`) | `schedule.qmd` finds files by `%02d` |
| `homework/hw-NN/meta.yml` present and valid | schedule links, release and tracking scripts |
| 8-step table included, never pasted | one source of truth for the exam rubric |
| Feedback-policy banner reproduced verbatim | syllabus, schedule, every homework README |
| No solution or exam content in this repo | this repo is public and its history is permanent |
