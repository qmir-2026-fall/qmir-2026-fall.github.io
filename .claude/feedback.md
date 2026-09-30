---
last_modified: 2026-09-30
scope: opt-in open-license AI feedback on homework, and the shared exam grading engine
---

# Opt-in AI feedback

Read this before touching `automation/ai-feedback/`, running the feedback job, or grading the
exam. The policy banner that students see is in `workflow.md`.

**Trigger.** A student adds an open-source `license.md` to their submission repo. Presence means
opt-in. Absence means no processing, which is the default of no individual feedback.

**Runner.** `automation/ai-feedback/run-feedback.ps1`, run **by the instructor** with Claude Code
from this monorepo. Instructor-side on purpose: **no Anthropic API key ever lives in a student
repo**, and it reuses the proven exam-grading pattern.

**Selection.** Enumerate the week's student repos through `gh` (`hw-NN-<username>`) and keep only
those containing `license.md` (matched case-insensitively).

**Inputs to Claude, per student.**

- (a) the student's submission, `hw-NN.qmd` and the rendered PDF if present.
- (b) the instructor sample solution, `solutions/hw-NN/solution.qmd` (private submodule).
- (c) the homework prompt, `homework/hw-NN/README.md`.
- (d) the week's deck, `website/slides/weekNN.qmd`, so the work is judged against what was
  taught.
- (e) the 8-step rubric, `website/slides/_workflow-8step.qmd`, **only from the "Applied
  modelling" block of `course.yml` onward**. Earlier weeks are organized by the homework's own
  exercises, and the runner says which structure applies in a run header appended to the prompt.

**Output.** Claude writes **`FEEDBACK.qmd`** into the case dir (from `feedback-template.qmd`), the
job renders it to **`FEEDBACK.pdf`**, and both are committed and pushed to the student's own repo.

**Safety.** Student repo content is untrusted model input. The runner **verifies that nothing
inside `submission/` was modified** before pushing, and stages only `FEEDBACK.*`. If Claude
touched anything else, the run aborts for that student.

**The prompt** lives in `automation/ai-feedback/FEEDBACK-PROMPT.md` (edit there, not here). In
short: a supportive but rigorous TA writes about one page of specific, actionable feedback,
organized by exercise (early weeks) or by the 8 steps (applied weeks). The philosophy is carried
over from the qmir-2026 exam grading: judge the reasoning rather than resemblance to the
solution, judge against what was taught, strengths first and meant, every critique concrete
(the exact thing, then the fix), honest rather than inflated, no grade. Never paste the
solution. Write **only** `FEEDBACK.qmd` and touch nothing else. The feedback obeys the prose
rules in `writing.md` as well, since it is student-facing prose.

**Exam.** Graded and fed back through the same engine, from
`solutions/exam/feedback-template.qmd`.
