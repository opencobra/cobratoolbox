---
description: "Tasks for the Tier-2 safe batch"
---

# Tasks: Tier-2 tests for every safe untested model-manipulation function

**Input**: `specs/20261103-105830-tier2-safe-batch/` (spec, plan, research, quickstart)

## Procedure for every probe-and-write task (T003-T032)

1. Read the source function fully (and the toolbox functions it calls) and its help header.
2. Probe in MATLAB: call it on the smallest distributed model (`getDistributedModel`) with
   documented inputs. DROP the function (report the reason, write no test) if it needs a solver
   at run time, a model `getDistributedModel` does not provide (e.g. a whole-body model), data
   files the toolbox does not ship, a MATLAB toolbox, or user interaction. Inputs that are model
   fields the toolbox can derive (e.g. adding a field from existing ones) are allowed.
3. Write `test<Name>.m` in the stated folder, in the pilot style (see
   `test/verifiedTests/reconstruction/testModelManipulation/testExtractCompModel.m`): header
   (Purpose, Function under test, Tier 2 statement, Reference values paragraph: first run
   2026-11-03, model, no solver, guards consistency; Coverage exemptions; Known defects documented
   (NOT tested, NOT fixed here); Authors "- Generated for feature 20261103-105830-tier2-safe-batch,
   2026-11-03."), opening `prepareTest()`, model(s) loaded once before the first `%%`, one
   independent `%%` section per behaviour/branch, structural + content + Tier-5 assertions,
   `cd(currentDir)` at the end.
4. Never change `src`; a defect is recorded per III-Defects (`- DEFECT:` ... `LINES:`) and its input
   skipped. Restore any global state the function changes. Do not suppress output.
5. Verify: (a) `runWithCoverage` (100% or exemptions listed); (b) one run with the solver spies
   first on the path: must pass; (c) note runtime.

## Phase 1: Setup

- [X] T001 Confirm branch stacked on 20261102-142225-tier2-test-pilot; spies and coverage helper present
- [X] T002 Confirm none of the 30 test files exists

## Phase 2: User Stories 1 and 2 — probe and write (≤150 lines first; US2 = larger)

### Group A

- [ ] T003 [P] [US1] Probe src/analysis/exploration/generateHyperlinkedModel.m (62 code lines) and, if kept, write test/verifiedTests/analysis/testExploration/testGenerateHyperlinkedModel.m
- [ ] T004 [P] [US1] Probe src/analysis/exploration/surfNetSubfunctions/generateGrRules.m (49 code lines) and, if kept, write test/verifiedTests/analysis/testExploration/testGenerateGrRules.m
- [ ] T005 [P] [US1] Probe src/analysis/mdFBA/buildMDFBAProblem.m (32 code lines) and, if kept, write test/verifiedTests/analysis/testMDFBA/testBuildMDFBAProblem.m
- [ ] T006 [P] [US1] Probe src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m (19 code lines) and, if kept, write test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m
- [ ] T007 [P] [US1] Probe src/analysis/thermo/vonBertalanffy/estimateDfGt0.m (113 code lines) and, if kept, write test/verifiedTests/analysis/testThermo/testEstimateDfGt0.m
- [ ] T008 [P] [US1] Probe src/analysis/thermo/vonBertalanffy/estimateDrGt0.m (108 code lines) and, if kept, write test/verifiedTests/analysis/testThermo/testEstimateDrGt0.m
- [ ] T009 [P] [US1] Probe src/analysis/topology/findCyclicRxns.m (3 code lines) and, if kept, write test/verifiedTests/analysis/testTopology/testFindCyclicRxns.m

### Group B

- [ ] T010 [P] [US1] Probe src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m (62 code lines) and, if kept, write test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m
- [ ] T011 [P] [US1] Probe src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m (57 code lines) and, if kept, write test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m
- [ ] T012 [P] [US1] Probe src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m (103 code lines) and, if kept, write test/verifiedTests/analysis/testWholeBody/testSetDietConstraints.m
- [ ] T013 [P] [US1] Probe src/base/io/KEGG/mapKEGGID2Model.m (30 code lines) and, if kept, write test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m
- [ ] T014 [P] [US1] Probe src/base/io/KEGG/mapMetName2KEGGID.m (45 code lines) and, if kept, write test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m
- [ ] T015 [P] [US1] Probe src/base/io/utilities/SBML/makeSBMLAnnotationString.m (97 code lines) and, if kept, write test/verifiedTests/base/testIO/testUtilities/testMakeSBMLAnnotationString.m
- [ ] T016 [P] [US1] Probe src/base/io/utilities/SBML/mapAnnotationsToFields.m (28 code lines) and, if kept, write test/verifiedTests/base/testIO/testUtilities/testMapAnnotationsToFields.m

### Group C

- [ ] T017 [P] [US1] Probe src/base/io/utilities/initFBAFields.m (53 code lines) and, if kept, write test/verifiedTests/base/testIO/testUtilities/testInitFBAFields.m
- [ ] T018 [P] [US1] Probe src/dataIntegration/XomicsToModel/prepareData/regulariseMitochondrialReactions.m (45 code lines) and, if kept, write test/verifiedTests/dataIntegration/testXomicsToModel/testRegulariseMitochondrialReactions.m
- [ ] T019 [P] [US1] Probe src/design/TrimGdel/geneReactionMILP.m (63 code lines) and, if kept, write test/verifiedTests/design/testTrimGdel/testGeneReactionMILP.m
- [ ] T020 [P] [US1] Probe src/design/TrimGdel/modelSetting.m (24 code lines) and, if kept, write test/verifiedTests/design/testTrimGdel/testModelSetting.m
- [ ] T021 [P] [US1] Probe src/reconstruction/modelGeneration/modelVerification/checkDatabaseIDs.m (24 code lines) and, if kept, write test/verifiedTests/reconstruction/testModelGeneration/testCheckDatabaseIDs.m
- [ ] T022 [P] [US1] Probe src/reconstruction/refinement/assignGPRA.m (7 code lines) and, if kept, write test/verifiedTests/reconstruction/testModelManipulation/testAssignGPRA.m
- [ ] T023 [P] [US1] Probe src/reconstruction/refinement/assignSubSystems.m (11 code lines) and, if kept, write test/verifiedTests/reconstruction/testModelManipulation/testAssignSubSystems.m

### Group D

- [ ] T024 [P] [US2] Probe src/analysis/persephone/additionalFunctions/physiologicalConstraintsHMDBbasedTEMP.m (624 code lines) and, if kept, write test/verifiedTests/analysis/testPersephone/testPhysiologicalConstraintsHMDBbasedTEMP.m
- [ ] T025 [P] [US2] Probe src/analysis/thermo/reactantContribution/setCommonZeroStandardGibbsEnergyOfFormation.m (221 code lines) and, if kept, write test/verifiedTests/analysis/testThermo/testSetCommonZeroStandardGibbsEnergyOfFormation.m
- [ ] T026 [P] [US2] Probe src/analysis/thermo/reactantContribution/thermodynamicAdjustmentToStoichiometry.m (153 code lines) and, if kept, write test/verifiedTests/analysis/testThermo/testThermodynamicAdjustmentToStoichiometry.m
- [ ] T027 [P] [US2] Probe src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased.m (635 code lines) and, if kept, write test/verifiedTests/analysis/testWholeBody/testPhysiologicalConstraintsHMDBbased.m
- [ ] T028 [P] [US2] Probe src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m (151 code lines) and, if kept, write test/verifiedTests/analysis/testWholeBody/testSetFeedingFastingConstraints.m

### Group E

- [ ] T029 [P] [US2] Probe src/base/solvers/varKin/optimizeVKmodel0.m (368 code lines) and, if kept, write test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m
- [ ] T030 [P] [US2] Probe src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m (371 code lines) and, if kept, write test/verifiedTests/reconstruction/testDemeter/testConditionSpecificGapFilling.m
- [ ] T031 [P] [US2] Probe src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m (240 code lines) and, if kept, write test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m
- [ ] T032 [P] [US2] Probe src/reconstruction/refinement/addReactionGEM.m (164 code lines) and, if kept, write test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m

## Phase 2b: Scope extension (spec section "Scope extension")

### Group F (scope extension)

- [ ] T038 [P] [US1] Probe src/analysis/ecosystem/constrainEcosystemPoint.m (36 code lines) and, if kept, write test/verifiedTests/analysis/testWholeBody/testConstrainEcosystemPoint.m (Tier 1 if the function takes no model)
- [ ] T039 [P] [US1] Probe src/analysis/persephone/performRegressions.m (135 code lines) and, if kept, write test/verifiedTests/analysis/testPersephone/testPerformRegressions.m (Tier 1 if the function takes no model)
- [ ] T040 [P] [US1] Probe src/analysis/persephone/validatePersephoneInputs.m (74 code lines) and, if kept, write test/verifiedTests/analysis/testPersephone/testValidatePersephoneInputs.m (Tier 1 if the function takes no model)
- [ ] T041 [P] [US1] Probe src/analysis/sampling/BarrierRound/PolytopeSimplifier/TwoSidedBarrier.m (101 code lines) and, if kept, write test/verifiedTests/analysis/testSampling/testTwoSidedBarrier.m (Tier 1 if the function takes no model)
- [ ] T042 [P] [US1] Probe src/analysis/sampling/BarrierRound/utils/TableDisplay.m (84 code lines) and, if kept, write test/verifiedTests/analysis/testSampling/testTableDisplay.m (Tier 1 if the function takes no model)
- [ ] T043 [P] [US1] Probe src/analysis/subspaces/lsqr/lsqrtest.m (17 code lines) and, if kept, write test/verifiedTests/analysis/testSubspaces/testLsqrtest.m (Tier 1 if the function takes no model)
- [ ] T044 [P] [US1] Probe src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m (185 code lines) and, if kept, write test/verifiedTests/analysis/testAdjustBaselinesInAlberty2006.m (Tier 1 if the function takes no model)
- [ ] T045 [P] [US1] Probe src/analysis/thermo/groupContribution/createComputedSpeciesData.m (163 code lines) and, if kept, write test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m (Tier 1 if the function takes no model)
- [ ] T046 [P] [US1] Probe src/analysis/topology/FR/connectedFR.m (30 code lines) and, if kept, write test/verifiedTests/analysis/testTopology/testConnectedFR.m (Tier 1 if the function takes no model)
- [ ] T047 [P] [US1] Probe src/analysis/topology/FR/largestConnectedFR.m (45 code lines) and, if kept, write test/verifiedTests/analysis/testTopology/testLargestConnectedFR.m (Tier 1 if the function takes no model)
- [ ] T048 [P] [US1] Probe src/base/io/definitions/descFileRead.m (22 code lines) and, if kept, write test/verifiedTests/base/testIO/testDescFileRead.m (Tier 1 if the function takes no model)

### Group G (scope extension)

- [ ] T049 [P] [US1] Probe src/base/utilities/issueConfirmationWarning.m (12 code lines) and, if kept, write test/verifiedTests/base/testTools/testIssueConfirmationWarning.m (Tier 1 if the function takes no model)
- [ ] T050 [P] [US1] Probe src/base/utilities/removeIndicesInDimenion.m (6 code lines) and, if kept, write test/verifiedTests/base/testTools/testRemoveIndicesInDimenion.m (Tier 1 if the function takes no model)
- [ ] T051 [P] [US1] Probe src/dataIntegration/chemoInformatics/RXN/readRXNFile.m (104 code lines) and, if kept, write test/verifiedTests/dataIntegration/testChemoInformatics/testReadRXNFile.m (Tier 1 if the function takes no model)
- [ ] T052 [P] [US1] Probe src/dataIntegration/fluxomics/getBinsOfFluxes.m (92 code lines) and, if kept, write test/verifiedTests/dataIntegration/testFitC13Data/testGetBinsOfFluxes.m (Tier 1 if the function takes no model)
- [ ] T053 [P] [US1] Probe src/dataIntegration/transcriptomics/rFASTCORMICS/createFitL.m (9 code lines) and, if kept, write test/verifiedTests/dataIntegration/testRFASTCORMICS/testCreateFitL.m (Tier 1 if the function takes no model)
- [ ] T054 [P] [US1] Probe src/dataIntegration/transcriptomics/rFASTCORMICS/createFitR.m (9 code lines) and, if kept, write test/verifiedTests/dataIntegration/testRFASTCORMICS/testCreateFitR.m (Tier 1 if the function takes no model)
- [ ] T055 [P] [US1] Probe src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m (75 code lines) and, if kept, write test/verifiedTests/reconstruction/testModelBorgifier/testMakeNamesUnique.m (Tier 1 if the function takes no model)
- [ ] T056 [P] [US1] Probe src/reconstruction/modelGeneration/massBalance/ispolymer.m (8 code lines) and, if kept, write test/verifiedTests/reconstruction/testModelGeneration/testIspolymer.m (Tier 1 if the function takes no model)
- [ ] T057 [P] [US1] Probe src/visualization/cellDesigner/readCD.m (22 code lines) and, if kept, write test/verifiedTests/visualization/testCellDesigner/testReadCD.m (Tier 1 if the function takes no model)
- [ ] T058 [P] [US1] Probe src/visualization/cellDesigner/updateCD.m (89 code lines) and, if kept, write test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m (Tier 1 if the function takes no model)
- [ ] T059 [P] [US1] Probe src/visualization/metabolicCartography/removeMapMol.m (62 code lines) and, if kept, write test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m (Tier 1 if the function takes no model)

The Phase 3 and Phase 4 tasks run after Phase 2b.

## Phase 3: User Story 3 — registry and summary

- [ ] T033 [US3] Regenerate test/known-defects.md with `python3 .github/scripts/known_defects.py` (exit 0)
- [ ] T034 [US3] Write specs/20261103-105830-tier2-safe-batch/summary.md (kept tests with coverage/runtime, dropped functions with reasons, defects found)

## Phase 4: Polish

- [ ] T035 Run all new tests in one MATLAB session (runScriptFile) and once with the solver spies; `git diff --name-only -- src` empty
- [ ] T036 Write specs/20261103-105830-tier2-safe-batch/agent-runs/<UTC>-implement/implementation-receipt.md
- [ ] T037 Commit with the maintainer identity (no co-author line), only this feature's files; push the branch with upstream tracking

## Dependencies & parallelism

Setup → groups A-E in parallel (one agent each; tasks touch different files) → US3 → Polish.
