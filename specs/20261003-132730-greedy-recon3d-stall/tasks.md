# Tasks: Greedy Extreme-Ray Basis Stall on Recon3D

**Input**: `specs/20261003-132730-greedy-recon3d-stall/` (spec.md, plan.md, research.md,
data-model.md, contracts/, quickstart.md)

**Tests**: REQUIRED. Spec FR-015 and the Traceability table name the tests, and the
constitution (Principle III) requires them. Write each test before its implementation
and confirm it FAILS on the current code where the task says so.

## Read this before executing any of it

- **Gate**: no task here may run until the human approves at Gate 2 and invokes
  `/speckit-implement` or the agent-assign pipeline (constitution Principle VI).
- **Read-only**: `findExtremePool.m`, `optimalExtremePoolDriver.m`, `test/models/`
  (COBRA.models submodule), `external/`, `deprecated/`, and the VK model file
  `~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat`.
- **Never loosen** the accuracy target or the `param.feasTol` clamp (FR-005).
  Non-negativity is exact (FR-003).
- **MATLAB**: no `nargin` (use `exist`/`isfield` as the file does). No `evalc`. Warnings
  visible; tests switch off only `greedyExtremeRayBasis:incompleteBasis` around a forced
  shortfall and restore the prior state. Seed with `rng(20261003)` where randomness
  matters.
- **Shared MATLAB session**: one MATLAB MCP session serves all agents, so run MATLAB
  tasks serially. Set `git config core.pager cat` before any in-MATLAB git call.
- Paths below are relative to the repository root. `GREEDY` =
  `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`.
  `TGREEDY` = `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`.

## Phase 1: Setup

- [X] T001 Run `TGREEDY` and `test/verifiedTests/analysis/testTopology/testFindExtremePathway.m` on the unmodified branch with gurobi. Record pass/fail and elapsed time in `specs/20261003-132730-greedy-recon3d-stall/measurements/20261003-pre-implementation-tests.md`.
- [X] T002 For every fixture `TGREEDY` passes to `greedyExtremeRayBasis` (F-series, G1, ecoli_core full and internal, badly-scaled case), record `status.accuracyTarget` (`%.17g`), `accuracyTargetDerived` and `regime` from the unmodified code in `specs/20261003-132730-greedy-recon3d-stall/measurements/20261003-target-invariants.md`. This is the bitwise reference for T006.

## Phase 2: Foundational — extract the accuracy-target derivation (BLOCKS US3, US4)

- [X] T003 [P] Write `test/verifiedTests/analysis/testTopology/testNullspaceAccuracyTarget.m`, following contracts/nullspaceAccuracyTarget.md. Assert: on ecoli_core's internal operative matrix the target is derived, the regime is `wellScaled`, and `accuracyTarget == tauMin*sigmaOne*sigmaMinPlus`. With `param.maxElementsForSpectrum = numel(S)` (boundary, inclusive): derived. With `param.maxElementsForSpectrum = numel(S) - 1`: `accuracyTargetDerived == false`, `regime == 'notAssessed'`, target `== eps*normest(S)` (`normest` is deterministic for a fixed matrix; if not, assert within 1e-12 relative). The badly-scaled fixture used by `TGREEDY` gives `badlyScaled`. Use the repo's verified-test header format, as in `TGREEDY`.
- [X] T004 Create `src/analysis/topology/extremeRays/optimalRays/nullspaceAccuracyTarget.m`: `target = nullspaceAccuracyTarget(Sop, param)`. Move the derivation verbatim from `GREEDY` (the block from `maxElementsForSpectrum = 5e7;` through the `~accuracyTargetDerived` fallback), keeping its comments and research.md references. Replace the literal with `param.maxElementsForSpectrum` (default `1e8` via `isfield`). Time the block into `spectrumTime`. Return the fields in contracts/nullspaceAccuracyTarget.md. Write a full openCOBRA help header (USAGE, INPUT, OPTIONAL INPUT, OUTPUT, EXAMPLE, NOTE).
- [X] T005 In `GREEDY`, add `param.maxElementsForSpectrum` defaulting (`isfield`, 1e8) to the parameter block. Replace the inlined derivation with a call to `nullspaceAccuracyTarget(model.S, param)`, unpacking into the existing local names (`accuracyTarget`, `accuracyTargetDerived`, `regime`, `sigmaMinPlus`, `regimeBoundary`, `sigmaOne`). Document `maxElementsForSpectrum` in OPTIONAL INPUT.
- [X] T006 Run T003's test and `TGREEDY`. Confirm every value recorded in T002 is reproduced bit-for-bit (the 1e8 default changes no CI fixture, since all are far below 5e7). Append the result to `measurements/20261003-target-invariants.md`.

