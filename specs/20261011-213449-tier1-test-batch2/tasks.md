---

description: "Task list for the Tier-1 test coverage batch 2 (50 functions)"
---

# Tasks: Tier-1 test coverage batch 2 (50 functions)

**Input**: Design documents from `/specs/20261011-213449-tier1-test-batch2/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md) (selection table = source of truth for
function, test file and folder), [research.md](research.md), [data-model.md](data-model.md),
[quickstart.md](quickstart.md)

**Tests**: The deliverable IS the tests. No `src` file may change (III-Characterization).

## Rules every test-writing task follows (constitution III-Coverage / III-Naming; not restated)

Per test file: read the source; call the function in MATLAB (`matlab -batch`) with small
hand-built inputs to record current behaviour; write the test with the standard header,
`currentDir`/`fileDir`/`cd(fileDir)`, `prepareTest()`, shared inputs before the first `%%`
section, one `%%` section per branch with commented assertion groups, `cd(currentDir)`.
Pin defects and quirks, never fix them. If the function turns out to need a model, file,
solver, toolbox or display, STOP that task and replace it from the spec's reserve list
(probe first), reporting the swap. Never put personal information in specs/ files.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [X] T001 Confirm baseline: `git diff --stat -- src` is empty, MATLAB R2025a runs, `initCobraToolbox(false)` succeeds; create the new test folders listed in spec.md (empty folders are not tracked; they appear with their first test).
- [X] T002 Create the throwaway coverage runner and harness runner script in the session scratchpad (not committed): runs `runScriptFile` from `test/` and `CodeCoveragePlugin.forFile` with Cobertura output (`hits` attribute precedes `number`), printing status and covered/total lines for a list of test/source pairs.
- [X] T003 Read two sibling tests (`test/verifiedTests/base/testTools/testSplitString.m` and `test/verifiedTests/reconstruction/testModelManipulation/testGetMetAbbr.m`) and match header and boilerplate style.

---

## Phase 2: User Story 1 - first ten tests, then validation checkpoint (Priority: P1) 🎯 MVP

**Goal**: rows 1-10 of the spec table, reviewed before anything else is written.

### Test folder `test/verifiedTests/analysis/testExploration`

- [X] T004 [P] [US1] Row 1: write `test/verifiedTests/analysis/testExploration/testFindMatchingFieldEntries.m` for `src/analysis/exploration/findMatchingFieldEntries.m` (probe, test, run via harness runner, measure coverage).
- [X] T005 [P] [US1] Row 2: write `test/verifiedTests/analysis/testExploration/testNumToFormattedString.m` for `src/analysis/exploration/surfNetSubfunctions/numToFormattedString.m` (probe, test, run via harness runner, measure coverage).
- [X] T006 [US1] Run the 2 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/analysis/testPersephone`

- [X] T007 [P] [US1] Row 3: write `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m` for `src/analysis/persephone/calculateMetrics.m` (probe, test, run via harness runner, measure coverage).
- [X] T008 [US1] Run the 1 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/analysis/testRumba`

- [X] T009 [P] [US1] Row 4: write `test/verifiedTests/analysis/testRumba/testCompareConditions.m` for `src/analysis/rumba/compareConditions.m` (probe, test, run via harness runner, measure coverage).
- [X] T010 [US1] Run the 1 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/analysis/testSubspaces`

- [X] T011 [P] [US1] Row 5: write `test/verifiedTests/analysis/testSubspaces/testGmscale.m` for `src/analysis/subspaces/gmscale.m` (probe, test, run via harness runner, measure coverage).
- [X] T012 [US1] Run the 1 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/analysis/testThermo`

- [X] T013 [P] [US1] Row 6: write `test/verifiedTests/analysis/testThermo/testReaction2sparse.m` for `src/analysis/thermo/componentContribution/reaction2sparse.m` (probe, test, run via harness runner, measure coverage).
- [X] T014 [P] [US1] Row 7: write `test/verifiedTests/analysis/testThermo/testLogmod.m` for `src/analysis/thermo/utilities/logmod.m` (probe, test, run via harness runner, measure coverage).
- [X] T015 [P] [US1] Row 8: write `test/verifiedTests/analysis/testThermo/testMaxstar.m` for `src/analysis/thermo/utilities/maxstar.m` (probe, test, run via harness runner, measure coverage).
- [X] T016 [US1] Run the 3 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/analysis/testTopology`

