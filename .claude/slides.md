---
last_modified: 2026-09-30
scope: slide canvas, size ladder, columns, deck grammar and YAML, the two check stages
---

# Slides

Read this before touching anything under `website/slides/`, or before acting on a
`check-authoring.ps1` finding. Prose and cross-reference rules for decks are in `writing.md`,
and R code in decks follows `r-code.md`.

## Canvas and the size ladder

The canvas is Quarto's revealjs default, **1050 x 700 px**. A slide must fit that canvas with
every fragment revealed. This is measured, not eyeballed. See the check procedure below.

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

## Columns

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

## Deck grammar

- `#` is a section-divider slide.
- `##` is a content slide.
- `. . .` on its own line separates revealed beats.
- `::: notes` sits directly under the heading, before the body, and holds terse
  instructor-facing imperatives. Delivery cues and lines to say aloud belong here.

Density guidance, calibrated on the best-behaved deck of the previous course (median 31 source
lines per slide including notes): about three revealed beats of three to six short lines each.
It is guidance, not a lint rule, because the fit check measures the truth.

For a sense of scale, measured on this theme with the fit check: nine wrapping bullets come to
1197px at step 0, which overflows the 700px canvas by 71 percent, and drop under the canvas at
step 1. So roughly **six wrapping bullets at step 0, or ten at step 1**, before you are over.
Figures and tables eat that budget much faster.

## Deck YAML

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

## The check procedure

`automation/check-authoring.ps1` runs in two stages.

**Stage A, static.** Every rule code in the three style files. No dependencies, runs in about
a second, and `publish-site.ps1` runs it as a gate before rendering.

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

**What the check does not look at.** Two staging paths are skipped: `website/slides/_weekNN.qmd`
and `homework/_import/`. Both hold 2026 spring material ported verbatim, which does not follow
the style files yet (`workflow.md`). Neither is rendered or linked anywhere, and converting a
week means renaming or copying it back into scope, so nothing student-facing ever escapes the
gate.
