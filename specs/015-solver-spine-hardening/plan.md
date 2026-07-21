# Implementation Plan: Solver-Spine Consolidation and Abstraction Hardening

**Branch**: `015-solver-spine-hardening` | **Date**: 2026-07-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/015-solver-spine-hardening/spec.md`

## Summary

A phased, strictly behaviour-preserving refactor of the LP/QP/MILP/MIQP solver core
under `src/base/solvers`, addressing architectural weaknesses W1 (solver state in **14**
`eval`-accessed globals — 7 `_SOLVER` + 7 `_PARAMS`, touched at **10** eval sites), W2
(per-dispatcher duplicated status maps — the `dqqStatMap` literal now survives in **2**
byte-identical copies), and W3 (**27** analysis/design/dataIntegration files that bypass the
solver abstraction — **16 routable, 11 island**), plus one open latent bug
(`buildOptProblemFromModel` mosek-debug `names.con` sizing, and its `names.var` column
analogue). Counts are grounded file:line in [research.md](./research.md) and supersede the
pre-research estimates. Delivered as ONE feature in three sequenced,
independently-testable phases, safest-first:

- **P1 — status consolidation + builder bug.** Extend the feature-009
  `src/base/solvers/statusMapping/mapSolverStatus.m` to cover every
  `(solver, problemType, nativeStatus)` triple the four dispatchers currently handle
  inline; delete the duplicated `dqqStatMap` and all per-dispatcher inline maps; fix the
  `names.con` row-count sizing. Additive and fully guarded by the 009 net.
- **P2 — abstraction bypasses.** Route every direct-solver-call file outside
  `src/base/solvers` through `solveCobra{LP,QP,MILP,MIQP}`, except a documented
  single-solver islands list.
- **P3 — solver-state encapsulation.** Add a backward-compatible `CobraSolverState`
  accessor/struct over the existing globals; thread explicit state through `solveCobra*`;
  replace the `eval`-built solver-name/param access in the selection path with
  struct-field access.

The equivalence standard for every "behaviour-preserving" claim (per spec Clarifications
2026-07-19): identical canonical `.stat` **and** raw `.origStat`, and optimal objective
value equal within a justified tolerance, with the returned point feasible. The
primal/dual solution **vector** is not asserted (non-unique optima under non-strict
convexity).

## Technical Context

**Language/Version**: MATLAB, baseline R2024b or newer (constitution Scientific Computing
Constraints). No new language surface introduced.

**Primary Dependencies**: The COBRA solver interface (`solveCobraLP/QP/MILP/MIQP`,
`buildOptProblemFromModel`, `changeCobraSolver`, `parseSolverParameters`,
`getCobraSolverParams`); optimization backends gurobi, mosek, ibm_cplex/tomlab_cplex,
glpk, dqqMinos/quadMinos, pdco, lp_solve, matlab `linprog`. No new third-party
dependency.

**Storage**: N/A (in-memory model structs; no persistence).

**Testing**: `test/testAll.m` harness; `test/verifiedTests/base/testSolvers/` (existing
`testMapSolverStatus.m` from feature 009 + new status/regression tests); the feature-009
characterization net (`testCharacterize*`) as the behaviour-preservation oracle. All new
tests declare requirements via `prepareTest` and use justified floating-point tolerances.

**Target Platform**: Linux headless CI (Docker, Xvfb, Gurobi available); local dev with
gurobi + mosek per the project default solver policy. Must run headless, no GUI-only
calls.

**Project Type**: MATLAB library (single project). Work is concentrated in one domain
subtree (`src/base/solvers/`) plus the Phase-2 caller edits in `src/analysis/`,
`src/design/`, `src/dataIntegration/`.

**Performance Goals**: No regression. Status mapping is O(1) table lookup; consolidation
must not add measurable per-solve overhead. Genome-scale sparsity/vectorisation
preserved; no new solver calls inside loops.

**Constraints**: Strictly behaviour-preserving (FR-013 equivalence standard). No public
interface change (FR-011). No new canonical `.stat` value (FR-004). `.origStat` preserved
verbatim. Superseded selection/state access deprecated via shim, never deleted
(Principle II).

**Scale/Scope** (grounded in [research.md](./research.md)): Phase 1 — 4 dispatchers +
`mapSolverStatus.m` + `buildOptProblemFromModel` (≈6 files) and their tests; deletes 2
`dqqStatMap` copies and the inline maps; fixes Bug A (MIQP gurobi `.stat`/`.origStat`
inversion), Bug B (LP ibm_cplex code 101→stat 0), and the `names.con`/`names.var` sizing.
Phase 2 — **27** direct-call bypass files (**16 routable** rerouted through `solveCobra*`;
**11 island** documented + hardened) across `analysis/`, `design/`, `dataIntegration/`,
`reconstruction/`. Phase 3 — `changeCobraSolver.m`, `parseSolverParameters.m`,
`changeCobraSolverParams.m`, `getCobraSolverParams.m`, the four `solveCobra*`, plus a new
`CobraSolverState` accessor over the 14 globals (10 eval sites migrated).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Touches the canonical solver-status semantics
  (`.stat`/`.origStat`) and the model→problem builder — both Principle I/IV surfaces. No
  change to stoichiometry, bounds, objective, or `csense`/`osense` semantics. The
  canonical `.stat` value set is fixed (FR-004). Behaviour preserved under the FR-013
  equivalence standard; verified against the openCOBRA solver-interface sources under
  `src/base/solvers/`.
- **Testing and reproducibility**: Narrowest tests first — a status-map fixture test in
  `test/verifiedTests/base/testSolvers/` covering every native code the inline maps
  handle (Phase 1); a `buildOptProblemFromModel` `names.con` regression test on a model
  with `model.C` and no `model.ctrs` under mosek `param.debug` (Phase 1); per-module
  portability tests under a non-native configured solver (Phase 2); a `CobraSolverState`
  equivalence + explicit-state-solve test (Phase 3). All `prepareTest`-gated, justified
  tolerances, fixed seeds. The feature-009 characterization net runs before/after each
  phase (SC-006). Verified via the MATLAB MCP server (`run_matlab_test_file`).
- **User experience and diagnostics**: Diagnostic semantics unchanged (FR-011). `.origStat`
  still carries the raw solver code; solver warnings remain visible (VII-B); `printLevel`
  behaviour unchanged. The new mapper raises a defined error identifier for a genuinely
  unmappable `(solver, problemType)` only where the old code would also have failed, and
  otherwise folds unknown native codes into an existing non-optimal `.stat` (FR-004),
  never silently "optimal".
- **Performance and numerical integrity**: Status mapping is a table lookup; no added
  solver calls, no suppressed diagnostics, no skipped verification. Objective/feasibility/
  status quality must not degrade (FR-013). No debug/verification step is removed; the
  mosek `param.debug` path is fixed, not disabled.
- **External-solver configuration audit**: REQUIRED and central to this feature (FR-014).
  Phase 0 `research.md` enumerates, per solver, the native status codes and the relevant
  configuration surface being consolidated, cross-checked against the current inline maps
  so no native code is dropped or silently re-mapped. Representative instances: the
  feature-009 characterization models (LP/FBA) plus targeted QP/MILP/MIQP fixtures.
  Installed solvers audited: gurobi, mosek, ibm_cplex/tomlab_cplex, glpk, dqqMinos/
  quadMinos, pdco, lp_solve, matlab linprog.
- **Spec-driven scope control**: Edit paths — `src/base/solvers/statusMapping/`,
  `src/base/solvers/solveCobra{LP,QP,MILP,MIQP}.m`, `src/base/solvers/buildOptProblemFromModel.m`
  (P1); the routable bypass files in `src/analysis/**`, `src/design/TrimGdel/**`,
  `src/dataIntegration/transcriptomics/SWIFTCORE/**` (P2); `src/base/solvers/getSetSolver/changeCobraSolver.m`,
  `src/base/solvers/param/{parseSolverParameters,changeCobraSolverParams}.m`,
  `src/base/solvers/getCobraSolverParams.m`, and a new `CobraSolverState` (P3). Read-only:
  `external/`, `deprecated/`, vendored subtrees, and the documented solver islands (routed
  only where the abstraction can carry the capability). No new third-party dependency.
- **MATLAB coding standards**: No `evalc` suppression; the Phase-3 work specifically
  REMOVES `eval`-built global access (VII-A/D improvement). Warnings stay visible (VII-B).
  `try/catch` propagates `ME.stack` (VII-C). Optional args via `exist`/`isempty`, not
  `nargin` (VII-D). New functions carry the openCOBRA help header (VII-E). MATLAB
  best-practice skill consulted at implementation time (VII-F).
- **Parameter-setting fidelity**: N/A — this feature renders no ported/literate output;
  it is MATLAB-internal refactoring.
- **Artifact placement**: New source under the correct domain subfolders
  (`src/base/solvers/statusMapping/`, and a new `src/base/solvers/getSetSolver/` or
  `stateManagement/` folder for `CobraSolverState`). New tests under
  `test/verifiedTests/base/testSolvers/`. No generated artifacts committed to `src/`. The
  documented islands list is a Spec Kit artifact under `specs/015-solver-spine-hardening/`
  (and referenced from a source-level `README`/help only if a durable in-tree pointer is
  needed). Spec Kit artifacts stay under `specs/015-solver-spine-hardening/`.

**Result**: PASS (initial). **Post-design re-check (2026-07-20): PASS** — the grounded
Phase-0/Phase-1 artifacts (research.md, data-model.md, contracts/) surfaced no new violation.
The consolidated `mapSolverStatus` stays pure and keyed on `(solver,problemType,nativeStatus)`
so behaviour is preserved exactly (no `.stat` value added); the `CobraSolverState` façade
deprecates-via-shim without deleting globals or adding `eval`; islands are documented and only
hardened. Complexity Tracking remains empty.

## Project Structure

### Documentation (this feature)

```text
specs/015-solver-spine-hardening/
├── spec.md              # Approved specification (+ Clarifications 2026-07-19)
├── plan.md              # This file
├── research.md          # Phase 0: FR-014 status-map config-surface audit + bypass/globals inventory
├── data-model.md        # Phase 1: canonical status, status-map relation, islands list, CobraSolverState
├── quickstart.md        # Phase 1: runnable before/after validation scenarios per phase
├── contracts/
│   ├── mapSolverStatus.md       # signature + (solver,problemType,nativeStatus)->stat contract
│   ├── cobraSolverState.md      # accessor/struct API + backward-compat shim contract
│   └── solverIslands.md         # islands-list format + graceful-requirement contract
├── checklists/
│   └── requirements.md  # existing (passed 16/16)
├── human-loop.md        # orchestration index (this run)
└── tasks.md             # Phase 2 output (/speckit-tasks — not created by /speckit-plan)
```

### Source Code (repository root)

```text
src/base/solvers/
├── statusMapping/
│   └── mapSolverStatus.m          # P1: extend to all (solver,problemType,nativeStatus); single dqqStatMap
├── solveCobraLP.m                 # P1: obtain .stat from mapSolverStatus; remove inline maps  | P3: thread explicit state
├── solveCobraQP.m                 # P1: remove duplicated dqqStatMap + inline maps             | P3: thread explicit state
├── solveCobraMILP.m               # P1: obtain .stat from mapSolverStatus                       | P3: thread explicit state
├── solveCobraMIQP.m               # P1: obtain .stat from mapSolverStatus (+ fix .stat/.origStat inversion) | P3
├── buildOptProblemFromModel.m     # P1: size names.con from true constraint-row count of [S;C]/[S E;C D]
├── getSetSolver/
│   ├── changeCobraSolver.m        # P3: replace eval-built CBT_*_SOLVER access with struct-field access
│   └── CobraSolverState.m         # P3 (new): backward-compatible accessor/struct over the globals
├── param/
│   ├── parseSolverParameters.m    # P3: replace eval('global CBT_..._SOLVER') access
│   └── changeCobraSolverParams.m  # P3: replace eval('CBT_..._PARAMS.(name)=...') access
└── getCobraSolverParams.m         # P3: read via CobraSolverState

src/analysis/**, src/design/TrimGdel/**, src/dataIntegration/transcriptomics/SWIFTCORE/**
    # P2: routable direct-solver-call files rerouted through solveCobra{LP,QP,MILP,MIQP}
    # (documented islands under src/analysis/multiSpecies/SteadyCom/**, gMCS, findMIIS,
    #  ICONGEMs, FVA/mtFVA remain solver-specific where the capability can't yet be carried)

test/verifiedTests/base/testSolvers/
├── testMapSolverStatus.m          # existing (009); extended for full (solver,problemType) coverage
├── testBuildOptProblemNamesCon.m  # P1 (new): mosek-debug names.con regression
├── testSolverAbstractionRouting.m # P2 (new): per-module portability under a non-native solver
└── testCobraSolverState.m         # P3 (new): equivalence + explicit-state solve
```

**Structure Decision**: Single MATLAB-library project. All new source lives in
`src/base/solvers/` sub-folders by role (`statusMapping/`, `getSetSolver/`, `param/`);
all new tests live beside the existing solver tests in
`test/verifiedTests/base/testSolvers/`. No repository-layout change; no new top-level
directory. Phase-2 edits are confined to the identified caller files and reroute call
sites without moving files.

## Complexity Tracking

*No Constitution Check violations to justify — this table is intentionally empty.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | — | — |
