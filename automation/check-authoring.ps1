<#
.SYNOPSIS
  Check the repo against the authoring conventions in STYLE.md.

.DESCRIPTION
  Stage A (always): static rules over every .qmd and .md. Prose rules are applied only to
  prose, so code fences, inline code spans, raw HTML and math are stripped first while line
  numbers are preserved.

  Stage B (-Fit): the real slide-fit measurement. Renders a deck and drives headless Chrome
  through R's chromote to measure every slide against the 1050x700 canvas. Skips cleanly
  (without failing) when chromote or Chrome is unavailable.

  Every rule code emitted here is documented in STYLE.md.

.PARAMETER Path
  File or directory to check. Default: the whole repo.

.PARAMETER Week
  Zero-padded week number. Narrows the run to that deck, e.g. -Week 03.

.PARAMETER Fit
  Also run stage B on the deck(s) in scope. Implies a quarto render.

.PARAMETER Quiet
  Print only the summary line.

.EXAMPLE
  .\automation\check-authoring.ps1
.EXAMPLE
  .\automation\check-authoring.ps1 -Week 03 -Fit

  Keep this file ASCII-only (see automation/README.md, gotcha 4).
#>
[CmdletBinding()]
param(
  [string]$Path,
  [string]$Week,
  [switch]$Fit,
  [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "_common.ps1")

$RepoRoot = Split-Path $PSScriptRoot -Parent

# -----------------------------------------------------------------------------
# Findings
# -----------------------------------------------------------------------------
$script:Findings = New-Object System.Collections.ArrayList

function Add-Finding {
  param([string]$File, [int]$Line, [string]$Code, [string]$Message)
  $rel = $File
  if ($rel.StartsWith($RepoRoot)) { $rel = $rel.Substring($RepoRoot.Length).TrimStart('\', '/') }
  [void]$script:Findings.Add([pscustomobject]@{
      File    = ($rel -replace '\\', '/')
      Line    = $Line
      Code    = $Code
      Message = $Message
    })
}

# -----------------------------------------------------------------------------
# Prose extraction
#
# Returns one entry per source line: the line with everything that is NOT prose
# blanked out. Blanking rather than removing keeps line numbers exact.
# Stripped: YAML front matter, fenced code blocks, inline code spans, raw HTML
# tags and comments, display and inline math, link targets and image paths.
# -----------------------------------------------------------------------------
function Get-ProseLines {
  param([string[]]$Lines)

  $out = New-Object string[] $Lines.Count
  $inFence = $false
  $fenceMark = ''
  $inYaml = $false
  $inMath = $false
  $inHtmlComment = $false

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    $raw = $Lines[$i]
    $out[$i] = ''

    # YAML front matter: only between the first --- pair at the top of the file.
    if ($i -eq 0 -and $raw.Trim() -eq '---') { $inYaml = $true; continue }
    if ($inYaml) {
      if ($raw.Trim() -eq '---' -or $raw.Trim() -eq '...') { $inYaml = $false }
      continue
    }

    # HTML comments can span lines and routinely hold notes-to-self.
    if ($inHtmlComment) {
      if ($raw -match '-->') { $inHtmlComment = $false }
      continue
    }
    if ($raw -match '<!--' -and $raw -notmatch '-->') { $inHtmlComment = $true; continue }

    # Fenced code blocks, backtick or tilde, any fence length.
    if (-not $inFence -and $raw -match '^\s*(`{3,}|~{3,})') {
      $inFence = $true
      $fenceMark = $Matches[1].Substring(0, 1)
      continue
    }
    if ($inFence) {
      if ($raw -match "^\s*[$fenceMark]{3,}\s*$") { $inFence = $false }
      continue
    }

    # Display math blocks.
    if (-not $inMath -and $raw -match '^\s*\$\$') {
      # A one-line $$ ... $$ opens and closes on the same line.
      if (($raw -split '\$\$').Count -lt 3) { $inMath = $true }
      continue
    }
    if ($inMath) {
      if ($raw -match '\$\$') { $inMath = $false }
      continue
    }

    # Chunk option comments are YAML, not prose.
    if ($raw -match '^\s*#\|') { continue }

    $t = $raw
    $t = $t -replace '<!--.*?-->', ' '          # single-line HTML comment
    $t = $t -replace '`[^`]*`', ' '             # inline code span
    $t = $t -replace '\$[^$]+\$', ' '           # inline math
    $t = $t -replace '<[^>]+>', ' '             # raw HTML tag
    $t = $t -replace '\]\([^)]*\)', '] '        # link / image target
    $t = $t -replace 'https?://\S+', ' '        # bare URL
    $t = $t -replace '\{[^}]*\}', ' '           # pandoc attributes, shortcodes
    $out[$i] = $t
  }
  return , $out
}

# Regions that are R code: inside a ```{r} fence. Used by the code rules so a
# Markdown table full of pipes is never mistaken for pipeline syntax.
function Get-ChunkRanges {
  param([string[]]$Lines)
  $ranges = @()
  $start = -1
  $inFence = $false
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if (-not $inFence -and $Lines[$i] -match '^\s*```+\s*\{[rR][ ,}]') {
      $inFence = $true; $start = $i; continue
    }
    if (-not $inFence -and $Lines[$i] -match '^\s*```+\s*\{') { $inFence = $true; $start = -1; continue }
    if (-not $inFence -and $Lines[$i] -match '^\s*```+') { $inFence = $true; $start = -1; continue }
    if ($inFence -and $Lines[$i] -match '^\s*```+\s*$') {
      if ($start -ge 0) { $ranges += , @($start, $i) }
      $inFence = $false; $start = -1
    }
  }
  # Unary comma. Without it PowerShell unrolls a single-element array of arrays
  # into a flat list of ints and every $r[0] silently becomes a line number.
  return , $ranges
}

# EVERY fenced block, whatever its language, including ``` markdown and bare ```.
# Get-ChunkRanges above is R-only on purpose, so the code rules can look inside an
# R chunk. The MARKUP rules need the opposite: anything fenced is displayed code and
# must not be read as document markup.
function Get-FenceRanges {
  param([string[]]$Lines)
  $ranges = @()
  $start = -1
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($start -lt 0) {
      if ($Lines[$i] -match '^\s*(`{3,}|~{3,})') { $start = $i }
      continue
    }
    if ($Lines[$i] -match '^\s*(`{3,}|~{3,})\s*$') {
      $ranges += , @($start, $i)
      $start = -1
    }
  }
  # Unary comma, for the same reason as in Get-ChunkRanges.
  return , $ranges
}

