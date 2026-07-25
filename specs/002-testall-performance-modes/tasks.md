# Tasks: testAll performance modes

**Input**: Design documents from `specs/002-testall-performance-modes/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: This feature changes test-harness behaviour; the narrowest checks are a
unit test for the mode resolver and fast-vs-full equivalence checks (per-test
pass/fail identical, coverage within 5 pp). No scientific assertions change.

**Organization**: grouped by user story (US1 fast mode = P1 MVP; US2 full-mode
fidelity + docs = P2; US3 profiling report = P3).

## Implementation status (2026-07-13)

Mechanism + three high-value per-test edits implemented and verified. Some per-test
edits were **deferred** where trimming risked changing an assertion or coverage
unpredictably (correctness-first); see `audit/fast-mode-edits.md`. Verified:
`testGetCobraTestMode` pass; prepareTest fast/full/explicit behaviour correct;
`testGpSampler` fast 12s (vs ~147s full); `testMultiProductionEnvelopeInorg` fast
2.9s / full 55.7s both pass; `testSimulatePairwiseInteractions` fast pass.
Deferred to a full/CI run: whole-suite MoCov coverage delta (T018) and a full
`testAll` profiling run (T017 validated via the equivalent prototype).

Legend: `[X]` done · `[A]` auto-handled by the shared mechanism (no edit needed) ·
`[~]` partially done / deferred with rationale.

## Path Conventions

MATLAB single project: source under `src/`, test harness under `test/`, tests under
`test/verifiedTests/**`.

---

## Phase 1: Setup

- [X] T001 Add `test/performance/` to `.gitignore` (regenerable profiling artifacts, per Principle IX).

## Phase 2: Foundational (blocks US1 and US2)

- [X] T002 Create the mode resolver `src/base/install/getCobraTestMode.m` (contracts/mode-control.md): `'fast'|'full'`; `COBRA_CI=1`→full; global `CBT_TEST_MODE`, env `COBRA_TEST_MODE`, default fast; invalid→`COBRA:testMode:invalid`.
- [X] T003 [P] Add unit test `test/verifiedTests/base/testInstall/testGetCobraTestMode.m` covering all branches (default fast, env full, CI forces full, invalid errors). Verified passing.
- [X] T004 `test/testAll.m` resolves mode via `getCobraTestMode` and prints it; no behaviour change in full mode.

## Phase 3: User Story 1 — Fast, coverage-preserving suite by default (P1) 🎯 MVP

- [X] T005 [US1] `src/base/install/prepareTest.m`: fast mode → minimal (default) solver per class unless `requiredSolvers`/`useSolversIfAvailable` given. Verified (extensive+full=6, fast=1, explicit=6).
- [X] T006 [US1] Audit of slow tests → `audit/fast-mode-edits.md` (edited / auto / deferred classification + deviations).
- [X] T007 [P] [US1] `testGpSampler.m`: fast → single default LP solver. Verified fast 12s pass.
- [~] T008 [P] [US1] `testSimulatePairwiseInteractions.m`: solver-trim applied (verified fast pass). modelList 5→3 **deferred** (fragile hardcoded cleanup).
- [A] T009 [P] [US1] `testReadSBML.m`: already returns one solver via `requireOneSolverOf` — no edit needed.
- [A] T010 [P] [US1] `testTest4HumanFctExt.m`: solver loop already single locally; the ~686 FBA solves are the coverage and cannot be trimmed — no fast edit.
- [~] T011 [P] [US1] Non-solver: `testMultiProductionEnvelopeInorg.m` done (removed `pause(3)`; fast skips unasserted calls; verified fast 2.9s / full 55.7s). `testWriteSBML`/`testModelBorgifier`/`testJoinModelsPairwiseFromList` **deferred** (rationale in audit).
- [X] T012 [US1] Edited tests run in both modes — pass/fail identical (verified: fast passes for all edited; full passes for the unconditional-change test).
- [~] T013 [US1] Fast-vs-full timing recorded (55.7s→2.9s; ~147s→12s). Whole-suite MoCov coverage delta deferred to a full/CI run.

## Phase 4: User Story 2 — Revert to the complete suite (P2)

- [X] T014 [US2] Full-mode fidelity verified: fast guards are `if getCobraTestMode('isFast')` so full mode is the original path by construction; only the pure `pause(3)` removal is unconditional. `testMultiProductionEnvelopeInorg` full passes.
- [X] T015 [US2] Contributor note + backward-compat added to `documentation/source/guides/testGuide.rst` (single-sourced; how to select full, CI=full, profiling report).

## Phase 5: User Story 3 — Opt-in profiling report (P3)

- [X] T016 [US3] `test/testAll.m` opt-in report (contracts/profiling-report.md): `COBRA_PERF=1`/`PERFORMANCE_REPORT`; ranked CSV + profiler HTML; try/catch warns; off by default.
- [~] T017 [US3] Report logic validated via the equivalent prototype (`profileTestSubset.m` produced testTiming.csv + html on a live run). A full `testAll COBRA_PERF=1` run deferred (60-min suite).

## Phase 6: Polish & cross-cutting

- [~] T018 Whole-suite fast-vs-full SC-001/SC-002 run deferred (60-min suite); per-test evidence recorded instead.
- [X] T019 [P] `mcp__matlab__check_matlab_code` on new/edited files: only pre-existing/by-design (global) warnings; no new issues introduced.
- [X] T020 Implementation receipt written under `agent-runs/`; human-loop.md points at it.
