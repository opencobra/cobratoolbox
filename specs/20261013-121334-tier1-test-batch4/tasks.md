---

description: "Task list for the Tier-1 test coverage batch 4"
---

# Tasks: Tier-1 test coverage batch 4 (functions found by a second scan)

**Input**: Design documents from `specs/20261013-121334-tier1-test-batch4/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md) (selection table = source of truth), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: the deliverable IS the tests. No `src/` file may change; no defective behaviour may be asserted. A function that cannot be tested faithfully is not written; its task is closed as DROPPED and the reason is added to `dropped-functions.md`.

## Rules every test-writing task follows (constitution III-Coverage / III-Naming / III-Defects; not restated)

Per test file: read the source; call the function in MATLAB (`matlab -batch`) with small hand-built inputs to record current behaviour; write the test with the standard header (`Function under test:`, `Known defects documented (NOT tested, NOT fixed here):` in the standard entry format or `None found.`), `currentDir`/`fileDir`/`cd(fileDir)`, `prepareTest()`, shared inputs before the first `%` section, one `%` section per branch with commented assertion groups, `cd(currentDir)`. Never change a function under `src/`. A defect is documented and its input skipped (the uncovered lines are listed as exemptions); never assert defective behaviour. If a function turns out to need a file, model, solver, MATLAB toolbox or display, DROP it, and report the drop with the reason. Sections must not rely on variables from earlier sections. Never put personal information in any file.


## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Confirm the baseline: on `develop`, `git diff --stat -- src` empty, MATLAB R2025a runs, `initCobraToolbox(false)` succeeds, `python3 .github/scripts/known_defects.py --check` passes.
- [x] T002 Prepare the throwaway coverage/harness runner in the session scratchpad (not committed): runs `runScriptFile` from `test/` and the code-coverage plugin per test/source pair, reports status, covered/total lines and failing sections.
- [x] T003 Confirm that every new test name is unique under `test/`, and that no function name of the selection table is also a MATLAB built-in or an `external/` function (`which -all`).

---

## Phase 2: User Story 1 - the first ten functions, then validation checkpoint (Priority: P1) MVP

### Test folder `test/verifiedTests/analysis/testExploration`

- [x] T004 [P] [US1] Row: write `test/verifiedTests/analysis/testExploration/testFindEpistaticInteractions.m` for `src/analysis/exploration/findEpistaticInteractions.m` (probe, test, run via harness runner, measure coverage).
- [x] T005 [P] [US1] Row: write `test/verifiedTests/analysis/testExploration/testFindHiCarbonRxns.m` for `src/analysis/exploration/findHiCarbonRxns.m` (probe, test, run via harness runner, measure coverage).
- [x] T006 [P] [US1] Row: write `test/verifiedTests/analysis/testExploration/testFindRootNPmets.m` for `src/analysis/exploration/findRootNPmets.m` (probe, test, run via harness runner, measure coverage).
- [x] T007 [P] [US1] Row: write `test/verifiedTests/analysis/testExploration/testFindRxnsActiveWithGenes.m` for `src/analysis/exploration/findRxnsActiveWithGenes.m` (probe, test, run via harness runner, measure coverage).
- [x] T008 [P] [US1] Row: write `test/verifiedTests/analysis/testExploration/testFindRxnsInActiveWithGenes.m` for `src/analysis/exploration/findRxnsInActiveWithGenes.m` (probe, test, run via harness runner, measure coverage).
- [x] T009 [P] [US1] Row: write `test/verifiedTests/analysis/testExploration/testGetObjectiveSense.m` for `src/analysis/exploration/getObjectiveSense.m` (probe, test, run via harness runner, measure coverage).
- [x] T010 [US1] Run the tests of `analysis/testExploration` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testAdditionalAnalysis`

- [x] T011 [P] [US1] Row: write `test/verifiedTests/analysis/testAdditionalAnalysis/testInorder.m` for `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/inorder.m` (probe, test, run via harness runner, measure coverage).
- [x] T012 [US1] Run the tests of `analysis/testAdditionalAnalysis` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testNutritionAlgorithm`

- [x] T013 [P] [US1] Row: write `test/verifiedTests/analysis/testNutritionAlgorithm/testGetMolFormula.m` for `src/analysis/nutritionAlgorithm/getMolFormula.m` (probe, test, run via harness runner, measure coverage).
- [x] T014 [US1] Run the tests of `analysis/testNutritionAlgorithm` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testSampling`

- [x] T015 [P] [US1] Row: write `test/verifiedTests/analysis/testSampling/testConvRevSamples.m` for `src/analysis/sampling/ACHR/convRevSamples.m` (probe, test, run via harness runner, measure coverage).
- [x] T016 [P] [US1] Row: write `test/verifiedTests/analysis/testSampling/testSetField.m` for `src/analysis/sampling/BarrierRound/utils/setField.m` (probe, test, run via harness runner, measure coverage).
- [x] T017 [US1] Run the tests of `analysis/testSampling` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