# Display-math block ranges, so an opening $$ is never mistaken for a closing one.
function Get-MathRanges {
  param([string[]]$Lines)
  $ranges = @()
  $start = -1
  $inFence = $false
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match '^\s*```') { $inFence = -not $inFence; continue }
    if ($inFence) { continue }
    if ($start -lt 0) {
      if ($Lines[$i] -match '^\s*\$\$' -and ($Lines[$i] -split '\$\$').Count -lt 3) { $start = $i }
    } elseif ($Lines[$i] -match '\$\$') {
      $ranges += , @($start, $i)
      $start = -1
    }
  }
  return , $ranges
}

# -----------------------------------------------------------------------------
# Stage A: static rules
# -----------------------------------------------------------------------------
# U+2014 em dash and U+2013 en dash, built from code points so this file stays
# ASCII-only (automation/README.md, gotcha 4). `u{...} is PS 7 only, hence [char].
$DashPattern = "[$([char]0x2014)$([char]0x2013)]"

$CalloutTypes = @('note', 'warning', 'important', 'tip')
$ColumnWidths = @('50', '55', '45', '60', '40', '33', '34')

# Abbreviations whose period is not the end of a sentence (E004). Case-sensitive on
# purpose: lowercase "no." really does end a sentence, "No. 4" does not.
$Abbreviations = @(
  'e\.g\.', 'i\.e\.', 'etc\.', 'vs\.', 'cf\.', 'approx\.', 'ca\.', 'et al\.',
  'No\.', 'Nos\.', 'Dr\.', 'Prof\.', 'Mr\.', 'Ms\.', 'St\.', 'Fig\.', 'Tab\.',
  'pp\.', 'p\.'
)

# One sentence per line (E003 and E004), the two halves of the same rule.
# Returns the line reduced to the sentence text: leading blockquote markers and list
# markers removed, trailing whitespace gone. Inline code, math, links and attributes
# are already blanked by Get-ProseLines.
function Get-SentenceText {
  param([string]$Line)
  $t = $Line -replace '^\s+', ''
  while ($t -match '^>\s?') { $t = $t -replace '^>\s?', '' }
  # Emphasis can open before the list marker: "**1. Weekly homework.**" is a numbered
  # item in bold, and its "1." is a marker, not the end of a sentence.
  $t = $t -replace '^[*_]{1,2}\s*', ''
  $t = $t -replace '^([-*+]|\d+[.)])\s+', ''
  return $t.TrimEnd()
}