- [X] T017 [P] [US1] Row 9: write `test/verifiedTests/analysis/testTopology/testCreateBIGraph.m` for `src/analysis/topology/reactingMoieties/createBIGraph.m` (probe, test, run via harness runner, measure coverage).
- [X] T018 [US1] Run the 1 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/analysis/testWholeBody`

- [X] T019 [P] [US1] Row 10: write `test/verifiedTests/analysis/testWholeBody/testCalculateFoodScore.m` for `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateFoodScore.m` (probe, test, run via harness runner, measure coverage).
- [X] T020 [US1] Run the 1 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

- [ ] T021 [US1] CHECKPOINT: stop. Commit locally, report rows 1-10 (coverage table, quirks pinned, any swaps) and WAIT for maintainer approval before Phase 3. Do not start Phase 3 without approval.

---

## Phase 3: User Story 2 - remaining 40 tests, grouped by source folder (Priority: P2)

**Goal**: rows 11-50, one group at a time; each group independently verifiable.

### Test folder `test/verifiedTests/analysis/testWholeBody`

- [ ] T022 [P] [US2] Row 11: write `test/verifiedTests/analysis/testWholeBody/testCompareDiets.m` for `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/compareDiets.m` (probe, test, run via harness runner, measure coverage).
- [ ] T023 [P] [US2] Row 12: write `test/verifiedTests/analysis/testWholeBody/testConvertNutrientsToMmol.m` for `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/convertNutrientsToMmol.m` (probe, test, run via harness runner, measure coverage).
- [ ] T024 [P] [US2] Row 13: write `test/verifiedTests/analysis/testWholeBody/testSearcher.m` for `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m` (probe, test, run via harness runner, measure coverage).
- [ ] T025 [P] [US2] Row 14: write `test/verifiedTests/analysis/testWholeBody/testCalculateBMR.m` for `src/analysis/wholeBody/PSCMToolbox/calculateBMR.m` (probe, test, run via harness runner, measure coverage).
- [ ] T026 [P] [US2] Row 15: write `test/verifiedTests/analysis/testWholeBody/testCompareMaleFemale.m` for `src/analysis/wholeBody/PSCMToolbox/compareMaleFemale.m` (probe, test, run via harness runner, measure coverage).
- [ ] T027 [US2] Run the 5 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/base/testCardOpt`

- [ ] T028 [P] [US2] Row 16: write `test/verifiedTests/base/testCardOpt/testEvalObj.m` for `src/base/solvers/cardOpt/sparseLP/evalObj.m` (probe, test, run via harness runner, measure coverage).
- [ ] T029 [P] [US2] Row 17: write `test/verifiedTests/base/testCardOpt/testUpdateObj.m` for `src/base/solvers/cardOpt/sparseLP/updateObj.m` (probe, test, run via harness runner, measure coverage).
- [ ] T030 [US2] Run the 2 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/base/testIO/testUtilities`

- [ ] T031 [P] [US2] Row 18: write `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` for `src/base/io/utilities/SBML/getDataBases.m` (probe, test, run via harness runner, measure coverage).
- [ ] T032 [P] [US2] Row 19: write `test/verifiedTests/base/testIO/testUtilities/testParseSBMLAnnotationField.m` for `src/base/io/utilities/parseSBMLAnnotationField.m` (probe, test, run via harness runner, measure coverage).
- [ ] T033 [P] [US2] Row 20: write `test/verifiedTests/base/testIO/testUtilities/testParseSBMLAnnotationFieldRxn.m` for `src/base/io/utilities/parseSBMLAnnotationFieldRxn.m` (probe, test, run via harness runner, measure coverage).
- [ ] T034 [P] [US2] Row 21: write `test/verifiedTests/base/testIO/testUtilities/testParseSBMLNotesField.m` for `src/base/io/utilities/parseSBMLNotesField.m` (probe, test, run via harness runner, measure coverage).
- [ ] T035 [US2] Run the 4 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/base/testSolvers`

