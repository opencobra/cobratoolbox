---

description: "Task list for the Tier-1 test coverage batch 3"
---

# Tasks: Tier-1 test coverage batch 3 (remaining plain-data functions)

**Input**: Design documents from `specs/20261012-135523-tier1-test-batch3/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md) (selection table = source of truth), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: the deliverable IS the tests. No `src/` file may change; no defective behaviour may be asserted.

## Rules every test-writing task follows (constitution III-Coverage / III-Naming / III-Defects; not restated)

Per test file: read the source; call the function in MATLAB (`matlab -batch`) with small hand-built inputs to record current behaviour; write the test with the standard header (`Function under test:`, `Known defects documented (NOT tested, NOT fixed here):` in the standard entry format or `None found.`), `currentDir`/`fileDir`/`cd(fileDir)`, `prepareTest()`, shared inputs before the first `%` section, one `%` section per branch with commented assertion groups, `cd(currentDir)`. Never change a function under `src/`. A defect is documented and its input skipped (the uncovered lines are listed as exemptions); never assert defective behaviour. If a function turns out to need a file, model, solver, MATLAB toolbox or display, DROP it, and report the drop with the reason. Sections must not rely on variables from earlier sections. Never put personal information in any file.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [ ] T001 Confirm the baseline: on `develop`, `git diff --stat -- src` empty, MATLAB R2025a runs, `initCobraToolbox(false)` succeeds, `python3 .github/scripts/known_defects.py --check` passes.
- [ ] T002 Prepare the throwaway coverage/harness runner in the session scratchpad (not committed): runs `runScriptFile` from `test/` and the code-coverage plugin per test/source pair, reports status, covered/total lines and failing `%%` sections.
- [ ] T003 Record, in the scratchpad, the non-comment lines of existing tests that will be touched (none expected) and confirm that every new test name is unique under `test/`.

---

## Phase 2: User Story 1 - the ten smallest, simplest functions, then validation checkpoint (Priority: P1) MVP

### Test folder `test/verifiedTests/reconstruction/testMassChargeBalance`

- [ ] T004 [P] [US1] Row: write `test/verifiedTests/reconstruction/testMassChargeBalance/testIspolymer.m` for `src/reconstruction/modelGeneration/massBalance/ispolymer.m` (probe, test, run via harness runner, measure coverage).
- [ ] T005 [US1] Run the tests of `reconstruction/testMassChargeBalance` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testTools`

- [ ] T006 [P] [US1] Row: write `test/verifiedTests/base/testTools/testCountUnique.m` for `src/base/utilities/countUnique.m` (probe, test, run via harness runner, measure coverage).
- [ ] T007 [US1] Run the tests of `base/testTools` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/visualization/testMetabolicCartography`

- [ ] T008 [P] [US1] Row: write `test/verifiedTests/visualization/testMetabolicCartography/testVisualizeFluxFromFile.m` for `src/visualization/metabolicCartography/visualizeFluxFromFile.m` (probe, test, run via harness runner, measure coverage).
- [ ] T009 [US1] Run the tests of `visualization/testMetabolicCartography` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testMetaboAnnotator`

- [ ] T010 [P] [US1] Row: write `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m` for `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m` (probe, test, run via harness runner, measure coverage).
- [ ] T011 [US1] Run the tests of `dataIntegration/testMetaboAnnotator` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testExploration`

- [ ] T012 [P] [US1] Row: write `test/verifiedTests/analysis/testExploration/testIsValidPrintFields.m` for `src/analysis/exploration/surfNetSubfunctions/isValidPrintFields.m` (probe, test, run via harness runner, measure coverage).
- [ ] T013 [US1] Run the tests of `analysis/testExploration` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testGT1`

- [ ] T014 [P] [US1] Row: write `test/verifiedTests/analysis/testGT1/testFindGenesAboveThresholdGT1.m` for `src/analysis/igemRNA/GT1/findGenesAboveThresholdGT1.m` (probe, test, run via harness runner, measure coverage).
- [ ] T015 [P] [US1] Row: write `test/verifiedTests/analysis/testGT1/testFindGenesBelowThresholdGT1.m` for `src/analysis/igemRNA/GT1/findGenesBelowThresholdGT1.m` (probe, test, run via harness runner, measure coverage).
- [ ] T016 [US1] Run the tests of `analysis/testGT1` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testTools`

- [ ] T017 [P] [US1] Row: write `test/verifiedTests/base/testTools/testIsvar.m` for `src/base/utilities/isvar.m` (probe, test, run via harness runner, measure coverage).
- [ ] T018 [US1] Run the tests of `base/testTools` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testPersephone`

- [ ] T019 [P] [US1] Row: write `test/verifiedTests/analysis/testPersephone/testFdrBHadjustment.m` for `src/analysis/persephone/fdrBHadjustment.m` (probe, test, run via harness runner, measure coverage).
- [ ] T020 [US1] Run the tests of `analysis/testPersephone` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testSubspaces`

- [ ] T021 [P] [US1] Row: write `test/verifiedTests/analysis/testSubspaces/testLsqraprod.m` for `src/analysis/subspaces/lsqr/lsqraprod.m` (probe, test, run via harness runner, measure coverage).
- [ ] T022 [US1] Run the tests of `analysis/testSubspaces` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

- [ ] T023 [US1] CHECKPOINT: regenerate the registry, commit locally, report these ten (coverage table, defects, drops) and WAIT for maintainer approval before Phase 3. Do not start Phase 3 without approval.

---

## Phase 3: User Story 2 - remaining small and medium functions, grouped by folder (Priority: P2)

### Test folder `test/verifiedTests/analysis/testExploration`

- [ ] T024 [P] [US2] Row: write `test/verifiedTests/analysis/testExploration/testPrintHyperlink.m` for `src/analysis/exploration/surfNetSubfunctions/printHyperlink.m` (probe, test, run via harness runner, measure coverage).
- [ ] T025 [P] [US2] Row: write `test/verifiedTests/analysis/testExploration/testPrintMetRxnInfo.m` for `src/analysis/exploration/surfNetSubfunctions/printMetRxnInfo.m` (probe, test, run via harness runner, measure coverage).
- [ ] T026 [US2] Run the tests of `analysis/testExploration` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testPersephone`

- [ ] T027 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` for `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` (probe, test, run via harness runner, measure coverage).
- [ ] T028 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testGetVMHID.m` for `src/analysis/persephone/additionalFunctions/getVMHID.m` (probe, test, run via harness runner, measure coverage).
- [ ] T029 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testPerformRegressions.m` for `src/analysis/persephone/performRegressions.m` (probe, test, run via harness runner, measure coverage).
- [ ] T030 [P] [US2] Row: write `test/verifiedTests/analysis/testPersephone/testRunNonparametricTests.m` for `src/analysis/persephone/runNonparametricTests.m` (probe, test, run via harness runner, measure coverage).
- [ ] T031 [US2] Run the tests of `analysis/testPersephone` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testQFCA`

- [ ] T032 [P] [US2] Row: write `test/verifiedTests/analysis/testQFCA/testMergeFullyCoupled.m` for `src/analysis/QFCA/mergeFullyCoupled.m` (probe, test, run via harness runner, measure coverage).
- [ ] T033 [US2] Run the tests of `analysis/testQFCA` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testReactingMoieties`

- [ ] T034 [P] [US2] Row: write `test/verifiedTests/analysis/testReactingMoieties/testAddBondMappingsRXNFile.m` for `src/analysis/topology/reactingMoieties/addBondMappingsRXNFile.m` (probe, test, run via harness runner, measure coverage).
- [ ] T035 [P] [US2] Row: write `test/verifiedTests/analysis/testReactingMoieties/testExtractBondSubgraphs.m` for `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m` (probe, test, run via harness runner, measure coverage).
- [ ] T036 [P] [US2] Row: write `test/verifiedTests/analysis/testReactingMoieties/testMapAontoBOld.m` for `src/analysis/topology/reactingMoieties/mapAontoBOld.m` (probe, test, run via harness runner, measure coverage).
- [ ] T037 [P] [US2] Row: write `test/verifiedTests/analysis/testReactingMoieties/testMinimumSetCoverPlain.m` for `src/analysis/topology/reactingMoieties/minimumSetCoverPlain.m` (probe, test, run via harness runner, measure coverage).
- [ ] T038 [P] [US2] Row: write `test/verifiedTests/analysis/testReactingMoieties/testTabulatePlain.m` for `src/analysis/topology/reactingMoieties/tabulatePlain.m` (probe, test, run via harness runner, measure coverage).
- [ ] T039 [US2] Run the tests of `analysis/testReactingMoieties` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testSampling`

- [ ] T040 [P] [US2] Row: write `test/verifiedTests/analysis/testSampling/testMixFraction.m` for `src/analysis/sampling/ACHR/mixFraction.m` (probe, test, run via harness runner, measure coverage).
- [ ] T041 [US2] Run the tests of `analysis/testSampling` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testSubspaces`

- [ ] T042 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testFourFundamentalSubpaces.m` for `src/analysis/subspaces/fourFundamentalSubpaces.m` (probe, test, run via harness runner, measure coverage).
- [ ] T043 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testEchelonNullspace.m` for `src/analysis/subspaces/nullspace/echelonNullspace.m` (probe, test, run via harness runner, measure coverage).
- [ ] T044 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testNullSpaceOperatorApply.m` for `src/analysis/subspaces/nullspace/nullSpaceOperatorApply.m` (probe, test, run via harness runner, measure coverage).
- [ ] T045 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testRowReduce.m` for `src/analysis/subspaces/rowReduce/rowReduce.m` (probe, test, run via harness runner, measure coverage).
- [ ] T046 [P] [US2] Row: write `test/verifiedTests/analysis/testSubspaces/testProjectOntoSubspace.m` for `src/analysis/subspaces/subspaceProjection/projectOntoSubspace.m` (probe, test, run via harness runner, measure coverage).
- [ ] T047 [US2] Run the tests of `analysis/testSubspaces` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testThermo`

- [ ] T048 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testCheckFormulae.m` for `src/analysis/thermo/formulae/checkFormulae.m` (probe, test, run via harness runner, measure coverage).
- [ ] T049 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testCreateFragmentIncidenceMatrix.m` for `src/analysis/thermo/groupContribution/wang/createFragmentIncidenceMatrix.m` (probe, test, run via harness runner, measure coverage).
- [ ] T050 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testMoleFraction.m` for `src/analysis/thermo/protons/moleFraction.m` (probe, test, run via harness runner, measure coverage).
- [ ] T051 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testAcidDissociationConstant.m` for `src/analysis/thermo/reactantContribution/acidDissociationConstant.m` (probe, test, run via harness runner, measure coverage).
- [ ] T052 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testConnectedRxnsInNullSpace.m` for `src/analysis/thermo/thermoFBA/connectedRxnsInNullSpace.m` (probe, test, run via harness runner, measure coverage).
- [ ] T053 [P] [US2] Row: write `test/verifiedTests/analysis/testThermo/testTransform.m` for `src/analysis/thermo/trainingModel/Transform.m` (probe, test, run via harness runner, measure coverage).
- [ ] T054 [US2] Run the tests of `analysis/testThermo` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testIO`

- [ ] T055 [P] [US2] Row: write `test/verifiedTests/base/testIO/testConvertCobraLP2mps.m` for `src/base/io/convertCobraLP2mps.m` (probe, test, run via harness runner, measure coverage).
- [ ] T056 [P] [US2] Row: write `test/verifiedTests/base/testIO/testGetAnnotationFieldName.m` for `src/base/io/definitions/getAnnotationFieldName.m` (probe, test, run via harness runner, measure coverage).
- [ ] T057 [US2] Run the tests of `base/testIO` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testIO/testUtilities`

- [ ] T058 [P] [US2] Row: write `test/verifiedTests/base/testIO/testUtilities/testConvertSBMLID.m` for `src/base/io/utilities/SBML/convertSBMLID.m` (probe, test, run via harness runner, measure coverage).
- [ ] T059 [P] [US2] Row: write `test/verifiedTests/base/testIO/testUtilities/testParseCVTerms.m` for `src/base/io/utilities/SBML/parseCVTerms.m` (probe, test, run via harness runner, measure coverage).
- [ ] T060 [P] [US2] Row: write `test/verifiedTests/base/testIO/testUtilities/testMergeTextDataAndData.m` for `src/base/io/utilities/mergeTextDataAndData.m` (probe, test, run via harness runner, measure coverage).
- [ ] T061 [US2] Run the tests of `base/testIO/testUtilities` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testSolvers`

