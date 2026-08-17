# Phase 1 Data Model: Single-Test-Per-Function Naming Convention

This feature introduces no runtime data type. The "entities" are the four
file-level merge/rename specifications and the one constitution clause — recorded
here as the exact, concrete operations `tasks.md` implements, derived from reading
each file in full (not by pattern-matching filenames).

## Entity: Merge 1 — `testSolveCobraLP.m` ← `testCharacterizeSolveCobraLP.m`

- **Destination**: `test/verifiedTests/base/testSolvers/testSolveCobraLP.m` (175
  lines). Ends with a `%%`-delimited block (`osenseStr='max'; minNorm='zero'; ...
  optimizeCbModel_param.zeroNormApprox='all'; solution = optimizeCbModel(...);
  assert(solution.f0==1)`) immediately followed by `% change the directory` /
  `cd(currentDir)` — no local functions defined anywhere in the file.
- **Insertion point**: immediately before the final `cd(currentDir)` line (after
  the `assert(solution.f0==1)` block).
- **Appended content**: everything from `testCharacterizeSolveCobraLP.m` between
  its own `cd(fileDir);` line and its own `cd(currentDir);` line — i.e. the
  `tol = 1e-6;` declaration, the `solverPkgs = prepareTest('needsLP', true);` call,
  the `model = buildToyModel(); optProblem = buildOptProblemFromModel(model);`
  setup, and the `for k = 1:length(solverPkgs.LP)` loop (OPTIMAL / INFEASIBLE /
  UNBOUNDED / gurobi-barrier-without-crossover assertions).
- **Local function moved**: `function model = buildToyModel()` (the tiny
  A→R1→B→R2→R3 pathway model), appended after the destination's final
  `cd(currentDir)`.
- **Header update**: destination header's `Purpose:` gains one line noting it now
  also pins the `solveCobraLP` status matrix (optimal/infeasible/unbounded) via a
  characterization block merged from feature 009; `Authors:` gains the feature-009
  attribution alongside the existing 2017 CI-integration credit.
