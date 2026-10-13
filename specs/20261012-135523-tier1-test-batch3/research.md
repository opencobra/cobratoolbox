# Research: Tier-1 test coverage batch 3

## Method

1. Static scan of all toolbox functions that no test mentions (see the spec): unique name
   (also against `external/`), function name equals file name, plain-data arguments, none of
   the file, display, system, network, solver or random-number calls; `exist` allowed unless it
   looks up files or folders. Result: 74 candidates (about 460 excluded for I/O or display,
   about 140 take a model, about 70 depend on solvers or toolbox state).
2. MATLAB product scan (`matlab.codetools.requiredFilesAndProducts`) for all 74: 69 need only
   base MATLAB; 5 report the Parallel Computing Toolbox (`calcMDVfromSamp`, `score_KS`,
   `removeMapMol`, `makeSAMMIparseVector`, `runHiLoExp`). They are kept in the list but are
   dropped if the per-function probe shows the toolbox is really required.
3. Per-function probe at implementation time (probe-then-write, as in batch 2): read the
   source, call it in MATLAB with small hand-built input, record current behaviour, then write
   the test. A function that turns out to need a file, model, solver, toolbox or display is
   dropped and reported. Reason for probing per function rather than all up front: the expected
   values and the assertions that use them must be fixed together.

## Decisions

- **Checkpoint set**: the ten smallest functions without a toolbox flag (listed in tasks.md),
  to validate the style quickly.
- **Large functions** (more than 150 code lines) come last; one that cannot be tested
  faithfully is reported and left, not weakened.
- **Defects**: recorded in the III-Defects entry format in the header, never asserted; the
  registry is regenerated at the end.
- **Section independence**: variables are defined before the first `%%` section, never carried
  between sections (a problem found in earlier batches).
- **No reserves**: the candidate pool is exhausted by this list; a drop reduces the count.
