# QMIR authoring and coding conventions

The house style for every `.qmd` and `.md` in this repo: slides, website pages, homework
starters, sample solutions, feedback templates and the docs you are reading.

`CLAUDE.md` is the operating manual for the *term* (what gets built, when, by which script).
This file is the manual for the *files* (how they are written). Read it before authoring or
editing any `.qmd`.

Everything here is mechanically checked. Run this before you commit:

```powershell
.\automation\check-authoring.ps1                 # whole repo, static rules
.\automation\check-authoring.ps1 -Week 03 -Fit   # one deck, plus real slide-fit measurement
```

Each rule below carries the code the checker reports (`E0NN`). A rule not worth enforcing does
not belong in this file.

---

## 1. Prose and typography

The site is written in English throughout. The voice is encouraging, clear and non-dogmatic,
pitched at 4th and 5th semester bachelor students with no statistics background beyond
descriptives.

**No em dashes or en dashes in prose** (`E001`). Use a comma, a colon, parentheses, or recast
the sentence. Where a dash genuinely reads better, write a literal double hyphen: Pandoc renders
it as an en dash and it survives every output format.

```markdown
Bad:   The website is the source of truth — if it is not linked, it does not exist.
Good:  The website is the source of truth. If it is not linked, it does not exist.
Good:  QMIR -- Week 3 -- Priors
```

**No semicolons in prose** (`E002`). A semicolon almost always marks two sentences pretending to
be one. Split them.

The rule is about *prose*. Code, YAML mechanics, SCSS, URLs, file paths and the box-drawing
banners in comments are all exempt, and the checker strips fenced code blocks, inline code spans,
raw HTML and math before it looks.

**One sentence per line.** Diffs stay readable, and a reworded sentence shows up as one changed
line instead of a reflowed paragraph.

Other prose rules:

- Sentence case for headings, not Title Case.
- Package and function names in backticks: `brms`, `pp_check()`.
- The feedback-policy banner (CLAUDE.md §2) is reproduced **verbatim** wherever it appears. Do
  not reword it. Consistency is the entire point of it.

---

## 2. Cross-references

Every figure, table, equation and heading is labelled with Quarto crossref syntax and referenced
by label. Never write "the figure below" or "the table above". A label survives reordering and a
positional phrase does not.

**Figures** (`E020`). A chunk needs the label *and* the caption. A `fig-` label without a
`fig-cap` is not a cross-reference, and Quarto warns about it.

````markdown
```{r}
#| label: fig-prior-predictive
#| fig-cap: "Prior predictive draws for turnout. The N(0, 10) prior on the intercept implies
#|   turnout rates far outside the unit interval, which is the signal that it is too wide."
#| fig-height: 4
#| dpi: 500
```
````

**Tables** (`E021`). The same pairing, a `tbl-` label plus a `tbl-cap`. For a static Markdown
table, put the caption on the line below it:

```markdown
: Packages installed in week 1 and what each is for. {#tbl-packages}
```

**Equations** (`E022`). Display math takes a label, with a blank line after the opening `$$` and
before the closing one. Inline math uses single `$`.

```markdown
$$
p(\theta \mid Y) \propto L(Y \mid \theta) \times p(\theta)
$$ {#eq-bayes-core}
```

**Headings** (`E023`). Every `##` and `###` carries a section label so it can be referenced and
linked. Kebab-case, topical, prefixed `sec-`.

```markdown
## Prior predictive checks {#sec-prior-predictive .smaller}
```

Attribute order is fixed: **id first, then classes**. The previous course iteration used both
orderings, which made the decks harder to grep than they needed to be.

**Captions must be self-sufficient.** A reader who sees only the figure and its caption should
understand what is plotted and what the point is. This is graded on the exam, so the course
materials have to model it.

Reference with `@fig-x`, `@tbl-x`, `@eq-x`, `@sec-x`.

---

## 3. Callouts

Exactly four types, each with one job (`E030`). `callout-caution` is not used.

| Type | Use it for |
|---|---|
| `note` | Additional context, background, deeper or further information. The default. |
| `warning` | Frequently occurring errors, mistakes and pitfalls to avoid. |
| `important` | What students MUST keep in mind to avoid getting lost or making a fundamental error. The harder variant of `warning`. |
| `tip` | Useful advice, tips, best practice. |

Shape: a bold lead sentence on its own line, then one to three explanation lines, one sentence
per line.

```markdown
::: {.callout-warning}
**`brm()` silently accepts a flat prior.**
If you omit `prior =`, brms picks improper flat priors for the population-level effects.
The model still samples, so nothing warns you that you skipped step 3.
:::
```

On slides, size a callout with the ladder classes from §5, never with an inline style.

---

## 4. R code

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

---

## 5. Slides

### 5.1 Canvas and the size ladder

The canvas is Quarto's revealjs default, **1050 x 700 px**. A slide must fit that canvas with
every fragment revealed. This is measured, not eyeballed. See §6.

There is one size ladder and nothing outside it.

| Step | Markup | When |
|---|---|---|
| 0 | `## Heading {#sec-x}` | Section dividers, title slides, four to six short bullets. |
| 1 | `## Heading {#sec-x .smaller}` | The default for a content slide. |
| 2 | `::: {.small}` block inside a step-1 slide | One dense block: a table, a derivation, a callout. |
| 3 | `::: {.xsmall}` block | Last resort. One block only. |
| - | **Split the slide** | Anything that still overflows. A fourth font size is not the answer. |

