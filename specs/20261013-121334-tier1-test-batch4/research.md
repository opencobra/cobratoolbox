# Research: Tier-1 test coverage batch 4

## Method

1. Second static scan of `src/`: functions whose name appears in no file under `test/` (799 of
   1592). Removed: those that use, directly or through other toolbox functions, a solver,
   file or network I/O, plotting or dialogs, parallel loops, system calls or a MATLAB toolbox
   (591); scripts (71); `old`/`new` backup copies, CVX-based files, demeter suite tests and
   the 18 functions dropped in batch 3. Remainder 160; two files sharing the name
   `Rate_function` are excluded, leaving 158.
2. MATLAB product scan (`matlab.codetools.requiredFilesAndProducts`) for all 158: 155 need only
   base MATLAB; 3 report the Parallel Computing Toolbox (`chrrExpSampler`, `makeSAMMIJson`,
   `makeSAMMIdataString`). They stay in the list and are dropped if the probe shows the toolbox
   is really required.
3. Per-function probe at implementation time (probe-then-write, as in batches 2 and 3): read
   the source, call it in MATLAB with small hand-built input, record current behaviour, then
   write the test. A function that needs a file, solver, toolbox, external data, always errors,
   does not terminate, or has inputs that cannot be understood from the source is dropped and
   reported in `dropped-functions.md`. Functions that call other toolbox functions are
   checked for transitive heavy dependencies the text scan could miss.
4. Name conflicts: a name that also exists as a MATLAB built-in or in `external/` is dropped
   (the probe checks `which -all`).

## Decisions

- **Checkpoint set**: ten small functions with branches (rows 1-10) to validate the style.
- **Rounds**: rows 11-150 are written in rounds of about 20, ordered by folder; after each
  round the tests are run, covered/total measured, and the work committed locally.
- **Large functions** (more than 150 code lines, rows 151-158) come last; one that cannot be
  tested faithfully is reported and left, not weakened.
- **Defects**: recorded in the III-Defects entry format in the header, never asserted; the
  registry is regenerated at the end.
- **Section independence**: variables are defined before the first `%%` section, never carried
  between sections.
- **Tiny functions** (fewer than 8 code lines, no branches) are kept and tested with a short
  file, because they are still untested.
- **File name differs from function name**: `convertATPflux2StepNumer.m` declares
  `convertATPflux2StepNumber` and `sortAtomMappingIdx.m` declares `sortAtomMappingIndexes`.
  MATLAB resolves calls by file name, so the tests call the file name and record the mismatch
  as a cosmetic defect.