- [x] T018 [US1] CHECKPOINT: regenerate the registry, commit locally, report these ten (coverage table, defects, drops) and WAIT for maintainer approval before Phase 3. Do not start Phase 3 without it.

---

## Phase 3: User Story 2 - remaining small and medium functions, grouped by folder (Priority: P2)

### Test folder `test/verifiedTests/analysis/testExploration`

- [x] T019 [P] [US2] Row: write `test/verifiedTests/analysis/testExploration/testFindOrphanRxns.m` for `src/analysis/exploration/findOrphanRxns.m` (probe, test, run via harness runner, measure coverage).
- [x] T020 [P] [US2] Row: write `test/verifiedTests/analysis/testExploration/testPrintRxnFormulaLinked.m` for `src/analysis/exploration/surfNetSubfunctions/printRxnFormulaLinked.m` (probe, test, run via harness runner, measure coverage).
- [x] T021 [US2] Run the tests of `analysis/testExploration` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testMgPipe`

- [x] T022 [P] [US2] Row: write `test/verifiedTests/analysis/testMgPipe/testMakeDummyModel.m` for `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/makeDummyModel.m` (probe, test, run via harness runner, measure coverage).
- [x] T023 [US2] Run the tests of `analysis/testMgPipe` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testPersephone`

- [x] T024 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testConvertToStr.m` for `src/analysis/persephone/additionalFunctions/convertToStr.m` (probe, test, run via harness runner, measure coverage).
- [x] T025 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testCreateForestPlot.m` for `src/analysis/persephone/createForestPlot.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T026 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testCreateVolcanoPlot.m` for `src/analysis/persephone/createVolcanoPlot.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T027 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testFindPvalCategories.m` for `src/analysis/persephone/findPvalCategories.m` (probe, test, run via harness runner, measure coverage).
- [x] T028 [US2] Run the tests of `analysis/testPersephone` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testRMTA`

- [x] T029 [P] [US2] Row: write `test/verifiedTests/analysis/testRMTA/testMTA_TS.m` for `src/analysis/rMTA/MTA_TS.m` (probe, test, run via harness runner, measure coverage).
- [x] T030 [P] [US2] Row: write `test/verifiedTests/analysis/testRMTA/testBuildMTAproblemFromModel.m` for `src/analysis/rMTA/buildMTAproblemFromModel.m` (probe, test, run via harness runner, measure coverage).
- [x] T031 [US2] Run the tests of `analysis/testRMTA` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testRelaxedFBA`

- [x] T032 [P] [US2] Row: write `test/verifiedTests/analysis/testRelaxedFBA/testPlotRelaxedFBA.m` for `src/analysis/relaxedFBA/plotRelaxedFBA.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T033 [US2] Run the tests of `analysis/testRelaxedFBA` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testRumba`

- [x] T034 [P] [US2] Row: write `test/verifiedTests/analysis/testRumba/testAddMissingReactions.m` for `src/analysis/rumba/addMissingReactions.m` (probe, test, run via harness runner, measure coverage).
- [x] T035 [P] [US2] Row: write `test/verifiedTests/analysis/testRumba/testPValDistForModelOverlap.m` for `src/analysis/rumba/pValDistForModelOverlap.m` (probe, test, run via harness runner, measure coverage).
- [x] T036 [US2] Run the tests of `analysis/testRumba` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testSampling`

- [x] T037 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testRemoveCorrelRxns.m` for `src/analysis/sampling/ACHR/removeCorrelRxns.m` (probe, test, run via harness runner, measure coverage).
- [x] T038 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testConfigCMatrix.m` for `src/analysis/sampling/BarrierRound/CMatrix/configCMatrix.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T039 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testConfigPolytopeSimplifier.m` for `src/analysis/sampling/BarrierRound/PolytopeSimplifier/configPolytopeSimplifier.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T040 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testStandardize_problem.m` for `src/analysis/sampling/BarrierRound/PolytopeSimplifier/standardize_problem.m` (probe, test, run via harness runner, measure coverage).
- [x] T041 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testFullification.m` for `src/analysis/sampling/BarrierRound/fullification.m` (probe, test, run via harness runner, measure coverage).
- [x] T042 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testGetField.m` for `src/analysis/sampling/BarrierRound/utils/getField.m` (probe, test, run via harness runner, measure coverage).
- [x] T043 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testLoadModular.m` for `src/analysis/sampling/BarrierRound/utils/loadModular.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T044 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testChrrExpSampler.m` for `src/analysis/sampling/CHRR/chrrExpSampler.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T045 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testChrrParseModel.m` for `src/analysis/sampling/CHRR/chrrParseModel.m` (probe, test, run via harness runner, measure coverage).
- [x] T046 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testCalcSampleDifference.m` for `src/analysis/sampling/calcSampleDifference.m` (probe, test, run via harness runner, measure coverage).
- [x] T047 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testIdentifyCorrelSets.m` for `src/analysis/sampling/identifyCorrelSets.m` (probe, test, run via harness runner, measure coverage).
- [x] T048 [US2] Run the tests of `analysis/testSampling` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testSubspaces`

- [x] T049 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testAprod.m` for `src/analysis/subspaces/lsqr/aprod.m` (probe, test, run via harness runner, measure coverage).
- [x] T050 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testCgls.m` for `src/analysis/subspaces/lsqr/cgls.m` (probe, test, run via harness runner, measure coverage).
- [x] T051 [US2] Run the tests of `analysis/testSubspaces` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testNullspace`

