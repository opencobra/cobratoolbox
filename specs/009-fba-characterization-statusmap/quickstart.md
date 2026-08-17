# Quickstart / Validation Guide: LP/FBA characterization net + mapSolverStatus

How to prove the feature works. Unlike a docs feature, this runs MATLAB — use the MATLAB MCP
(`run_matlab_test_file`, `run_matlab_file`, `check_matlab_code`). CI solver is gurobi; other
solvers skip cleanly. Run from repo root after `initCobraToolbox`.

## Prerequisites

- On branch `009-fba-characterization-statusmap`, implementation applied.
- An LP solver available (gurobi in CI); a QP solver for the `needsQP` cases (else those skip).

## V1 — Part 1 net exists and pins behavior (FR-001…005, SC-001/002/003)

1. Run `testOptimizeCbModel` via the MATLAB MCP; confirm it passes and exercises the
   status matrix, all `minNorm` strategies, both senses, allowLoops, and primal+dual.
2. Run `testBuildOptProblemFromModel` and `testSolveCobraLP`; confirm pass.
3. **Perturbation check (SC-001):** temporarily change one pinned reference (or nudge a fixture)
   and confirm the suite FAILS — proving the net actually pins behavior. Revert.

## V2 — Clean skip when a solver is absent (FR-006, US1-5)

1. Confirm every new test declares `prepareTest('needsLP'|'needsQP', ...)`.
2. On a machine lacking QP, confirm the QP/L2 cases skip (`COBRA:RequirementsNotMet`), not error.

## V3 — Part 1 does not change the functions under test (FR-007)

1. `git diff` shows NO change to `optimizeCbModel.m` or `buildOptProblemFromModel.m` after Part 1.

## V4 — mapSolverStatus exists and reproduces the maps (FR-008, SC-004)

1. `test -f src/base/solvers/statusMapping/mapSolverStatus.m`.
2. Run `testMapSolverStatus`: feed representative native codes per (solver, problemType) and assert
   the canonical `.stat` matches the pre-refactor mapping (including the `106||106` quirk).
3. `check_matlab_code` on the helper: clean (openCOBRA header, no shadowing, warnings visible).

## V5 — Refactor is behavior-preserving (FR-009/010/011, SC-005/006)

1. With V1 green, apply Part 2 (extract + reroute) and re-run the Part-1 suite: it MUST stay green
   with the SAME pinned `.stat`/`.origStat` for every case.
2. Confirm the duplicated map literals are gone: `grep -n dqqStatMap src/base/solvers/solveCobraLP.m`
   shows the table removed from the dispatcher; the cplex if-blocks in QP/MILP/MIQP no longer repeat.
3. Existing solver tests still pass: `testOptimizeCbModel`, `testSolveCobraLP`, `testSolveCobraLPCPLEX`.
4. `git diff` shows no signature/field change in `solveCobra*`, no change to `changeCobraSolver`.

## V6 — Scope / gate-safety

1. Diff confined to `src/base/solvers/**` (4 dispatchers + new `statusMapping/`) and
   `test/verifiedTests/**` and `specs/009-.../**`.
2. No change to `mosek/parseMskResult.m`, the lindo dead block, `.origStat` mutation (W16), or any
   W1/W5/W17 target.

## Done when

V1–V6 pass and the constitutional implementation receipt is written under
`specs/009-fba-characterization-statusmap/agent-runs/<UTC-timestamp>-<short-name>/`.
