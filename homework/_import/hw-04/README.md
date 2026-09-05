# Homework 04
## Wrangling Real Data: The ParlGov Dataset

> **A note on AI tools:** The exercises below ask you to make analytical decisions and interpret results in your own words. AI can write the code — but it cannot do the thinking for you, and the thinking is the point. Use AI the smart way: to understand what a function does, to decode an error message, or to check whether your reasoning is sound. Do not use it to generate answers you then paste in. You will need these skills for the take-home exam.

---

### The Data

This homework uses **ParlGov** — a comparative dataset on political parties, elections, and governments in 37 democracies. The Excel file `data/parlgov.xlsx` contains three sheets you will work with:

| Sheet | What it contains | Unit of observation |
|---|---|---|
| `election` | Election results by party | One row = one party in one election |
| `party` | Party-level attributes | One row = one party |
| `cabinet` | Government composition | One row = one party in one cabinet |

The key variables you will use most:

- `country_name` — country name
- `election_type` — `"parliament"` or `"ep"` (European Parliament)
- `election_date` — date of the election
- `vote_share` — percentage of votes won by the party
- `seats` / `seats_total` — seats won and total seats available
- `left_right` — expert-rated ideological position (0 = far left, 10 = far right)
- `party_name_english` — English party name
- `family_name` — party family (e.g., Social democracy, Conservative, Green/Ecologist)

---

### Goal

Practice the full tidyverse wrangling workflow on a real political science dataset:

> Clone → Import → Wrangle → Visualise → Render → Commit → Push

---

### 🔁 Workflow Requirements

As in previous weeks, process and version control matter as much as the output.

**Render frequently.** Do not wait until the end. Render after each exercise and check that the output looks right.

**Commit regularly.** Do not complete everything and commit once. You must make **at least four commits** with informative messages, for example:

1. `add YAML and setup chunk`
2. `complete exercise 1: import and explore`
3. `complete exercises 2 and 3: filter and summarise`
4. `add figure and interpretation`

Four is the minimum — more is fine and encouraged.

---

### Submission

No separate submission is required. Your work is considered submitted when:

- All commits are pushed to GitHub before the deadline
- The repository contains `hw04.qmd` and the rendered `hw04.pdf`

---

### Exercises at a Glance

| Exercise | Topic |
|---|---|
| 1 | Import and explore the data |
| 2 | Filter and select |
| 3 | Mutate and compute new variables |
| 4 | Summarise and group |
| 5 | A full wrangling pipeline |
| 6 | A labelled figure with cross-reference |
| 7 | Reflection |

See `hw04.qmd` for the full task descriptions.

---

### Tips

- Use `?read_excel` if you are unsure how to specify the sheet name argument.
- The `election_date` column is stored as a character string in this file. You can convert it with `as.Date(election_date)` inside `mutate()` if you need date arithmetic — but it is not required.
- Missing values (`NA`) appear in several columns, especially `left_right`. Most summary functions accept `na.rm = TRUE` to ignore them.
- If your code throws an error and you cannot fix it before the deadline, add `#| error: true` to that cell so the document still renders.


## Feedback policy

> **A sample solution is published for this homework after the due date. Individual feedback is
> NOT provided by default.** The only individual feedback available is **optional AI feedback**:
> add an open-source `license.md` to this repo to opt in, and an AI will read your submission
> alongside the sample solution and write a `FEEDBACK.pdf` back into your repo. No `license.md`,
> no processing.