- [x] T052 [P] [US2] Row: write `test/verifiedTests/analysis/testNullspace/testNullspaceLUSOLapply2Modes.m` for `src/analysis/subspaces/nullspace/nullspaceLUSOLapply2Modes.m` (probe, test, run via harness runner, measure coverage).
- [x] T053 [US2] Run the tests of `analysis/testNullspace` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testSubspaces`

- [x] T054 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testProjectSVD.m` for `src/analysis/subspaces/subspaceProjection/projectSVD.m` (probe, test, run via harness runner, measure coverage).
- [x] T055 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testSubspaceSVD.m` for `src/analysis/subspaces/subspaceProjection/subspaceSVD.m` (probe, test, run via harness runner, measure coverage).
- [x] T056 [US2] Run the tests of `analysis/testSubspaces` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testThermo`

- [x] T057 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testAssignQualDir.m` for `src/analysis/thermo/directionalityReport/assignQualDir.m` (probe, test, run via harness runner, measure coverage).
- [x] T058 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testCompareQualAndQuantDir.m` for `src/analysis/thermo/directionalityReport/compareQualAndQuantDir.m` (probe, test, run via harness runner, measure coverage).
- [x] T059 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m` for `src/analysis/thermo/inchi/getMolecularWeight.m` (probe, test, run via harness runner, measure coverage).
- [x] T060 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testSingleMetaboliteSpeciesReaction.m` for `src/analysis/thermo/reactantContribution/singleMetaboliteSpeciesReaction.m` (probe, test, run via harness runner, measure coverage).
- [x] T061 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testWaterGibbsEnergyOfFormation.m` for `src/analysis/thermo/reactantContribution/waterGibbsEnergyOfFormation.m` (probe, test, run via harness runner, measure coverage).
- [x] T062 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testAssignQuantDir.m` for `src/analysis/thermo/thermoDirectionality/assignQuantDir.m` (probe, test, run via harness runner, measure coverage).
- [x] T063 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testDGfzeroGroupContToBiochemical.m` for `src/analysis/thermo/thermoDirectionality/dGfzeroGroupContToBiochemical.m` (probe, test, run via harness runner, measure coverage).
- [x] T064 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testPrintDirectionalityFromBounds.m` for `src/analysis/thermo/thermoFBA/printDirectionalityFromBounds.m` (probe, test, run via harness runner, measure coverage).
- [x] T065 [US2] Run the tests of `analysis/testThermo` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testTopology`

- [x] T066 [P] [US2] Row: write `test/verifiedTests/analysis/testTopology/testCombinatorialDependentRows.m` for `src/analysis/topology/FR/combinatorialDependentRows.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T067 [P] [US2] Row: write `test/verifiedTests/analysis/testTopology/testConnectedFR.m` for `src/analysis/topology/FR/connectedFR.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T068 [P] [US2] Row: write `test/verifiedTests/analysis/testTopology/testLargestConnectedFR.m` for `src/analysis/topology/FR/largestConnectedFR.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T069 [P] [US2] Row: write `test/verifiedTests/analysis/testTopology/testIntegerizeS.m` for `src/analysis/topology/integerizeS.m` (probe, test, run via harness runner, measure coverage).
- [x] T070 [US2] Run the tests of `analysis/testTopology` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testTransport`

- [x] T071 [P] [US2] Row: write `test/verifiedTests/analysis/testTransport/testFindTransRxns.m` for `src/analysis/transport/findTransRxns.m` (probe, test, run via harness runner, measure coverage).
- [x] T072 [US2] Run the tests of `analysis/testTransport` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testWholeBody`