- [ ] T036 [P] [US2] Row 22: write `test/verifiedTests/base/testSolvers/testInitialBDCA.m` for `src/base/solvers/varKin/BDCAmethods/InitialBDCA.m` (probe, test, run via harness runner, measure coverage).
- [ ] T037 [P] [US2] Row 23: write `test/verifiedTests/base/testSolvers/testStopCritBDCA.m` for `src/base/solvers/varKin/BDCAmethods/StopCritBDCA.m` (probe, test, run via harness runner, measure coverage).
- [ ] T038 [P] [US2] Row 24: write `test/verifiedTests/base/testSolvers/testInitialDuplo.m` for `src/base/solvers/varKin/derFreeMethods/InitialDuplo.m` (probe, test, run via harness runner, measure coverage).
- [ ] T039 [P] [US2] Row 25: write `test/verifiedTests/base/testSolvers/testStopCritDuplo.m` for `src/base/solvers/varKin/derFreeMethods/StopCritDuplo.m` (probe, test, run via harness runner, measure coverage).
- [ ] T040 [P] [US2] Row 26: write `test/verifiedTests/base/testSolvers/testInitialization.m` for `src/base/solvers/varKin/levMarMethods/Initialization.m` (probe, test, run via harness runner, measure coverage).
- [ ] T041 [US2] Run the 5 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/base/testTools`

- [ ] T042 [P] [US2] Row 27: write `test/verifiedTests/base/testTools/testHyperlink.m` for `src/base/hyperlink.m` (probe, test, run via harness runner, measure coverage).
- [ ] T043 [P] [US2] Row 28: write `test/verifiedTests/base/testTools/testParseGPR.m` for `src/base/parseGPR.m` (probe, test, run via harness runner, measure coverage).
- [ ] T044 [P] [US2] Row 29: write `test/verifiedTests/base/testTools/testParseMetNames.m` for `src/base/parseMetNames.m` (probe, test, run via harness runner, measure coverage).
- [ ] T045 [P] [US2] Row 30: write `test/verifiedTests/base/testTools/testPreparseGPR.m` for `src/base/preparseGPR.m` (probe, test, run via harness runner, measure coverage).
- [ ] T046 [P] [US2] Row 31: write `test/verifiedTests/base/testTools/testCalcDist.m` for `src/base/utilities/calcDist.m` (probe, test, run via harness runner, measure coverage).
- [ ] T047 [US2] Run the 5 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/dataIntegration/testChemoInformatics`

- [ ] T048 [P] [US2] Row 32: write `test/verifiedTests/dataIntegration/testChemoInformatics/testEditChemicalFormula.m` for `src/dataIntegration/chemoInformatics/editChemicalFormula.m` (probe, test, run via harness runner, measure coverage).
- [ ] T049 [P] [US2] Row 33: write `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m` for `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` (probe, test, run via harness runner, measure coverage).
- [ ] T050 [US2] Run the 2 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/dataIntegration/testFitC13Data`

- [ ] T051 [P] [US2] Row 34: write `test/verifiedTests/dataIntegration/testFitC13Data/testCombination.m` for `src/dataIntegration/fluxomics/c13solver/Combination.m` (probe, test, run via harness runner, measure coverage).
- [ ] T052 [P] [US2] Row 35: write `test/verifiedTests/dataIntegration/testFitC13Data/testSolveLin.m` for `src/dataIntegration/fluxomics/c13solver/solveLin.m` (probe, test, run via harness runner, measure coverage).
- [ ] T053 [P] [US2] Row 36: write `test/verifiedTests/dataIntegration/testFitC13Data/testScore_ridge.m` for `src/dataIntegration/fluxomics/score_ridge.m` (probe, test, run via harness runner, measure coverage).
- [ ] T054 [US2] Run the 3 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/dataIntegration/testMetaboAnnotator`

- [ ] T055 [P] [US2] Row 37: write `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCleanUpMetabolite_structure.m` for `src/dataIntegration/metaboAnnotator/buildMetStruct/cleanUpMetabolite_structure.m` (probe, test, run via harness runner, measure coverage).
- [ ] T056 [P] [US2] Row 38: write `test/verifiedTests/dataIntegration/testMetaboAnnotator/testRemoveSmilesInchiKey.m` for `src/dataIntegration/metaboAnnotator/buildMetStruct/removeSmilesInchiKey.m` (probe, test, run via harness runner, measure coverage).
- [ ] T057 [US2] Run the 2 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/design`

- [ ] T058 [P] [US2] Row 39: write `test/verifiedTests/design/testAnalyzeRxns.m` for `src/design/analyzeRxns.m` (probe, test, run via harness runner, measure coverage).
- [ ] T059 [P] [US2] Row 40: write `test/verifiedTests/design/testSeperateTransposeJoinOE.m` for `src/design/optEnvelope/seperateTransposeJoinOE.m` (probe, test, run via harness runner, measure coverage).
- [ ] T060 [US2] Run the 2 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/reconstruction/testDemeter`

