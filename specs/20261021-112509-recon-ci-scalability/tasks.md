# Tasks: CI scalability of COBRA functions

Format: `[ID] [P?] [Story] description` (paths exact). Tests are written and run on the UNMODIFIED
function before any `src/` edit; the test file is never edited after it first passes.

## Phase 1: Baseline and setup
- [x] T001 [US1] Baseline per stage on the 30 665 x 38 841 model -> research.md
- [x] T002 [US1] Function-level profile of the leaks stage (solver-bound) -> research.md
- [x] T003 [US1] Function-level profiles of flux-consistency and stoichiometry stages -> research.md
- [x] T004 [US1] Copy the benchmark harness into specs/20261021-112509-recon-ci-scalability/bench/

## Phase 2: checkDuplicateRxn (US2, US3, US4)
- [x] T010 [US3] Write test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m
      (Tier 1; `prepareTest()`; methods 1/'rxnAbbr', 2/'S', 'FR'; boundsFlag; removeFlag 0/1;
      printLevel 0 and 1; defaults for omitted arguments; no-duplicate, one-pair, three-member group
      with warning, reversed duplicate, duplicates differing in scale; empty removal). Do not touch src.
- [x] T011 [US3] Run it on the unmodified function; record pass and line coverage (target 100 %, exemptions in header); record file hash
- [x] T012 [US2] Save real-model reference outputs of the unmodified function (S and FR, 2026-10-09 models, 6 151 x 6 022 and the 2026-09 mid-size) to the scratchpad
- [x] T013 [US1] Edit src/reconstruction/modelGeneration/checkDuplicateRxn.m per plan (sparse scaling, grouped scan, preallocation)
- [x] T014 [US2] Re-run testCheckDuplicateRxn.m unedited (hash equal) and the legacy testRemoveDuplicateRxn.m; both pass
- [x] T015 [US2] Compare real-model outputs with T012 (isequal)
- [x] T016 [US1] Large model, methods S and FR under the 24 GB cap: time and peak memory -> research.md

## Phase 3: Other candidates (decided from T003 by the selection rule)
- [x] T020 [US1] Decide per function (findSExRxnInd, removeRxns, removeMetabolites,
      findFluxConsistentSubset, findStoichConsistentSubset, maxCardinalityConservationVector); record
      "change" or "measured, not worth changing"; for each "change", add a T010..T016 group

## Phase 3b: removeFieldEntriesForType (decided in T020)
- [x] T021 [US3] Write test/verifiedTests/reconstruction/testRemoveFieldEntriesForType/testRemoveFieldEntriesForType.m (Tier 2) on the unmodified function; known defect recorded (grRules without rules)
- [x] T022 [US2] Edit src/reconstruction/refinement/removeFieldEntriesForType.m (one pass over the rules)
- [x] T023 [US2] Re-run the test unedited (hash equal); 1200 randomised removals identical; flux-consistency stage output identical
- [x] T024 [US1] Flux-consistency stage 366 s -> 138 s -> research.md

## Phase 4: Close
- [x] T030 (manual consistency pass: spec FR-009, plan selection rule, research decisions and tasks agree; SC-005 cannot be verified locally) Run /speckit-analyze consistency check
- [x] T031 Write the implementation receipt in the format of the Implementation Receipt Ledger
- [x] T032 Commit on the feature branch (ASCII message, repo conventions); push to the maintainer's fork only; no PR