- [x] T073 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testCalculateMacroOriginalDiet.m` for `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateMacroOriginalDiet.m` (probe, test, run via harness runner, measure coverage).
- [x] T074 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testExtractDietFromModel.m` for `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/extractDietFromModel.m` (probe, test, run via harness runner, measure coverage).
- [x] T075 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testIsValidVmhID.m` for `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m` (probe, test, run via harness runner, measure coverage).
- [x] T076 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testAdjustWholeBodyRxnCoeff.m` for `src/analysis/wholeBody/PSCMToolbox/adjustWholeBodyRxnCoeff.m` (probe, test, run via harness runner, measure coverage).
- [x] T077 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testCompareBounds2Models.m` for `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m` (probe, test, run via harness runner, measure coverage).
- [x] T078 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testConvertATPflux2StepNumer.m` for `src/analysis/wholeBody/PSCMToolbox/convertATPflux2StepNumer.m` (probe, test, run via harness runner, measure coverage).
- [x] T079 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testDetermineFluxValuesOnBoundary.m` for `src/analysis/wholeBody/PSCMToolbox/determineFluxValuesOnBoundary.m` (probe, test, run via harness runner, measure coverage).
- [x] T080 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testFindMetinOrgan.m` for `src/analysis/wholeBody/PSCMToolbox/findMetinOrgan.m` (probe, test, run via harness runner, measure coverage).
- [x] T081 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testGetBasicHarveyStats.m` for `src/analysis/wholeBody/PSCMToolbox/getBasicHarveyStats.m` (probe, test, run via harness runner, measure coverage).
- [x] T082 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testGetListOfUniqueIsozymes.m` for `src/analysis/wholeBody/PSCMToolbox/getListOfUniqueIsozymes.m` (probe, test, run via harness runner, measure coverage).
- [x] T083 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testGetRxnsFromGene.m` for `src/analysis/wholeBody/PSCMToolbox/getRxnsFromGene.m` (probe, test, run via harness runner, measure coverage).
- [x] T084 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testSetSimulationConstraints.m` for `src/analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/setSimulationConstraints.m` (probe, test, run via harness runner, measure coverage).
- [x] T085 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testLinearRegression.m` for `src/analysis/wholeBody/PSCMToolbox/linearRegression.m` (probe, test, run via harness runner, measure coverage).
- [x] T086 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testSetDietConstraints.m` for `src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T087 [P] [US2] Row: write `test/verifiedTests/analysis/testWholeBody/testHomogeniseCouplingConstraints.m` for `src/analysis/wholeBody/io/homogeniseCouplingConstraints.m` (probe, test, run via harness runner, measure coverage).
- [x] T088 [US2] Run the tests of `analysis/testWholeBody` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testInstall`

- [x] T089 [P] [US2] Row: write `test/verifiedTests/base/testInstall/testAddCOBRABinaryPathToSystemPath.m` for `src/base/install/addCOBRABinaryPathToSystemPath.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T090 [P] [US2] Row: write `test/verifiedTests/base/testInstall/testGetGitBashVersion.m` for `src/base/install/getGitBashVersion.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T091 [US2] Run the tests of `base/testInstall` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testIO`

- [x] T092 [P] [US2] Row: write `test/verifiedTests/base/testIO/testMapKEGGID2Model.m` for `src/base/io/KEGG/mapKEGGID2Model.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T093 [P] [US2] Row: write `test/verifiedTests/base/testIO/testGetBioQualifiers.m` for `src/base/io/utilities/SBML/getBioQualifiers.m` (probe, test, run via harness runner, measure coverage).
- [x] T094 [P] [US2] Row: write `test/verifiedTests/base/testIO/testGetMultiDimensionFields.m` for `src/base/io/utilities/getMultiDimensionFields.m` (probe, test, run via harness runner, measure coverage).
- [x] T095 [P] [US2] Row: write `test/verifiedTests/base/testIO/testModel2xls.m` for `src/base/io/utilities/model2xls.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T096 [P] [US2] Row: write `test/verifiedTests/base/testIO/testWriteGDXFromCOBRA.m` for `src/base/io/writeGDXFromCOBRA.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T097 [US2] Run the tests of `base/testIO` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testSolvers`

- [x] T098 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testNLPobjPerFlux.m` for `src/base/solvers/NLP/NLPobjPerFlux.m` (probe, test, run via harness runner, measure coverage).
- [x] T099 [US2] Run the tests of `base/testSolvers` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testCardOpt`

- [x] T100 [P] [US2] Row: write `test/verifiedTests/base/testCardOpt/testComputeMutualCoherence.m` for `src/base/solvers/cardOpt/sparseLP/computeMutualCoherence.m` (probe, test, run via harness runner, measure coverage).
- [x] T101 [US2] Run the tests of `base/testCardOpt` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testSolvers`

- [x] T102 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testBuildCplexProblemFromCOBRAStruct.m` for `src/base/solvers/cplex/buildCplexProblemFromCOBRAStruct.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T103 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testCplexStatus.m` for `src/base/solvers/cplex/cplexStatus.m` (probe, test, run via harness runner, measure coverage).
- [x] T104 [US2] Run the tests of `base/testSolvers` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testEntropicFBA`

