# Data Model / Contracts: LP/FBA characterization net + mapSolverStatus

No runtime data model. The "entities" are the function contract introduced, the characterization
axes/fixtures pinned, and the new/edited files. Exact per-code maps are transcribed from the
current source during implementation (research.md R1); the tables below define the shape.

## E1 — `mapSolverStatus` contract (NEW, `src/base/solvers/statusMapping/mapSolverStatus.m`)

```matlab
function [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)
% Map a solver's native status code to the COBRA canonical solution status.
%
% USAGE:
%    [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)
%
% INPUTS:
%    solver:        solver name (as in changeCobraSolver), e.g. 'gurobi','ibm_cplex','dqqMinos'
%    problemType:   'LP' | 'QP' | 'MILP' | 'MIQP'
%    origStat:      solver-native status code (numeric or string, as returned by the solver)
%
% OUTPUTS:
%    stat:          canonical status: 1 optimal, 0 infeasible, 2 unbounded,
%                   3 feasible-but-not-proven-optimal/numerical, -1 other
%    origStatText:  human-readable native status text where the current code produces one
%                   (e.g. dqq); '' otherwise
%
% Author: (generated for feature 009; behaviour transcribed verbatim from
%          solveCobra{LP,QP,MILP,MIQP}.m — see specs/009-.../research.md R1)
```

- **Contract**: for every (solver, problemType, origStat) currently handled inline, returns the
  IDENTICAL canonical `stat` (and, where applicable, `origStatText`) that the current dispatcher
  produces — including the `106||106` quirk and every fallthrough `-1`. Unknown/unmapped native
  codes return the same fallback the current site uses (no swallowed states).
- **Purity**: does not read/write globals, does not mutate `.origStat`, no side effects, warnings
  visible; `try/catch` (if any) propagates `ME.stack`.

## E2 — Edited dispatchers (status-map call sites ONLY)

| File | Sites rerouted (research.md R1) | Unchanged |
|------|--------------------------------|-----------|
| `solveCobraLP.m` | dqqStatMap (:419,:555 dup), lp_solve (:661), gurobi block | mosek (`parseMskResult`), glpk, lindo dead block, `.origStat` mutation (:1616) |
| `solveCobraQP.m` | cplex-family block ×3 (:218,:268,:325), qpng (:375) | everything else |
| `solveCobraMILP.m` | cplex ×3 (:209,:302,:469), gurobi (:274), glpk (:149) | everything else |
| `solveCobraMIQP.m` | cplex ×2 (:127,:305), gurobi ×2 (:203,:268) | everything else |

Each site: replace the inline map/if-block with `stat = mapSolverStatus(solver, '<TYPE>', origStat)`
(and `origStatText` where produced), preserving the surrounding `solution.stat`/`.origStat`
assignment exactly.

## E3 — Characterization axes (Part 1, pinned within tolerance)

| Axis | Values pinned | Function |
|------|---------------|----------|
| status matrix | optimal(1), infeasible(0), unbounded(2), numerical(3 where reproducible) | optimizeCbModel, solveCobraLP |
| minNorm | 0/[], 'one', 'zero'(each zeroNormApprox), weighted vector, 'optimizeCardinality' | optimizeCbModel |
| osense | 'max', 'min' | optimizeCbModel |
| allowLoops | true, false | optimizeCbModel |
| quantities | `.stat`(exact), `.f`/objective, `‖S·v−b‖` residual, duals `.w`,`.y`, primal `.v`/`.x` (tol) | optimizeCbModel |
| model→problem | LP and QP problem construction | buildOptProblemFromModel |

## E4 — Fixtures (research.md R2)

- Tiny purpose-built toy model(s) constructed in-test: feasible (optimal), contradictory-bounds
  (infeasible), unbounded-objective (unbounded); L2 minNorm variant → QP (needsQP).
- Reference values captured from CURRENT code via the MATLAB MCP; stored as literals or
  `ref_*.mat` beside each test; `rng` fixed; `tol` justified (e.g. 1e-6 continuous, exact int stat).

## E5 — Test files (NEW)

- `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`
- `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`
- `test/verifiedTests/base/testSolvers/testSolveCobraLP.m`
- `test/verifiedTests/base/testSolvers/testMapSolverStatus.m` (Part 2 unit — feed native codes, assert canonical)

## Backward-compatibility / gate-safety contract

- No change to `changeCobraSolver`, `solveCobra*` signatures, or returned solution fields
  (`.stat`,`.origStat`,`.full`,`.obj`, duals) — Principle II.
- Existing `testOptimizeCbModel.m`, `testSolveCobraLP.m`, `testSolveCobraLPCPLEX.m` MUST still pass
  unchanged after Part 2.
