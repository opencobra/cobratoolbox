# Research: lrsRun without the separate redund program

## R1. Does lrs remove redundancy itself?

- **Decision**: yes; append the option line `redund 0 0` to the H-representation and run `lrs`.
- **Rationale**: lrslib's user guide documents `redund start end` as an lrs option (0 0 = all rows).
  Since lrslib 7, `redund` is the same program as `lrs`: on Debian/Ubuntu `/usr/bin/redund` is a
  symbolic link to `lrs`. Checked 2026-11-20 with the installed lrs 7.1 and with COBRA's bundled
  `binary/glnxa64/bin/lrs/lrs` (7.3, which ships no `redund`). On four inputs, `redund` and `lrs` with
  the option gave the same rows and the same `linearity` line:
  - the quadrant of testLrsRun (3 rows to 2);
  - a two-variable example (4 rows to 2);
  - an lrs facet-enumeration output of a square, with `*` comment lines after `end`;
  - a 3-D example with `linearity 1 1` and redundant rows (7 rows to 5).
- **Alternatives considered**:
  - Keep calling `redund` and declare it: CI and COBRA's own Linux binaries lack it; this is
    rejected by Principle XI (option 2 is feasible).
  - Remove redundancy in MATLAB with an LP per row: needs a solver and floating point instead of
    lrs's exact arithmetic; rejected (option 2 comes before option 3).
  - Ship a `redund` link in `binary/`: `binary/` is a submodule outside this feature, and a link
    does not help users with their own lrs.

## R2. Where does the option go, and how is the input prepared?

- **Decision**: copy lrs's facet output, after `lrsSpecifyRows` has written the row count, to a
  temporary file `[tempname '.ine']`, then append a newline (if the text does not end with one) and
  `redund 0 0`. Run `lrs <copy> > <m>_noR.ine` with absolute paths, as the other calls. Delete the
  copy through an `onCleanup` object, so it is removed on success and on error.
- **Rationale**: lrs reads options after `end`, and comment lines in between are ignored (checked
  with an lrs output carrying `*Totals` lines). A copy leaves lrs's facet output `<m>.ine` unchanged
  (the spec, FR-003). A file in the system temporary folder cannot collide with the user's files.
  The bundled lrs 7.3 crashes on the unspecified count `*****`; `lrsSpecifyRows` already runs before
  this step.
- **Alternatives considered**:
  - The existing `sed -i 's/end/end\nredund 0 0/g'` route: it edits the file in place, replaces every
    occurrence of `end` (for example inside a comment or a name), and needs GNU sed. Rejected and
    removed.
  - Editing `<m>.ine` in MATLAB: it still changes a file callers and the test read.

## R3. Output differences that readers might see

- **Decision**: none that matter. With the option, lrs 7.1 also writes the echo line
  `redund  1 <n>` before `H-representation` and `*` comment lines after `end`; 7.3 writes no echo.
  `lrsReadHalfspace` reads the `linearity` line and the rows between `begin` and `end`, and
  testLrsRun's reader reads between `begin` and `end`; neither is affected. `redund` itself writes
  the same layout.
- **Callers**: no function in `src/` calls lrsRun with `redund = 0`; `extremePools`, the only
  caller, uses the default `redund = 1`.

## R4. lrslib version

- **Decision**: lrslib 7.0 or later (2018) is assumed, as bundled by COBRA (7.3) and shipped by
  current Linux distributions. On those versions `redund` is `lrs` itself, so nothing that worked
  with `redund` stops working.

## R5. External-solver configuration audit (Principle IV)

- No optimisation solver is invoked. lrs is run with its defaults (exact/hybrid arithmetic); the only
  option added is `redund 0 0` (check every row), the same work `redund` did with its defaults.
