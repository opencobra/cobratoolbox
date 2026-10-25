# Implementation Plan: Greedy Extreme-Ray Basis Stall on Recon3D

**Branch**: `20261003-132730-greedy-recon3d-stall` | **Date**: 2026-10-03 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261003-132730-greedy-recon3d-stall/spec.md`

## Summary

`greedyExtremeRayBasis` stalls at 237/251 rays on the Recon3D VK model under the
caller's reference call (no `maxTime`, so it spins for the 10 000 s default). Research
(research.md, measured on the VK file with a scratchpad prototype) shows four defects.
Only one of them causes the stall:

| # | Defect | Remedy | Effect measured on the reference call |
|---|---|---|---|
| R1 | rays judged after `findExtremePool` truncates entries < 1e-5 | judge and return the solver's own `sol.full`, negatives clipped to 0; `findExtremePool` unchanged | **necessary and sufficient**: 251/251 in 31 s, 0 accuracy rejections |
| R2 | accuracy rejections never escalate to the stall remedy | count them in `nfail`; report `nStallEscalations` | correctness; inert on gurobi once R1 lands |
| R3 | spectrum skipped above 5e7 elements | ceiling 1e8 as optional `param.maxElementsForSpectrum` | target derived (3.9e-13), regime assessed; 5.3 s |
| R4 | attainable-dimension LP is not maximal-support | `z <= x, z <= 1, x >= 0` formulation | Recon3D 251 (was 237); F4 2 (was 1) |

All four together: **complete, 251/251, 35.9 s, worst row residual 3.5e-16**, against a
baseline of 237/251 and then no progress. US4 adds `checkNullspaceBasis` to judge a
supplied basis, such as `model.L`, against the same contract. On `model.L` it finds
**101 of 251 rows failing** the derived target.

## Technical Context

**Language/Version**: MATLAB R2026a (COBRA Toolbox; must remain valid on the CI MATLAB
image)

**Primary Dependencies**: COBRA Toolbox solver abstraction (`solveCobraLP`,
`changeCobraSolver`, `getCobraSolverParams`), `getNullSpace`, `getRankLUSOL`; gurobi as
this routine's nominated LP solver (mosek rejected on `develop`, commit a590dcca0)

**Storage**: N/A (in-memory matrices). Measurements are recorded as markdown under
`specs/<feature>/measurements/`

**Testing**: script-style verified tests (repo convention) under
`test/verifiedTests/analysis/testTopology/`, run through the MATLAB MCP server and
`testAll` on CI

**Target Platform**: Linux workstation (development, Recon3D acceptance) and CI runners
(ecoli_core plus micro-fixtures)

**Project Type**: scientific library (MATLAB toolbox)

**Performance Goals**: SC-001, reference call complete in < 10 min (measured 35.9 s).
SC-002, accuracy-rejection fraction < 5 % (measured 0 %). SC-003, spectrum < 15 s
(measured 5.3 s)

**Constraints**: accuracy target never loosened (FR-005). Non-negativity exact (FR-003).
`findExtremePool` outputs unchanged (FR-012). Parent features' status contract preserved
and only extended additively (FR-011)

**Scale/Scope**: operative matrices up to 1e8 elements for the dense spectrum. Recon3D
operative matrix 5824 x 8748, nullity 251

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design: PASS.*

- **Scientific code quality**: the LP formulation of the ray search is unchanged. The
  attainable-dimension LP is replaced by a provably maximal-support one (R4, with an
  argument in research.md). The accuracy target derivation is unchanged in mathematics
  and only extracted for reuse (R6). The interface change is additive only: one
  optional parameter and two status fields (contracts/).
- **Testing and reproducibility**: narrowest test is
  `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` (new cases:
  ecoli_core rescaled-row stall regression for R1, impossible-target escalation count for
  R2, spectrum ceiling parameter for R3, F4 and G1 attainable dimension for R4). New
  `testCheckNullspaceBasis.m` and `testNullspaceAccuracyTarget.m` (III-Naming: one file
  per function). Regression: `testFindExtremePathway.m` unchanged and passing. The
  Recon3D acceptance is a recorded measurement (quickstart.md) with fixed seed
  `rng(20261003)`.
- **User experience and diagnostics**: no change to printed output at `printLevel 0`.
  The five outcomes are preserved. A shortfall verdict on Recon3D changes from a false
  `structural` to `sampling`, which is the intended correction (FR-008). New status
  fields are documented in the help header.
- **Performance and numerical integrity**: speed comes only from no longer discarding
  exact rays. Acceptance residual, target and non-negativity checks are unchanged and
  still applied to the returned object. The returned residual on Recon3D is 3.5e-16
  against a 3.9e-13 target. No verification step is made skippable.
- **External-solver configuration audit**: gurobi through `solveCobraLP`. The tuned
  per-solver settings of feature 20260915 are unchanged and still forwarded via
  `param.solverSettings`. The new maximal-support LP has an unbounded `x` (`ub = inf`)
  and a 0/1-valued `z` at optimum. Measured on gurobi with default settings: optimal,
  support threshold `z > 0.5` robust (values are 0 or 1). No new solver parameter is
  introduced. Representative instance: the Recon3D operative matrix (2m = 11 648
  variables).
- **Spec-driven scope control**: edit
  `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`. New
  `src/analysis/topology/extremeRays/optimalRays/checkNullspaceBasis.m` and
  `src/analysis/topology/extremeRays/optimalRays/nullspaceAccuracyTarget.m`. Edit
  `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`. New
  `test/verifiedTests/analysis/testTopology/testCheckNullspaceBasis.m` and
  `testNullspaceAccuracyTarget.m`. **Read-only**: `findExtremePool.m`,
  `optimalExtremePoolDriver.m`, `test/models/` (COBRA.models submodule, including the
  corrupt xomics file), `external/`, `deprecated/`, the VK model file. No new
  dependency.
- **MATLAB coding standards**: optional arguments by `exist`/`isfield` as the file
  already does (no `nargin`). No `evalc`. Warnings stay visible (tests switch off only
  the named `greedyExtremeRayBasis:incompleteBasis` identifier where a shortfall is
  forced, and restore it). `try/catch` in the attainable-dimension helper keeps
  propagating `ME.stack` in its warning, as now. `check_matlab_code` is clean on touched
  files. The MATLAB coding-guidelines resource and the `matlab-testing` skill are
  consulted for the new tests.
- **Parameter-setting fidelity**: N/A (no ported or literate output).
- **Artifact placement**: source under `src/analysis/topology/extremeRays/optimalRays/`.
  Tests beside existing topology tests. Measurements as markdown under
  `specs/<feature>/measurements/` (planning artifacts, as in the predecessor features).
  The research prototype stays in the session scratchpad and is not committed. No
  generated output under `src/`.

## Project Structure

### Documentation (this feature)

```text
specs/20261003-132730-greedy-recon3d-stall/
├── spec.md
├── plan.md              # this file
├── research.md          # R0–R6, measured
├── data-model.md
├── quickstart.md        # acceptance run on the VK file + CI test run
├── contracts/
│   ├── greedyExtremeRayBasis.md   # additive param/status changes
│   ├── checkNullspaceBasis.md     # new function
│   └── nullspaceAccuracyTarget.md # extracted helper
├── measurements/
│   └── 20261003-baseline-diagnosis.md
├── checklists/requirements.md
├── human-loop.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
src/analysis/topology/extremeRays/optimalRays/
├── greedyExtremeRayBasis.m      # EDIT: R1 R2 R3 R4, uses nullspaceAccuracyTarget
├── nullspaceAccuracyTarget.m    # NEW: target + regime derivation, extracted verbatim
├── checkNullspaceBasis.m        # NEW: US4 supplied-basis validation
├── findExtremePool.m            # READ-ONLY (FR-012)
└── optimalExtremePoolDriver.m   # READ-ONLY

