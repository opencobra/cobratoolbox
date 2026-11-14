# Research: Fix the R2026a fast-mode suite failures

All findings below were measured on 2026-11-12 in MATLAB R2026a Update 3 (`26.1.0.3276743`), on branch
`20261107-133937-r2026a-test-failures` after merging `upstream/develop` `5200aad48` (merge `1357a49ec`).
That machine has no Optimization Toolbox; glpk, gurobi and mosek are installed.

## R0. Upstream status (checked before planning)

- **Decision**: none of the six failures, nor the worktree finding, is fixed upstream; the scope stands.
- **Rationale**: `upstream/develop` @ `5200aad48` (PRs #2721-#2724) touches neither the six tests nor
  `initCobraToolbox.m`. Upstream's own run records show `testExtractBondSubgraphs` and
  `testClassifySubgraphIsomorphism` failing (R2025a) and deliberately left alone; `testFitC13Data` and
  `testOptimizeCbModelNLP` are only skipped there because CI uses default-mode start-up. Upstream
  `testFitC13Data.m:20` still reads `solverPkgs`; `initCobraToolbox.m` still requires `.git` to be a folder.

## R1. Agent-mode solver availability (FR-001)

- **Decision**: in agent mode, mark each of glpk, pdco, mosek and matlab installed and working only when the same
  local predicate that `changeCobraSolver` uses for that solver holds:

  | Solver | Predicate (from `changeCobraSolver.m` installation switch) |
  |---|---|
  | glpk | `exist('glpkmex', 'file') >= 2` |
  | mosek | `exist('mosekopt', 'file') >= 2` |
  | pdco | `exist('pdco', 'file') >= 2` |
  | matlab | Optimization Toolbox listed by `ver('optim')` and `license('test', 'Optimization_Toolbox')` |
  | gurobi | unchanged: `~isempty(which('gurobi'))` |

  The default EP, CLP and NLP solvers (`CBT_EP_SOLVER`, `CBT_CLP_SOLVER`, `CBT_NLP_SOLVER`) are set only when that
  solver passed its check; otherwise they stay empty, as after default start-up with that solver missing.
- **Rationale**: the predicates are the ones default mode already trusts, so agent and default modes agree on what
  is installed (FR-003 untouched). None calls the network, checks out a license or solves a problem (FR-001).
  Measured cost: `ver('optim')` 0.018 s, `license('test', ...)` 0.002 s, the three `exist` calls 0.054 s together,
  about 0.07 s in all (SC-002 allows 1 s). The matlab predicate ignores `linprog`, so mosek's own `linprog` on the
  path cannot make the matlab solver look installed (spec edge case).
- **Alternatives considered**: (a) `changeCobraSolver(name, type, 0, 1)` as default mode does. Rejected because it
  solves a validation problem and is the slow step agent mode exists to avoid. (b) `exist('fmincon')`. Rejected
  because `fmincon` sits in `toolbox/shared/optimlib`, which can exist without an Optimization Toolbox license.
  (c) A new shared helper file. Rejected under Principle V: a local function in `initCobraToolbox.m` is enough.
- **Runtime note**: `runmat` mode follows the agent flow. `ver` and `license` are MATLAB built-ins used unchanged,
  so this is not a runtime workaround under constitution VIII-Runtime; their RunMat behaviour is checked in the
  quickstart and, if RunMat lacks them, raised as a new defect rather than worked around here.

## R2. Thermochemistry `new/` folders in agent mode (FR-002)

- **Decision**: in agent mode, remove from the path every entry under the thermochemistry base folder (the folder
  that holds `vonBertalanffy/initVonBertalanffy.m`) whose name contains `<filesep>new`, by filtering the current
  path string. Do this silently; no disk walk.
- **Rationale**: default mode runs `addpath(genpath(basePath))` and then `editCobraToolboxPath(basePath,
  [filesep 'new'], 'remove')`, which removes every folder under `basePath` that contains `<filesep>new`. Agent
  mode has already added all of `src/` with `genpath`, so the on-path entries under `basePath` are exactly the
  `genpath` set. The same pattern applied to the same base gives the same result. This session had 6 such folders
  on the path after agent start-up. Filtering the path string avoids the recursive `dir` and the `disp` lines of
  `editCobraToolboxPath`, which agent mode must not print.
- **Alternatives considered**: calling `editCobraToolboxPath` from agent mode. Rejected because it walks the disk
  and prints one line per folder. Not adding the `new/` folders in the first place would change the shared
  `genpath` loop that default mode also uses (FR-003).

## R3. `testFitC13Data` undefined name (FR-004)

- **Decision**: line 20 reads `solvers.LP{1}` (the value `prepareTest` returns), not `solverPkgs.LP{1}`.
- **Rationale**: lines 44-45 already use `solvers.NLP{1}` and `solvers.LP{1}`; `solverPkgs` is defined nowhere.

## R4. Error parity across MATLAB releases (FR-005)

Six recorded error cases exist in total. Their state on R2026a:

| Test, case | Recorded (R2024b) | R2026a | Same failure? |
|---|---|---|---|
| extract, fallback `duplicateAtomIndex` | `MATLAB:sizeDimensionsMustMatch` | identical | yes, unchanged |
| extract, fallback `nonIntegerAtomIndex` | `MATLAB:sizeDimensionsMustMatch` | identical | yes, unchanged |
| extract, fallback `namedBIGNodes` | `MATLAB:UndefinedFunction`, "Undefined function 'eq' for input arguments of type 'cell'." | `MATLAB:math:mustBeNumericCharOrLogical`, "Invalid data type. Argument must be numeric, char, or logical." | yes: `==` on a cell array, `extractBondSubgraphs.m:458`; R2026a raises this identifier for `{'a'} == 1` |
| extract, peeling `atomBeyondBIG` | `MATLAB:graphfun:digraph:InvalidNodeID` | identical | yes, unchanged |
| classify, error case 1 | `MATLAB:table:IllegalVarSubscript`, "Table variable names must be strings or character vectors." | `MATLAB:table:IllegalMultipleVarDotSubscript`, "Dot subscripting on a table extracts one variable ..." (R2025a, upstream record: same identifier, message "A table variable name must be a string scalar or a character vector.") | yes: dot-subscripting a table with a non-name, raised in the table class `dotReference` |
| classify, error case 2 | `MATLAB:table:UnrecognizedVarName` | identical | yes, unchanged |

- **Decision**: keep the recorded R2024b fixtures as the reference. Each test gets a local function that accepts a
  caught error when (a) its identifier and message equal the recorded ones, or (b) its identifier and message equal
  an entry in an explicit equivalence list held in that test. Each entry names the recorded identifier, the accepted
  identifier, the accepted message and the release where it was observed. Every other error is rejected. The lists:
  - extract: `MATLAB:UndefinedFunction` -> `MATLAB:math:mustBeNumericCharOrLogical` (R2026a).
  - classify: `MATLAB:table:IllegalVarSubscript` -> the same identifier with the R2025a message, and ->
    `MATLAB:table:IllegalMultipleVarDotSubscript` with the R2026a message.

  Each test also feeds its own check deliberately different errors and asserts that they are rejected (SC-003): for
  every recorded case, one with a foreign identifier and one with the recorded identifier but a different message.
- **Rationale**: a list of exact pairs is the narrowest rule that passes on R2024b, R2025a and R2026a and still
  rejects any failure that has not been reviewed. It keeps the tests' purpose (parity with the pre-change code)
  and does not re-record the fixtures, which would need the deleted pre-change code. A future rename fails loudly
  with the existing diagnostic, and the fix is one reviewed list entry.
- **Alternatives considered**: (a) comparing identifiers only. Rejected because R2026a changed the identifiers.
  (b) Comparing the identifier's "family" (prefix) or the stack location. Rejected as too loose: any table error
  would pass. (c) Re-recording the fixtures on R2026a. Rejected because the pre-change code no longer exists and
  the result would no longer be a parity check. (d) One shared helper file under `test/`. Rejected because the two
  lists do not overlap and the comparison is about 10 lines; a local function per test keeps III-Naming simple
  and adds no new module that would need its own test.

## R5. `testEcosystemToy` under mosek (FR-006, FR-007; maintainer decision 2026-11-12)

- **Diagnosis**: the community model and grid were built exactly as in the test, under gurobi and then mosek.
  - Feasibility: both solvers find the same 82 feasible points; maximum community growth is 100 for both.
  - Qualitative FVA: no `NaN` in mosek's `fvaResults` (0 entries); no FVA solve failed. The largest
    |gurobi - mosek| over all flux bounds is 6.8e-7.
  - 28 of 656 qualitative states differ (18 points). Every flip is a zero or an equality that mosek's
    interior-point solution misses by 1e-9 to 3.1e-7. Examples: point 15, `org1_EX_A`, gurobi [-3.08642, 0]
    (state -1) against mosek [-3.09, -1.61e-08] (state -2); point 64, `EX_A_e`, gurobi exact equality (-3)
    against mosek (-2).
  - Cause: `ecosystemQualitativeFVA` passes `delta = 1e-9` (its default) to `getQualitativeFluxStates`. That is
    below what an interior-point solver delivers; the COBRA LP feasibility tolerance (`feasTol`) is 1e-6 for
    glpk, gurobi and mosek. Flips by threshold: 28 at 1e-9, 8 at 1e-8, 0 at 1e-7, 0 at 1e-6. Gurobi's states are
    identical at every threshold from 1e-9 to 1e-6.
  - The spec's earlier description ("no optimal value ... `NaN`") was wrong and has been corrected (spec
    Clarifications, 2026-11-12).
