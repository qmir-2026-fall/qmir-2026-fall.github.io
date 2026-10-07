# Homework 05: Visualising democracy with V-Dem

<!-- This README ships to students in the distribution repo. Keep the policy banner verbatim. -->

## The task

Open `hw-05.qmd` and work through it with `ggplot2`, as in week 5.
You redo the session on new data: instead of life expectancy in gapminder, you explore how democracy has changed since 1950, over time and across continents.
You build figures for one, two and more variables, style them for a reader, fix two deliberately bad figures, and end with one figure that answers a question: your **data summary**, step 2 of the workflow.

Use AI tools to explain an error message or a function, not to write your answers.
The point of this homework is the practice.

## The data

The data come from **V-Dem** (Varieties of Democracy), the largest dataset on democracy, with country-year measures from 1789 to 2025.
They are not in this repository.
You load them from the R package `vdemdata`, which is on GitHub rather than on CRAN, so it needs a different installation.
Run these two lines **once, in the Console**, not in your document:

```r
install.packages("pak")
pak::pak("vdeminstitute/vdemdata")
```

The setup chunk of `hw-05.qmd` then loads the package and builds `vdem_df`, a country-year table from 1950 onwards with the regime type and nine indices.
The table at the top of `hw-05.qmd` describes every column.
The full codebook is at <https://v-dem.net/data/the-v-dem-dataset/>.

The data come from Michael Coppedge, John Gerring, Carl Henrik Knutsen, Staffan I. Lindberg, Jan Teorell and colleagues (2026), *V-Dem Country-Year Dataset v16*, Varieties of Democracy (V-Dem) Project, <https://v-dem.net/data/the-v-dem-dataset/>.

## What to submit

- Complete `hw-05.qmd` and render it to PDF.
- Commit as you go, at least three commits with meaningful messages.
- Push to your `hw-05-<username>` repo in the `qmir-2026-fall` organisation.
  **Rendering and pushing is your submission.**

## Feedback policy

> **A sample solution is published for this homework after the due date.
> Individual feedback is NOT provided by default.**
> The only individual feedback available is **optional AI feedback**: add an open-source `license.md` to this repo to opt in, and an AI will read your submission alongside the sample solution and write a `FEEDBACK.pdf` back into your repo.
> No `license.md`, no processing.

### How to opt in

Create a file named `license.md` in the root of this repository containing the MIT License text below, then commit and push it.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
