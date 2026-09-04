# homework/

Homework **sources as students see them**, one folder per week. This directory is public;
it is the payload that `automation/release-homework.ps1` pushes into the distribution repo
`hw-NN`.

**Sample solutions are not here.** They live in the private submodule at
`solutions/hw-NN/solution.qmd`.

## Start a new homework

```powershell
cp -r homework/_template homework/hw-05
mkdir solutions/hw-05    # and copy solutions/_template/solution.qmd into it
```

Then edit, in `homework/hw-05/`:
- `hw-05.qmd` — the student-facing starter (rename from `hw-NN.qmd`).
- `README.md` — the prompt + the standing feedback-policy banner.
- `meta.yml` — slug, week, release + due date, and which 8-step stages this homework exercises.
  The website's schedule reads this file: the accept link appears once `meta.yml` exists, and
  the solution link appears once `due` has passed.
- `data/` — any datasets shipped to students.

…and in `solutions/hw-05/`:
- `solution.qmd` — the sample solution (published as a PDF after the due date, and the
  standard the opt-in AI feedback compares submissions against).

## Convention

- Distribution repo name: **`hw-NN`** (zero-padded, no day suffix). Student repos:
  `hw-NN-<username>` — the tracker finds submissions by that exact name.
- `_template/.github/workflows/hw-check.yml` and `_template/.gitignore` ship with every
  distribution repo; the release script adds them if a week's folder does not already carry them.
- Keep starter files free of solution content. Anything named `solution.*` is excluded from the
  payload and asserted against before publishing.
