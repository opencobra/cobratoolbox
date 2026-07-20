# Data Model — testAll performance modes

This feature has no persistent data store; the "entities" are small in-memory /
config concepts and regenerable artifacts.

## Test execution mode

- **Values**: `fast` (default) | `full`.
- **Resolution** (highest precedence first): `COBRA_CI=1` → `full`; global
  `CBT_TEST_MODE`; env `COBRA_TEST_MODE`; else `fast`.
- **Validation**: any value other than `fast`/`full` (case-insensitive) → error
  `COBRA:testMode:invalid` with the accepted values.
- **Consumers**: `getCobraTestMode` (resolver), `prepareTest` (solver breadth),
  individual tests with hardcoded solver lists, `testAll.m` (reporting header).
- **Invariant**: full mode ⇒ pre-feature behaviour exactly (no trimming applied).

## Solver-selection request (input to `prepareTest`)

- **Existing fields** (unchanged contract): `requiredSolvers`,
  `useSolversIfAvailable`, `requireOneSolverOf`, `needsLP/MILP/QP/...`,
  `useMinimalNumberOfSolvers`.
- **New behaviour**: when mode = fast AND the caller did not explicitly request
  multiple solvers, `prepareTest` behaves as `useMinimalNumberOfSolvers=true`
  (returns the default solver per class). An explicit multi-solver request
  (`requiredSolvers`/`useSolversIfAvailable`) or an explicit cross-solver opt-out
  overrides this and returns the full set in both modes.
- **Output** (unchanged shape): struct with one cell-array field per solver class
  (`LP`, `MILP`, `QP`, ...). Fast mode → single-element cells for
  solver-independent tests; full mode → all available.

## Per-test timing record (already produced)

- **Source**: `runTestSuite` → `resultTable` with columns
  `TestName, Status, Passed, Skipped, Failed, Time, Details` (per `runScriptFile`
  wall-clock via `etime`). No change to this structure.
- **Use**: the profiling report sorts by `Time` descending to rank slowest tests.

## Performance report artifacts (regenerable, gitignored)

- **`testTiming.csv`**: rows of `{rank, test, status, time_s}` sorted slowest-first.
- **Profiler hotspots**: `profile('info')` saved (`.mat`) + `profsave` HTML tree;
  top-N functions by total time printed and/or written.
- **Location**: `test/performance/` (added to `.gitignore`). Written only when the
  performance option is enabled; absence is normal.
- **Invariant**: producing (or failing to produce) these artifacts never changes any
  test's pass/fail/skip outcome.