**Checkpoint**: the derivation is single-sourced; behaviour is unchanged.

## Phase 3: User Story 1 — complete accurate basis on Recon3D (P1) 🎯 MVP

**Goal**: the reference call returns 251/251 accurate rays in bounded time.
**Independent test**: quickstart.md §2 on the VK file; in CI, the ecoli_core rescaled-row
regression.

- [X] T007 [US1] In `TGREEDY`, add the R1 regression (research.md R5). Build ecoli_core's internal operative matrix as the existing test does. Pick programmatically the metabolite present in the most columns of its `getNullSpace` basis (`abs > 1e-9`). Multiply that row by `2e5`. Call `greedyExtremeRayBasis` with `internalStoichiometriMatrixLeftNullspace = 1`, gurobi, `printLevel 0`, `maxTime = 60`, `rng(20261003)`. Assert: `outcome == 'complete'`; `raysFound == raysExpected`; `raysRejectedForAccuracy == 0`; `regime == 'wellScaled'`; every row's `max|row*Sop| <= status.acceptanceTarget`; `min(Zpos(:)) >= 0`; and some positive entry `< 1e-5` (the class truncation used to destroy). Also call it on a model whose `S` is the transpose of the rescaled operative matrix, with `leftRight = 'right'`, `internalStoichiometriMatrixLeftNullspace = 0` and `SConsistentRxnBool = true(size(S,2),1)`. Assert the same outcome, ray count and zero accuracy rejections, and `S*Zpos` within target (edge case: identical behaviour in both modes). Run it and confirm it FAILS on the current code (baseline measured: 7/11, 1814 accuracy rejections).
- [X] T008 [US1] In `TGREEDY`, add the R2 test. On the existing impossible-target case (`feasTol = -1`, short `maxNewBasisTime`), assert `isfield(status,'nStallEscalations') && status.nStallEscalations > 0`. Assert that the field exists, with value 0, on a complete ecoli_core run and on the `badlyScaled`, `emptyNullspace` and `missingField` returns (every-return-path rule). Confirm it FAILS on the current code (field absent).
- [X] T009 [US1] R1 in `GREEDY` main loop: immediately after the `findExtremePool` call (non-paired branch), when `~isempty(sol.full) && numel(sol.full) == nVar`, set `x = sol.full; x(x < 0) = 0;`. Comment why: truncation at `10*feasTol` destroys exact vertices, per research.md R1 with the measured numbers. Leave `findExtremePool.m` untouched.
- [X] T010 [US1] R1 in `compareSolversAtState` (same file): apply the identical raw-and-clip rule to each solver's `xi` before its residual is recorded, and to the returned `x`, so that paired instrumentation judges rays exactly as the ordinary path does (inertness, predecessor FR-017).
- [X] T011 [US1] R2 in `GREEDY`: on the accuracy-rejection path, increment `nfail`. Add `nStallEscalations = 0` to the search-state initialisation, and increment it whenever `nfail` reaches `nfailMax` from below on any failure path (empty solve, accuracy, dependence). Add `status.nStallEscalations` to the final status and to the `missingField`, `emptyNullspace` and `badlyScaled` early-return structs (value 0). Document it in the OUTPUTS block.
- [X] T012 [US1] Add a dated help-header NOTE to `GREEDY`: "CHANGE OF DEFAULT NUMERICAL BEHAVIOUR, October 2026, feature 20261003-132730-greedy-recon3d-stall". Explain that rays are now judged and returned untruncated (entries below `10*feasTol` are kept, negatives clipped), that accuracy failures escalate, and why. Cite the Recon3D numbers.
- [X] T013 [US1] Run `TGREEDY`; T007 and T008 must now pass, and every pre-existing assertion must still pass.
- [X] T014 [US1] Run quickstart.md §2 (the reference call on the VK file, `rng(20261003)`, no `maxTime`). Record outcome, rays, elapsed, `raysRejectedForAccuracy`, `raysRejectedForDependence`, `nTargetedObjectives`, `nStallEscalations`, target, regime, `spectrumTime` and worst residual in `specs/20261003-132730-greedy-recon3d-stall/measurements/20261003-acceptance.md`. Check SC-001 (< 10 min, 251/251) and SC-002 (`raysRejectedForAccuracy / (raysRejectedForAccuracy + raysRejectedForDependence + raysFound) < 0.05`). Run the call in the background. If it has not returned after 10 min, stop it and record an SC-001 failure; do not let it hold the shared MATLAB session for the 10 000 s default.