- **Variable-collision analysis**: destination reuses `tol`, `model`, `solverPkgs`
  as names at earlier points in the file, but the insertion point is after every
  read of those variables in the destination's own logic — the appended block's
  reassignment of `tol`/`model`/`solverPkgs`/`optProblem`/`k`/`solverLP`/
  `solverLPOK`/`sol`/`infProblem`/`unbProblem`/`barrierParams`/`sol_barrier*` is
  therefore dead-on-arrival for the rest of the file (there is no "rest of the
  file" except `cd(currentDir)`). Safe by construction (research.md R3).
- **`prepareTest` union**: destination's own `solvers = prepareTest('needsLP',true,'useSolversIfAvailable',...,'excludeSolvers',...)`
  at the top is untouched; the appended block keeps its own
  `prepareTest('needsLP', true)` call immediately before its loop, unchanged.

## Entity: Merge 2 — `testOptimizeCbModel.m` ← `testCharacterizeOptimizeCbModel.m`

- **Destination**: `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`
  (209 lines, uses `iAF1260.mat`, extensively mutates `model.g0`/`model.g1` across
  a long `optimizeCardinality`/norm-minimization assertion sequence). Ends with
  `% change the directory` / `cd(currentDir)` — no local functions defined.
- **Insertion point**: immediately before the final `cd(currentDir)` line.
- **Appended content**: everything from `testCharacterizeOptimizeCbModel.m`
  between its `cd(fileDir);` and `cd(currentDir);` — the `tol`/`objTol` tolerance
  declarations, `solverPkgs = prepareTest('needsLP', true);`, and the per-solver
  loop covering OPTIMAL(max)/OPTIMAL(min)/every `minNorm` strategy (`'one'`,
  `'zero'`, a positive-scalar vector, the QP-gated L2 case)/the
  `'optimizeCardinality'`-without-`model.g0`-errors check/`allowLoops`
  on/off/INFEASIBLE/UNBOUNDED.
- **Local function moved**: `function model = buildToyModel()` (identical toy
  model to Merge 1's, but a separate copy in a separate destination file — no
  cross-file collision since each merge target is distinct), appended after the
  destination's final `cd(currentDir)`.
- **Header update**: destination `Purpose:` gains a line noting the merged
  characterization coverage (status matrix, minNorm strategies, allowLoops,
  dual-quantity presence) from feature 009; `Authors:` gains the feature-009
  attribution.
- **Variable-collision analysis**: destination's `tol = 1e-6` (line 18) matches the
  appended block's own `tol = 1e-6` value exactly, so even without the
  dead-on-arrival ordering these would agree; `model`, `solverPkgs`, `k`, `solverOK`
  are all reassigned by the appended block but only after the destination's own
  last use of them. Safe by construction.
- **`prepareTest` union**: destination's two separate `prepareTest('needsLP',true,'useSolversIfAvailable',...)`
  calls (one per its two solver loops) are untouched; the appended block keeps its
  own `prepareTest('needsLP', true)` call.

## Entity: Merge 3 — `testEntropicFluxBalanceAnalysis.m` ← `testCharacterizeEntropicFBA.m`

- **Destination**: `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`
  (64 lines, uses `Recon3DModel_301.mat` restricted to its stoichiometrically
  consistent subset, `mosek`-only via `requiredSolvers`). Ends with `% change the
  directory` / `cd(currentDir)` — no local functions defined.
- **Insertion point**: immediately before the final `cd(currentDir)` line.
- **Appended content**: everything from `testCharacterizeEntropicFBA.m` between
  its `cd(fileDir);` and `cd(currentDir);` — the `ecoli_core_model.mat` load, the
  `refNormV`/`relTol`/`mbTol` pinned-reference declarations, and the
  `for k = 1:numel(backends)` loop over `{'mosek', 'pdco'}` (skips `mosek` cleanly
  via `exist('mosekopt','file')` rather than `prepareTest`, since it loops both
  backends manually rather than declaring one `prepareTest` requirement set).
- **Local function moved**: none — the characterize file defines no local function.
- **Header update**: destination `Purpose:` gains a line noting the merged
  regression-baseline coverage (`fluxes` method, mosek+pdco, feature 010);
  `Authors:` gains the feature-010 attribution alongside the existing "Creator:
  Yanjun Liu" credit.
- **Variable-collision analysis**: destination uses `model`, `param`, `solution`,
  `solverPkgs` for its own Recon3D run; the appended block reassigns `model`
  (to the ecoli_core toy model), `param`, `solution`, plus new names `d`,
  `refNormV`, `relTol`, `mbTol`, `backends`, `backend`, `k`, `ref`. All reassignment
  happens after the destination's own last read of `model`/`param`/`solution`.
  Safe by construction.
- **`prepareTest` union**: destination's `solverPkgs = prepareTest('requiredSolvers',{'mosek'}, 'needsEP', true);`
  is untouched; the appended block does not call `prepareTest` at all (it checks
  `exist('mosekopt','file')` directly and always has `pdco` available since it's
  built-in) — this is the appended block's own pre-existing skip mechanism,
  unchanged by the merge, still a superset of what it covered before.

## Entity: Rename — `testCharacterizeBuildOptProblemFromModel.m` → `testBuildOptProblemFromModel.m`

- Pure rename, no merge (no existing conventional counterpart — R2). Content
  unchanged except the header's `% The COBRAToolbox: <name>.m` line and the
  `fileDir = fileparts(which('<name>'))` call, both updated to the new function
  name, exactly as this session already did for
  `testCharacterizeBuildGurobiProblemFromModel.m` → `testBuildGurobiProblemFromModel.m`
  in feature 017.

## Entity: Constitution clause — `III-Naming: One Test File Per Function`

- **Location**: new `#### III-Naming: One Test File Per Function` sub-heading
  immediately after the existing `#### III-Characterization: Legacy Back-Fill
  Mode` sub-clause, both under `### III. Testing, Reproducibility, And Continuous
  Integration`.
- **Content** (binding rule, not restating III-Characterization): every test file
  is named `test<FunctionName>.m` where `<FunctionName>` capitalizes only the
  source function's leading character (verbatim otherwise); exactly one test file
  exists per source function; when characterization work needs to pin behaviour of
  a function that already has a test, the new assertions are added to that
  existing file, not a second `testCharacterize<Name>.m`-style file.
- **Governance**: Sync Impact Report block prepended above the existing one(s) at
  the top of `constitution.md`; version `1.4.0` → `1.5.0` (MINOR); `**Last
  Amended**` date updated to 2026-08-17.
