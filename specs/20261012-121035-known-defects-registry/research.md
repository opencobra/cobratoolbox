# Research: Known-defects registry

## Decisions

- **Language**: Python 3 stdlib. Rationale: the repo's CI already runs `python3` for
  `select_tests.py` on the self-hosted runner, the check must not need MATLAB, and the
  parsing is plain text. Alternatives: MATLAB (needs a licence and a slow container start
  for a text check), shell/awk (hard to validate and test), Julia (not on the runner).
- **Source of truth**: the test headers only. Rationale: Constitution III-Defects and
  Principle X; a second hand-written list would drift.
- **Entry shape**: `- DEFECT:` bullet with six labelled fields, continuation lines joined.
  Rationale: easy to write by hand in a MATLAB comment, unambiguous because only the six
  uppercase keywords start a field. Alternative considered: YAML in comments (needs a parser
  dependency and is easy to break by indentation).
- **Strictness**: free text under the heading that is not an entry or `None found.` is an
  error. Rationale: otherwise a defect could be written in prose and silently never reach the
  registry. Tests without `Function under test:` are ignored so the 284 older human tests
  are unaffected.
- **Header-vs-code safety**: the back-fill only edits comment lines. Verification: compare the
  list of non-comment lines of every edited file before and after (must be identical) and
  re-run the 55 tests.
- **CI wiring**: one step in the existing `build` job, placed before the test-selection step so
  it runs for every pull request, including ones where no MATLAB tests are selected. The
  step runs the unit tests and `--check`.
- **select_tests interaction**: a pull request that touches `.github/**` already forces the
  full suite (existing policy); a pull request that changes only the registry or a header is
  handled by the existing selector as before. Nothing in `select_tests.py` is changed.

## Defects to capture (from the batch-2 receipt and the re-read of the pilot tests)

calculateMetrics, calculateFoodScore, compareDiets, searcher, createBIGraph,
numToFormattedString, getDataBases (two entries), parseSBMLAnnotationField, InitialDuplo,
StopCritBDCA, StopCritDuplo, Combination (two entries: k = 0 and negative parameters
printing), getInchiData (negative charge), buildRxnEquationsFromName, makeColorGradient,
combineChildren, checkInputData (header listed; equal headers skip removal),
editChemicalFormula (zero count), parseMetNames, getDefaultValue. The registry-only
documentation items removeSmilesInchiKey (external converter) and hyperlink (desktop-only
line) are coverage exemptions, not defects, but the spec lists them; each gets a
`limitation` entry because the function cannot be exercised fully without external
resources. The pilot tests are re-read in the first task of the back-fill.