**Checkpoint**: US1 is shippable alone (MVP).

## Phase 4: User Story 2 — truthful shortfall classification (P2)

**Goal**: `shortfallKind` and `attainableDimension` are correct.
**Independent test**: F4 → 2; G1 → structural, 0; Recon3D truncated run → sampling, 251.

- [X] T015 [P] [US2] In `TGREEDY`, add the F4 case `S = sparse([1; -1; 2])`, `SConsistentRxnBool = true`. Force a shortfall with `feasTol = -1` and `maxNewBasisTime = maxTime = 2`. Assert `attainableDimensionAssessed`, `attainableDimension == 2` (the nullity), and `shortfallKind == 'sampling'`. Confirm it FAILS on the current code (measured: 1). Keep the existing G1 assertions, and additionally assert `statusG1.attainableDimension == 0` when the run falls short.
- [X] T016 [US2] Replace the body of `attainableNullspaceDimension` in `GREEDY` with the maximal-support LP from research.md R4: variables `[x; z]`, `S'x = 0`, `z - x <= 0`, `0 <= z <= 1`, `x >= 0` with `ub = inf`, maximise `sum(z)`, support `z > 0.5`, then `attainable = |support| - getRankLUSOL(S(support,:))`. Keep the signature, the `try/catch` that warns with `ME.message` and `ME.stack(1)`, and the `sol.stat ~= 1` guard. Update the function's comment with the F4 counterexample showing why `max sum(x)` is not maximal-support.
- [X] T017 [US2] Run `TGREEDY` (T015 passes; G1 still `structural`). Then, on the VK file, run the reference call with `maxTime = 5` to force a shortfall. Record `shortfallKind == 'sampling'` and `attainableDimension == 251` (SC-004) in `measurements/20261003-acceptance.md`.

## Phase 5: User Story 3 — derived target on large matrices (P2)

**Goal**: genome-scale matrices below 1e8 elements get a derived target and regime.
**Independent test**: ceiling parameter governs the fallback; Recon3D derives.

- [X] T018 [P] [US3] In `TGREEDY`, add: ecoli_core internal with default parameters gives `accuracyTargetDerived == true` and `status.spectrumTime >= 0`. With `param.maxElementsForSpectrum = 1`: `accuracyTargetDerived == false`, `regime == 'notAssessed'`, `spectrumTime == 0`, and the basis is still returned and accurate against the fallback target.
- [X] T019 [US3] In `GREEDY`, set `status.spectrumTime` from `nullspaceAccuracyTarget`'s output on the main path and to 0 on the early-return structs that precede the derivation (`missingField`, `emptyNullspace`). The `badlyScaled` path carries the measured value. Document it in OUTPUTS.
- [X] T020 [US3] Run `TGREEDY`. From T014's run, confirm SC-003 (`accuracyTargetDerived`, `wellScaled`, `spectrumTime < 15 s`) and record it in `measurements/20261003-acceptance.md`.

## Phase 6: User Story 4 — validate a supplied basis (P3)

**Goal**: judge `model.L` (or any basis) by the routine's own contract.
**Independent test**: shipped `model.L` → `inaccurate`, 101 failing rows, spans the nullspace.

- [X] T021 [P] [US4] Write `test/verifiedTests/analysis/testTopology/testCheckNullspaceBasis.m` per contracts/checkNullspaceBasis.md, using ecoli_core. Cases:
  - A complete basis returned by `greedyExtremeRayBasis` gives `outcome == 'valid'`, `spansNullspace`, and empty `failingRows`.
  - The same basis with row 1 perturbed by `1e-6` in one entry gives `'inaccurate'` with `failingRows == 1`.
  - One entry set to `-1e-3` gives `'negative'`.
  - The last row removed gives `'rankDeficient'`.
  - `residualByRow` equals `max(abs(B*Sop),[],2)` exactly.
  - A dimension-mismatched `B` raises an error with identifier `checkNullspaceBasis:dimensionMismatch`.
