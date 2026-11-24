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

## Phase 4: setGurobiParam (approved 2026-11-23, fixes 1-3)

- [X] T013 [US1] Test first: full `test/verifiedTests/base/testSolvers/testSetGurobiParam.m` (no earlier full version): every branch, the three defect cases; see it fail on the current code
- [X] T014 [US1] Fix `src/base/solvers/gurobi/setGurobiParam.m` (timelimit only without TimeLimit; OutputFlag/DisplayInterval without printLevel; tolerances only when given; lpmethod warning); help and NOTE
- [X] T015 [US1] Coverage run; ledger TESTED; blocked reasons drop setGurobiParam; registry; `--check`, `--verify-coverage`
- [X] T016 [US2] Impact: callers solveCobraLP and solveCobraQP (Gurobi branch); run testSolveCobraLP, testSolveCobraQP and other Gurobi-solving tests; report
- [X] T017 Commit

## Phase 5: findSExRxnInd (approved 2026-11-23, fixes 1-4)

- [X] T018 [US1] Test first: full `test/verifiedTests/reconstruction/testModelGeneration/testFindSExRxnInd.m` from the pre-quarantine version, extended with DM_atp(c), Ex_, a model without c and the printLevel-0 silence (diary); see it fail on the current code
- [X] T019 [US1] Fix `src/reconstruction/modelGeneration/massBalance/findSExRxnInd.m` (one ATP boolean removed from DMRxnBool and the exchange set; c of size n; Ex_ with three characters; biomass message gated by printLevel); help and NOTE
- [X] T020 [US1] Coverage run; ledger TESTED; blocked reasons drop findSExRxnInd; registry; `--check`, `--verify-coverage`
- [X] T021 [US2] Impact: tests of the callers (checkStoichiometricConsistency, findStoichConsistentSubset, conservationAnalysis, extremePools and others with tests); report
- [X] T022 Commit

## Phase 6: getFilesInDir (approved 2026-11-23, fixes 1-3)

- [X] T023 [US1] Test first: full `test/verifiedTests/base/testInstall/testGetFilesInDir.m` (no earlier full version): folders outside git and git repositories made with git init in a tempname folder (every type, checkSubFolders, restrictToPattern, the default folder, the COBRA remote switch to ignored, empty listings); requires git; see it fail on the current code
- [X] T024 [US1] Fix `src/base/install/getFilesInDir.m` (empty names dropped; checkSubFolders default true; rdir folders dropped); help NOTE
- [X] T025 [US1] Coverage run; ledger TESTED; blocked reasons drop getFilesInDir; registry; `--check`, `--verify-coverage`
- [X] T026 [US2] Impact: callers initCobraToolbox, removeTempFiles, changeCobraSolver, testAll; run testRemoveTempFiles, testChangeCobraSolver and other tests of the callers; report
- [X] T027 Commit

## Phase 7: checkBalance (approved 2026-11-23, fix and help correction)

- [X] T028 [US1] Test first: full `test/verifiedTests/reconstruction/testModelGeneration/testCheckBalance.m` (no earlier full version): E and dE by hand for several elements, none, one and several missing formulas, non-standard formulae, missingFormulaeBool given, printLevel 1 and -1 (file in a tempname folder), the errors; see it fail on the current code
- [X] T029 [US1] Fix `src/reconstruction/modelGeneration/massBalance/checkBalance.m` line 92 (any(..., 1)); help: printLevel default 1; NOTE
- [X] T030 [US1] Coverage run; ledger TESTED; blocked reasons drop checkBalance; registry; `--check`, `--verify-coverage`
- [X] T031 [US2] Impact: old and new dE on the shipped test models; tests of checkMassChargeBalance and its callers; report
- [X] T032 Commit

## Phase 8: setCplexParametersForProblem (approved 2026-11-23, option A)

- [X] T033 [US1] Test first: full `test/verifiedTests/base/testSolvers/testSetCplexParametersForProblem.m` (no earlier full version): a hand-built stand-in for the Cplex object (setDefault, Param, DisplayFunc, Start); display, the four log destinations (file in a tempname folder), tolerances, MIP parameters, qpmethod, lpmethod, the MIQP method codes and names, the solver-specific fields, the errors; see it fail on the current code
- [X] T034 [US1] Fix `src/base/solvers/cplex/setCplexParametersForProblem.m` (no barrier default after an MIQP method name); help NOTE
- [X] T035 [US1] Coverage run; ledger TESTED; blocked reasons drop setCplexParametersForProblem; registry; `--check`, `--verify-coverage`
- [X] T036 [US2] Impact: callers solveCobraLP/QP/MILP/MIQP (ibm_cplex branch, CPLEX not installed here: only the parameter structure can be checked); run their tests; report
- [X] T037 Commit

Added after each review.

## Final Phase: unblocked functions, records, push

- [X] T090 [US3] Tests for the functions whose blockers are all cleared
- [X] T091 Registry, ledger checks, receipt, privacy scan, commit, push the branch (the seven fixes)
- [X] T092 After T090: registry, ledger checks, second receipt, privacy scan, commit (push when the maintainer asks)