- [ ] T061 [P] [US2] Row 41: write `test/verifiedTests/reconstruction/testDemeter/testCheckInputData.m` for `src/reconstruction/demeter/src/integration/checkInputData.m` (probe, test, run via harness runner, measure coverage).
- [ ] T062 [P] [US2] Row 42: write `test/verifiedTests/reconstruction/testDemeter/testMapMediumData2AGORA.m` for `src/reconstruction/demeter/src/integration/mapMediumData2AGORA.m` (probe, test, run via harness runner, measure coverage).
- [ ] T063 [US2] Run the 2 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/reconstruction/testModelBorgifier`

- [ ] T064 [P] [US2] Row 43: write `test/verifiedTests/reconstruction/testModelBorgifier/testBuildRxnEquations.m` for `src/reconstruction/comparison/modelBorgifier/buildRxnEquations.m` (probe, test, run via harness runner, measure coverage).
- [ ] T065 [P] [US2] Row 44: write `test/verifiedTests/reconstruction/testModelBorgifier/testBuildRxnEquationsFromName.m` for `src/reconstruction/comparison/modelBorgifier/buildRxnEquationsFromName.m` (probe, test, run via harness runner, measure coverage).
- [ ] T066 [P] [US2] Row 45: write `test/verifiedTests/reconstruction/testModelBorgifier/testNewCompsNewMets.m` for `src/reconstruction/comparison/modelBorgifier/newCompsNewMets.m` (probe, test, run via harness runner, measure coverage).
- [ ] T067 [P] [US2] Row 46: write `test/verifiedTests/reconstruction/testModelBorgifier/testRemoveDuplicateNames.m` for `src/reconstruction/comparison/modelBorgifier/removeDuplicateNames.m` (probe, test, run via harness runner, measure coverage).
- [ ] T068 [US2] Run the 4 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/reconstruction/testModelManipulation`

- [ ] T069 [P] [US2] Row 47: write `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m` for `src/reconstruction/refinement/GPRLogic/combineChildren.m` (probe, test, run via harness runner, measure coverage).
- [ ] T070 [P] [US2] Row 48: write `test/verifiedTests/reconstruction/testModelManipulation/testConvertIrrevFluxDistribution.m` for `src/reconstruction/refinement/convertIrrevFluxDistribution.m` (probe, test, run via harness runner, measure coverage).
- [ ] T071 [P] [US2] Row 49: write `test/verifiedTests/reconstruction/testModelManipulation/testReassignFwBwMatch.m` for `src/reconstruction/refinement/reassignFwBwMatch.m` (probe, test, run via harness runner, measure coverage).
- [ ] T072 [US2] Run the 3 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

### Test folder `test/verifiedTests/visualization/testReconMap`

- [ ] T073 [P] [US2] Row 50: write `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m` for `src/visualization/maps/ReconMap/makeColorGradient.m` (probe, test, run via harness runner, measure coverage).
- [ ] T074 [US2] Run the 1 test(s) above through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption in the header; record covered/total per function.

---

## Phase 4: User Story 3 - whole-batch verification and receipt (Priority: P3)

- [ ] T075 [US3] Run all 50 tests together through `runScriptFile` from `test/`; record pass count and total time (target under 5 minutes).
- [ ] T076 [US3] Verify `git diff --stat -- src` is empty, `git status --short` shows only the 50 new test files and this feature folder, no test created any file, and each function name appears in exactly one test file (SC-001, SC-003, SC-004, SC-007).
- [ ] T077 [US3] Read every header: purpose, function path, Tier 1, coverage exemptions, known defects pinned, authors/date; `prepareTest()` present after `cd(fileDir)`; comment on every assertion group (SC-005).
- [ ] T078 [US3] Scan every file under `specs/20261011-213449-tier1-test-batch2/` for personal information (names, emails, account names) and remove any (FR-011, SC-008).
- [ ] T079 [US3] Write the implementation receipt at `specs/20261011-213449-tier1-test-batch2/agent-runs/<UTC-timestamp>-tier1-test-batch2/implementation-receipt.md` with Prompt, Final response, Diff summary, Tests (covered/total for all 50), Unresolved issues; no personal information.
- [ ] T080 [US3] Commit (author from the local git configuration, no co-author line), do not push, report files changed, checks run, passed/failed, behaviours not verified, and stop for maintainer validation (SC-006).

---

## Dependencies & Execution Order

- Phase 1 -> Phase 2 -> CHECKPOINT (maintainer approval) -> Phase 3 -> Phase 4.
- Within a folder group the test-writing tasks are `[P]` (different files); the group's
  run-and-measure task follows them.
- Commit after each folder group (local only).

## Implementation Strategy

MVP = rows 1-10 (Phase 2). Present them for review, apply style feedback to those ten, then
carry the feedback into the remaining forty. Total tasks: 80.
