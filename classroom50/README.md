# classroom50/

Notes on **Classroom 50** (Fifty Foundation, GPL-3.0) — the GitHub-native replacement for the
retired GitHub Classroom.

## Status: evaluated and deferred (2026-09-04)

**Not in use this term.** Distribution is plain GitHub template repos and tracking is
`automation/tracking.ps1` + `tracking/progress.qmd` (see `CLAUDE.md` §6).

Why deferred: as of 2026-09-04 `foundation50/gh-teacher` is days old with almost no adoption,
and it additionally requires the org to be on the **Team plan** (free via GitHub Education).
A live course should not depend on that. What it would add over the current setup is an accept
flow that names the student's repo and adds them as a collaborator automatically, plus a scores
dashboard — convenience, not capability.

## If it is ever adopted

Classroom 50 is a thin wrapper over template repos + Actions + `gh`, which is exactly what the
pipeline already does, so switching is cheap:

```bash
# teacher machine
gh extension install foundation50/gh-teacher
gh teacher login                          # requests admin:org + workflow scopes

gh teacher classroom add <org> qmir --name "QMIR 2026-fall" --term "Fall 2026"
gh teacher roster add <org> qmir <user> --first-name ... --email ... --section main

# students, one time:
gh extension install foundation50/gh-student
gh student login
```

Per assignment (`release-homework.ps1` creates the `hw-NN` template repo first):

```bash
gh teacher assignment add <org> qmir hw-NN --name "Homework NN" --template <org>/hw-NN
```

Then re-enable the commented `gh teacher assignment add` line in the `-Classroom` branch of
`automation/release-homework.ps1`.

Autograding, if it is ever used, runs in GitHub Actions and burns org Actions minutes — keep it
to **mechanical checks only** (renders? files present?); substantive assessment is the sample
solution + opt-in AI feedback.

## Historical note

GitHub Classroom's management site went down **2026-08-28** and its metadata was deleted
**2026-09-04**; the export window has closed. Last term's roster survives only as the local
`qmir-2026/exam-registrations/*.xlsx` files and the repos still sitting in the `qmir-2026` org.

**Never** put a real roster or any student PII in this folder — the repository is public.
