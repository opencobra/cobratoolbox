# Quickstart / Validation Guide

How to validate the feature locally and in CI. (Run guide only — implementation lives in
`tasks.md`.)

## Prerequisites

- MATLAB R2024b+ (dev host here: R2026a with only M2HTML + Matrix Computation toolboxes — this is
  useful, because most solver/toolbox-gated tests will *skip* locally, exercising the skip path).
- For coverage: MoCov + jsonlab checked out somewhere; `MOCOV_PATH` / `JSONLAB_PATH` env vars set.

## Scenario A — Requirement gating skips gracefully (US2, SC-002, SC-005)

1. Pick a backfilled test that needs a solver the host lacks (e.g. an EP-solver test such as
   `test/verifiedTests/base/…/testEntropicFluxBalanceAnalysis.m`, or any LP test with no LP
   solver configured).
2. Run it via the harness (or directly): it should raise `COBRA:RequirementsNotMet` and be
   reported **Skipped**, not Errored.
   - Expected: in the `runTestSuite`/`testAll` summary the test appears under "The following
     tests were skipped", and `sumFailed` does not include it.
3. Configure the required solver (e.g. `changeCobraSolver('gurobi','all')` where available) and
   re-run: the test now **runs and passes exactly as before** (assertions unchanged).
   - MCP check: `mcp__matlab__run_matlab_test_file` on the single test in each state.

## Scenario B — Coverage is produced (US1, SC-001, SC-006)

1. Set `MOCOV_PATH` and `JSONLAB_PATH`, then run `test/testAll.m` (or a small subset).
2. Expected console line: `Covered Lines: <c>, Total Lines: <t>, Coverage: <p>%` (`testAll.m:290`).
3. Expected files in the run root: `coverage.json`, `coverage_html/`, and the new
   `coverage.xml` (Cobertura).
4. In CI: the `coverage.xml` + `coverage_html/` are uploaded as an artifact **regardless** of
   Codecov; the Codecov step is `continue-on-error` with `fail_ci_if_error: false`, so a missing
   token or a Codecov outage does not fail the build.

## Scenario C — Skip-count gate warns, never fails (US3, SC-003)

1. After a run, `testReport.junit.xml` contains `skipped="<n>"`.
2. The skip-gate CI step compares `<n>` to `test/verifiedTests/.skip-baseline.json`'s
   `maxSkipped`.
3. Force `<n> > maxSkipped` (e.g. lower the baseline, or remove a solver): expect a GitHub
   `::warning::` annotation and a **green** build (exit 0).
4. With `<n> ≤ maxSkipped`: no warning, build unaffected.

## Regression checks (SC-004, FR-009)

- The CTRF pass/fail PR comment is still produced (`testAllCI_step2.yml` unchanged).
- No test's pass/fail outcome changes when its required resources are present.
- `git diff` touches only `.github/workflows/`, `test/testAll.m` (one additive `mocov` arg),
  `test/verifiedTests/**` (added `prepareTest` calls + `.skip-baseline.json`), and the feature's
  `specs/` planning artifacts. No `src/` scientific code.

## Definition of done (feature-level)

All of SC-001..SC-006 observed: coverage %/artifact present, 0 solver-absence errors (all
skipped), skip count reported + baseline-compared (warn only), no pass/fail regression,
reproducibility scenario A passes, coverage runtime within the research.md bound.
