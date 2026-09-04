# homework/

Homework **sources**, one folder per week, each **with its sample solution**. This folder is
private and is **never published as-is** — `automation/release-homework.ps1` copies each `hw-NN/`
into a public distribution repo **minus `solution.*`**.

## Start a new homework

```powershell
cp -r homework/_template homework/hw-05
```

Then edit, in `homework/hw-05/`:
- `hw-05.qmd` — the student-facing starter (rename from `hw-NN.qmd`).
- `solution.qmd` — the sample solution (published as a PDF after the due date).
- `README.md` — the prompt + the standing feedback-policy banner.
- `meta.yml` — slug, week, due date, and which 8-step stages this homework exercises.
- `data/` — any datasets shipped to students.

## Convention

- Distribution repo name: **`hw-NN`** (zero-padded, no day suffix). Student repos: `hw-NN-<username>`.
- Keep starter files free of solution content. Anything named `solution.*` is stripped on release.
