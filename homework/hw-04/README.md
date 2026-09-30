# Homework 04: Wrangling ParlGov election data

<!-- This README ships to students in the distribution repo. Keep the policy banner verbatim. -->

## The task

Open `hw-04.qmd` and work through it with the verbs from week 4.
You read a real political science dataset from an Excel file, make it tidy, transform it, join it to a second table and summarise it by group.
It ends in one pipeline that answers a question with a captioned table: your first **data summary**, step 2 of the workflow.

Use AI tools to explain an error message or a function, not to write your answers.
The point of this homework is the practice.

## The data

`data/parlgov.xlsx` is **ParlGov**, a database of parties, elections and cabinets in 37 democracies.
You work with two of its sheets:

| Sheet | One row is | Columns you will use |
|---|---|---|
| `election` | one party in one election | `country_name`, `election_type`, `election_date`, `vote_share`, `seats`, `seats_total`, `party_id` |
| `party` | one party | `party_id`, `family_name`, `left_right`, `state_market`, `liberty_authority` |

: The two ParlGov sheets this homework reads. {#tbl-parlgov-sheets}

The `variable` sheet documents every column.
The data come from Holger Döring and Philip Manow (2024), *Parliaments and governments database (ParlGov): Information on parties, elections and cabinets in established democracies*, version of 12 August 2024, <https://www.parlgov.org>.

Section 4 also reads the EU membership file from class, straight from GitHub, so you need an internet connection when you render.

## What to submit

- Complete `hw-04.qmd` and render it to PDF.
- Commit as you go, at least three commits with meaningful messages.
- Push to your `hw-04-<username>` repo in the `qmir-2026-fall` organisation.
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
