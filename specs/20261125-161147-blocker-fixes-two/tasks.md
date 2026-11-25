# Tasks: Fix the three remaining core blockers and test what they unblock

`F` = this feature folder; `B` = `specs/20261113-142115-test-backfill-tiers`.

## Phase 1: Setup

- [X] T001 Feature folder, spec, plan, tasks; `F/review.md` for the impact reports

## Phase 2: optimizeCardinality (approved 2026-11-25)

- [X] T002 [US1] Test first: full `test/verifiedTests/base/testCardOpt/testOptimizeCardinality.m` (small problems; stand-in solveCobraLP for statuses -1, 0, 2, 3 and others); see it fail on the current code
- [X] T003 [US1] Fix `src/base/solvers/cardOpt/sparseLP/optimizeCardinality.m` line 906 (`case {1, 3}`); NOTE
- [X] T004 [US1] Coverage run (`F/coverage-optimizeCardinality.jsonl`); ledger TESTED; seeds removed; registry
- [X] T005 [US2] Impact: callers' tests (testSparseLP, sparseFBA, relaxedFBA, findSparseMode, leak tests and others with a test); report

## Phase 3: checkMassChargeBalance (approved 2026-11-25, revised version)

- [X] T006 [US1] Test first: new sections in `test/verifiedTests/reconstruction/testMassChargeBalance/testMassChargeBalance.m` (printLevel -1 and 2 with every reaction mass balanced); header updated; see it fail on the current code
- [X] T007 [US1] Fix `src/reconstruction/modelGeneration/massBalance/checkMassChargeBalance.m` (lines 235, 260 accept an empty imBalancedMass; line 260 q; help of imBalancedMass and imBalancedCharge); NOTE
- [X] T008 [US1] Coverage run; `B/inventory/existing-defective.tsv` line removed; ledger and registry
- [X] T009 [US2] Impact: callers' tests (checkMassChargeBalance users with a test); report

## Phase 4: changeGeneAssociation (approved 2026-11-25, fixes a-c)

- [X] T010 [US1] Test first: full `test/verifiedTests/reconstruction/testRefinement/testChangeGeneAssociation.m`; see it fail on the current code
- [X] T011 [US1] Fix `src/reconstruction/refinement/changeGeneAssociation.m` (nGenes update; translation before the look-up; full-size rxnGeneMat); NOTE
- [X] T012 [US1] Coverage run; ledger TESTED; registry
- [X] T013 [US2] Impact: tests of addReaction and other callers; report
- [X] T014 Commit the three fixes (as the maintainer, no co-author)

## Phase 5: unblocked functions

- [X] T015 Unblock: drop the three names from blocked reasons, PENDING where no blocker remains, propagate; `--check`
- [ ] T016 [US3] Waves until no PENDING row remains (helpers write tests; lead confirms quarantines and reach, applies, joint coverage, registry, privacy scan, commit per wave)

## Final Phase

- [ ] T017 Review section, receipt, privacy scan, commit
- [ ] T018 Push this branch and `20261125-154813-c13-tests-coverage` (maintainer, 2026-11-25: "push the tests")
