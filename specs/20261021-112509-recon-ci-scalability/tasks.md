# Tasks: CI scalability of COBRA functions

Format: `[ID] [P?] [Story] description` (paths exact). Tests are written and run on the UNMODIFIED
function before any `src/` edit; the test file is never edited after it first passes.

## Phase 1: Baseline and setup
- [x] T001 [US1] Baseline per stage on the 30 665 x 38 841 model -> research.md
- [x] T002 [US1] Function-level profile of the leaks stage (solver-bound) -> research.md
- [ ] T003 [US1] Function-level profiles of flux-consistency and stoichiometry stages -> research.md
- [ ] T004 [US1] Copy the benchmark harness into specs/20261021-112509-recon-ci-scalability/bench/

## Phase 2: checkDuplicateRxn (US2, US3, US4)
- [ ] T010 [US3] Write test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m
      (Tier 1; `prepareTest()`; methods 1/'rxnAbbr', 2/'S', 'FR'; boundsFlag; removeFlag 0/1;
      printLevel 0 and 1; defaults for omitted arguments; no-duplicate, one-pair, three-member group
      with warning, reversed duplicate, duplicates differing in scale; empty removal). Do not touch src.
- [ ] T011 [US3] Run it on the unmodified function; record pass and line coverage (target 100 %, exemptions in header); record file hash
- [ ] T012 [US2] Save real-model reference outputs of the unmodified function (S and FR, 2026-10-09 models, 6 151 x 6 022 and the 2026-09 mid-size) to the scratchpad
- [ ] T013 [US1] Edit src/reconstruction/modelGeneration/checkDuplicateRxn.m per plan (sparse scaling, grouped scan, preallocation)
- [ ] T014 [US2] Re-run testCheckDuplicateRxn.m unedited (hash equal) and the legacy testRemoveDuplicateRxn.m; both pass
- [ ] T015 [US2] Compare real-model outputs with T012 (isequal)
- [ ] T016 [US1] Large model, methods S and FR under the 24 GB cap: time and peak memory -> research.md

## Phase 3: Other candidates (decided from T003 by the selection rule)
- [ ] T020 [US1] Decide per function (findSExRxnInd, removeRxns, removeMetabolites,
      findFluxConsistentSubset, findStoichConsistentSubset, maxCardinalityConservationVector); record
      "change" or "measured, not worth changing"; for each "change", add a T010..T016 group

## Phase 4: Close
- [ ] T030 Run /speckit-analyze consistency check
- [ ] T031 Write the implementation receipt in the format of the Implementation Receipt Ledger
- [ ] T032 Commit on the feature branch (ASCII message, repo conventions); push to the maintainer's fork only; no PR