- [ ] T062 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testGetParamList.m` for `src/base/solvers/cplex/getParamList.m` (probe, test, run via harness runner, measure coverage).
- [ ] T063 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testSplitRow.m` for `src/base/solvers/rescale/splitRow.m` (probe, test, run via harness runner, measure coverage).
- [ ] T064 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testFuncGradHessSub.m` for `src/base/solvers/varKin/BDCAmethods/FuncGradHessSub.m` (probe, test, run via harness runner, measure coverage).
- [ ] T065 [P] [US2] Row: write `test/verifiedTests/base/testSolvers/testRate_function1.m` for `src/base/solvers/varKin/levMarMethods/Rate_function1.m` (probe, test, run via harness runner, measure coverage).
- [ ] T066 [US2] Run the tests of `base/testSolvers` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testTools`

- [ ] T067 [P] [US2] Row: write `test/verifiedTests/base/testTools/testCreateDeltaMatchMatrix.m` for `src/base/createDeltaMatchMatrix.m` (probe, test, run via harness runner, measure coverage).
- [ ] T068 [P] [US2] Row: write `test/verifiedTests/base/testTools/testDispMatrix.m` for `src/base/utilities/dispMatrix.m` (probe, test, run via harness runner, measure coverage).
- [ ] T069 [P] [US2] Row: write `test/verifiedTests/base/testTools/testMapAontoB.m` for `src/base/utilities/mapAontoB.m` (probe, test, run via harness runner, measure coverage).
- [ ] T070 [P] [US2] Row: write `test/verifiedTests/base/testTools/testUpdateStructData.m` for `src/base/utilities/updateStructData.m` (probe, test, run via harness runner, measure coverage).
- [ ] T071 [US2] Run the tests of `base/testTools` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testFitC13Data`

- [ ] T072 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testFitC13Data/testIdv2idv.m` for `src/dataIntegration/fluxomics/c13solver/idv2idv.m` (probe, test, run via harness runner, measure coverage).
- [ ] T073 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testFitC13Data/testCalcMDVfromSamp.m` for `src/dataIntegration/fluxomics/calcMDVfromSamp.m` (probe, test, run via harness runner, measure coverage) (product scan: Parallel Computing Toolbox; probe whether it is only a code path, drop if required).
- [ ] T074 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testFitC13Data/testCompareTwoMDVs.m` for `src/dataIntegration/fluxomics/compareTwoMDVs.m` (probe, test, run via harness runner, measure coverage).
- [ ] T075 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testFitC13Data/testNaturallabel.m` for `src/dataIntegration/fluxomics/naturallabel.m` (probe, test, run via harness runner, measure coverage).
- [ ] T076 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testFitC13Data/testScore_KS.m` for `src/dataIntegration/fluxomics/score_KS.m` (probe, test, run via harness runner, measure coverage) (product scan: Parallel Computing Toolbox; probe whether it is only a code path, drop if required).
- [ ] T077 [US2] Run the tests of `dataIntegration/testFitC13Data` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testMetaboAnnotator`

- [ ] T078 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAddField2MetStructure.m` for `src/dataIntegration/metaboAnnotator/buildMetStruct/addField2MetStructure.m` (probe, test, run via harness runner, measure coverage).
- [ ] T079 [US2] Run the tests of `dataIntegration/testMetaboAnnotator` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testXomicsToModel`

- [ ] T080 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testXomicsToModel/testCompareXomicsModels.m` for `src/dataIntegration/XomicsToModel/analysis/compareXomicsModels.m` (probe, test, run via harness runner, measure coverage).
- [ ] T081 [P] [US2] Row: write `test/verifiedTests/dataIntegration/testXomicsToModel/testMetsToKeep.m` for `src/dataIntegration/XomicsToModel/metabolomics/metsToKeep.m` (probe, test, run via harness runner, measure coverage).
- [ ] T082 [US2] Run the tests of `dataIntegration/testXomicsToModel` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testDemeter`

- [ ] T083 [P] [US2] Row: write `test/verifiedTests/reconstruction/testDemeter/testGapfillRefinedGenomeReactions.m` for `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m` (probe, test, run via harness runner, measure coverage).
- [ ] T084 [US2] Run the tests of `reconstruction/testDemeter` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testFastGapFill`

