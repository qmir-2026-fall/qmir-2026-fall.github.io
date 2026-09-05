# Staged homework, ported from the 2026 spring course

Everything under `_import/` is **raw material, not a released homework**.
The leading underscore is what keeps it here: `schedule.qmd` only looks at `homework/hw-NN/`,
and `check-authoring.ps1` skips this whole directory, so nothing in here can link a repo that
does not exist or fail the style gate while it is still being converted.

## Promoting a week

```powershell
cp -r homework/_import/hw-05 homework/hw-05
# edit hw-05.qmd, README.md and meta.yml until check-authoring.ps1 is happy
./automation/check-authoring.ps1 -Path homework/hw-05
./automation/release-homework.ps1 -Week 05
```

Each folder is already in the shape `release-homework.ps1` expects: `hw-NN.qmd`, `README.md`,
`meta.yml`, `data/`. The `released:` and `due:` dates in `meta.yml` are the week's session date
and the `due_offset_days` from `course.yml`, and `steps:` is seeded from the matching session.
Nothing in here follows `STYLE.md` yet.

## Provenance

The spring numbering does not carry over unchanged.
Spring's first homework, `hw-w3`, was the reproducible-workflow assignment, which is this term's
**session 2** material, so it lands as `hw-02` and every later week lines up with its own session.

| This term | Spring source under `qmir-2026/hw/` | What came across |
|---|---|---|
| `hw-02` | `w03/hw-w3/` | Starter and README. Build artifacts (`.log`, `.tex`, `_files`) dropped. |
| `hw-03` | none | **New week.** Starter is a copy of `homework/_template/hw-NN.qmd`. |
| `hw-04` | `w04/hw-w4/` | Starter, README, `parlgov.xlsx`. |
| `hw-05` | `w05/hw-w05/` | README and both Eurostat workbooks. |
| `hw-06` | `w06/hw-w06/` | Starter. The `hw-w06-thu` copy was identical and was skipped. |
| `hw-07` | `w07/hw-w07/` | Starter. |
| `hw-08` | `w08/` | Starter, `fdi_governance.csv`. |
| `hw-09` | `w09/` | Starter, `income_education.csv`. |
| `hw-10` | `w10/` | Starter, `eu_growth.csv`. The `w10-thu` copy was identical and was skipped. |
| `hw-11` | `w11/` | README, `BrexitVote.csv`, the Hobolt paper, a week-local `references.bib`. |
| `hw-12` | `w12/` | Starter (the course-reflection questionnaire). |

Sample solutions went to the **private `solutions/` submodule** as `solutions/hw-NN/solution.qmd`,
renamed from six different spring names. Spring had solutions for six of the ten weeks:
`hw-04`, `hw-05`, `hw-08`, `hw-09`, `hw-10` and `hw-11`.
`w10/gen-dat.R` went there too rather than into the student payload, because it simulates
`eu_growth.csv` and therefore states the true interaction coefficients.

Not copied, deliberately: the roughly 150 cloned student repos interleaved with these folders,
`w03/w3_feedback/`, `w04/hw-w04-Aufsicht/`, and the per-student feedback files.
This repository is public and its history is permanent.

## Known gaps

- **No starter for `hw-05`.** That is by design in the spring source: the README tells students
  to build `hw05.qmd` from scratch. Decide whether to keep that.
- **No starter for `hw-11`.** The README *is* the assignment there.
- **No README for `hw-03`, `hw-06`, `hw-07`, `hw-08`, `hw-09`, `hw-10`, `hw-12`.** A placeholder
  carrying the verbatim feedback banner is in place, and the brief still has to be written out of
  the starter.
- **No sample solution for `hw-02`, `hw-03`, `hw-06`, `hw-07`, `hw-12`.**
- `hw-07` is due 2026-10-28, which is the cancelled session date. The offset is the usual seven
  days, so move it if that reads badly on the schedule.
- The four READMEs that came from spring (`hw-02`, `hw-04`, `hw-05`, `hw-11`) carry their own
  **AI-tools warning** above the banner. That text predates this term's AI policy, which declares
  AI assistance in commit messages instead. Reconcile the two when you convert the week.
- `hw-04` and `hw-06` still carry a `QMIR 2026` subtitle from the spring term.
