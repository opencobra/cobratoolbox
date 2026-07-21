# Implementation Receipt

**Feature**: 009-fba-characterization-statusmap
**Run (UTC)**: 20260715T152500Z
**Scope**: PARTIAL — Part 1 (LP characterization net) complete + the in-scope `:911` defect-fix +
the flagship Part 2 consolidation (dqq). Remaining Part 2 (QP/MILP/MIQP status-map consolidation)
paused by user decision.

## Prompt

Human-loop orchestrated run for feature 009. User invoked `/speckit-implement` (Principle VI
authorization), chose "both parts in 009" at clarify, chose "continue to Part 2 now" at the T007
gate, chose to "fix :911 now, folded into 009" when the net caught a latent bug, and chose to
"commit this increment, pause rest" at the Part 2 checkpoint.

## Final response

009 partial implementation committed — a complete, verified increment; the remaining QP/MILP/MIQP
consolidations are paused.

Delivered and verified (via the MATLAB MCP, R2026a, gurobi):
- Part 1 LP characterization net — 3 tests green: testCharacterizeOptimizeCbModel (status matrix,
  all minNorm modes, both senses, allowLoops, primal+dual), testCharacterizeBuildOptProblemFromModel,
  testCharacterizeSolveCobraLP.
- FR-013 defect-fix: solveCobraLP.m:911 `param` -> `gurobiParam` on the gurobi INF_OR_UNBD retry —
  the latent bug the net caught (crashed on R2026a gurobi for unbounded LPs). Gurobi now returns a
  clean stat==2. Verified.
- Part 2 flagship consolidation: new src/base/solvers/statusMapping/mapSolverStatus.m (dqq/quadMinos
  LP map, behavior-exact; clean check_matlab_code) + exhaustive testMapSolverStatus.m unit test
  (green). Both dqqStatMap duplications in solveCobraLP.m (:419 & :555) replaced by
  mapSolverStatus calls — the map that appeared verbatim twice in one file is now single-sourced.
  The live gurobi net stayed green after the edit.

Not done (paused): T010 remainder (lp_solve/gurobi-block LP — lp_solve not installed; gurobi LP is
control-flow not a pure map), T011 (QP cplex×3), T012 (MILP), T013 (MIQP), T014 (dispatcher
check_matlab_code), T015-T016 (full quickstart + scope check). These are guarded mostly by unit
tests since cplex/tomlab are not installed here.

Backward-compat held: optimizeCbModel.m and buildOptProblemFromModel.m UNCHANGED; no interface or
model-field change. Not pushed.

## Diff summary

- M `src/base/solvers/solveCobraLP.m` — (1) `:911` `param`→`gurobiParam` (FR-013 fix); (2) both
  `dqqStatMap` literals (28 duplicated lines) replaced by `mapSolverStatus(solver,'LP',sol.inform)`.
- A `src/base/solvers/statusMapping/mapSolverStatus.m` — new canonical status-map helper (dqq LP).
- A `test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/testCharacterizeOptimizeCbModel.m`
- A `test/verifiedTests/base/testSolvers/testCharacterizeBuildOptProblemFromModel.m`
- A `test/verifiedTests/base/testSolvers/testCharacterizeSolveCobraLP.m`
- A `test/verifiedTests/base/testSolvers/testMapSolverStatus.m`
- A `specs/009-fba-characterization-statusmap/**` (spec + plan + research + data-model + quickstart +
  tasks + checklists + implementation-review + human-loop + this receipt)
- M `.specify/feature.json` (009 pointer)
- UNCHANGED: `optimizeCbModel.m`, `buildOptProblemFromModel.m`, `mosek/parseMskResult.m`.

## Tests

Run via MATLAB MCP (R2026a, gurobi active):
- testCharacterizeOptimizeCbModel — PASS
- testCharacterizeBuildOptProblemFromModel — PASS
- testCharacterizeSolveCobraLP — PASS (still green after the solveCobraLP.m edits)
- testMapSolverStatus — PASS (exhaustive dqq map)
- check_matlab_code(mapSolverStatus.m) — clean (0 issues)
- Verified the `:911` fix directly: unbounded LP under gurobi returns stat==2 (was a crash).

Not yet run: full quickstart V1–V6; existing testOptimizeCbModel/testSolveCobraLP/testSolveCobraLPCPLEX
regression (deferred with the paused Part 2).

## Unresolved issues

- Remaining Part 2 (QP/MILP/MIQP status-map consolidation) paused — larger grind, mostly
  unit-test-guarded (cplex/tomlab not installed); MILP/QP/MIQP would want their own char tests.
- `106 || 106` MILP/MIQP quirk (research R1 D1) — untouched; preserve verbatim when those maps are
  consolidated; candidate follow-up defect.
- The Part-1 net exercises only gurobi in this env; F1 (make the non-gurobi map coverage exhaustive
  in testMapSolverStatus) applies as the QP/MILP/MIQP maps are added.
- Not pushed.