- [x] T105 [P] [US2] Row: write `test/verifiedTests/base/testEntropicFBA/testPrepareEnzymeConstrainedEP.m` for `src/base/solvers/entropicFBA/prepareEnzymeConstrainedEP.m` (probe, test, run via harness runner, measure coverage).
- [x] T106 [US2] Run the tests of `base/testEntropicFBA` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testSolvers`

- [x] T107 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testMosekParamStrip.m` for `src/base/solvers/mosek/mosekParamStrip.m` (probe, test, run via harness runner, measure coverage).
- [x] T108 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testMergeCobraParams.m` for `src/base/solvers/param/mergeCobraParams.m` (probe, test, run via harness runner, measure coverage).
- [x] T109 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testParseSolverParameters.m` for `src/base/solvers/param/parseSolverParameters.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T110 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testExtended_rate_function.m` for `src/base/solvers/varKin/levMarMethods/Extended_rate_function.m` (probe, test, run via harness runner, measure coverage).
- [x] T111 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testStopCriterion.m` for `src/base/solvers/varKin/levMarMethods/StopCriterion.m` (probe, test, run via harness runner, measure coverage).
- [x] T112 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testLin_sym_solver_mldivide.m` for `src/base/solvers/varKin/levMarMethods/lin_sym_solver_mldivide.m` (probe, test, run via harness runner, measure coverage).
- [x] T113 [US2] Run the tests of `base/testSolvers` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testUtilities`

- [x] T114 [P] [US2] Row: write `test/verifiedTests/base/testUtilities/testApplyToNonNan.m` for `src/base/utilities/applyToNonNan.m` (probe, test, run via harness runner, measure coverage).
- [x] T115 [P] [US2] Row: write `test/verifiedTests/base/testUtilities/testGetDefaultTableRow.m` for `src/base/utilities/getDefaultTableRow.m` (probe, test, run via harness runner, measure coverage).
- [x] T116 [P] [US2] Row: write `test/verifiedTests/base/testUtilities/testRemoveZeroRowsCols.m` for `src/base/utilities/removeZeroRowsCols.m` (probe, test, run via harness runner, measure coverage).
- [x] T117 [US2] Run the tests of `base/testUtilities` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testXomicsToModel`

- [x] T118 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testXomicsToModel/testCoreMetRxnAnalysis.m` for `src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m` (probe, test, run via harness runner, measure coverage).
- [x] T119 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testXomicsToModel/testDestroyDummyModel.m` for `src/dataIntegration/XomicsToModel/oneRxnPerActiveGene/destroyDummyModel.m` (probe, test, run via harness runner, measure coverage).
- [x] T120 [US2] Run the tests of `dataIntegration/testXomicsToModel` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testChemoInformatics`

- [x] T121 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testChemoInformatics/testSortAtomMappingIdx.m` for `src/dataIntegration/chemoInformatics/reactions/sortAtomMappingIdx.m` (probe, test, run via harness runner, measure coverage).
- [x] T122 [US2] Run the tests of `dataIntegration/testChemoInformatics` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testATN`

- [x] T123 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testATN/testExtractElementalTransitionNetwork.m` for `src/dataIntegration/fluxomics/atomTransition/ATN/extractElementalTransitionNetwork.m` (probe, test, run via harness runner, measure coverage).
- [x] T124 [US2] Run the tests of `dataIntegration/testATN` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testC13solver`

- [x] T125 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testC13solver/testCdv2idv.m` for `src/dataIntegration/fluxomics/c13solver/cdv2idv.m` (probe, test, run via harness runner, measure coverage).
- [x] T126 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testC13solver/testIdv2cdv.m` for `src/dataIntegration/fluxomics/c13solver/idv2cdv.m` (probe, test, run via harness runner, measure coverage).
- [x] T127 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testC13solver/testIdv2mdv.m` for `src/dataIntegration/fluxomics/c13solver/idv2mdv.m` (probe, test, run via harness runner, measure coverage).
- [x] T128 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testC13solver/testRatioScore.m` for `src/dataIntegration/fluxomics/c13solver/ratioScore.m` (probe, test, run via harness runner, measure coverage).
- [x] T129 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testC13solver/testRatioScore_grad.m` for `src/dataIntegration/fluxomics/c13solver/ratioScore_grad.m` (probe, test, run via harness runner, measure coverage).
- [x] T130 [US2] Run the tests of `dataIntegration/testC13solver` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testFluxomics`

- [x] T131 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testFluxomics/testGetBinsOfFluxes.m` for `src/dataIntegration/fluxomics/getBinsOfFluxes.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T132 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testFluxomics/testGetRandGlc.m` for `src/dataIntegration/fluxomics/getRandGlc.m` (probe, test, run via harness runner, measure coverage).
- [x] T133 [US2] Run the tests of `dataIntegration/testFluxomics` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testMetaboAnnotator`

- [x] T134 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertModel2Metstructure.m` for `src/dataIntegration/metaboAnnotator/buildMetStruct/convertModel2Metstructure.m` (probe, test, run via harness runner, measure coverage).
- [x] T135 [US2] Run the tests of `dataIntegration/testMetaboAnnotator` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testMOOMIN`

- [x] T136 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testMOOMIN/testWeightFunction.m` for `src/dataIntegration/transcriptomics/MOOMIN/weightFunction.m` (probe, test, run via harness runner, measure coverage).
- [x] T137 [US2] Run the tests of `dataIntegration/testMOOMIN` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testEFlux`

- [x] T138 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testEFlux/testVerifyEFluxExpressionStruct.m` for `src/dataIntegration/transcriptomics/eFlux/verifyEFluxExpressionStruct.m` (probe, test, run via harness runner, measure coverage).
- [x] T139 [US2] Run the tests of `dataIntegration/testEFlux` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testPreprocessing`

- [x] T140 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testPreprocessing/testGPRparser.m` for `src/dataIntegration/transcriptomics/preprocessing/GPRparser.m` (probe, test, run via harness runner, measure coverage).
- [x] T141 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testPreprocessing/testFindUsedGenesLevels.m` for `src/dataIntegration/transcriptomics/preprocessing/findUsedGenesLevels.m` (probe, test, run via harness runner, measure coverage).
- [x] T142 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testPreprocessing/testSelectGeneFromGPR.m` for `src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m` (probe, test, run via harness runner, measure coverage).
- [x] T143 [US2] Run the tests of `dataIntegration/testPreprocessing` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testRFASTCORMICS`

- [x] T144 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testRFASTCORMICS/testGPRrulesMapper.m` for `src/dataIntegration/transcriptomics/rFASTCORMICS/GPRrulesMapper.m` (probe, test, run via harness runner, measure coverage).
- [x] T145 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testRFASTCORMICS/testCreateFitL.m` for `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitL.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T146 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testRFASTCORMICS/testCreateFitR.m` for `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitR.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T147 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testRFASTCORMICS/testFindOrganicExRxns.m` for `src/dataIntegration/transcriptomics/rFASTCORMICS/findOrganicExRxns.m` (probe, test, run via harness runner, measure coverage).
- [x] T148 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testRFASTCORMICS/testFixIrr.m` for `src/dataIntegration/transcriptomics/rFASTCORMICS/fixIrr.m` (probe, test, run via harness runner, measure coverage).
- [x] T149 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testRFASTCORMICS/testMapExpressionToModel.m` for `src/dataIntegration/transcriptomics/rFASTCORMICS/mapExpressionToModel.m` (probe, test, run via harness runner, measure coverage).
- [x] T150 [US2] Run the tests of `dataIntegration/testRFASTCORMICS` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/design/testTrimGdel`

