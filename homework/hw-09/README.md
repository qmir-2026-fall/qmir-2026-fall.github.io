# Homework 09: Multivariate Bayesian linear regression

<!-- This README ships to students in the distribution repo. Keep the policy banner verbatim. -->

## Before you start

The current `rstan` on CRAN cannot compile models, so update it once before you use `brms`.
Run this line in the R Console, then restart R:

```r
install.packages("rstan", repos = c("https://stan-dev.r-universe.dev", "https://cloud.r-project.org"))
```

Week 9 also uses `broom.mixed` for regression tables.
Install it once with `install.packages("broom.mixed")`.

## The task

Open `hw-09.qmd` and work through it, as a follow-up to week 9.
In 1973, the University of California, Berkeley looked as if it admitted women less often than men, until the data were broken down by department.
You analyse a synthetic dataset built on that case: 600 applicants, the selectivity of the programme they applied to, and the review score the admission committee gave them.

Run **all eight steps** of the workflow, and compare two models: a naive one with gender only, and one that also controls for programme selectivity.
Justify the control with a DAG, compare the models with LOO, and report both in one regression table.

## What to submit

- Complete `hw-09.qmd` and render it to PDF.
- Commit as you go, at least three commits with meaningful messages.
- Push to your `hw-09-<username>` repo in the `qmir-2026-fall` organisation.
  **Rendering and pushing is your submission.**
- Due **25 November 2026**, before the session.

## Feedback policy

> **A sample solution is published for this homework after the due date.
> Individual feedback is NOT provided by default.**
> The only individual feedback available is **optional AI feedback**: add an open-source `license.md` to this repo to opt in, and an AI will read your submission alongside the sample solution and write a `FEEDBACK.pdf` back into your repo.
> No `license.md`, no processing.

### How to opt in

1. Create a file named `license.md` in the root of this repository containing the MIT License text below, then commit and push it.
2. When your homework is finished, make your last commit with the message `final submission`, so it is clear which version to give feedback on.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