# A line that opens a block of its own is never the continuation of the previous
# sentence: a heading, a fenced div, a table row, display math, a list item, or the
# ": caption" line that follows a Markdown table.
function Test-OpensBlock {
  param([string]$Text)
  return ($Text -match '^\s*(#|:{3,}|\||\$\$|[-*+]\s|\d+[.)]\s|:\s)')
}

function Test-File {
  param([string]$File)

  $lines = [System.IO.File]::ReadAllLines($File)
  if ($lines.Count -eq 0) { return }
  $prose = Get-ProseLines -Lines $lines
  $chunks = Get-ChunkRanges -Lines $lines
  $fences = Get-FenceRanges -Lines $lines
  $maths = Get-MathRanges -Lines $lines

  $name = Split-Path $File -Leaf
  $isQmd = $name -match '\.qmd$'
  $isDeck = $File -match '[\\/]website[\\/]slides[\\/]'
  $isRenderedDeck = $name -match '^week\d{2}\.qmd$'

  # One sentence per line applies to prose a student reads: every rendered .qmd, plus
  # the README.md that ships inside a homework distribution repo. The repo's own
  # manuals (CLAUDE.md, STYLE.md, notes.md, the automation and folder READMEs) are
  # hard-wrapped at 95 columns on purpose, and STYLE.md section 1 says so.
  $slash = $File -replace '\\', '/'
  $isStudentFacing = $isQmd -or ($slash -match '/homework/(hw-\d+|_template)/README\.md$')

  # Display equations need a label on the CLOSING $$ (E022).
  foreach ($m in $maths) {
    if ($lines[$m[1]] -notmatch '\{#eq-') {
      Add-Finding $File ($m[1] + 1) 'E022' 'display equation without a {#eq-...} label'
    }
  }

  # --- prose rules -----------------------------------------------------------
  for ($i = 0; $i -lt $prose.Count; $i++) {
    $p = $prose[$i]
    if ([string]::IsNullOrWhiteSpace($p)) { continue }
    if ($p -match $DashPattern) {
      Add-Finding $File ($i + 1) 'E001' 'em dash or en dash in prose, use a comma, a colon, parentheses, or --'
    }
    if ($p -match ';') {
      Add-Finding $File ($i + 1) 'E002' 'semicolon in prose, split the sentence'
    }

    if (-not $isStudentFacing) { continue }

    $t = Get-SentenceText -Line $p
    if ($t -eq '') { continue }
    # Headings, fenced divs, table rows and the reveal separator ". . ." are markup,
    # not sentences. A table cell is the one place prose cannot be split.
    if ($t -match '^(#|:{3,}|\|)' -or $t -match '^\.(\s*\.){2}\s*$') { continue }

    # E003: does this line finish its sentence? Trailing emphasis, brackets and
    # quotes sit after the full stop, so strip them before looking.
    $tail = $t -replace '[*`"''\)\]\s]+$', ''
    if ($tail -ne '' -and $tail -notmatch '[.!?:]$') {
      $nx = ''
      if ($i + 1 -lt $prose.Count) { $nx = Get-SentenceText -Line $prose[$i + 1] }
      if ($nx -ne '' -and -not (Test-OpensBlock -Text $prose[$i + 1])) {
        Add-Finding $File ($i + 1) 'E003' 'sentence continues on the next line, one sentence per line'
      }
    }

    # E004: the other half. A full stop followed by the start of a new sentence means
    # two sentences share one line. Decimals, ellipses, initials and the abbreviations
    # above are periods that end nothing. A Markdown table caption is exempt: Pandoc
    # reads it as one block, and splitting it risks the caption rather than the prose.
    #
    # -creplace and -cmatch throughout. PowerShell's -match is CASE-INSENSITIVE, so
    # [A-Z] happily matched a lowercase word and every second line came back flagged.
    if ($t -match '^:\s' -or $t -match '^!\[') { continue }
    $s = $t -creplace '\d\.\d', ' '
    $s = $s -creplace '\.\.\.', ' '
    $s = $s -creplace '\b([A-Z]\.)+', ' '
    # \b matters: without it "p\." also blanks the full stop in "setup.", and every
    # sentence ending in one of these letter pairs stops being a sentence end.
    foreach ($a in $Abbreviations) { $s = $s -creplace ('\b' + $a), ' ' }
    if ($s -cmatch '[.!?]["*)`]{0,3}\s+[*_]{0,2}[A-Z(@]') {
      Add-Finding $File ($i + 1) 'E004' 'more than one sentence on this line, split it'
    }
  }

  # --- whole-file markup rules ----------------------------------------------
  $inCallout = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $l = $lines[$i]
    $n = $i + 1
    $inChunk = $false
    foreach ($r in $chunks) { if ($i -gt $r[0] -and $i -lt $r[1]) { $inChunk = $true; break } }
    $inShownCode = $false
    foreach ($r in $fences) { if ($i -gt $r[0] -and $i -lt $r[1]) { $inShownCode = $true; break } }

    if ($inChunk) {
      if ($l -match '%>%') { Add-Finding $File $n 'E010' 'use the native pipe |> instead of %>%' }
      if ($l -match '\bcolor\s*=') { Add-Finding $File $n 'E011' 'use colour = in ggplot2 calls, not color =' }
      if ($l -match '(?<!case_)\brecode\s*\(') { Add-Finding $File $n 'E012' 'recode() is deprecated, use case_match()' }
      # Only the real file readers, and only when the literal looks like a path.
      # A project helper that wraps here() internally must not be flagged.
      $readers = 'read_csv2?|read_tsv|read_delim|read_table2?|read\.csv2?|read\.table|read\.delim|read_excel|read_xlsx|read_rds|readRDS|read_dta|read_sav|read_lines|read_file|file\.path'
      if ($l -match "\b($readers)\s*\(\s*[`"'][^`"']*\.[A-Za-z0-9]{1,5}[`"']" -and $l -notmatch 'here\s*\(') {
        Add-Finding $File $n 'E013' 'wrap the path in here(), a bare relative path is not Quarto-robust'
      }
      if ($l -match '^\s*library\s*\(' -and $l -notmatch '#\s*\S') {
        Add-Finding $File $n 'E014' 'library() needs a trailing comment saying what the package is for'
      }
      continue
    }

    # A deck that TEACHES markdown shows markdown. Everything inside a fenced block is
    # displayed code, not document markup, so the markup rules below must not read it:
    # week02 quotes `## A subsection` on a slide about headings, and that is the lesson,
    # not an unlabelled heading. R chunks already returned above.
    if ($inShownCode) { continue }

    # Markup rules run on the line with inline code spans blanked, so an example
    # of a violation quoted in backticks is documentation, not a violation.
    $lc = $l -replace '`[^`]*`', ' '

    # Headings need a section label. This is a crossref rule, so it applies to
    # rendered Quarto documents only, not to plain Markdown docs like this repo's
    # READMEs. Section dividers (#) are exempt: they are slide breaks.
    # A heading directly inside a callout is the callout's TITLE, not a section.
    if ($lc -match '^\s*:{3,}\s*\{?[^}]*\.callout-') { $inCallout = $true }
    elseif ($inCallout -and $lc -match '^\s*:{3,}\s*$') { $inCallout = $false }

    if ($isQmd -and -not $inCallout -and $l -match '^(#{2,3})\s+(.+)$') {
      $head = $Matches[2]
      if ($head -notmatch '\{#sec-') {
        Add-Finding $File $n 'E023' 'heading without a {#sec-...} label'
      }
      if ($head -match '\{\s*\.[a-z]' -and $head -match '\{#sec-' -and $head -notmatch '\{#sec-[a-z0-9-]+\s') {
        # id present but not first inside the brace: {.smaller #sec-x}
        Add-Finding $File $n 'E023' 'attribute order is id first, then classes: {#sec-x .smaller}'
      }
    }

    if ($lc -match ':::+\s*\{?\s*\.callout-([a-z]+)') {
      $type = $Matches[1]
      if ($CalloutTypes -notcontains $type) {
        Add-Finding $File $n 'E030' "callout-$type is not one of note, warning, important, tip"
      }
    }

    if ($lc -match 'style\s*=\s*["''][^"'']*font-size') {
      Add-Finding $File $n 'E031' 'inline font-size, use the {.small} / {.xsmall} ladder'
    }

    # Math notation (STYLE.md section 9). Math survives in $lc, which only blanks code
    # spans, so a macro quoted in backticks is documentation and is not flagged.
    if ($lc -match '\\(bm|vec)\s*\{' -or $lc -match '\\boldsymbol\s*\{\s*[A-Za-z]') {
      Add-Finding $File $n 'E050' 'bold Latin with \mathbf, bold Greek with \boldsymbol, never \bm or \vec'
    }

    if ($lc -match '^\s*:{4,}\s*columns\s*$') {
      Add-Finding $File $n 'E032' 'use the :::: {.columns} idiom, not the bare columns fence'
    }
    if ($lc -match '\.column\s+width\s*=\s*["''](\d+)%') {
      if ($ColumnWidths -notcontains $Matches[1]) {
        Add-Finding $File $n 'E032' "column width $($Matches[1])% is not one of the permitted widths"
      }
    }

    if ($lc -match '\{[^}]*\.xsmall[^}]*\.small[\s}]' -or $l -match '\{[^}]*\.small[^}]*\.xsmall[\s}]') {
      Add-Finding $File $n 'E033' 'one ladder class per block, .small and .xsmall do not combine'
    }

    if ($isDeck -and $isRenderedDeck -and $lc -match '^\s*\|\s*6a\s*\|') {
      Add-Finding $File $n 'E042' 'the 8-step table is pasted, include _workflow-8step.qmd instead'
    }
  }

  # --- chunk-level crossref rules -------------------------------------------
  foreach ($r in $chunks) {
    $head = @()
    for ($i = $r[0] + 1; $i -lt $r[1]; $i++) {
      if ($lines[$i] -match '^\s*#\|') { $head += $lines[$i] } elseif ($lines[$i].Trim() -ne '') { break }
    }
    $body = @()
    for ($i = $r[0] + 1; $i -lt $r[1]; $i++) { $body += $lines[$i] }
    $headText = ($head -join "`n")
    $bodyText = ($body -join "`n")
    $n = $r[0] + 1

    $label = $null
    if ($headText -match '#\|\s*label:\s*(\S+)') { $label = $Matches[1] }

    if (-not $label) {
      Add-Finding $File $n 'E020' 'chunk without a #| label:'
    }

    $makesPlot = $bodyText -match '\bggplot\s*\(|\bpp_check\s*\(|\bmcmc_\w+\s*\(|\bplot\s*\('
    $makesTable = $bodyText -match '\bkable\s*\(|\bmodelsummary\s*\('

    if ($makesPlot) {
      if ($label -and $label -notmatch '^fig-') {
        Add-Finding $File $n 'E020' "chunk '$label' produces a plot, so its label must start with fig-"
      }
      if ($headText -notmatch '#\|\s*fig-cap:') {
        Add-Finding $File $n 'E020' 'figure chunk without a #| fig-cap:, a label alone is not a cross-reference'
      }
    }
    if ($makesTable) {
      if ($label -and $label -notmatch '^tbl-') {
        Add-Finding $File $n 'E021' "chunk '$label' produces a table, so its label must start with tbl-"
      }
      if ($headText -notmatch '#\|\s*tbl-cap:') {
        Add-Finding $File $n 'E021' 'table chunk without a #| tbl-cap:'
      }
    }
  }

  # --- deck YAML rules -------------------------------------------------------
  if ($isDeck -and $lines[0].Trim() -eq '---') {
    $yaml = @()
    for ($i = 1; $i -lt $lines.Count; $i++) {
      if ($lines[$i].Trim() -eq '---') { break }
      $yaml += $lines[$i]
    }
    $yamlText = ($yaml -join "`n")

    if ($isRenderedDeck) {
      if ($yamlText -notmatch '(?m)^title:\s*"Week \d+:\s') {
        Add-Finding $File 2 'E040' 'deck title must read "Week NN: <topic>", schedule.qmd parses that prefix'
      }
    }
    foreach ($key in @('format', 'author', 'date', 'execute', 'theme')) {
      if ($yamlText -match "(?m)^$key\s*:") {
        Add-Finding $File 2 'E041' "'$key' belongs in slides/_metadata.yml, not in a deck"
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Stage B: real slide-fit measurement
# -----------------------------------------------------------------------------
function Test-SlideFit {
  param([string]$DeckQmd)

  $rscript = Get-RscriptPath
  if (-not $rscript) {
    Write-Host "  [skip] R not found, cannot run the slide-fit stage." -ForegroundColor DarkYellow
    return $true
  }

  $deckName = [System.IO.Path]::GetFileNameWithoutExtension($DeckQmd)
  $siteDir = Join-Path $RepoRoot "website"
  $html = Join-Path $siteDir "_site\slides\$deckName.html"

  Write-Host "  rendering $deckName ..." -ForegroundColor DarkGray
  Push-Location $siteDir
  try {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & quarto render "slides/$deckName.qmd" --quiet 2>&1 | Out-Null
    $rc = $LASTEXITCODE
    $ErrorActionPreference = $prev
  } finally { Pop-Location }

  if ($rc -ne 0 -or -not (Test-Path $html)) {
    Write-Host "  [fail] quarto render failed for $deckName." -ForegroundColor Red
    return $false
  }

  $checker = Join-Path $PSScriptRoot "check-slide-fit.R"
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  # Write-Host, not bare output: anything a PowerShell function emits to the pipeline
  # becomes part of its RETURN VALUE, so the report would vanish into the boolean.
  & $rscript --vanilla $checker $html 2>&1 | ForEach-Object { Write-Host $_ }
  $rc = $LASTEXITCODE
  $ErrorActionPreference = $prev
  return ($rc -eq 0)
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
$targets = @()

if ($Week) {
  $pad = "{0:d2}" -f [int]$Week
  $deck = Join-Path $RepoRoot "website\slides\week$pad.qmd"
  if (-not (Test-Path $deck)) { throw "No deck at website/slides/week$pad.qmd" }
  $targets = @(Get-Item $deck)
} elseif ($Path) {
  if (Test-Path $Path -PathType Leaf) {
    $targets = @(Get-Item $Path)
  } else {
    $targets = Get-ChildItem $Path -Recurse -Include *.qmd, *.md -File
  }
} else {
  $targets = Get-ChildItem $RepoRoot -Recurse -Include *.qmd, *.md -File
}

# Never lint build output, caches, the private submodule, vendored files, or staged
# material ported from the 2026 spring course.
#
# The two staging paths are deliberate holes, not oversights (CLAUDE.md section 7). A ported
# deck sits at website/slides/_weekNN.qmd and a ported homework at homework/_import/hw-NN/
# until it has been converted to STYLE.md. Neither is rendered by Quarto and neither is
# visible to schedule.qmd, so they cannot reach a student. Promoting one (rename the deck to
# weekNN.qmd, copy the homework folder to homework/hw-NN/) moves it back INTO scope, which is
# what makes the conversion checkable.
$targets = $targets | Where-Object {
  $p = $_.FullName -replace '\\', '/'
  ($p -notmatch '/_site/') -and
  ($p -notmatch '/_freeze/') -and
  ($p -notmatch '/\.quarto/') -and
  ($p -notmatch '/\.git/') -and
  ($p -notmatch '_cache/') -and
  ($p -notmatch '_files/') -and
  ($p -notmatch '/solutions/') -and
  ($p -notmatch '/homework/_import/') -and
  ($p -notmatch '/website/slides/_week\d+\.qmd$')
}

foreach ($t in $targets) { Test-File -File $t.FullName }

# @() is load-bearing. Windows PowerShell 5.1 unwraps a one-element pipeline result to a
# bare PSCustomObject, whose .Count is $null, so a run with EXACTLY ONE finding printed no
# finding at all and reported a blank count. A gate that hides findings is worse than no gate.
$sorted = @($script:Findings | Sort-Object File, Line, Code)

if (-not $Quiet) {
  if ($sorted.Count -gt 0) {
    Write-Host ""
    $w = ($sorted | ForEach-Object { "$($_.File):$($_.Line)".Length } | Measure-Object -Maximum).Maximum
    foreach ($f in $sorted) {
      $loc = "$($f.File):$($f.Line)".PadRight($w)
      Write-Host "$loc  $($f.Code)  $($f.Message)"
    }
    Write-Host ""
  }
}

$fitOk = $true
if ($Fit) {
  $decks = $targets | Where-Object { $_.Name -match '^week\d{2}\.qmd$' }
  if (-not $decks) { Write-Host "No decks in scope for the slide-fit stage." -ForegroundColor DarkYellow }
  foreach ($d in $decks) {
    Write-Host "-- slide fit: $($d.Name) --" -ForegroundColor Cyan
    if (-not (Test-SlideFit -DeckQmd $d.FullName)) { $fitOk = $false }
  }
}

$n = $sorted.Count
if ($n -eq 0) {
  Write-Host "check-authoring: clean ($($targets.Count) files)." -ForegroundColor Green
} else {
  Write-Host "check-authoring: $n finding(s) across $($targets.Count) files. See STYLE.md." -ForegroundColor Red
}

if ($n -gt 0 -or -not $fitOk) { exit 1 }
exit 0