`.small` is 0.80em and `.xsmall` is 0.70em, both defined in `website/slides/theme.scss`.

- Inline `style="font-size: ..."` is an error (`E031`). The previous course iteration used 20
  different ad-hoc values between 0.5em and 0.92em, which is exactly the drift this ladder exists
  to prevent.
- At most one ladder class applies to a block, and `.xsmall` never nests inside `.small`
  (`E033`).
- `.scrollable` is allowed only on a genuine reference or appendix slide, and needs a comment
  saying why.
- Shrinking a table is the one exception: `kable_styling(font_size = 16)` is the sanctioned
  idiom.

### 5.2 Columns

One idiom (`E032`):

```markdown
:::: {.columns}

::: {.column width="55%"}
Left.
:::

::: {.column width="45%"}
Right.
:::

::::
```

Permitted widths: 50/50, 55/45, 45/55, 60/40, 40/60 and 33/33/33. The bare six-colon
`columns` form is not used.

### 5.3 Deck grammar

- `#` is a section-divider slide.
- `##` is a content slide.
- `. . .` on its own line separates revealed beats.
- `::: notes` sits directly under the heading, before the body, and holds terse
  instructor-facing imperatives. Delivery cues and lines to say aloud belong here.

Density guidance, calibrated on the best-behaved deck of the previous course (median 31 source
lines per slide including notes): about three revealed beats of three to six short lines each.
It is guidance, not a lint rule, because §6 measures the truth.

For a sense of scale, measured on this theme with the fit check: nine wrapping bullets come to
1197px at step 0, which overflows the 700px canvas by 71 percent, and drop under the canvas at
step 1. So roughly **six wrapping bullets at step 0, or ten at step 1**, before you are over.
Figures and tables eat that budget much faster.

### 5.4 Deck YAML

Shared deck options live in `website/slides/_metadata.yml` and apply to every deck in that
directory. A deck's own YAML holds its `title:` and nothing else (`E041`).

```yaml
---
title: "Week 03: Priors and the prior predictive check"
---
```

**The title shape is a contract** (`E040`). `schedule.qmd` strips the `Week NN: ` prefix to build
the Topic column, so a deck titled any other way produces a mangled schedule. Filenames are
zero-padded (`week03.qmd`), because the schedule finds decks by `week%02d.qmd`.

The 8-step workflow table is included, never pasted (`E042`):

```markdown
{{< include _workflow-8step.qmd >}}
```

---

## 6. The check procedure

`automation/check-authoring.ps1` runs in two stages.

**Stage A, static.** Every rule code in this file. No dependencies, runs in about a second, and
`publish-site.ps1` runs it as a gate before rendering.

```
> .\automation\check-authoring.ps1

website/slides/week03.qmd:41   E001  em dash in prose
website/slides/week03.qmd:88   E020  fig- chunk 'fig-priors' has no fig-cap
website/slides/week03.qmd:112  E031  inline font-size, use .small or .xsmall

3 finding(s).
```

**Stage B, slide fit.** Added with `-Fit`. Renders the deck, then drives headless Chrome through
R's `chromote` to load it in reveal's print-pdf layout, where every slide is laid out at
1050 x 700 with all fragments shown, and measures each slide's real height.

```
> .\automation\check-authoring.ps1 -Week 03 -Fit

OVERFLOW (canvas 1050x700)
  slide  7  Priors on the logit scale     812px  (+16.0%)  -> split the slide
  slide 14  Posterior predictive check    731px  (+4.4%)   -> wrap dense block in .small
  20 of 22 slides fit.
```

How to act on stage B, in order of preference:

1. Overflow under about 8 percent: wrap the densest block in the next ladder step.
2. Overflow above that: split the slide. Two clear slides beat one crowded one.
3. Never respond by inventing a font size.

Stage B needs the `chromote` R package and a Chrome or Edge install. If either is missing it
prints a skip notice and returns success, so stage A still stands on its own.

---

## 7. Contracts that automation depends on

Breaking one of these does not raise an error. It silently produces a wrong website. All of them
are checked.

| Contract | Consumer |
|---|---|
| Deck title is `Week NN: <topic>` | `schedule.qmd` builds the Topic column from it |
| Filenames zero-padded (`week03.qmd`, `hw-03/`) | `schedule.qmd` finds files by `%02d` |
| `homework/hw-NN/meta.yml` present and valid | schedule links, release and tracking scripts |
| 8-step table included, never pasted | one source of truth for the exam rubric |
| Feedback-policy banner reproduced verbatim | syllabus, schedule, every homework README |
| No solution or exam content in this repo | this repo is public and its history is permanent |

---

## 8. What this repo deliberately does not do

Recorded so the decisions are not relitigated.

- No frequentist framing in methods content. The course is Bayesian by design (CLAUDE.md §3).
  Contrast the two frameworks where that teaches something. Do not substitute one for the other.
- No `.Rmd`. Quarto `.qmd` everywhere.
- No hand-typed schedule, roster or homework status. All of it is built from `course.yml`,
  `meta.yml` and the GitHub API.
- No per-deck duplication of shared YAML, colours, or the workflow table.
