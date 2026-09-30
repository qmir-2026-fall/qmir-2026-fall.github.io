---
last_modified: 2026-09-30
scope: prose and typography, one sentence per line, cross-references, callouts, math notation
---

# Writing

Read this before authoring or editing any `.qmd`, a student-facing `README.md`, a glossary entry,
or any math. It is the house style for every `.qmd` and `.md` in this repo: slides, website
pages, homework starters, sample solutions, feedback templates and the manuals in `.claude/`.
R code conventions are in `r-code.md`, and slide geometry is in `slides.md`.

Everything in the three style files (`writing.md`, `r-code.md`, `slides.md`) is mechanically
checked. Run this before you commit:

```powershell
.\automation\check-authoring.ps1                 # whole repo, static rules
.\automation\check-authoring.ps1 -Week 03 -Fit   # one deck, plus real slide-fit measurement
```

Each rule below carries the code the checker reports (`E0NN`). A rule not worth enforcing does
not belong in these files.

## Prose and typography

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

### One sentence per line

**A sentence occupies exactly one source line.** Do not hard-wrap a sentence at some column
(`E003`), and do not put two sentences on one line (`E004`). Diffs stay readable, and a reworded
sentence shows up as one changed line instead of a reflowed paragraph.

```markdown
Bad:   This week has no right answer, because what is
       practised is the workflow. A complete submission is a repository.
Good:  This week has no right answer, because what is practised is the workflow.
       A complete submission is a repository.
```

Lines therefore run long, and that is correct. **Never reflow a paragraph to fit a column.**

Splitting is safe: Markdown joins soft line breaks inside a paragraph, so the rendered output is
byte-identical either way. Split a bold lead sentence off from what follows it in the same way,
even when the emphasis then spans the break.

**Where it applies.** Every `.qmd`, plus the `README.md` that ships inside a homework
distribution repo, which is everything a student reads. The repo's own manuals (everything in
`.claude/`, the folder and `automation/` READMEs) are hard-wrapped at 95 columns instead, and
the checker exempts them. Those are read as documents, they are not rendered, and rewrapping
them would churn the files that are re-read most.

Two exceptions inside a file in scope, both because the unit is not a paragraph:

- A **caption** is one line, however long, and may hold several sentences: a Markdown table
  caption (`: ... {#tbl-x}`) and an image caption (`![...](...)`). Pandoc reads the caption as
  one block, so a line break there risks the caption rather than the prose.
- A **table cell** is the one place a sentence cannot be moved to a line of its own.

Other prose rules:

- Sentence case for headings, not Title Case.
- Package and function names in backticks: `brms`, `pp_check()`.
- The feedback-policy banner (`workflow.md`) is reproduced **verbatim** wherever it appears. Do
  not reword it. Consistency is the entire point of it.

## Cross-references

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

## Callouts

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

On slides, size a callout with the ladder classes from `slides.md`, never with an inline style.

## Mathematical notation

One notation for the whole course, fixed in week 3 (`@tbl-structures` in
`website/slides/week03.qmd`) and followed everywhere after. It is the standard linear-algebra
convention. The shapes are told apart by **bold**, not by italics: every letter in math mode is
already italic, so italics cannot carry the distinction.

| Concept | Symbol | LaTeX |
|---|---|---|
| Scalar | $x$, italic lowercase | `x` |
| Vector | $\mathbf{x}$, bold lowercase | `\mathbf{x}` |
| Matrix | $\mathbf{X}$, bold uppercase | `\mathbf{X}` |
| Tensor (order 3 or more) | $\mathcal{X}$, calligraphic | `\mathcal{X}` |

Consequences for the rest of the term:

- The outcome is the vector $\mathbf{y}$ and the predictors are the matrix $\mathbf{X}$. The
  staged decks from weeks 8 to 11 write $\mathbf{Y}$, so rewrite it as $\mathbf{y}$ when you
  convert them.
- A single entry is a scalar, so it is italic with a subscript: $y_i$, $x_{ij}$.
- Bold Latin letters use `\mathbf`. Bold Greek letters (a parameter vector such as
  $\boldsymbol{\beta}$) use `\boldsymbol`, because `\mathbf` cannot bold Greek. `\bm` and `\vec`
  are not used (`E050`).
- R has no scalars: a single value is a vector of length 1. Say so wherever the two meet.
