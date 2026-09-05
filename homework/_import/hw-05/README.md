# Homework 05
## Wrangling & Visualising Real Data: EU Emissions and Wealth

> **A note on AI tools:** The exercises below ask you to make analytical decisions and interpret results in your own words. AI can write the code — but it cannot do the thinking for you, and the thinking is the point. Use AI the smart way: to understand what a function does, to decode an error message, or to check whether your reasoning is sound. Do not use it to generate answers you then paste in. You will need these skills for the take-home exam.

---

### The Data

This homework uses two Eurostat datasets you already encountered in class:

| File | What it contains | Unit of observation |
|---|---|---|
| `Eurostat_GHGpc.xlsx` | Net greenhouse gas emissions per capita | One row = one country, columns = years |
| `Eurostat_GDPpc.xlsx` | GDP per capita in purchasing power standards | One row = one country, columns = years |

Both files are provided in the `data/` folder of this repository. **Open them in Excel before you start.** Two minutes of inspection will save you an hour of debugging.

---

### Goal

Practice the full import → clean → reshape → join → analyse → visualise pipeline on real Eurostat data, and produce a polished, reproducible Quarto document.

---

### Submission

**Create your own Quarto document from scratch.** Name it `hw05.qmd`. Do not copy a template — set up the YAML header, a setup chunk, and the document structure yourself. This is deliberate practice for the take-home exam, where you will do the same.

To pass this assignment, you must submit **two files**:

- `hw05.qmd` — your source file
- `hw05.pdf` — the rendered output

**The PDF must contain only formatted output — figures, tables, and prose. No code, no warnings, no messages.** Use chunk options and the YAML `execute:` block to control this globally. A PDF with visible code chunks will not be accepted.

If your code throws an error you cannot resolve before the deadline, add `#| error: true` to that chunk so the document still renders. A document that renders with an acknowledged error is better than one that does not render at all.

---

### Exercises at a Glance

| Exercise | Topic |
|---|---|
| 1 | Load packages and import data |
| 2 | Clean and reshape the GHG data |
| 3 | Scale GHG data relative to the EU27 baseline |
| 4 | Clean and reshape the GDP data |
| 5 | Join and finalise the dataset |
| 6 | Add membership era and country code variables |
| 7 | Summary table |
| 8–12 | Plots 1–5 |
| 13 | Reflection |

---

### Exercises

#### Exercise 1 — Load Packages and Import Data

Load the following packages in a setup chunk: `tidyverse`, `readxl`, `janitor`, `countrycode`, `knitr`.

Then load both Excel files into your R environment. Before writing any code, open each file in Excel and note:
- How many rows of metadata appear before the actual data?
- What do the column names look like on import without any arguments?

Use `skip =` and `clean_names()` to load each file correctly. Print the first few rows of each to confirm.

> **Hint:** The correct `skip` values are not the same for both files. Count carefully.

---

#### Exercise 2 — Clean and Reshape the GHG Data

Starting from the raw GHG import:

1. Rename the first column to `country`
2. Remove the `x2019` column (it has no counterpart in the GDP data)
3. Remove stray footer rows (rows where `country` is `NA`, `"Special value"`, or `":"`)
4. Pivot to long format with columns `country`, `year`, and `ghg_pc`
5. Convert `year` to an integer (remember to strip the `x` prefix added by `clean_names()`)

> **Hint:** Use `str_remove(year, "^x")` before `as.integer()`.

---

#### Exercise 3 — Scale GHG Relative to the EU27 Baseline

The GDP data expresses each country's GDP as an index where the EU27 average = 100. The GHG data does not — it uses raw tonnes per capita. To make them comparable, rescale the GHG data using the same approach.

For each year:
1. Find the EU27 average GHG value
2. Compute a scaling factor: `100 / eu27_value`
3. Multiply all country values in that year by the scaling factor

After rescaling, the EU27 row should equal 100 in every year.

> **Hint:** Use `group_by(year)` and `mutate()`. You can extract the EU27 value within a mutate using `ghg_pc[country == "European Union - 27 countries (from 2020)"]`.

---

#### Exercise 4 — Clean and Reshape the GDP Data

Apply the same cleaning steps to the GDP data:

1. Rename the first column to `country`
2. Remove rows where `country` is `NA`
3. Pivot to long format with columns `country`, `year`, and `gdp_pc`
4. Convert `year` to an integer

---

#### Exercise 5 — Join and Finalise the Dataset

1. Join the two long datasets together on `country` and `year` using `left_join()`
2. Check: does the row count after joining equal the row count of the GHG data? If not, investigate.
3. Convert `country` to a factor and recode `"European Union - 27 countries (from 2020)"` to `"EU27"`
4. Remove the separate `ghg` and `gdp` objects from your environment using `rm()`

---