- [X] T022 [US4] Create `src/analysis/topology/extremeRays/optimalRays/checkNullspaceBasis.m` per contracts/checkNullspaceBasis.md. Build `Sop` exactly as `GREEDY` does (consistency restriction, `'right'` transpose). Derive the target via `nullspaceAccuracyTarget`, apply the `feasTol` clamp, and compute the per-row residual, non-negativity, `rank(full(B))` (fall back to `getRankLUSOL` above the spectrum ceiling) and nullity from the same spectrum. Apply the outcome precedence negative > rankDeficient > inaccurate > valid. Print one summary line when `printLevel > 0`. Full openCOBRA help header.
- [X] T023 [US4] Run `testCheckNullspaceBasis`. Then run quickstart.md §2's `checkNullspaceBasis` calls on the VK file, both on the shipped `model.L` (expect `'inaccurate'`, 101 failing rows, `spansNullspace` true) and on the new `L` (expect `'valid'`). Record them in `measurements/20261003-acceptance.md` (SC-006).

## Phase 7: Polish and cross-cutting

- [X] T024 [P] Run `check_matlab_code` (MATLAB MCP) on `GREEDY`, `nullspaceAccuracyTarget.m`, `checkNullspaceBasis.m` and the three test files. Fix new warnings only.
- [X] T025 Run all four tests in quickstart.md §1, including the unchanged `testFindExtremePathway.m` (FR-012, SC-005). Record the results in `measurements/20261003-acceptance.md`.
- [X] T026 FR-013 non-regression: re-run the iDopaNeuroC / iAF1260 / ecoli_core cases recorded in `specs/20260915-082551-extreme-ray-coverage/measurements/results.md` with their seeds. Record coverage, worst residual and runtime against the earlier values in `measurements/20261003-predecessor-regression.md`. iDopaNeuroC must reach 105/105 (SC-005).
- [X] T027 Write the constitutional implementation receipt at `specs/20261003-132730-greedy-recon3d-stall/agent-runs/<UTC-timestamp>-greedy-recon3d-stall/implementation-receipt.md` (Prompt, Final response, Diff summary, Tests, Unresolved issues), and point `human-loop.md` at it.

## Dependencies

- T001, T002 → T003–T006 (Foundational) → US3 (T018–T020) and US4 (T021–T023).
- US1 (T007–T014) depends only on Phase 1. It may proceed in parallel with Phase 2 on a
  different code region, but both edit `GREEDY`, so execute them serially. MVP = Phase 1 + US1.
- US2 (T015–T017) depends only on Phase 1 (separate local function).
- T014, T017, T020 and T023 all run on the VK file and write to the same measurements
  file: run them serially.
- Phase 7 after all stories.

## Parallel opportunities

- T003, T015, T018 and T021 write different files ([P]). Their MATLAB runs are still
  serial (one shared session).
- T024 is static analysis and can run alongside any non-MATLAB step.

## Implementation strategy

1. MVP: Phase 1 → US1 (T007–T014). This alone fixes the reported stall (research.md
   ablation: R1 is necessary and sufficient).
2. Then US2 (verdict correctness), Foundational + US3, US4, Polish.
3. Stop and validate at each checkpoint. A Gate 2 "first slice" approval = Phase 1 + US1.

## Task-to-requirement coverage

| Requirement | Tasks |
|---|---|
| FR-001, SC-001, SC-002 | T007, T009, T013, T014 |
| FR-002, FR-003, FR-016 | T007, T009, T010 |
| FR-004 | T008, T011 |
| FR-005 | T006, T007 (target unchanged), T013 |
| FR-006, FR-007, SC-003 | T003–T006, T018–T020 |
| FR-008, FR-009, SC-004 | T015–T017 |
| FR-010, SC-006 | T021–T023 |
| FR-011 | T008, T011, T018, T019, T013 |
| FR-012, SC-005 | T025 (findExtremePool untouched) |
| FR-013 | T026 |
| FR-014 | T014, T017, T020, T023 (before/after vs baseline record) |
| FR-015 | T007, T008, T015, T018, T021, T003 |
