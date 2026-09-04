# ─────────────────────────────────────────────────────────────────────────────
# Measure whether every slide of a rendered RevealJS deck fits the canvas.
#
# Called by automation/check-authoring.ps1 -Fit. Standalone use:
#
#     Rscript automation/check-slide-fit.R website/_site/slides/week01.html
#
# Why a browser. Slide overflow is a layout property. It depends on the theme,
# the font, the rendered figure sizes and how many fragments a slide reveals, so
# counting source lines cannot answer it. The previous course iteration had no
# check at all and handled overflow by hand, which is how it ended up with 20
# different ad-hoc font sizes.
#
# How. Reveal's print-pdf mode lays every slide out at the configured canvas size
# with all fragments made visible, which is exactly the "does it fit on one
# slide" question. We load the deck in that mode and compare each laid-out
# slide's scrollHeight against the canvas height.
#
# Exit codes: 0 = every slide fits, or the check could not run (a missing browser
# must not fail the build). 1 = at least one slide overflows.
# ─────────────────────────────────────────────────────────────────────────────

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("usage: check-slide-fit.R <rendered-deck.html> [canvas_width] [canvas_height]")
}

html <- normalizePath(args[1], winslash = "/", mustWork = TRUE)
canvas_w <- if (length(args) >= 2) as.numeric(args[2]) else 1050
canvas_h <- if (length(args) >= 3) as.numeric(args[3]) else 700

# Tolerance in px. Reveal's own layout rounds, and a slide one or two pixels over
# is not something a human would ever notice on a projector.
tol <- 6

skip <- function(msg) {
  cat("  [skip]", msg, "\n")
  cat("  [skip] Static checks still applied. Install with: install.packages(\"chromote\")\n")
  quit(status = 0)
}

if (!requireNamespace("chromote", quietly = TRUE)) {
  skip("the chromote package is not installed.")
}

# chromote::find_chrome() looks for Chrome, Chromium and Brave but not Edge, which is
# the browser present on a stock Windows install. Fall back to it explicitly.
find_browser <- function() {
  # find_chrome() writes a "Google Chrome was not found" notice to stderr before
  # returning NULL. That is not an error here, because Edge is the fallback.
  found <- suppressMessages(suppressWarnings(
    tryCatch(chromote::find_chrome(), error = function(e) NULL)
  ))
  if (!is.null(found) && nzchar(found)) {
    return(found)
  }
  candidates <- c(
    file.path(Sys.getenv("ProgramFiles(x86)"), "Microsoft/Edge/Application/msedge.exe"),
    file.path(Sys.getenv("ProgramFiles"), "Microsoft/Edge/Application/msedge.exe"),
    file.path(Sys.getenv("LOCALAPPDATA"), "Microsoft/Edge/Application/msedge.exe")
  )
  hit <- candidates[file.exists(candidates)]
  if (length(hit)) hit[1] else NULL
}

chrome <- find_browser()
if (is.null(chrome)) {
  skip("no Chrome, Chromium or Edge installation found.")
}
Sys.setenv(CHROMOTE_CHROME = chrome)

b <- tryCatch(
  chromote::ChromoteSession$new(),
  error = function(e) NULL
)
if (is.null(b)) skip("could not start a headless browser session.")

on.exit(try(b$close(), silent = TRUE), add = TRUE)

url <- paste0("file:///", sub("^/", "", html))

invisible(b$Page$navigate(url, wait_ = TRUE))
invisible(b$Page$loadEventFired(wait_ = TRUE, timeout_ = 60))

# Reveal builds the print layout asynchronously after load. Poll for the pages
# rather than sleeping a fixed amount, so a slow deck is not measured half-built.
js_ready <- "document.querySelectorAll('.reveal .slides section').length"
n_sections <- 0
for (i in seq_len(40)) {
  Sys.sleep(0.25)
  n_sections <- tryCatch(
    b$Runtime$evaluate(js_ready)$result$value,
    error = function(e) 0
  )
  if (is.numeric(n_sections) && n_sections > 0 && i > 4) break
}
if (!is.numeric(n_sections) || n_sections == 0) {
  skip("the deck produced no slides in print layout.")
}

