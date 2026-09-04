# homework/

Homework **sources as students see them**, one folder per week. This directory is public.
It is the payload that `automation/release-homework.ps1` pushes into the distribution repo
`hw-NN`.

**Sample solutions are not here.** They live in the private submodule at
`solutions/hw-NN/solution.qmd`.

## Start a new homework

```powershell
cp -r homework/_template homework/hw-05
mkdir solutions/hw-05    # and copy solutions/_template/solution.qmd into it
```

Then edit, in `homework/hw-05/`:

- `hw-05.qmd`, the student-facing starter (rename from `hw-NN.qmd`).
- `README.md`, the prompt plus the standing feedback-policy banner.
- `meta.yml`: slug, week, release and due date, and which 8-step stages this homework exercises.
  The website's schedule reads this file. The accept link appears once `meta.yml` exists, and
  the solution link appears once `due` has passed.
- `data/`, any datasets shipped to students.

And in `solutions/hw-05/`:

- `solution.qmd`, the sample solution. It is published as a PDF after the due date, and it is
  the standard the opt-in AI feedback compares submissions against.

Both files follow `STYLE.md`. The starter is where students first meet the conventions, so it
has to model them: labelled and captioned figures, `here()` for paths, a setup chunk, and the
closing session-info and execution-time chunks. Run `automation/check-authoring.ps1` when done.

## Convention

- Distribution repo name: **`hw-NN`** (zero-padded, no day suffix). Student repos:
  `hw-NN-<username>`, and the tracker finds submissions by that exact name.
- `_template/.github/workflows/hw-check.yml` and `_template/.gitignore` ship with every
  distribution repo. The release script adds them if a week's folder does not already carry them.
- Keep starter files free of solution content. Anything named `solution.*` is excluded from the
  payload and asserted against before publishing.
