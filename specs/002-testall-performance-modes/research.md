# Research — testAll performance modes

Consolidates the measured analysis (session scratchpad: `testAll-performance-report.md`,
`slowTests_ranked_full.csv`, live profiler run) into design decisions.

## Measured baseline

- Instrumented full run: 235 tests, **824.8 s** total, 28 skipped, 10 fail/error.
- Highly concentrated: top 5 = 33%, top 10 = 51%, top 20 = 70% of runtime.
- Live 4-test profile: `solveCobraLP` = 198 s of 268 s (4,427 calls). `testGpSampler`
  ranged **12 s → 147 s** depending only on whether glpk was in its solver loop.
- Broken today (independent of this feature): `testFVA` (FAIL), `testdynamicRFBA`
  (ERROR). Must remain visibly broken in fast mode (FR-007), not masked.

## Decision 1 — Mode resolver

**Decision**: New `src/base/install/getCobraTestMode.m` returns `'fast'` or `'full'`.
Resolution order: (1) `COBRA_CI=1` → `'full'` always (FR-012); (2) global/workspace
override `CBT_TEST_MODE` if set to a valid value; (3) env var `COBRA_TEST_MODE`
(`fast`/`full`); (4) default `'fast'`. Invalid values → error with guidance (edge case).

**Rationale**: Mirrors the existing `COBRA_CI` env-var idiom in `testAll.m`; one
resolver read the same way by `testAll.m`, `prepareTest`, and individual tests.
CI-forces-full is encoded once, centrally, so it cannot be bypassed per test.

**Alternatives**: A single global variable only (rejected — no CI override path,
easy to leave stale between runs); a `testAll('fast')` argument (rejected — `testAll`
is a script, and individual tests can't see a script argument).

## Decision 2 — Solver-loop trimming via `prepareTest`

**Decision**: In fast mode, `prepareTest` returns the **minimal (default) solver per
class** — equivalent to its existing `useMinimalNumberOfSolvers=true` — UNLESS the
caller explicitly requests multiple solvers (`requiredSolvers`, `useSolversIfAvailable`,
or a new explicit `allSolvers`/`crossSolver` opt-out). Tests that already consume
`prepareTest`'s returned lists in a `for` loop then collapse to one iteration
automatically. Full mode behaviour is unchanged.

**Rationale**: `prepareTest` already documents and implements
`useMinimalNumberOfSolvers` for exactly this situation ("tests which only use FBA to
generate input… only validate on one solver"). Reusing it is minimal, central, and
low-risk, and it preserves cross-solver tests that opt in via `requiredSolvers`.

**Alternatives**: A brand-new solver-list helper every test must call (rejected —
more churn than reusing `prepareTest`'s existing contract); trimming inside
`runTestSuite` (rejected — it has no visibility into which solvers a test's
assertions depend on).

**Coverage note**: tests in `test/verifiedTests/base/testSolvers/*` (whose purpose is
cross-solver agreement) request all solvers explicitly and therefore keep looping in
both modes (FR-005). This is what bounds the coverage drop.

## Decision 3 — Tests that hardcode multi-solver lists

**Decision**: Some slow tests set e.g. `solverPkgs = {'gurobi','tomlab_cplex','glpk'}`
directly rather than via `prepareTest` (e.g. `testGpSampler`,
`testSimulatePairwiseInteractions`). Give each a small mode-aware edit: in fast mode
reduce the list to the single class default (via `getCobraTestMode` +
`CBT_*_SOLVER`); in full mode keep the original list. Assertions unchanged.

**Rationale**: These are among the biggest wins (testGpSampler solver breadth caused
the 12→147 s swing) and cannot be reached through `prepareTest` because they bypass it.

## Decision 4 — Non-solver, per-test speedups (mode-guarded)

From the per-test analysis, apply only coverage-preserving changes, each guarded so
full mode is unchanged:

- **Large SBML → .mat**: where a `.mat` equivalent exists, load it in fast mode
  instead of re-parsing multi-MB XML (e.g. `testModelBorgifier` iIT341; `testWriteSBML`
  capture the struct from the first write instead of re-serialising). Full mode keeps
  the XML path for parse coverage.
- **Dead waits**: remove `pause(3)` in `testMultiProductionEnvelopeInorg` (safe in
  both modes — pure wall-time, no assertion depends on it).
- **Plot-only / unasserted work**: in fast mode skip figure rendering and unasserted
  extra envelope/gene-deletion computations whose outputs are never checked.
- **Duplicated model builds**: `testSimulatePairwiseInteractions` and
  `testJoinModelsPairwiseFromList` build the same 5 models / 10 pairs; in fast mode
  reduce `modelList` (e.g. 5→3) — still exercises every join/interaction branch.

**Rationale**: Each removes redundant work while keeping the exercised code paths;
`pause` removal is unconditional because it adds nothing in any mode.

## Decision 5 — Profiling report (opt-in)

**Decision**: In `testAll.m`, after `runTestSuite`, if a `COBRA_PERF=1` (or global)
flag is set, write a ranked per-test timing CSV and a profiler hotspot report
(`profsave` HTML + top functions from `profile('info')`, which `testAll` already
enables) to `test/performance/`, and print the slowest tests. Wrapped in try/catch
that warns; never alters pass/fail (FR-009). Off by default.

**Rationale**: Surfaces data already collected (`resultTable.Time`, live profiler);
validated by the scratchpad prototype `profileTestSubset.m`. Independent, low-risk
slice — can ship separately from the speedups.

## Decision 6 — CI and the 001 coverage gate

**Decision**: CI (`COBRA_CI=1`) always runs full mode (Decision 1), so the
`001-ci-coverage-gating` coverage and skip baselines continue to measure the complete
suite and need no re-baselining. Fast mode never feeds the gate.

**Rationale**: Keeps the two features decoupled; avoids re-calibrating the gate and
avoids fast mode tripping it. Matches the clarify answer.

## Open items for tasks

- Enumerate the exact bounded set of test files to edit (from the ranked CSV), and
  mark for each whether it is `prepareTest`-driven (auto) or hardcoded (manual edit).
- Confirm each candidate's assertions are solver-independent before trimming.
- Decide the representative-subset used by the quickstart fast-vs-full check.
