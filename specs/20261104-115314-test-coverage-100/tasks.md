---
description: "Tasks for bringing every test to 100% coverage or documented exemptions"
---

# Tasks: Bring every test to 100% line coverage of its function (or documented exemptions)

**Input**: `specs/20261104-115314-test-coverage-100/` (spec, plan, research, quickstart)

## Procedure for every GAP test (Phase 3)

1. Read the function under test fully and the test; list the undocumented missed lines from the
   inventory.
2. For each missed line, decide: (a) reachable with a documented input → add an independent
   `%%` section that reaches it and asserts the documented behaviour (no solver in Tier 1/2;
   only solvers the test already declares); (b) reachable only with an unavailable solver or
   toolbox, a GUI or another OS → exemption with that reason; (c) reachable only with a
   defective input → III-Defects entry, input skipped, lines listed; (d) no input can reach it →
   exemption "dead code" with the reason.
3. Update the header "Coverage exemptions" block with line numbers and reasons; keep every
   existing assertion; add the Authors line "- Coverage completed by feature
   20261104-115314-test-coverage-100, 2026-11-04."
4. Re-measure with `tools/measureCoverage.m`: the test passes and every missed line is
   documented. Never change `src/`.

## Phase 1: Setup

- [X] T001 Map the 605 tests to functions (309 header, 218 name, 78 none) — research R3
- [X] T002 Write and validate tools/measureCoverage.m — research R1

## Phase 2: User Story 1 — inventory (P1)

- [X] T002a Write tools/runCoverage.py (resumable, per-chunk MATLAB through matlab-safe) and the machine guard (research R4)
- [X] T003 [US1] Measure all 527 mapped tests with at most three memory-capped MATLAB sessions (tools/runCoverage.py) into coverage-runs/*.jsonl; 191 were recorded before the interruption and are kept
- [X] T004 [US1] Write tools/build_inventory.py (documented-line parsing per research R2) and generate coverage-inventory.md with status per test and the 78 out-of-scope tests
- [X] T005 [US1] Refine Phase 3 into per-batch tasks from the inventory (GAP counts per domain)

## Phase 3: User Story 2 — close the gaps (P1)

- [X] T010 [P] [US2] Batch b1-solvers: 17 tests, 1631 undocumented missed lines; close every gap or document the exemption
- [X] T011 [P] [US2] Batch b2-base: 21 tests, 353 undocumented missed lines; close every gap or document the exemption
- [X] T012 [P] [US2] Batch b3-thermo-topology: 13 tests, 881 undocumented missed lines; close every gap or document the exemption
- [X] T013 [P] [US2] Batch b4-exploration-fba: 19 tests, 630 undocumented missed lines; close every gap or document the exemption
- [X] T014 [P] [US2] Batch b5-analysis-rest: 20 tests, 529 undocumented missed lines; close every gap or document the exemption
- [X] T015 [P] [US2] Batch b6-modelgen: 6 tests, 1480 undocumented missed lines; close every gap or document the exemption
- [X] T016 [P] [US2] Batch b7-reconstruction: 17 tests, 167 undocumented missed lines; close every gap or document the exemption
- [X] T017 [P] [US2] Batch b8-dataintegration: 8 tests, 793 undocumented missed lines; close every gap or document the exemption
- [X] T018 [P] [US2] Batch b9-design-viz: 17 tests, 267 undocumented missed lines; close every gap or document the exemption

- [X] T019 [US2] Batch b10-remaining: testJoinModelsPairwiseFromList and testOptForce, which failed at baseline only because of test interleaving and a minute rollover

Tests hardcoding an unavailable solver (9 report 0% while passing) switch to the solvers returned by prepareTest. Two tests report no executable lines from the coverage plugin (ERROR) and are measured another way. At most three batches run at once; every MATLAB run uses matlab-safe.

## Phase 4: User Story 3 and polish

- [X] T090 [US3] Report SKIPPED and FAILING tests with reasons in coverage-inventory.md
- [X] T091 Re-measure all changed tests; regenerate coverage-inventory.md and test/known-defects.md
- [X] T092 Write agent-runs/<UTC>-implement/implementation-receipt.md
- [X] T093 Commit per batch (maintainer identity, no co-author line, only feature files) and push the branch

## Phase 5: Diagnosable failures in testCreateMetIntrcNetwork (FR-009, SC-005)

- [X] T100 [US2] Add a message with the check name, expected value and actual value to the 17 direct assertions in test/verifiedTests/visualization/testCreateMetIntrcNetwork/testCreateMetIntrcNetwork.m, leaving every condition unchanged
- [X] T101 [US2] Add a local function at the end of test/verifiedTests/visualization/testCreateMetIntrcNetwork/testCreateMetIntrcNetwork.m that returns the error message actually thrown, and use it in the messages of the 3 `verifyCobraFunctionError` assertions
- [X] T102 [US2] Verify test/verifiedTests/visualization/testCreateMetIntrcNetwork/testCreateMetIntrcNetwork.m: it passes through matlab-safe, it still has 20 assertions with unchanged conditions, and a throwaway copy with wrong expected values prints both values (SC-005)
- [X] T103 Write agent-runs/<UTC>-diagnosable-asserts/implementation-receipt.md and commit only the test and this feature's files (maintainer identity, no co-author line, scanned for local details); push only when the maintainer asks

## Phase 6: Warning checks that later warnings cannot hide (FR-010, SC-006)

- [X] T104 [US2] Replace the `lastwarn` checks in test/verifiedTests/visualization/testCreateMetIntrcNetwork/testCreateMetIntrcNetwork.m with `evalc` capture of the three calls, keeping the expected texts and reporting the captured text in the failure messages
- [X] T105 [US2] Verify test/verifiedTests/visualization/testCreateMetIntrcNetwork/testCreateMetIntrcNetwork.m: it passes through matlab-safe, it still has 20 assertions, the other 17 conditions are unchanged, and a throwaway copy that raises a later warning still passes the warning checks
- [X] T106 Write agent-runs/<UTC>-warning-capture/implementation-receipt.md and commit only the test and this feature's files (maintainer identity, no co-author line, scanned for local details); push only when the maintainer asks, then confirm the CI result (SC-006)