- [ ] T085 [P] [US2] Row: write `test/verifiedTests/reconstruction/testFastGapFill/testAssignRxnWeights.m` for `src/reconstruction/fastGapFill/AuxillaryFiles/assignRxnWeights.m` (probe, test, run via harness runner, measure coverage).
- [ ] T086 [US2] Run the tests of `reconstruction/testFastGapFill` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testModelBorgifier`

- [ ] T087 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testCompareMatricies.m` for `src/reconstruction/comparison/modelBorgifier/compareMatricies.m` (probe, test, run via harness runner, measure coverage).
- [ ] T088 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testCountC.m` for `src/reconstruction/comparison/modelBorgifier/countC.m` (probe, test, run via harness runner, measure coverage).
- [ ] T089 [P] [US2] Row: write `test/verifiedTests/reconstruction/testModelBorgifier/testMergeTrxns.m` for `src/reconstruction/comparison/modelBorgifier/mergeTrxns.m` (probe, test, run via harness runner, measure coverage).
- [ ] T090 [US2] Run the tests of `reconstruction/testModelBorgifier` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/reconstruction/testStoichiometricConsistency`

- [ ] T091 [P] [US2] Row: write `test/verifiedTests/reconstruction/testStoichiometricConsistency/testOptimalConservationVectors.m` for `src/reconstruction/modelGeneration/stoichConsistency/optimalConservationVectors.m` (probe, test, run via harness runner, measure coverage).
- [ ] T092 [US2] Run the tests of `reconstruction/testStoichiometricConsistency` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/visualization/testMetabolicCartography`

- [ ] T093 [P] [US2] Row: write `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxWidthAndColor.m` for `src/visualization/metabolicCartography/addFluxWidthAndColor.m` (probe, test, run via harness runner, measure coverage).
- [ ] T094 [P] [US2] Row: write `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m` for `src/visualization/metabolicCartography/removeMapMol.m` (probe, test, run via harness runner, measure coverage) (product scan: Parallel Computing Toolbox; probe whether it is only a code path, drop if required).
- [ ] T095 [US2] Run the tests of `visualization/testMetabolicCartography` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/visualization/testSammi`

- [ ] T096 [P] [US2] Row: write `test/verifiedTests/visualization/testSammi/testMakeSAMMIparseVector.m` for `src/visualization/SAMMIM/makeSAMMIparseVector.m` (probe, test, run via harness runner, measure coverage) (product scan: Parallel Computing Toolbox; probe whether it is only a code path, drop if required).
- [ ] T097 [US2] Run the tests of `visualization/testSammi` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.


---

## Phase 4: User Story 3 - the ten largest functions (Priority: P3)

### Test folder `test/verifiedTests/analysis/testMultiSpeciesModelling`

- [ ] T098 [P] [US3] Row: write `test/verifiedTests/analysis/testMultiSpeciesModelling/testPerformStatisticalAnalysis.m` for `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m` (probe, test, run via harness runner, measure coverage).
- [ ] T099 [US3] Run the tests of `analysis/testMultiSpeciesModelling` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testThermo`

- [ ] T100 [P] [US3] Row: write `test/verifiedTests/analysis/testThermo/testAdjustBaselinesInAlberty2006.m` for `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m` (probe, test, run via harness runner, measure coverage).
- [ ] T101 [P] [US3] Row: write `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` for `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` (probe, test, run via harness runner, measure coverage).
- [ ] T102 [US3] Run the tests of `analysis/testThermo` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/analysis/testTopology`

