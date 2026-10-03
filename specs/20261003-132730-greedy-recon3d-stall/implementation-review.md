# Implementation Review

## Summary

Under the reference call (`internalStoichiometriMatrixLeftNullspace=1`, `solver='gurobi'`,
no `maxTime`), `greedyExtremeRayBasis` stalls on the Recon3D VK model at 237/251 rays and
then spins for the 10 000 s default. The cause is measured, not inferred: the routine
judges rays **after** `findExtremePool` zeroes entries below 1e-5, which turns exact
vertices (residual <= 3e-16) into rejected ones (~1.6e-4). A research prototype with that
one change (R1) completes **251/251 in 31 s**. Three further defects are fixed for
correctness:
- **R2**: accuracy failures never escalate to the targeted objective.
- **R3**: the spectrum is skipped just above 5e7 elements, so the target falls back and
  the regime is not assessed.
- **R4**: the attainable-dimension LP is not maximal-support, giving a false `structural`
  verdict (237 instead of 251).

US4 adds `checkNullspaceBasis`. On the shipped `model.L` it reports `inaccurate`, with
**101 of 251** rows failing the derived target (3.9e-13), although `model.L` is
non-negative and spans the nullspace.

## Embedded Core Commands Completed
- constitution: checked (Principle VI gate; III-Naming; II additive-only; IV solver abstraction; IX placement; receipt ledger)
- specify: done. clarify: 4 clarifications recorded in the spec (reference call, 10-min bound, CI fixture = ecoli_core from COBRA.models, in-repo Recon3D files unusable)
- checklist: requirements.md all pass
- plan: plan.md, research.md (R0–R6, measured), data-model.md, contracts/ (3), quickstart.md
- tasks: 27 tasks, 7 phases
- analyze: 0 critical, 0 high, 3 medium, 6 low. All 7 actionable items remediated in the artifacts (user choice "Fix all"). O1 (hit-fraction print) and R1 (long reference call) recorded as risks.

## Cross-Artifact Analysis Summary
Coverage 100 % (16 FR + 6 SC → 27 tasks). No constitution conflicts. One spec criterion
was re-derived in planning from measurement: SC-003, from "< 10 % of call time" to
"< 15 s", because the fix made the search so fast that 5.3 s became 15 %. **Please
confirm at this gate.**

## Proposed Implementation Scope
- **Tasks proposed**: T001–T027 (all).
- **First independently testable slice**: Phase 1 + US1 = T001, T002, T007–T014. That
  alone fixes the reported stall (R1 + R2) and is verified on CI (ecoli_core
  rescaled-row regression) and on the VK file (acceptance).
- **Files likely to change**:
  - `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` (edit)
  - `src/analysis/topology/extremeRays/optimalRays/nullspaceAccuracyTarget.m` (new; US3/US4)
  - `src/analysis/topology/extremeRays/optimalRays/checkNullspaceBasis.m` (new; US4)
  - `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` (edit)
  - `test/verifiedTests/analysis/testTopology/testNullspaceAccuracyTarget.m` (new)
  - `test/verifiedTests/analysis/testTopology/testCheckNullspaceBasis.m` (new)
  - `specs/20261003-132730-greedy-recon3d-stall/measurements/*.md`, `agent-runs/…/implementation-receipt.md`
- **Files that should NOT change**: `findExtremePool.m`, `optimalExtremePoolDriver.m`,
  `testFindExtremePathway.m`, `test/models/**` (COBRA.models submodule, incl. the corrupt
  xomics file), `external/**`, `deprecated/**`, the VK model file.

## Tests and Validation Expected
1. Narrowest: `testGreedyExtremeRayBasis.m`. The new R1 case (ecoli_core, one
   conserved row ×2e5) must fail before the fix (7/11, 1814 accuracy rejections) and
   pass after it (11/11, 0).
2. `testNullspaceAccuracyTarget.m`, `testCheckNullspaceBasis.m`, and the unchanged
   `testFindExtremePathway.m`.
3. Acceptance on the VK file (quickstart §2): 251/251 in < 10 min, accuracy-rejection
   fraction < 5 %, target derived, `wellScaled`, spectrum < 15 s; `model.L` →
   `inaccurate`/101; new `L` → `valid`.
4. Predecessor non-regression (T026): iDopaNeuroC 105/105.

## Blocking Issues
None.

## Acceptable Risks
- Behaviour change (documented NOTE, T012): returned rays may now carry exact entries
  below 1e-5 that were formerly zeroed. That was the bug, but downstream code that
  assumed sparsity at 1e-5 will see slightly denser rows. Measured on Recon3D: smallest
  positive entry 3.5e-8 on the rescaled ecoli fixture. Recon3D rays are exact.
- The reference call has no `maxTime`. A regression would hold the shared MATLAB
  session, so T014 runs it in the background with a manual 10-min abort.
- The spectrum ceiling rises to 1e8 elements: up to 0.75 GB dense and ~8 s on matrices
  that previously skipped it.
- O1: the printed "Hit fraction" overstates efficiency (pre-existing, out of scope).

## Human Approval
- Approved: no
- Approved option:
- Approved tasks/scope:
- Implementation path (core `/speckit-implement` or agent-assign pipeline):
- Required implementation invocation per constitution: `/speckit-implement`, or `/speckit-agent-assign-assign` → `-validate` → `-execute`
- Date (UTC):
