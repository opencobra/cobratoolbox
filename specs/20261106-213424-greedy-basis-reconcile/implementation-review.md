# Implementation Review

## Summary
Merge `upstream/develop` (already containing `origin/develop` and feature B) into the feature branch; reconcile
`greedyExtremeRayBasis.m` as B's published contract plus A's checkpoint in caller orientation; fix the three
failing tests; verify 0 regressions against two `testAll` baselines; fast-forward `develop`; push and open the
upstream PR only on explicit confirmation.

## Embedded Core Commands Completed
- constitution: checked · specify: done (a95a049b0) · clarify: done (3 Qs, 2026-11-06) · checklist: passed ·
  plan: done (2026-11-07) · tasks: done (30) · analyze: done (0 critical, 3 should-fix, 1 Gate-2 decision)

## Cross-Artifact Analysis Summary
- F1 (should-fix): spec US2 still says two merges; plan does one (R1).
- D1 (should-fix): T014 script belongs under `specs/<feature>/verification/`, not `results/`.
- B1 (should-fix): SC-003/T005 fixture set = ancestor `467094a5d`'s `testGreedyExtremeRayBasis` fixtures; run ancestor via `matlab -batch`.
- B2 (decide): `testAll` mode for the three runs.
- R1 (acceptable risk): merge runs in the main checkout, where the other session has uncommitted files (not touched by the merge).

## Proposed Implementation Scope
- Tasks proposed: T001–T030 (T028, T029 each need a separate explicit confirmation).
- First independently testable slice: Phases 1–4 (T001–T021): merge started, mechanical conflicts resolved, reconciled function passing `testGreedyExtremeRayBasis`, adapted resume test and inertness. Nothing reaches `develop`.
- Files likely to change: `greedyExtremeRayBasis.m`, `testGreedyExtremeRayBasisResume.m`, `waterGibbsEnergyOfFormation.m`, `compareBounds2Models.m`, `setSimulationConstraints.m`, `CLAUDE.md`, `.specify/feature.json`, plus the 357 files the upstream merge brings; possibly a small fix for `testCheckNullspaceBasis` (T022).
- Files that should NOT change: `external/`, `deprecated/`, submodule pointers (beyond upstream), `findStoichConsistentSubset.m` and other files of the other session.

## Tests and Validation Expected
1. `checkcode` on `greedyExtremeRayBasis.m` (no `ENDCT`/`NOTERM`).
2. `testGreedyExtremeRayBasis`, `testGreedyExtremeRayBasisResume`, then `testCheckNullspaceBasis`.
3. Inertness vs `467094a5d` (FR-007/FR-008).
4. `testAll` merged vs old `develop` and `upstream/develop`: 0 regressions.

## Blocking Issues
None.

## Acceptable Risks
R1 above; C2 (signal-kill path not automatically testable); SSH push currently failing (T028 dry-runs first).

## Human Approval
- Approved: no
- Approved option:
- Approved tasks/scope:
- Required implementation invocation per constitution: `/speckit-implement`, or `/speckit-agent-assign-assign` → `-validate` → `-execute`
- Date (UTC):