- [x] T151 [P] [US2] Row: write `test/verifiedTests/design/testTrimGdel/testCalculateGR.m` for `src/design/TrimGdel/calculateGR.m` (probe, test, run via harness runner, measure coverage).
- [x] T152 [US2] Run the tests of `design/testTrimGdel` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/design/testDesign`

- [x] T153 [P] [US2] Row: write `test/verifiedTests/design/testDesign/testAugmentBOF.m` for `src/design/augmentBOF.m` (probe, test, run via harness runner, measure coverage).
- [x] T154 [P] [US2] Row: write `test/verifiedTests/design/testDesign/testCreateBilevelMILPproblem.m` for `src/design/createBilevelMILPproblem.m` (probe, test, run via harness runner, measure coverage).
- [x] T155 [US2] Run the tests of `design/testDesign` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testComparison`

- [x] T156 [P] [US2] Row: write `test/verifiedTests/reconstruction/testComparison/testCompareModels.m` for `src/reconstruction/comparison/compareModels.m` (probe, test, run via harness runner, measure coverage).
- [x] T157 [US2] Run the tests of `reconstruction/testComparison` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testModelBorgifier`

- [x] T158 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testTmodelFields.m` for `src/reconstruction/comparison/modelBorgifier/TmodelFields.m` (probe, test, run via harness runner, measure coverage).
- [x] T159 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testCharpos.m` for `src/reconstruction/comparison/modelBorgifier/charpos.m` (probe, test, run via harness runner, measure coverage).
- [x] T160 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testColText.m` for `src/reconstruction/comparison/modelBorgifier/colText.m` (probe, test, run via harness runner, measure coverage).
- [x] T161 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testFindRxnMatch.m` for `src/reconstruction/comparison/modelBorgifier/findRxnMatch.m` (probe, test, run via harness runner, measure coverage).
- [x] T162 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testFixChemFormulas.m` for `src/reconstruction/comparison/modelBorgifier/fixChemFormulas.m` (probe, test, run via harness runner, measure coverage).
- [x] T163 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testFixNames.m` for `src/reconstruction/comparison/modelBorgifier/fixNames.m` (probe, test, run via harness runner, measure coverage).
- [x] T164 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testIsmatlab.m` for `src/reconstruction/comparison/modelBorgifier/ismatlab.m` (probe, test, run via harness runner, measure coverage).
- [x] T165 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testOptWeightExp.m` for `src/reconstruction/comparison/modelBorgifier/optWeightExp.m` (probe, test, run via harness runner, measure coverage).
- [x] T166 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testOptWeightLin.m` for `src/reconstruction/comparison/modelBorgifier/optWeightLin.m` (probe, test, run via harness runner, measure coverage).
- [x] T167 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testOrderModelFieldsBorg.m` for `src/reconstruction/comparison/modelBorgifier/orderModelFieldsBorg.m` (probe, test, run via harness runner, measure coverage).
- [x] T168 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testOrganizeModelCool.m` for `src/reconstruction/comparison/modelBorgifier/organizeModelCool.m` (probe, test, run via harness runner, measure coverage).
- [x] T169 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testRemoveProblematicCharacters.m` for `src/reconstruction/comparison/modelBorgifier/removeProblematicCharacters.m` (probe, test, run via harness runner, measure coverage).
- [x] T170 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testRowvector.m` for `src/reconstruction/comparison/modelBorgifier/rowvector.m` (probe, test, run via harness runner, measure coverage).
- [x] T171 [US2] Run the tests of `reconstruction/testModelBorgifier` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testDemeter`

- [x] T172 [P] [US2] Row: write `test/verifiedTests/reconstruction/testDemeter/testAdaptDraftModelID.m` for `src/reconstruction/demeter/src/integration/adaptDraftModelID.m` (probe, test, run via harness runner, measure coverage).
- [x] T173 [P] [US2] Row: write `test/verifiedTests/reconstruction/testDemeter/testAddRefinementComments.m` for `src/reconstruction/demeter/src/refinement/addRefinementComments.m` (probe, test, run via harness runner, measure coverage).
- [x] T174 [US2] Run the tests of `reconstruction/testDemeter` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testFastGapFill`

