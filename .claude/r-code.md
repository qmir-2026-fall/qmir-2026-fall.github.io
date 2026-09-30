---
last_modified: 2026-09-30
scope: R code in every .qmd and script: paths, tidyverse, setup chunk, figures, tables, brms
---

# R code

Read this before writing or editing R code in any `.qmd` or script. Every rule carries the code
`automation/check-authoring.ps1` reports (`E0NN`). Prose rules are in `writing.md`.

**Paths.** `here()` for every path, always (`E013`). It resolves from the project root regardless
of where the `.qmd` sits or which working directory the render runs in, which is what makes it
Quarto-robust.

```r
df <- read_csv(here("homework", "hw-03", "data", "turnout.csv"))
```

::: {.callout-warning}
**A bare `here()` stops at `website/`, not at the repo root.**
`_quarto.yml` is itself a project-root marker, so inside the site project `here()` resolves to
`website/`. Anchor it explicitly with `here::i_am("website/schedule.qmd")` once at the top of any
chunk that needs a repo-root path, and `here()` is correct from then on.
:::

**Tidyverse, native pipe.** `|>`, never `%>%` (`E010`). `snake_case` throughout.

**Chunk options** are `#|` YAML comments only, never the legacy in-header knitr form. Every chunk
carries a `#| label:`.

**Setup chunk.** Opens with `start_time`, then one `library()` call per line, each with a short
trailing comment saying what it is for (`E014`), then the shared palette.

```r
start_time <- Sys.time()

library(tidyverse) # wrangling and visualization
library(here) # project-root-relative paths
library(brms) # Bayesian regression via Stan
library(ggpubr) # theme_pubr()

# Shared palette. Reused verbatim across slides, homework and solutions so a
# chain colour means the same thing in every artefact of the course.
col_1 <- "steelblue"
col_2 <- "#E07B39"
col_3 <- "#7B3F9E"
col_4 <- "goldenrod3"
chain_cols <- c(col_1, col_2, col_3, col_4)
```

Rendered documents (homework, solutions, labs) close with a session-info chunk and an
execution-time chunk, both `eval: true`.

**Figures.** `ggplot2` is the plotting system, `theme_pubr()` the default theme. `colour =`, not
`color =` (`E011`). Always a `title =` in `labs()`. One plot per chunk. `patchwork` for
multi-panel. `dpi: 500`. Colourblind-safe, readable in black and white, high
information-to-ink ratio.

**Tables.** A static overview goes in a raw Markdown table. A computed table goes through
`knitr::kable()`. Model output goes through `modelsummary`. Reach for `gt` only when the
formatting genuinely needs it.

**Other R rules.**

- `case_match()`, not the deprecated `recode()` (`E012`).
- `set.seed()` wherever there is randomness. Student-facing code must be reproducible.
- Comments are one to three words. The explanation belongs in the surrounding prose, which is the
  entire reason for writing in Quarto.
- Minimal new packages. Ask and justify before adding one.
- Run the Air formatter (built into Positron) before committing.

**`brms`.** Always an explicit `prior =`. Priors are philosophical commitments, not computational
conveniences, and the materials should defend them on principled grounds rather than fall back on
brms defaults.