- [ ] T103 [P] [US3] Row: write `test/verifiedTests/analysis/testTopology/testBilinearDecomposition.m` for `src/analysis/topology/FR/bilinearDecomposition.m` (probe, test, run via harness runner, measure coverage).
- [ ] T104 [US3] Run the tests of `analysis/testTopology` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/base/testSolvers`

- [ ] T105 [P] [US3] Row: write `test/verifiedTests/base/testSolvers/testInspectMosekNumerics.m` for `src/base/solvers/mosek/inspectMosekNumerics.m` (probe, test, run via harness runner, measure coverage).
- [ ] T106 [P] [US3] Row: write `test/verifiedTests/base/testSolvers/testInspectMosekProb.m` for `src/base/solvers/mosek/inspectMosekProb.m` (probe, test, run via harness runner, measure coverage).
- [ ] T107 [P] [US3] Row: write `test/verifiedTests/base/testSolvers/testParseMskResult.m` for `src/base/solvers/mosek/parseMskResult.m` (probe, test, run via harness runner, measure coverage).
- [ ] T108 [P] [US3] Row: write `test/verifiedTests/base/testSolvers/testSetMosekParam.m` for `src/base/solvers/mosek/setMosekParam.m` (probe, test, run via harness runner, measure coverage).
- [ ] T109 [US3] Run the tests of `base/testSolvers` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testFitC13Data`

- [ ] T110 [P] [US3] Row: write `test/verifiedTests/dataIntegration/testFitC13Data/testRunHiLoExp.m` for `src/dataIntegration/fluxomics/runHiLoExp.m` (probe, test, run via harness runner, measure coverage) (product scan: Parallel Computing Toolbox; probe whether it is only a code path, drop if required).
- [ ] T111 [US3] Run the tests of `dataIntegration/testFitC13Data` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.

### Test folder `test/verifiedTests/dataIntegration/testMetaboAnnotator`

- [ ] T112 [P] [US3] Row: write `test/verifiedTests/dataIntegration/testMetaboAnnotator/testSanityCheckMetIds.m` for `src/dataIntegration/metaboAnnotator/buildMetStruct/sanityCheckMetIds.m` (probe, test, run via harness runner, measure coverage).
- [ ] T113 [US3] Run the tests of `dataIntegration/testMetaboAnnotator` through `runScriptFile` and measure coverage; fix gaps until 100% or document each exemption; record covered/total.


---

## Phase 5: Registry, verification and receipt (User Story 4)

- [ ] T114 [US4] Regenerate the registry with `python3 .github/scripts/known_defects.py`; confirm the tool exits 0, every new defect appears once, and no entry is invalid.
- [ ] T115 [US4] Run all new tests together through `runScriptFile`; record pass count, section failures and total time (target under 10 minutes).
- [ ] T116 [US4] Verify `git diff --stat -- src` is empty, no test created a file, each function name appears in exactly one test file, and no test asserts a defective behaviour (read each defect entry against its assertions).
- [ ] T117 [US4] Scan every added or changed file for personal information; none.
- [ ] T118 [US4] Write the implementation receipt (Prompt, Final response, Diff summary, Tests with covered/total per function, dropped functions with reasons, Unresolved issues) under `specs/20261012-135523-tier1-test-batch3/agent-runs/<UTC-timestamp>-tier1-test-batch3/`.
- [ ] T119 [US4] Commit on `develop` (author from the local git configuration, no co-author line); do not push.

---

## Dependencies & Execution Order

Phase 1 -> Phase 2 -> CHECKPOINT (maintainer approval) -> Phase 3 -> Phase 4 -> Phase 5. Within a folder group the test-writing tasks are `[P]`; the group's run-and-measure task follows. Commit after each folder group (local only).

## Implementation Strategy

MVP = the ten tasks of Phase 2. Apply the maintainer's style feedback to those ten before writing the rest. Total tasks: 119.
