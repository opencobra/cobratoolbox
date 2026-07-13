# Tasks: testAll performance modes

**Input**: Design documents from `specs/002-testall-performance-modes/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: This feature changes test-harness behaviour; the narrowest checks are a
unit test for the mode resolver and fast-vs-full equivalence checks (per-test
pass/fail identical, coverage within 5 pp). No scientific assertions change.

**Organization**: grouped by user story (US1 fast mode = P1 MVP; US2 full-mode
fidelity + docs = P2; US3 profiling report = P3).

## Path Conventions

MATLAB single project: source under `src/`, test harness under `test/`, tests under
`test/verifiedTests/**`.

---

## Phase 1: Setup

- [ ] T001 Add `test/performance/` to `.gitignore` (regenerable profiling artifacts, per Principle IX).

## Phase 2: Foundational (blocks US1 and US2)

- [ ] T002 Create the mode resolver `src/base/install/getCobraTestMode.m` per contracts/mode-control.md: returns `'fast'|'full'`; `COBRA_CI=1` → `full`; global `CBT_TEST_MODE`, then env `COBRA_TEST_MODE`, then default `fast`; invalid value → error `COBRA:testMode:invalid`. Header/help per MATLAB standards; no side effects.
- [ ] T003 [P] Add unit test `test/verifiedTests/base/testInstall/testGetCobraTestMode.m` covering all resolution branches from quickstart §1 (default fast, env full, CI forces full, invalid errors), saving/restoring `COBRA_CI`/`COBRA_TEST_MODE`.
- [ ] T004 In `test/testAll.m` resolve the mode via `getCobraTestMode` and print the active mode in the banner/summary. No trimming logic here and no behaviour change when mode = full.

## Phase 3: User Story 1 — Fast, coverage-preserving suite by default (P1) 🎯 MVP

**Goal**: Default run is materially faster with coverage within 5 pp of full and the
same tests reported. **Independent test**: quickstart §2–§3 (per-test pass in both
modes; fast subset faster; coverage delta ≤5 pp; no test dropped).

- [ ] T005 [US1] Edit `src/base/install/prepareTest.m` per contracts/solver-selection.md: when `getCobraTestMode()=='fast'` AND the caller did not pass `requiredSolvers`/`useSolversIfAvailable` (nor an explicit all-solvers opt-out), behave as `useMinimalNumberOfSolvers=true` (default solver per class). Full mode and the requirement/skip logic unchanged.
- [ ] T006 [US1] Audit the ranked-slowest solver-looped tests (from research.md / slowTests_ranked_full.csv) and classify each as prepareTest-driven (auto-trimmed by T005) or hardcoded-solver-list (needs manual edit); record the concrete edit list in the audit notes under the feature dir.
- [ ] T007 [P] [US1] In `test/verifiedTests/analysis/testSampling/testGpSampler.m`, reduce the hardcoded `solverPkgs` loop to the single class-default solver when fast (guarded by `getCobraTestMode`); keep the full list in full mode. Verify assertions are solver-independent.
- [ ] T008 [P] [US1] In `test/verifiedTests/analysis/testMultiSpeciesModelling/testSimulatePairwiseInteractions.m`, trim the hardcoded 3-solver loop to one in fast mode; additionally reduce `modelList` (5→3) in fast mode to cut duplicated pairwise builds. Assertions (interaction type) unchanged.
- [ ] T009 [P] [US1] In `test/verifiedTests/base/testIO/testReadSBML.m`, move the min/max FBA block to one representative solver in fast mode (keep SBML parse coverage on all three models).
- [ ] T010 [P] [US1] In `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m`, ensure the solver loop runs one solver in fast mode and hoist the `load(refData)` calls out of the loop.
- [ ] T011 [P] [US1] Apply non-solver speedups, each fast-guarded so full mode is unchanged: remove `pause(3)` in `test/verifiedTests/design/testMultiProductionEnvelopeInorg.m` (unconditional; dead wait) and skip its unasserted/plot-only calls in fast mode; load iIT341 from `.mat` in `test/verifiedTests/reconstruction/testModelBorgifier/testModelBorgifier.m`; capture the SBML struct from the first write in `test/verifiedTests/base/testIO/testWriteSBML.m` (avoid the second serialisation); reduce `modelList` (5→3) fast-mode in `test/verifiedTests/analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList.m`.
- [ ] T012 [US1] For each edited test, run it in BOTH modes via `mcp__matlab__run_matlab_test_file` and confirm pass/fail/skip is identical to pre-edit (quickstart §2). Fix any test whose fast path changes an outcome.
- [ ] T013 [US1] Run the representative subset in fast vs full (quickstart §3): record wall-time (expect materially lower) and MoCov coverage (expect ≤5 pp absolute drop); confirm `testFVA`/`testdynamicRFBA` remain fail/error in both (not masked). Record numbers in the feature dir.

## Phase 4: User Story 2 — Revert to the complete suite (P2)

**Goal**: Full mode reproduces today exactly and is documented. **Independent test**:
quickstart §4.

- [ ] T014 [US2] Verify each fast-mode guard added in US1 resolves to the original code path in full mode (spot-check the diffs; confirm no unconditional change reduced full-mode work except the pure `pause(3)` removal). Document any deviation.
- [ ] T015 [US2] Add the contributor documentation + backward-compatibility note (Principle II/X, single-sourced) under `documentation/source/` explaining: fast is the new default, how to select full (`COBRA_TEST_MODE=full`), that CI runs full, and how to get a performance report. Reference, do not duplicate, the contracts.

## Phase 5: User Story 3 — Opt-in profiling report (P3)

**Goal**: Enabling the report yields a ranked timing table + hotspots without changing
pass/fail. **Independent test**: quickstart §5.

- [ ] T016 [US3] In `test/testAll.m` add the opt-in report per contracts/profiling-report.md: gated on `COBRA_PERF=1` or a `PERFORMANCE_REPORT` global; after `runTestSuite`, write ranked `test/performance/testTiming.csv`, save `profile('info')` + `profsave` HTML, print the slowest tests; wrap in try/catch that warns and never fails the run; off by default.
- [ ] T017 [US3] Validate quickstart §5: with `COBRA_PERF=1` the CSV + HTML appear and slowest tests print; disabled → no artifacts and unchanged pass/fail.

## Phase 6: Polish & cross-cutting

- [ ] T018 Full-suite (or large-subset) fast-vs-full run confirming SC-001 (material speedup) and SC-002 (≤5 pp coverage drop); attach the numbers to the implementation receipt.
- [ ] T019 [P] Run `mcp__matlab__check_matlab_code` on all new/edited `.m` files; resolve any new warnings (warnings stay visible; no evalc/nargin issues).
- [ ] T020 Write the implementation receipt under `specs/002-testall-performance-modes/agent-runs/<UTC>-<name>/implementation-receipt.md` (Prompt, Final response, Diff summary, Tests, Unresolved issues) and point human-loop.md at it.

## Dependencies & order

- Phase 1 → Phase 2 → Phase 3 (US1). US1 is the MVP and can ship alone.
- US2 (Phase 4) depends on US1 edits existing (verifies their full-mode path) — small.
- US3 (Phase 5) is independent of US1/US2 (only touches testAll.m reporting) and may
  be implemented in parallel with or before US1.
- Phase 6 depends on the shipped stories.

## Parallel opportunities

- T007–T011 edit distinct test files → run in parallel `[P]`.
- T003 (mode unit test) parallel with T004 (testAll wiring).
- T016 (US3) parallel with the US1 test edits (different files).

## MVP scope

**US1 (Phase 2 + Phase 3)** delivers the fast-by-default speedup and is independently
testable via quickstart §2–§3. US2 docs/fidelity and US3 profiling can follow.
