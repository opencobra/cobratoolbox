# Tasks: Fix the code defects of the core blocking functions

**Input**: `specs/20261120-161825-core-blocker-fixes/` (spec.md, plan.md). Tasks for functions 2-7
are added when the maintainer approves their fix.

`F` = this feature folder; `B` = `specs/20261113-142115-test-backfill-tiers`.

## Phase 1: Setup

- [X] T001 Feature folder, spec, plan, tasks; `F/review.md` for the impact reports

## Phase 2: User Story 1 + 2 - getCobraSolverParams (approved 2026-11-20)

- [X] T002 [US1] Test first: `test/verifiedTests/base/testSolvers/testGetCobraSolverParams.m` as a full test (wave 02 version, git 7691bdd2e, as the starting point) with sections for the global setting in the two-input form, 'default' returning the built-in value, the priority structure > global > default, the number of outputs per form and the structure output; restore and clear the globals; see it fail on the current code
- [X] T003 [US1] Fix `src/base/solvers/param/getCobraSolverParams.m` (useGlobals / returnStructure; help of paramStructureOut; NOTE)
- [X] T004 [US1] Coverage run (`F/coverage-getCobraSolverParams.jsonl`); defect entries removed; ledger row TESTED; blocked reasons drop getCobraSolverParams; registry; `--check`, `--verify-coverage`
- [X] T005 [US2] Impact: list the callers of the two-input form (outside old/ and deprecated/), state the condition under which their outputs change, and run the tests of the callers that have one (runScriptFile); report in `F/review.md`
- [X] T006 Commit (as the maintainer, no co-author)
- [X] T007 [US2] (approved 2026-11-20) in `src/analysis/FBA/optimizeCbModel.m`, after reading the global minNorm (line 321), treat 0 as no minNorm ([]), as lines 302-304 do for the input; test the case in testOptimizeCbModel (global minNorm 0, model without objective)

## Phase 3: getModelFieldsForType (approved 2026-11-23)

- [X] T008 [US1] Fix line 104 of `src/reconstruction/refinement/getModelFieldsForType.m` (`length(type-1)` -> `length(type)-1`); NOTE in the help
- [X] T009 [US1] Full test `test/verifiedTests/reconstruction/testRefinement/testGetModelFieldsForType.m` (written new; no earlier full version): every branch, the defect trigger (one-reaction model with rxnCustom), a custom 1x1 field with a type prefix (recorded behaviour), the 80 standard fields; run against the old function (shadowing copy first on the path) to see it fail, then against the fix
- [X] T010 [US1] Coverage run (`F/coverage-getModelFieldsForType.jsonl`); defect entry removed; ledger TESTED; blocked reasons drop getModelFieldsForType; registry; `--check`, `--verify-coverage`
- [X] T011 [US2] Impact: the 13 callers in src/; run the tests of those that have one; report in `F/review.md`
- [X] T012 Commit

## Phase 4: functions 3-7

Added after each review.

## Final Phase: unblocked functions, records, push

- [ ] T090 [US3] Tests for the functions whose blockers are all cleared
- [ ] T091 Registry, ledger checks, receipt, privacy scan, commit, push the branch