- [x] T175 [P] [US2] Row: write `test/verifiedTests/reconstruction/testFastGapFill/testFindIntracellularRxns.m` for `src/reconstruction/fastGapFill/AuxillaryFiles/findIntracellularRxns.m` (probe, test, run via harness runner, measure coverage).
- [x] T176 [US2] Run the tests of `reconstruction/testFastGapFill` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testModelGeneration`

- [x] T177 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelGeneration/testCheckFormulaValidty.m` for `src/reconstruction/modelGeneration/massBalance/checkFormulaValidty.m` (probe, test, run via harness runner, measure coverage).
- [x] T178 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelGeneration/testRegulariseModelFormulae.m` for `src/reconstruction/modelGeneration/massBalance/regulariseModelFormulae.m` (probe, test, run via harness runner, measure coverage).
- [x] T179 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelGeneration/testPrintBiomass.m` for `src/reconstruction/modelGeneration/modelProperties/printBiomass.m` (probe, test, run via harness runner, measure coverage).
- [x] T180 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelGeneration/testCheckPresentFields.m` for `src/reconstruction/modelGeneration/modelVerification/checkPresentFields.m` (probe, test, run via harness runner, measure coverage).
- [x] T181 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelGeneration/testPrintObjective.m` for `src/reconstruction/modelGeneration/printObjective.m` (probe, test, run via harness runner, measure coverage).
- [x] T182 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelGeneration/testSetConstraintsIrrevModel.m` for `src/reconstruction/modelGeneration/setConstraintsIrrevModel.m` (probe, test, run via harness runner, measure coverage).
- [x] T183 [US2] Run the tests of `reconstruction/testModelGeneration` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testRefinement`

- [x] T184 [P] [US2] Row: write `test/verifiedTests/reconstruction/testRefinement/testAssignGPRA.m` for `src/reconstruction/refinement/assignGPRA.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T185 [P] [US2] Row: write `test/verifiedTests/reconstruction/testRefinement/testAssignSubSystems.m` for `src/reconstruction/refinement/assignSubSystems.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T186 [P] [US2] Row: write `test/verifiedTests/reconstruction/testRefinement/testCheckIDsForTypeExist.m` for `src/reconstruction/refinement/checkIDsForTypeExist.m` (probe, test, run via harness runner, measure coverage).
- [x] T187 [P] [US2] Row: write `test/verifiedTests/reconstruction/testRefinement/testDispStoichAsTable.m` for `src/reconstruction/refinement/dispStoichAsTable.m` (probe, test, run via harness runner, measure coverage).
- [x] T188 [P] [US2] Row: write `test/verifiedTests/reconstruction/testRefinement/testFlipRxnOrientation.m` for `src/reconstruction/refinement/flipRxnOrientation.m` (probe, test, run via harness runner, measure coverage).
- [x] T189 [P] [US2] Row: write `test/verifiedTests/reconstruction/testRefinement/testGetEmptyConstraints.m` for `src/reconstruction/refinement/getEmptyConstraints.m` (probe, test, run via harness runner, measure coverage).
- [x] T190 [P] [US2] Row: write `test/verifiedTests/reconstruction/testRefinement/testUpdateMetNames.m` for `src/reconstruction/refinement/updateMetNames.m` (probe, test, run via harness runner, measure coverage).
- [x] T191 [US2] Run the tests of `reconstruction/testRefinement` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/visualization/testEscherMap`

- [x] T192 [P] [US2] Row: write `test/verifiedTests/visualization/testEscherMap/testModel2escher.m` for `src/visualization/EscherMap/model2escher.m` (probe, test, run via harness runner, measure coverage).
- [x] T193 [US2] Run the tests of `visualization/testEscherMap` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/visualization/testSAMMIM`