#### Exercise 6 — Add Membership Era and Country Codes

1. Create a new factor variable `membership` that takes the value `"New Member"` if a country acceded to the EU **after 2000**, and `"Old Member"` otherwise. EU27 itself should be coded as `NA`.

> **Hint:** Look up EU accession dates on Wikipedia. You will need to hard-code the new member states using `%in%` inside `mutate()` with `case_when()` or `ifelse()`.

2. Use `countrycode()` from the `countrycode` package to add a variable `iso2` containing the ISO 3166-1 alpha-2 country code for each country name.

> **Hint:** Check `?countrycode`. The relevant arguments are `sourcevar`, `origin = "country.name"`, and `destination = "iso2c"`. The EU27 aggregate will not match — that is expected and will produce a warning you can ignore.

---

#### Exercise 7 — Summary Table

Before moving to the plots, produce a publication-ready summary table using the `tabyl()` → `adorn_totals()` → `kable()` pipeline.

Specifically:

1. Filter out the EU27 row
2. Create a variable `above_eu` that is `TRUE` if a country's GHG index exceeds 100 (i.e. above the EU27 baseline) and `FALSE` otherwise
3. Use `tabyl(year, above_eu)` to cross-tabulate year against above/below baseline
4. Add row and column totals with `adorn_totals(c("row", "col"))`
5. Render with `kable()`, using informative column names and a caption

Write 2–3 sentences interpreting what the table shows.

---

#### Exercise 8 — Plot 1: Distribution of GHG Emissions Across Years

Create a **boxplot** showing the distribution of GHG emissions (the rescaled index) across years. Exclude the EU27 baseline from this plot.

- Year on the x-axis, GHG index on the y-axis
- Each box represents the distribution across EU member states in that year
- Title, axis labels, and a caption with the data source

Write 1–3 sentences describing what the distribution shows and whether it changes over time.

---

#### Exercise 9 — Plot 2: Bar Chart for 2022

Create a **bar chart** of GHG emissions (rescaled index) in 2022 across all EU member states, including the EU27 baseline.

- Countries ordered by GHG value (descending)
- The EU27 bar highlighted in a distinct colour
- Horizontal orientation (countries on the y-axis)
- Title, axis labels, legend, and caption

> **Hint:** Use `fct_reorder()` to order countries and `scale_fill_manual()` to control colours.

Write 1–3 sentences interpreting the chart.

---

#### Exercise 10 — Plot 3: GDP vs. GHG, Coloured by Membership Era

Create a **scatterplot** showing the relationship between GDP per capita and GHG emissions per capita. Exclude the EU27 baseline.

- GDP on the x-axis, GHG on the y-axis
- Points coloured by `membership` (Old Member / New Member)
- A linear regression line included (one line for all points, not per group)
- Title, axis labels, legend, and caption

Write 1–3 sentences interpreting the relationship. Does wealth predict emissions? Does membership era matter?

---

#### Exercise 11 — Plot 4: Labelled Scatterplot with Facets

Repeat Plot 3, but:

- Use `geom_text()` to display ISO2 country codes instead of points, faceted by `membership`
- If labels overlap substantially, use `geom_text_repel()` from the `ggrepel` package instead

> **Hint:** Install `ggrepel` in the console with `install.packages("ggrepel")` — never inside your `.qmd`.

Write 1–3 sentences on what the faceting reveals compared to Plot 3.

---

#### Exercise 12 — Plot 5: Repeat with Free Scales

Repeat Plot 4 exactly, but add `scales = "free"` to `facet_wrap()`.

Write 1–3 sentences describing what changes visually — and answer this directly:

> **Why might free scales be problematic when comparing panels?**

---

#### Exercise 13 — Reflection

Answer the following in 3–5 sentences:

The GHG rescaling in Exercise 3 transformed raw tonnes-per-capita values into an index where EU27 = 100. What assumption does this make about the EU27 average as a reference point? Can you think of a situation where this choice might be misleading?

---

### Tips

- Always call `clean_names()` immediately after `read_excel()` — it prevents backtick problems with numeric column names.
- After every join, check `nrow()` before and after. In a `left_join`, the row count must not change.
- Missing values appear in several places, especially after joining. Use `filter(!is.na(...))` before plotting rather than silently dropping them elsewhere.
- For the rendered PDF to show no code, set `echo: false` globally in your YAML `execute:` block. You can still override it for a single chunk with `#| echo: true` if needed — but for this homework, no chunk should be visible in the final PDF.

## Feedback policy

> **A sample solution is published for this homework after the due date. Individual feedback is
> NOT provided by default.** The only individual feedback available is **optional AI feedback**:
> add an open-source `license.md` to this repo to opt in, and an AI will read your submission
> alongside the sample solution and write a `FEEDBACK.pdf` back into your repo. No `license.md`,
> no processing.