- **Options presented**: (1) the test passes `'delta', 1e-6`; (2) the default `delta` follows the LP solver's
  feasibility tolerance; (3) mosek returns vertex solutions (basis identification or simplex); (4) skip mosek in
  the test.
- **Decision (maintainer)**: option 2. When the caller does not give `delta`, `ecosystemQualitativeFVA` uses
  `getCobraSolverParams('LP', 'feasTol')`, read when it is called. An explicit `delta` (including `1e-9`) behaves
  exactly as before. `getQualitativeFluxStates` keeps its own `1e-9` default: it does not call a solver.
- **Rationale**: a flux bound within the solver's feasibility tolerance of zero cannot be told apart from zero by
  that solver, so the solver's tolerance is the right scale for "zero". The change fixes mosek users as well as the
  test. Gurobi and glpk results of the existing tests do not change, because their states are identical at every
  threshold from 1e-9 to 1e-6 (to be confirmed for glpk and the other ecosystem tests in the quickstart).
- **Backward compatibility (Principle II)**: this is an approved change of a public default (spec Clarifications).
  Callers who need the old behaviour pass `'delta', 1e-9`. The help text states the new default and that recipe.
- **External-solver configuration audit**: no solver option is changed. The surface that matters here is each
  solver's primal feasibility tolerance as set from `feasTol`. Verified: glpk `tolbnd` (`solveCobraLP.m:591`) and
  mosek `MSK_DPAR_INTPNT_TOL_PFEAS` (`setMosekParam.m:414`, `:429`). Gurobi: `solveCobraLP.m:827` calls
  `setGurobiParam(param)`, which sets `FeasibilityTol = feasTol` when not given (`setGurobiParam.m:205`, `:214`;
  confirmed in T004). `getCobraSolverParams('LP', 'feasTol')` returns 1e-6
  for all three on this machine. Mosek returns interior (non-vertex) LP solutions, so zero fluxes come back as values below
  `feasTol`, not as exact zeros. Deriving `delta` from `feasTol` matches the threshold to that profile. The problem
  data are 23-reaction toy community LPs (sparse, continuous, well scaled).

## R6. Start-up inside a linked worktree (FR-008)

- **Decision**: `initCobraToolbox.m:239` treats `CBTDIR` as a git checkout when `.git` is a folder **or** a file
  (a linked worktree's `.git` is a file that points to the shared repository). Nothing else changes. Only default
  mode reaches this block: agent mode sets `installedGit = false`.
- **Rationale**: this is the smallest change that recognises both checkout kinds and leaves a true non-repository
  directory on the existing path (US4-2).
- **Alternatives considered**: `git rev-parse --is-inside-work-tree`. Rejected because it starts another process
  and is also true for a folder nested inside an unrelated repository, which changes US4-2 behaviour.
- **Verification**: an automated test would need a full default-mode start-up (minutes, with network checks)
  inside a temporary linked worktree, and creating that worktree changes the shared repository's worktree list.
  Under Principle III, the minimum is a documented reproducibility check: quickstart step 6 records the commands,
  the expected output and this reason.