- [x] T194 [P] [US2] Row: write `test/verifiedTests/visualization/testSAMMIM/testMakeSAMMIJson.m` for `src/visualization/SAMMIM/makeSAMMIJson.m` (probe, test, run via harness runner, measure coverage).
- [x] T195 [P] [US2] Row: write `test/verifiedTests/visualization/testSAMMIM/testMakeSAMMIdataString.m` for `src/visualization/SAMMIM/makeSAMMIdataString.m` (probe, test, run via harness runner, measure coverage).
- [x] T196 [US2] Run the tests of `visualization/testSAMMIM` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/visualization/testCellDesigner`

- [x] T197 [P] [US2] Row: write `test/verifiedTests/visualization/testCellDesigner/testReadCD.m` for `src/visualization/cellDesigner/readCD.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T198 [P] [US2] Row: write `test/verifiedTests/visualization/testCellDesigner/testRetrieveMet.m` for `src/visualization/cellDesigner/retrieveMet.m` (probe, test, run via harness runner, measure coverage).
- [x] T199 [P] [US2] Row: write `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` for `src/visualization/cellDesigner/updateCD.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T200 [US2] Run the tests of `visualization/testCellDesigner` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/visualization/testMetabolicCartography`

- [x] T201 [P] [US2] Row: write `test/verifiedTests/visualization/testMetabolicCartography/testUniqueSpeciesInMap.m` for `src/visualization/metabolicCartography/uniqueSpeciesInMap.m` (probe, test, run via harness runner, measure coverage).
- [x] T202 [US2] Run the tests of `visualization/testMetabolicCartography` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

---

## Phase 4: User Story 3 - the larger functions (Priority: P3)

### Test folder `test/verifiedTests/analysis/testSubspaces`

- [x] T203 [P] [US3] Row: write `test/verifiedTests/analysis/testSubspaces/testConservationAnalysis.m` for `src/analysis/subspaces/conservationAnalysis.m` (probe, test, run via harness runner, measure coverage).
- [x] T204 [US3] Run the tests of `analysis/testSubspaces` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testWholeBody`

- [x] T205 [P] [US3] Row: write `test/verifiedTests/analysis/testWholeBody/testAnnotateModel.m` for `src/analysis/wholeBody/PSCMToolbox/annotateModel.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T206 [P] [US3] Row: write `test/verifiedTests/analysis/testWholeBody/testSetFeedingFastingConstraints.m` for `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T207 [US3] Run the tests of `analysis/testWholeBody` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testSolvers`

- [x] T208 [P] [US3] Row: write `test/verifiedTests/base/testSolvers/testCheckSolFeas.m` for `src/base/solvers/cplex/checkSolFeas.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T209 [US3] Run the tests of `base/testSolvers` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testEntropicFBA`

- [x] T210 [P] [US3] Row: write `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` for `src/base/solvers/entropicFBA/processConcConstraints.m` (probe, test, run via harness runner, measure coverage).
- [x] T211 [US3] Run the tests of `base/testEntropicFBA` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testSolvers`

- [x] T212 [P] [US3] Row: write `test/verifiedTests/base/testSolvers/testSolveCobraLPLindo.m` for `src/base/solvers/lindo/solveCobraLPLindo.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T213 [P] [US3] Row: write `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` for `src/base/solvers/varKin/optimizeVKmodel0.m` (probe, test, run via harness runner, measure coverage). (DROPPED: see dropped-functions.md)
- [x] T214 [US3] Run the tests of `base/testSolvers` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testMetaboAnnotator`

- [x] T215 [P] [US3] Row: write `test/verifiedTests/dataIntegration/testMetaboAnnotator/testReplaceVMHIds.m` for `src/dataIntegration/metaboAnnotator/buildMetStruct/replaceVMHIds.m` (probe, test, run via harness runner, measure coverage).
- [x] T216 [US3] Run the tests of `dataIntegration/testMetaboAnnotator` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

---

## Phase 5: Registry, verification and receipt (User Story 4)

- [x] T217 [US4] Regenerate the registry with `python3 .github/scripts/known_defects.py`; confirm the tool exits 0, every new defect appears once, and no entry is invalid.
- [x] T218 [US4] Run all new tests together through `runScriptFile`; record pass count, section failures and total time (target under 10 minutes).
- [x] T219 [US4] Verify `git diff --stat -- src` is empty, no test created a file, each function name appears in exactly one test file, and no test asserts a defective behaviour (read each defect entry against its assertions).
- [x] T220 [US4] Scan every added or changed file for personal information; none.
- [x] T221 [US4] Write the implementation receipt (Prompt, Final response, Diff summary, Tests with covered/total per function, dropped functions with reasons, Unresolved issues) under `specs/20261013-121334-tier1-test-batch4/agent-runs/<UTC-timestamp>-tier1-test-batch4/`.
- [x] T222 [US4] Commit on `develop` (author from the local git configuration, no co-author line); do not push.

---

## Dependencies & Execution Order

Phase 1 -> Phase 2 -> CHECKPOINT (maintainer approval) -> Phase 3 -> Phase 4 -> Phase 5. Within a folder group the test-writing tasks are `[P]`; the group's run-and-measure task follows. Commit locally after each round of about 20 tests (no push).

## Implementation Strategy

MVP = the first ten tests (Phase 2). Apply the maintainer's style feedback to those ten before writing the rest. Total tasks: {t-1}.
