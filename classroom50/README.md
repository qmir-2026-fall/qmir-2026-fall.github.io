# classroom50/

Notes + config mirror for the **`classroom50`** config repo that lives in the course GitHub org.
Classroom 50 (Fifty Foundation, GPL-3.0) is the primary distribution + tracking backbone,
replacing GitHub Classroom (retiring 2026-08-28). See `CLAUDE.md` §6.

## One-time setup

```bash
# teacher machine
gh extension install foundation50/gh-teacher
gh teacher login                          # requests admin:org + workflow scopes

gh teacher classroom add <org> qmir --name "QMIR 2026-fall" --term "Fall 2026"
gh teacher roster add <org> qmir <user> --first-name ... --email ... --section main
# roster writes students.csv on the org -> export to ../tracking/students.csv

# students, one time:
gh extension install foundation50/gh-student
gh student login
```

Requirements: org on the **Team plan** (free via GitHub Education). Autograding (if used) runs in
GitHub Actions and burns org Actions minutes — keep it to **mechanical checks only** (renders? files
present?); substantive assessment is the sample solution + opt-in AI feedback.

## Per assignment

```bash
gh teacher assignment add <org> qmir hw-NN --name "Homework NN" --template <org>/hw-NN
```

(`automation/release-homework.ps1` creates the `hw-NN` template repo first, then registers it here.)

## Fallback

If Classroom 50 proves too young to rely on, the plain-GitHub path is documented in `CLAUDE.md` §6
and implemented by `automation/tracking.ps1` (enumerate `hw-NN-<username>` repos via `gh`). Because
Classroom 50 is a thin layer over template repos + Actions + `gh`, switching directions is cheap.

Keep any real roster/config exports here **git-ignored** if they contain student PII.