test/verifiedTests/analysis/testTopology/
├── testGreedyExtremeRayBasis.m  # EDIT: add R1–R4 cases
├── testNullspaceAccuracyTarget.m# NEW
├── testCheckNullspaceBasis.m    # NEW
└── testFindExtremePathway.m     # unchanged, must pass
```

**Structure Decision**: single MATLAB toolbox layout. All changes are confined to the
`optimalRays/` directory and its topology tests.

## Design notes (for tasks)

1. **R1**: in the main loop, after `findExtremePool`, set `x = sol.full` with
   `x(x < 0) = 0` when `sol.full` has `nVar` entries. Keep the empty/size guard. Apply
   the identical rule in `compareSolversAtState` so instrumentation stays inert. The
   per-row acceptance and the post-hoc verification remain the gates.
2. **R2**: `nfail = nfail + 1` on the accuracy-rejection path. Increment
   `nStallEscalations` whenever `nfail` reaches `nfailMax` from below.
3. **R3**: `param.maxElementsForSpectrum`, default 1e8, replacing the literal. Record
   `status.spectrumTime`.
4. **R4**: replace the body of `attainableNullspaceDimension` with the maximal-support
   LP. Same signature, same `try/catch` and warning behaviour.
5. **R6**: move the target and regime derivation into `nullspaceAccuracyTarget(Sop)`,
   returning `accuracyTarget, accuracyTargetDerived, regime, sigmaOne, sigmaMinPlus,
   regimeBoundary, spectrumTime`. Both `greedyExtremeRayBasis` and `checkNullspaceBasis`
   call it. The greedy routine's outputs on the existing tests must be bit-identical
   for the target.
6. Help-header NOTE: a dated "CHANGE OF DEFAULT NUMERICAL BEHAVIOUR" entry. Returned
   rays may now carry entries below 1e-5 that were formerly zeroed. They are exact, and
   they are what the accuracy target certifies.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
|---|---|---|
| New helper `nullspaceAccuracyTarget.m` (+ its test) | US4 must judge a supplied basis by the same target as the routine (single-sourcing) | duplicating ~30 lines of derivation in `checkNullspaceBasis` invites drift between the two certifications |
| New optional `param.maxElementsForSpectrum` | makes the R3 fallback testable on a small CI model | a genome-scale CI fixture costs minutes and memory per run |