# Measure.
#
# Reveal displays one slide at a time and fits the deck to the viewport with a CSS
# transform, so neither the rendered box nor a print-pdf page tells you how tall a
# slide's CONTENT is: both report the fixed canvas box. So we neutralise reveal's
# layout for the measurement, laying every slide out statically at the true canvas
# WIDTH with height:auto, and read the natural content height back. That number is
# directly comparable to the canvas height because reveal scales by transform and
# never changes the font size, so the unscaled coordinate system is 1050x700.
#
# Every fragment is forced visible first: a slide only overflows once its last beat
# is revealed. Sections containing another section are vertical-stack wrappers, not
# slides, so they are skipped.
js_measure <- sprintf("
(() => {
  const W = %f;
  const css = document.createElement('style');
  css.textContent = `
    .reveal .slides { position: static !important; transform: none !important;
      left: 0 !important; top: 0 !important; margin: 0 !important;
      width: ${W}px !important; height: auto !important; zoom: 1 !important; }
    .reveal .slides > section,
    .reveal .slides > section > section {
      display: block !important; position: static !important;
      height: auto !important; min-height: 0 !important;
      visibility: visible !important; opacity: 1 !important;
      transform: none !important; top: auto !important; }
    .reveal .fragment { opacity: 1 !important; visibility: visible !important; }
    .reveal .slides section .fragment:not(.visible) { opacity: 1 !important; }
  `;
  document.head.appendChild(css);
  document.querySelectorAll('.reveal .fragment').forEach(f => {
    f.classList.add('visible', 'current-fragment');
  });

  const out = [];
  let idx = 0;
  document.querySelectorAll('.reveal .slides section').forEach(s => {
    if (s.querySelector(':scope > section')) return;
    idx += 1;
    const head = s.querySelector('h1, h2, h3');
    const isTitle = s.id === 'title-slide';
    out.push({
      i: idx,
      title: isTitle ? '(title slide)'
            : head ? head.textContent.trim().slice(0, 40)
            : '(no heading)',
      h: Math.round(Math.max(s.scrollHeight, s.offsetHeight))
    });
  });
  return JSON.stringify(out);
})()
", canvas_w)

res <- tryCatch(
  b$Runtime$evaluate(js_measure, returnByValue = TRUE)$result$value,
  error = function(e) NULL
)
if (is.null(res)) skip("measurement script did not return a result.")

slides <- tryCatch(
  jsonlite::fromJSON(res, simplifyDataFrame = TRUE),
  error = function(e) NULL
)
if (is.null(slides) || length(slides) == 0 || nrow(slides) == 0) {
  skip("no measurable slides in the deck.")
}

slides$over <- slides$h - canvas_h
slides$pct <- 100 * slides$over / canvas_h
bad <- slides[slides$over > tol, , drop = FALSE]

remedy <- function(pct) {
  if (pct <= 8) {
    "wrap the dense block in .small"
  } else if (pct <= 20) {
    "wrap the dense block in .xsmall, or split"
  } else {
    "split the slide"
  }
}

cat(sprintf("  canvas %.0fx%.0f, %d slide(s) measured\n", canvas_w, canvas_h, nrow(slides)))

if (nrow(bad) == 0) {
  cat(sprintf("  all %d slides fit.\n", nrow(slides)))
  quit(status = 0)
}

cat("\n  OVERFLOW\n")
for (k in seq_len(nrow(bad))) {
  cat(sprintf(
    "    slide %2d  %-42s %4dpx  (+%.1f%%)  -> %s\n",
    bad$i[k], bad$title[k], bad$h[k], bad$pct[k], remedy(bad$pct[k])
  ))
}
cat(sprintf("\n  %d of %d slides fit. See STYLE.md section 5.1 for the ladder.\n",
            nrow(slides) - nrow(bad), nrow(slides)))
quit(status = 1)
