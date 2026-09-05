# -----------------------------------------------------------------------------
# Shared helpers for the site pages. Sourced by index.qmd, schedule.qmd,
# syllabus.qmd and glossary.qmd:
#
#     here::i_am("website/<page>.qmd")
#     source(here("website", "_course-helpers.R"))
#
# The leading underscore keeps Quarto from treating this as a render target.
#
# Everything term-level comes from course.yml (CLAUDE.md §7). Nothing here holds a
# date, a threshold or a block name of its own: this file only does arithmetic and
# formatting on what course.yml says.
# -----------------------------------------------------------------------------

# Read course.yml. Callers must have set here::i_am() first, because website/
# is itself a Quarto project root and a bare here() would stop there.
read_course <- function() {
  yaml::read_yaml(here::here("course.yml"))
}

# A PLACEHOLDER in course.yml prints as an honest "to be announced", never as the
# literal word. See course.yml for the keys that are still unset.
shown <- function(x, fallback = "to be announced") {
  if (is.null(x) || !nzchar(x) || identical(x, "PLACEHOLDER")) fallback else x
}

# The exam window as one printable string. Either both ends are known or neither is
# useful, so a single unset end makes the whole window "to be announced".
exam_window <- function(cfg) {
  opens <- shown(cfg$exam$opens)
  closes <- shown(cfg$exam$closes)
  if (identical(opens, "to be announced") || identical(closes, "to be announced")) {
    return("to be announced")
  }
  paste(opens, "to", closes)
}

pct <- function(x) paste0(round(100 * x), "%")

pad <- function(i) sprintf("%02d", i)

# --- the term calendar -------------------------------------------------------
# THE definition of when week N happens. The weekly grid starts at first_session,
# every date in skip_dates is removed, and what is left is taken in order until
# `count` sessions are found. So a cancelled date pushes every later week back by a
# week rather than silently renumbering the term.
session_dates <- function(cfg) {
  n <- cfg$sessions$count
  first <- as.Date(cfg$sessions$first_session)
  skips <- as.Date(unlist(cfg$sessions$skip_dates %||% list()))
  # Generate a generous grid, then drop the skipped dates and take the first n.
  grid <- first + seq(0, by = 7, length.out = n + length(skips))
  keep <- grid[!grid %in% skips]
  keep[seq_len(n)]
}

# The skipped dates that actually fall inside the term, with the week they sit
# between, so the schedule can print an explained "no session" row.
skipped_sessions <- function(cfg) {
  skips <- as.Date(unlist(cfg$sessions$skip_dates %||% list()))
  if (length(skips) == 0) {
    return(data.frame(date = as.Date(character()), after_week = integer()))
  }
  dates <- session_dates(cfg)
  skips <- sort(skips[skips >= min(dates) & skips <= max(dates)])
  data.frame(
    date = skips,
    after_week = vapply(skips, function(d) sum(dates < d), integer(1))
  )
}

# --- blocks ------------------------------------------------------------------
# Which of the three teaching blocks a week belongs to. Named ONCE in course.yml,
# so the schedule, the syllabus and the glossary cannot drift apart.
block_index_of <- function(cfg, i) {
  for (k in seq_along(cfg$blocks)) {
    b <- cfg$blocks[[k]]
    if (i >= b$from && i <= b$to) {
      return(k)
    }
  }
  NA_integer_ # week 1 sits outside the blocks
}

block_name_of <- function(cfg, i) {
  k <- block_index_of(cfg, i)
  if (is.na(k)) NA_character_ else cfg$blocks[[k]]$name
}

# Roman numerals for the block headings. Three blocks, so a lookup is enough.
block_numeral <- function(k) c("I", "II", "III", "IV", "V")[k]

# --- the planned week entry --------------------------------------------------
week_entry <- function(cfg, i) {
  hit <- Filter(function(w) identical(w$week, i), cfg$weeks)
  if (length(hit) == 0) NULL else hit[[1]]
}

`%||%` <- function(x, y) if (is.null(x)) y else x
