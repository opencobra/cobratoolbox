# Tasks: XomicsToModel test

**Input**: spec.md, plan.md. **Tests**: the two new tests are the deliverable; validated by running them in full mode.

## Implementation status (2026-07-14) — DONE (both extractors viable)

Both extractors converged (T001 fastCore 572s → 1375×2222/1235 genes; T002 thermoKernel
563s → 1393×2232/1231 genes; both feasible). T003 fixtures copied. T004/T005 both tests
written. T006 verified: both PASS in full mode (fastCore 553s, thermoKernel 550s) and both
SKIP in fast mode. T007 checkcode clean (by-design globals only); no src change. T008 receipt
written under agent-runs/. Assertions: feasible model + size within 5% + ≥85% of 334 core
reactions retained.

## Phase 1: Viability & references (must precede writing assertions)

- [ ] T001 Run `XomicsToModel` with `fastCore` to COMPLETION once (generous bounded `matlab -batch`, e.g. ≤30 min) on the shipped model + omics data; record runtime and capture reference facts (extracted model size, `optimizeCbModel` stat/objective, a set of expected core reactions). If it does not complete within the cap, DEFER the fastCore test and document.
- [ ] T002 Same for `thermoKernel` (to completion, bounded); record runtime + references, or defer+document if it does not converge.

## Phase 2: Fixtures

- [ ] T003 Create `test/verifiedTests/dataIntegration/testXomicsToModel/data/` and copy the tutorial's omics fixtures (bibliomicData.xlsx, exometabolomicData.txt, transcriptomicData.txt) into it. Confirm the generic model resolves from `papers/2023_iDopaNeuro/Recon3DModel_301_xomics_input.mat` (CBTDIR-anchored); the test skips cleanly if it is absent.

## Phase 3: Tests (US1)

- [ ] T004 [US1] Write `testXomicsToModel_fastCore.m`: openCOBRA header; full-mode-only guard (skip in fast mode via getCobraTestMode + COBRA:RequirementsNotMet); `prepareTest('needsLP',true,'needsMILP',true)`; figures invisible (onCleanup restore); load model + omics; set `param` per the tutorial with `tissueSpecificSolver='fastCore'`; call `XomicsToModel`; assert non-empty, `optimizeCbModel` stat==1, size matches T001 references (within tolerance), expected core reactions present.
- [ ] T005 [US1] Write `testXomicsToModel_thermoKernel.m`: same, with `tissueSpecificSolver='thermoKernel'`, asserting against T002 references. (Only if T002 completed; else defer.)
- [ ] T006 [US1] Run each new test in FULL mode via bounded `matlab -batch`/`runScriptFile`; confirm passed (or clean skip if a config was deferred/solver absent), and confirm both are SKIPPED in fast mode.

## Phase 4: Polish

- [ ] T007 `check_matlab_code` on the new tests; resolve new warnings. Confirm no `src` change and no other test regressed. Record captured runtimes.
- [ ] T008 Write the implementation receipt under `agent-runs/`; record any deferred config as a follow-up (incl. thermoKernel if it did not converge); point human-loop.md at it.

## Accounted-for outcomes
- XomicsToModel covered by a real (full-mode-only) test; thermoKernel covered by the second test if it converges.
- Deferred/documented if a config does not complete within the bounded cap.
