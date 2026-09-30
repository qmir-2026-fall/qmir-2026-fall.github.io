---
last_modified: 2026-09-30
scope: distribution through GitHub template repos, org permissions, rosters, progress tracking
---

# GitHub: distribution and tracking

Read this before touching the org, the template repos, the student link, org permissions,
rosters, attendance, or `tracking/`. The release scripts' place in the week is in `workflow.md`.

## Distribution: plain GitHub template repos

GitHub Classroom is gone (management site down 2026-08-28, metadata deleted 2026-09-04). The
export window has **closed**, and last term's roster survives only as the local
`qmir-2026/exam-registrations/*.xlsx` and the repos in the `qmir-2026` org.

**Decision (2026-09-04): plain GitHub, no classroom service.**

- `release-homework.ps1` creates the public repo `hw-NN`, pushes the starter payload, and marks
  it a **template repo**.

- **The canonical student link.** Never `.../hw-NN/generate`. That page defaults the **Owner**
  dropdown to the student's personal account, and in week 2 of this term every student duly
  landed there, off the org and invisible to `tracking.ps1`, which only enumerates
  `gh repo list $Org`. Use GitHub's query parameters on `/new` instead:

  ```
  https://github.com/new?template_owner=<org>&template_name=hw-NN&owner=<org>&name=hw-NN-USERNAME&visibility=private
  ```

  Built in exactly two places, which must stay in step: `hw_of()` in `website/schedule.qmd` and
  `$templateUrl` in `automation/release-homework.ps1`. `owner` only pre-selects for someone who
  may create repos in the org, so **every student must be an org member** and
  `members_can_create_repositories` must stay `true`. The dropdown is still editable, so the
  schedule and `website/installation.qmd` say the rule in prose as well.

- **Org permissions are part of the design, not a detail.** Student repos live in the org, so the
  org default must be `default_repository_permission: none`. At `read`, which is GitHub's
  default, **every org member can read every org repo including the private `solutions`**, exam
  and all. That was live from 2026-09-04 until it was caught on 2026-09-20 (traffic showed no
  student fetch). `none` costs nothing: a member who creates a repo is its admin, so students keep
  full access to their own submission.
- Tracking is `tracking.ps1` plus `progress.qmd` (below), the primary path rather than a
  fallback.
- Autograding stays **mechanical only**. `homework/_template/.github/workflows/hw-check.yml`
  ships inside each distribution repo and only checks that the submission renders. Substantive
  assessment is always the sample solution plus the opt-in AI feedback (`feedback.md`).

**Classroom 50 (Fifty Foundation, GPL-3.0): evaluated and deferred.** It is a thin wrapper over
exactly this (template repos, Actions, `gh`), so adopting it later is cheap: `gh extension
install foundation50/gh-teacher`, put the org on the Team plan (free through GitHub Education),
and re-enable the `-Classroom` branch in `release-homework.ps1`. As of 2026-09-04 it is days old
with almost no adoption, which is not something a live course should depend on. Do not revisit
this unless asked: the decision is recorded here, so the `classroom50/` notes folder is gone.

## Cheap progress tracking

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
