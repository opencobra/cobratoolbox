# Feature Specification: Tier-1 test coverage batch 4 (functions found by a second scan)

**Feature Branch**: none (work stays on `develop`)

**Created**: 2026-10-13

**Status**: Draft

**Input**: User description: "Re-scan the source for Tier-1 functions that still have no test and write the tests with Spec Kit."

This is a CHARACTERIZATION feature under Constitution Principle III (III-Characterization).
It applies III-Coverage (line-coverage goal, Tier 1, `prepareTest()` opening, memory
efficiency, readability), III-Naming (one `test<FunctionName>.m` per function) and
III-Defects (a defect found while testing is documented in the header in the standard format
and skipped, never asserted; every test passes). It follows batches 1 to 3. It changes no `src` file.

## What this batch covers

A second scan of all toolbox functions that no test mentions (a function is "mentioned" when
its name appears in any file under `test/`) found 799 functions. Those that use, directly or
through other toolbox functions, a solver, files, the network, plotting or a dialog, parallel
loops or a MATLAB toolbox were set aside as higher tiers (591), scripts were removed (71), and
so were old/new backup copies, CVX-based files, the demeter suite tests and the functions
already dropped in batch 3. The 160 that remained were reduced to 158 by removing two files that share one name
(`Rate_function`, which a single test file cannot address). The list below is PROVISIONAL: it
comes from a text scan, so the probe in the plan phase confirms each function; any that turn
out to need files, a solver, a toolbox, external data, or that do not terminate or cannot be
tested faithfully are dropped and reported with the reason.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pin the first ten functions and validate the style (Priority: P1)

The first ten rows of the selection table are written, run and reviewed before the rest.

**Why this priority**: an early checkpoint avoids repeating a style mistake dozens of times.

**Independent Test**: the ten tests pass through the harness runner and reach 100% line
coverage of their function (or document every uncovered line); the maintainer reviews them.

**Acceptance Scenarios**:

1. **Given** the approved selection, **When** the first ten tests are written, **Then** each is
   named per III-Naming, opens per III-Coverage, passes, and reports covered/total lines.
2. **Given** the ten tests, **When** they are reviewed, **Then** the rest are not started until
   approved.

---

### User Story 2 - Pin the remaining small and medium functions (Priority: P2)

Rows 11 to 150 (functions of up to 150 code lines), grouped by source folder.

**Independent Test**: each folder group passes and meets the coverage goal on its own.

**Acceptance Scenarios**:

1. **Given** the approved style, **When** a folder group is implemented, **Then** every test in
   it passes and meets the coverage goal.
2. **Given** a function that the probe shows is not Tier 1, **When** it is found, **Then** it is
   dropped and reported with the reason, never silently skipped.

---

### User Story 3 - Pin the largest functions (Priority: P3)

The last 8 rows (more than 150 code lines each) are written after the others; if one is too
costly for a faithful test it is reported and left for a later feature rather than weakened.

**Independent Test**: each large function has a test with documented coverage.

**Acceptance Scenarios**:

1. **Given** a large function, **When** its test is written, **Then** it follows the same rules
   and its uncovered lines, if any, are listed with reasons.

---

### User Story 4 - Defects are recorded in the standard format (Priority: P2)

Every defect found is recorded in the test header in the III-Defects format and appears in the
generated registry `test/known-defects.md` after regeneration.

**Independent Test**: regenerate the registry; each new defect appears once; the tool reports no
invalid entry.

**Acceptance Scenarios**:

1. **Given** a defect found in a function, **When** its test is written, **Then** the header
   holds a complete entry, the defective input is skipped and the test passes.
2. **Given** all new tests, **When** the registry is regenerated, **Then** it lists the new
   defects and the registry tool exits successfully.

---

### Edge Cases

- A function with persistent state: state is cleared before each case and at the end.
- A function that prints to the console: output is not suppressed; documented as console noise.
- A function whose branch cannot be reached with plain data: the line is listed as a coverage
  exemption with the reason.
- A function that errors on valid input: documented as a defect and skipped.
- A function that needs a MATLAB toolbox: dropped (a Tier 1 test declares no requirement).
- A function whose probe shows it needs a model: dropped and left to the Tier 2 feature.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Exactly one test file per selected function, named per III-Naming, in the folder
  of the selection table, running within `test/testAll.m`.
- **FR-002**: Each test follows III-Coverage: Tier 1 declared, `prepareTest()` after the
  `cd(fileDir)` lines, hand-built inputs only, 100% line coverage or every uncovered line
  documented, shared variables defined before the first `%%` section.
- **FR-003**: Each test header states purpose, function under test, tier, coverage exemptions,
  known defects (III-Defects format) and authors/date; the body has a commented `%%` section per
  branch.
- **FR-004**: Assertions use `assert`; exact equality only for discrete values; floating-point
  comparisons use a justified tolerance; expected-failure paths use `verifyCobraFunctionError`;
  expected values come from reading the source and a recorded probe, not guesses.
- **FR-005**: A defect is never asserted and the function is never changed; the defective
  input is skipped and recorded in the header (III-Defects). Every test passes.
- **FR-006**: Tests are memory efficient, create no files, leave no persistent or global state,
  and do not suppress console output of the function under test.
- **FR-007**: No file under `src/` changes.
- **FR-008**: The first ten tests are completed and verified, then work stops for maintainer
  validation before the rest are written.
- **FR-009**: Each test is run through the harness runner and its function's line coverage is
  measured; covered/total is reported per function.
- **FR-010**: After the tests are written, the known-defects registry is regenerated and checked
  with its tool.
- **FR-011**: The spec, plan, tasks, research notes and receipt, and all added tests, contain no
  personal information.
- **FR-012**: The contributor reports files changed, checks run, tests passed or failed,
  functions dropped with reasons, and behaviours not yet verified, and writes the
  implementation receipt.

### Key Entities

- **Selected function**: source function with test file name, folder, size and branch count.
- **Dropped function**: a candidate the probe shows is not Tier 1, with the reason.
- **Defect entry**: a III-Defects entry in a test header.

## Existing Contract *(characterization mode)*

- **Function(s) under test**: the functions in the selection table below.
- **Current inputs / outputs**: as in each source function; recorded per function by the probe.
- **Invariants & expected results**: derived from the source and the probe; tolerances only
  where floating-point results occur, each justified.
- **Coverage gap**: none of the functions is mentioned in any file under `test/`; each name is
  unique among toolbox and bundled third-party functions (checked by the scan).

### Selection (PROVISIONAL, for maintainer approval before tasks are generated)

Method: see "What this batch covers". Test folders follow the sibling convention: an existing
folder is used wherever one matches the source folder; otherwise a new folder named
`test<SourceFolder>` is created.

| # | Source function | Test file | Test folder | Code lines | Branch keywords |
|---|-----------------|-----------|-------------|-----------:|----------------:|
| 1 | `src/analysis/exploration/findEpistaticInteractions.m` | `testFindEpistaticInteractions.m` | `test/verifiedTests/analysis/testExploration/` | 29 | 6 |
| 2 | `src/analysis/exploration/findHiCarbonRxns.m` | `testFindHiCarbonRxns.m` | `test/verifiedTests/analysis/testExploration/` | 19 | 2 |
| 3 | `src/analysis/exploration/findRootNPmets.m` | `testFindRootNPmets.m` | `test/verifiedTests/analysis/testExploration/` | 31 | 9 |
| 4 | `src/analysis/exploration/findRxnsActiveWithGenes.m` | `testFindRxnsActiveWithGenes.m` | `test/verifiedTests/analysis/testExploration/` | 13 | 3 |
| 5 | `src/analysis/exploration/findRxnsInActiveWithGenes.m` | `testFindRxnsInActiveWithGenes.m` | `test/verifiedTests/analysis/testExploration/` | 13 | 3 |
| 6 | `src/analysis/exploration/getObjectiveSense.m` | `testGetObjectiveSense.m` | `test/verifiedTests/analysis/testExploration/` | 31 | 7 |
| 7 | `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/inorder.m` | `testInorder.m` | `test/verifiedTests/analysis/testAdditionalAnalysis/` | 30 | 6 |
| 8 | `src/analysis/nutritionAlgorithm/getMolFormula.m` | `testGetMolFormula.m` | `test/verifiedTests/analysis/testNutritionAlgorithm/` | 33 | 7 |
| 9 | `src/analysis/sampling/ACHR/convRevSamples.m` | `testConvRevSamples.m` | `test/verifiedTests/analysis/testSampling/` | 17 | 4 |
| 10 | `src/analysis/sampling/BarrierRound/utils/setField.m` | `testSetField.m` | `test/verifiedTests/analysis/testSampling/` | 8 | 2 |
| 11 | `src/analysis/exploration/findOrphanRxns.m` | `testFindOrphanRxns.m` | `test/verifiedTests/analysis/testExploration/` | 4 | 0 |
| 12 | `src/analysis/exploration/surfNetSubfunctions/printRxnFormulaLinked.m` | `testPrintRxnFormulaLinked.m` | `test/verifiedTests/analysis/testExploration/` | 124 | 27 |
| 13 | `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/makeDummyModel.m` | `testMakeDummyModel.m` | `test/verifiedTests/analysis/testMgPipe/` | 32 | 0 |
| 14 | `src/analysis/persephone/additionalFunctions/convertToStr.m` | `testConvertToStr.m` | `test/verifiedTests/analysis/testPersephone/` | 7 | 1 |
| 15 | `src/analysis/persephone/createForestPlot.m` | `testCreateForestPlot.m` | `test/verifiedTests/analysis/testPersephone/` | 52 | 5 |
| 16 | `src/analysis/persephone/createVolcanoPlot.m` | `testCreateVolcanoPlot.m` | `test/verifiedTests/analysis/testPersephone/` | 54 | 4 |
| 17 | `src/analysis/persephone/findPvalCategories.m` | `testFindPvalCategories.m` | `test/verifiedTests/analysis/testPersephone/` | 18 | 0 |
| 18 | `src/analysis/rMTA/MTA_TS.m` | `testMTA_TS.m` | `test/verifiedTests/analysis/testRMTA/` | 15 | 0 |
| 19 | `src/analysis/rMTA/buildMTAproblemFromModel.m` | `testBuildMTAproblemFromModel.m` | `test/verifiedTests/analysis/testRMTA/` | 75 | 1 |
| 20 | `src/analysis/relaxedFBA/plotRelaxedFBA.m` | `testPlotRelaxedFBA.m` | `test/verifiedTests/analysis/testRelaxedFBA/` | 115 | 19 |
| 21 | `src/analysis/rumba/addMissingReactions.m` | `testAddMissingReactions.m` | `test/verifiedTests/analysis/testRumba/` | 8 | 0 |
| 22 | `src/analysis/rumba/pValDistForModelOverlap.m` | `testPValDistForModelOverlap.m` | `test/verifiedTests/analysis/testRumba/` | 24 | 1 |
| 23 | `src/analysis/sampling/ACHR/removeCorrelRxns.m` | `testRemoveCorrelRxns.m` | `test/verifiedTests/analysis/testSampling/` | 47 | 10 |
| 24 | `src/analysis/sampling/BarrierRound/CMatrix/configCMatrix.m` | `testConfigCMatrix.m` | `test/verifiedTests/analysis/testSampling/` | 5 | 0 |
| 25 | `src/analysis/sampling/BarrierRound/PolytopeSimplifier/configPolytopeSimplifier.m` | `testConfigPolytopeSimplifier.m` | `test/verifiedTests/analysis/testSampling/` | 5 | 0 |
| 26 | `src/analysis/sampling/BarrierRound/PolytopeSimplifier/standardize_problem.m` | `testStandardize_problem.m` | `test/verifiedTests/analysis/testSampling/` | 79 | 19 |
| 27 | `src/analysis/sampling/BarrierRound/fullification.m` | `testFullification.m` | `test/verifiedTests/analysis/testSampling/` | 15 | 0 |
| 28 | `src/analysis/sampling/BarrierRound/utils/getField.m` | `testGetField.m` | `test/verifiedTests/analysis/testSampling/` | 6 | 1 |
| 29 | `src/analysis/sampling/BarrierRound/utils/loadModular.m` | `testLoadModular.m` | `test/verifiedTests/analysis/testSampling/` | 5 | 0 |
| 30 | `src/analysis/sampling/CHRR/chrrExpSampler.m` | `testChrrExpSampler.m` | `test/verifiedTests/analysis/testSampling/` | 61 | 14 |
| 31 | `src/analysis/sampling/CHRR/chrrParseModel.m` | `testChrrParseModel.m` | `test/verifiedTests/analysis/testSampling/` | 19 | 4 |
| 32 | `src/analysis/sampling/calcSampleDifference.m` | `testCalcSampleDifference.m` | `test/verifiedTests/analysis/testSampling/` | 11 | 1 |
| 33 | `src/analysis/sampling/identifyCorrelSets.m` | `testIdentifyCorrelSets.m` | `test/verifiedTests/analysis/testSampling/` | 43 | 6 |
| 34 | `src/analysis/subspaces/lsqr/aprod.m` | `testAprod.m` | `test/verifiedTests/analysis/testSubspaces/` | 6 | 1 |
| 35 | `src/analysis/subspaces/lsqr/cgls.m` | `testCgls.m` | `test/verifiedTests/analysis/testSubspaces/` | 43 | 8 |
| 36 | `src/analysis/subspaces/nullspace/nullspaceLUSOLapply2Modes.m` | `testNullspaceLUSOLapply2Modes.m` | `test/verifiedTests/analysis/testNullspace/` | 26 | 1 |
| 37 | `src/analysis/subspaces/subspaceProjection/projectSVD.m` | `testProjectSVD.m` | `test/verifiedTests/analysis/testSubspaces/` | 3 | 0 |
| 38 | `src/analysis/subspaces/subspaceProjection/subspaceSVD.m` | `testSubspaceSVD.m` | `test/verifiedTests/analysis/testSubspaces/` | 10 | 0 |
| 39 | `src/analysis/thermo/directionalityReport/assignQualDir.m` | `testAssignQualDir.m` | `test/verifiedTests/analysis/testThermo/` | 10 | 1 |
| 40 | `src/analysis/thermo/directionalityReport/compareQualAndQuantDir.m` | `testCompareQualAndQuantDir.m` | `test/verifiedTests/analysis/testThermo/` | 30 | 0 |
| 41 | `src/analysis/thermo/inchi/getMolecularWeight.m` | `testGetMolecularWeight.m` | `test/verifiedTests/analysis/testThermo/` | 39 | 8 |
| 42 | `src/analysis/thermo/reactantContribution/singleMetaboliteSpeciesReaction.m` | `testSingleMetaboliteSpeciesReaction.m` | `test/verifiedTests/analysis/testThermo/` | 18 | 4 |
| 43 | `src/analysis/thermo/reactantContribution/waterGibbsEnergyOfFormation.m` | `testWaterGibbsEnergyOfFormation.m` | `test/verifiedTests/analysis/testThermo/` | 15 | 0 |
| 44 | `src/analysis/thermo/thermoDirectionality/assignQuantDir.m` | `testAssignQuantDir.m` | `test/verifiedTests/analysis/testThermo/` | 66 | 16 |
| 45 | `src/analysis/thermo/thermoDirectionality/dGfzeroGroupContToBiochemical.m` | `testDGfzeroGroupContToBiochemical.m` | `test/verifiedTests/analysis/testThermo/` | 115 | 27 |
| 46 | `src/analysis/thermo/thermoFBA/printDirectionalityFromBounds.m` | `testPrintDirectionalityFromBounds.m` | `test/verifiedTests/analysis/testThermo/` | 24 | 6 |
| 47 | `src/analysis/topology/FR/combinatorialDependentRows.m` | `testCombinatorialDependentRows.m` | `test/verifiedTests/analysis/testTopology/` | 15 | 0 |
| 48 | `src/analysis/topology/FR/connectedFR.m` | `testConnectedFR.m` | `test/verifiedTests/analysis/testTopology/` | 30 | 3 |
| 49 | `src/analysis/topology/FR/largestConnectedFR.m` | `testLargestConnectedFR.m` | `test/verifiedTests/analysis/testTopology/` | 45 | 10 |
| 50 | `src/analysis/topology/integerizeS.m` | `testIntegerizeS.m` | `test/verifiedTests/analysis/testTopology/` | 76 | 16 |
| 51 | `src/analysis/transport/findTransRxns.m` | `testFindTransRxns.m` | `test/verifiedTests/analysis/testTransport/` | 32 | 7 |
| 52 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateMacroOriginalDiet.m` | `testCalculateMacroOriginalDiet.m` | `test/verifiedTests/analysis/testWholeBody/` | 12 | 0 |
| 53 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/extractDietFromModel.m` | `testExtractDietFromModel.m` | `test/verifiedTests/analysis/testWholeBody/` | 19 | 2 |
| 54 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m` | `testIsValidVmhID.m` | `test/verifiedTests/analysis/testWholeBody/` | 9 | 0 |
| 55 | `src/analysis/wholeBody/PSCMToolbox/adjustWholeBodyRxnCoeff.m` | `testAdjustWholeBodyRxnCoeff.m` | `test/verifiedTests/analysis/testWholeBody/` | 21 | 4 |
| 56 | `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m` | `testCompareBounds2Models.m` | `test/verifiedTests/analysis/testWholeBody/` | 51 | 5 |
| 57 | `src/analysis/wholeBody/PSCMToolbox/convertATPflux2StepNumer.m` | `testConvertATPflux2StepNumer.m` | `test/verifiedTests/analysis/testWholeBody/` | 10 | 1 |
| 58 | `src/analysis/wholeBody/PSCMToolbox/determineFluxValuesOnBoundary.m` | `testDetermineFluxValuesOnBoundary.m` | `test/verifiedTests/analysis/testWholeBody/` | 26 | 0 |
| 59 | `src/analysis/wholeBody/PSCMToolbox/findMetinOrgan.m` | `testFindMetinOrgan.m` | `test/verifiedTests/analysis/testWholeBody/` | 4 | 0 |
| 60 | `src/analysis/wholeBody/PSCMToolbox/getBasicHarveyStats.m` | `testGetBasicHarveyStats.m` | `test/verifiedTests/analysis/testWholeBody/` | 99 | 0 |
| 61 | `src/analysis/wholeBody/PSCMToolbox/getListOfUniqueIsozymes.m` | `testGetListOfUniqueIsozymes.m` | `test/verifiedTests/analysis/testWholeBody/` | 30 | 7 |
| 62 | `src/analysis/wholeBody/PSCMToolbox/getRxnsFromGene.m` | `testGetRxnsFromGene.m` | `test/verifiedTests/analysis/testWholeBody/` | 72 | 21 |
| 63 | `src/analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/setSimulationConstraints.m` | `testSetSimulationConstraints.m` | `test/verifiedTests/analysis/testWholeBody/` | 29 | 0 |
| 64 | `src/analysis/wholeBody/PSCMToolbox/linearRegression.m` | `testLinearRegression.m` | `test/verifiedTests/analysis/testWholeBody/` | 8 | 0 |
| 65 | `src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m` | `testSetDietConstraints.m` | `test/verifiedTests/analysis/testWholeBody/` | 103 | 18 |
| 66 | `src/analysis/wholeBody/io/homogeniseCouplingConstraints.m` | `testHomogeniseCouplingConstraints.m` | `test/verifiedTests/analysis/testWholeBody/` | 66 | 7 |
| 67 | `src/base/install/addCOBRABinaryPathToSystemPath.m` | `testAddCOBRABinaryPathToSystemPath.m` | `test/verifiedTests/base/testInstall/` | 18 | 1 |
| 68 | `src/base/install/getGitBashVersion.m` | `testGetGitBashVersion.m` | `test/verifiedTests/base/testInstall/` | 24 | 4 |
| 69 | `src/base/io/KEGG/mapKEGGID2Model.m` | `testMapKEGGID2Model.m` | `test/verifiedTests/base/testIO/` | 30 | 7 |
| 70 | `src/base/io/utilities/SBML/getBioQualifiers.m` | `testGetBioQualifiers.m` | `test/verifiedTests/base/testIO/` | 27 | 0 |
| 71 | `src/base/io/utilities/getMultiDimensionFields.m` | `testGetMultiDimensionFields.m` | `test/verifiedTests/base/testIO/` | 3 | 0 |
| 72 | `src/base/io/utilities/model2xls.m` | `testModel2xls.m` | `test/verifiedTests/base/testIO/` | 97 | 18 |
| 73 | `src/base/io/writeGDXFromCOBRA.m` | `testWriteGDXFromCOBRA.m` | `test/verifiedTests/base/testIO/` | 55 | 4 |
| 74 | `src/base/solvers/NLP/NLPobjPerFlux.m` | `testNLPobjPerFlux.m` | `test/verifiedTests/base/testSolvers/` | 3 | 0 |
| 75 | `src/base/solvers/cardOpt/sparseLP/computeMutualCoherence.m` | `testComputeMutualCoherence.m` | `test/verifiedTests/base/testCardOpt/` | 8 | 0 |
| 76 | `src/base/solvers/cplex/buildCplexProblemFromCOBRAStruct.m` | `testBuildCplexProblemFromCOBRAStruct.m` | `test/verifiedTests/base/testSolvers/` | 63 | 13 |
| 77 | `src/base/solvers/cplex/cplexStatus.m` | `testCplexStatus.m` | `test/verifiedTests/base/testSolvers/` | 110 | 95 |
| 78 | `src/base/solvers/entropicFBA/prepareEnzymeConstrainedEP.m` | `testPrepareEnzymeConstrainedEP.m` | `test/verifiedTests/base/testEntropicFBA/` | 50 | 10 |
| 79 | `src/base/solvers/mosek/mosekParamStrip.m` | `testMosekParamStrip.m` | `test/verifiedTests/base/testSolvers/` | 9 | 1 |
| 80 | `src/base/solvers/param/mergeCobraParams.m` | `testMergeCobraParams.m` | `test/verifiedTests/base/testSolvers/` | 7 | 1 |
| 81 | `src/base/solvers/param/parseSolverParameters.m` | `testParseSolverParameters.m` | `test/verifiedTests/base/testSolvers/` | 53 | 12 |
| 82 | `src/base/solvers/varKin/levMarMethods/Extended_rate_function.m` | `testExtended_rate_function.m` | `test/verifiedTests/base/testSolvers/` | 22 | 3 |
| 83 | `src/base/solvers/varKin/levMarMethods/StopCriterion.m` | `testStopCriterion.m` | `test/verifiedTests/base/testSolvers/` | 80 | 20 |
| 84 | `src/base/solvers/varKin/levMarMethods/lin_sym_solver_mldivide.m` | `testLin_sym_solver_mldivide.m` | `test/verifiedTests/base/testSolvers/` | 3 | 0 |
| 85 | `src/base/utilities/applyToNonNan.m` | `testApplyToNonNan.m` | `test/verifiedTests/base/testUtilities/` | 5 | 1 |
| 86 | `src/base/utilities/getDefaultTableRow.m` | `testGetDefaultTableRow.m` | `test/verifiedTests/base/testUtilities/` | 6 | 1 |
| 87 | `src/base/utilities/removeZeroRowsCols.m` | `testRemoveZeroRowsCols.m` | `test/verifiedTests/base/testUtilities/` | 4 | 0 |
| 88 | `src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m` | `testCoreMetRxnAnalysis.m` | `test/verifiedTests/dataIntegration/testXomicsToModel/` | 120 | 29 |
| 89 | `src/dataIntegration/XomicsToModel/oneRxnPerActiveGene/destroyDummyModel.m` | `testDestroyDummyModel.m` | `test/verifiedTests/dataIntegration/testXomicsToModel/` | 77 | 23 |
| 90 | `src/dataIntegration/chemoInformatics/reactions/sortAtomMappingIdx.m` | `testSortAtomMappingIdx.m` | `test/verifiedTests/dataIntegration/testChemoInformatics/` | 42 | 8 |
| 91 | `src/dataIntegration/fluxomics/atomTransition/ATN/extractElementalTransitionNetwork.m` | `testExtractElementalTransitionNetwork.m` | `test/verifiedTests/dataIntegration/testATN/` | 10 | 0 |
| 92 | `src/dataIntegration/fluxomics/c13solver/cdv2idv.m` | `testCdv2idv.m` | `test/verifiedTests/dataIntegration/testC13solver/` | 16 | 4 |
| 93 | `src/dataIntegration/fluxomics/c13solver/idv2cdv.m` | `testIdv2cdv.m` | `test/verifiedTests/dataIntegration/testC13solver/` | 7 | 1 |
| 94 | `src/dataIntegration/fluxomics/c13solver/idv2mdv.m` | `testIdv2mdv.m` | `test/verifiedTests/dataIntegration/testC13solver/` | 54 | 9 |
| 95 | `src/dataIntegration/fluxomics/c13solver/ratioScore.m` | `testRatioScore.m` | `test/verifiedTests/dataIntegration/testC13solver/` | 5 | 0 |
| 96 | `src/dataIntegration/fluxomics/c13solver/ratioScore_grad.m` | `testRatioScore_grad.m` | `test/verifiedTests/dataIntegration/testC13solver/` | 5 | 0 |
| 97 | `src/dataIntegration/fluxomics/getBinsOfFluxes.m` | `testGetBinsOfFluxes.m` | `test/verifiedTests/dataIntegration/testFluxomics/` | 92 | 19 |
| 98 | `src/dataIntegration/fluxomics/getRandGlc.m` | `testGetRandGlc.m` | `test/verifiedTests/dataIntegration/testFluxomics/` | 19 | 1 |
| 99 | `src/dataIntegration/metaboAnnotator/buildMetStruct/convertModel2Metstructure.m` | `testConvertModel2Metstructure.m` | `test/verifiedTests/dataIntegration/testMetaboAnnotator/` | 29 | 6 |
| 100 | `src/dataIntegration/transcriptomics/MOOMIN/weightFunction.m` | `testWeightFunction.m` | `test/verifiedTests/dataIntegration/testMOOMIN/` | 7 | 1 |
| 101 | `src/dataIntegration/transcriptomics/eFlux/verifyEFluxExpressionStruct.m` | `testVerifyEFluxExpressionStruct.m` | `test/verifiedTests/dataIntegration/testEFlux/` | 11 | 3 |
| 102 | `src/dataIntegration/transcriptomics/preprocessing/GPRparser.m` | `testGPRparser.m` | `test/verifiedTests/dataIntegration/testPreprocessing/` | 17 | 3 |
| 103 | `src/dataIntegration/transcriptomics/preprocessing/findUsedGenesLevels.m` | `testFindUsedGenesLevels.m` | `test/verifiedTests/dataIntegration/testPreprocessing/` | 33 | 10 |
| 104 | `src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m` | `testSelectGeneFromGPR.m` | `test/verifiedTests/dataIntegration/testPreprocessing/` | 58 | 14 |
| 105 | `src/dataIntegration/transcriptomics/rFASTCORMICS/GPRrulesMapper.m` | `testGPRrulesMapper.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 13 | 1 |
| 106 | `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitL.m` | `testCreateFitL.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 9 | 0 |
| 107 | `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitR.m` | `testCreateFitR.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 9 | 0 |
| 108 | `src/dataIntegration/transcriptomics/rFASTCORMICS/findOrganicExRxns.m` | `testFindOrganicExRxns.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 38 | 10 |
| 109 | `src/dataIntegration/transcriptomics/rFASTCORMICS/fixIrr.m` | `testFixIrr.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 10 | 0 |
| 110 | `src/dataIntegration/transcriptomics/rFASTCORMICS/mapExpressionToModel.m` | `testMapExpressionToModel.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 57 | 15 |
| 111 | `src/design/TrimGdel/calculateGR.m` | `testCalculateGR.m` | `test/verifiedTests/design/testTrimGdel/` | 32 | 8 |
| 112 | `src/design/augmentBOF.m` | `testAugmentBOF.m` | `test/verifiedTests/design/testDesign/` | 21 | 4 |
| 113 | `src/design/createBilevelMILPproblem.m` | `testCreateBilevelMILPproblem.m` | `test/verifiedTests/design/testDesign/` | 147 | 12 |
| 114 | `src/reconstruction/comparison/compareModels.m` | `testCompareModels.m` | `test/verifiedTests/reconstruction/testComparison/` | 68 | 10 |
| 115 | `src/reconstruction/comparison/modelBorgifier/TmodelFields.m` | `testTmodelFields.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 23 | 0 |
| 116 | `src/reconstruction/comparison/modelBorgifier/charpos.m` | `testCharpos.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 5 | 1 |
| 117 | `src/reconstruction/comparison/modelBorgifier/colText.m` | `testColText.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 6 | 0 |
| 118 | `src/reconstruction/comparison/modelBorgifier/findRxnMatch.m` | `testFindRxnMatch.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 145 | 14 |
| 119 | `src/reconstruction/comparison/modelBorgifier/fixChemFormulas.m` | `testFixChemFormulas.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 3 | 0 |
| 120 | `src/reconstruction/comparison/modelBorgifier/fixNames.m` | `testFixNames.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 7 | 0 |
| 121 | `src/reconstruction/comparison/modelBorgifier/ismatlab.m` | `testIsmatlab.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 5 | 1 |
| 122 | `src/reconstruction/comparison/modelBorgifier/optWeightExp.m` | `testOptWeightExp.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 4 | 0 |
| 123 | `src/reconstruction/comparison/modelBorgifier/optWeightLin.m` | `testOptWeightLin.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 4 | 0 |
| 124 | `src/reconstruction/comparison/modelBorgifier/orderModelFieldsBorg.m` | `testOrderModelFieldsBorg.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 18 | 2 |
| 125 | `src/reconstruction/comparison/modelBorgifier/organizeModelCool.m` | `testOrganizeModelCool.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 85 | 17 |
| 126 | `src/reconstruction/comparison/modelBorgifier/removeProblematicCharacters.m` | `testRemoveProblematicCharacters.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 56 | 9 |
| 127 | `src/reconstruction/comparison/modelBorgifier/rowvector.m` | `testRowvector.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 7 | 1 |
| 128 | `src/reconstruction/demeter/src/integration/adaptDraftModelID.m` | `testAdaptDraftModelID.m` | `test/verifiedTests/reconstruction/testDemeter/` | 34 | 0 |
| 129 | `src/reconstruction/demeter/src/refinement/addRefinementComments.m` | `testAddRefinementComments.m` | `test/verifiedTests/reconstruction/testDemeter/` | 82 | 19 |
| 130 | `src/reconstruction/fastGapFill/AuxillaryFiles/findIntracellularRxns.m` | `testFindIntracellularRxns.m` | `test/verifiedTests/reconstruction/testFastGapFill/` | 10 | 2 |
| 131 | `src/reconstruction/modelGeneration/massBalance/checkFormulaValidty.m` | `testCheckFormulaValidty.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 33 | 10 |
| 132 | `src/reconstruction/modelGeneration/massBalance/regulariseModelFormulae.m` | `testRegulariseModelFormulae.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 60 | 15 |
| 133 | `src/reconstruction/modelGeneration/modelProperties/printBiomass.m` | `testPrintBiomass.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 12 | 2 |
| 134 | `src/reconstruction/modelGeneration/modelVerification/checkPresentFields.m` | `testCheckPresentFields.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 96 | 27 |
| 135 | `src/reconstruction/modelGeneration/printObjective.m` | `testPrintObjective.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 31 | 4 |
| 136 | `src/reconstruction/modelGeneration/setConstraintsIrrevModel.m` | `testSetConstraintsIrrevModel.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 92 | 20 |
| 137 | `src/reconstruction/refinement/assignGPRA.m` | `testAssignGPRA.m` | `test/verifiedTests/reconstruction/testRefinement/` | 7 | 0 |
| 138 | `src/reconstruction/refinement/assignSubSystems.m` | `testAssignSubSystems.m` | `test/verifiedTests/reconstruction/testRefinement/` | 11 | 2 |
| 139 | `src/reconstruction/refinement/checkIDsForTypeExist.m` | `testCheckIDsForTypeExist.m` | `test/verifiedTests/reconstruction/testRefinement/` | 26 | 6 |
| 140 | `src/reconstruction/refinement/dispStoichAsTable.m` | `testDispStoichAsTable.m` | `test/verifiedTests/reconstruction/testRefinement/` | 10 | 2 |
| 141 | `src/reconstruction/refinement/flipRxnOrientation.m` | `testFlipRxnOrientation.m` | `test/verifiedTests/reconstruction/testRefinement/` | 14 | 2 |
| 142 | `src/reconstruction/refinement/getEmptyConstraints.m` | `testGetEmptyConstraints.m` | `test/verifiedTests/reconstruction/testRefinement/` | 10 | 2 |
| 143 | `src/reconstruction/refinement/updateMetNames.m` | `testUpdateMetNames.m` | `test/verifiedTests/reconstruction/testRefinement/` | 13 | 2 |
| 144 | `src/visualization/EscherMap/model2escher.m` | `testModel2escher.m` | `test/verifiedTests/visualization/testEscherMap/` | 8 | 1 |
| 145 | `src/visualization/SAMMIM/makeSAMMIJson.m` | `testMakeSAMMIJson.m` | `test/verifiedTests/visualization/testSAMMIM/` | 63 | 16 |
| 146 | `src/visualization/SAMMIM/makeSAMMIdataString.m` | `testMakeSAMMIdataString.m` | `test/verifiedTests/visualization/testSAMMIM/` | 9 | 0 |
| 147 | `src/visualization/cellDesigner/readCD.m` | `testReadCD.m` | `test/verifiedTests/visualization/testCellDesigner/` | 22 | 6 |
| 148 | `src/visualization/cellDesigner/retrieveMet.m` | `testRetrieveMet.m` | `test/verifiedTests/visualization/testCellDesigner/` | 24 | 6 |
| 149 | `src/visualization/cellDesigner/updateCD.m` | `testUpdateCD.m` | `test/verifiedTests/visualization/testCellDesigner/` | 89 | 17 |
| 150 | `src/visualization/metabolicCartography/uniqueSpeciesInMap.m` | `testUniqueSpeciesInMap.m` | `test/verifiedTests/visualization/testMetabolicCartography/` | 10 | 0 |
| 151 | `src/analysis/subspaces/conservationAnalysis.m` | `testConservationAnalysis.m` | `test/verifiedTests/analysis/testSubspaces/` | 153 | 27 |
| 152 | `src/analysis/wholeBody/PSCMToolbox/annotateModel.m` | `testAnnotateModel.m` | `test/verifiedTests/analysis/testWholeBody/` | 185 | 34 |
| 153 | `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m` | `testSetFeedingFastingConstraints.m` | `test/verifiedTests/analysis/testWholeBody/` | 151 | 24 |
| 154 | `src/base/solvers/cplex/checkSolFeas.m` | `testCheckSolFeas.m` | `test/verifiedTests/base/testSolvers/` | 203 | 38 |
| 155 | `src/base/solvers/entropicFBA/processConcConstraints.m` | `testProcessConcConstraints.m` | `test/verifiedTests/base/testEntropicFBA/` | 248 | 67 |
| 156 | `src/base/solvers/lindo/solveCobraLPLindo.m` | `testSolveCobraLPLindo.m` | `test/verifiedTests/base/testSolvers/` | 170 | 39 |
| 157 | `src/base/solvers/varKin/optimizeVKmodel0.m` | `testOptimizeVKmodel0.m` | `test/verifiedTests/base/testSolvers/` | 368 | 80 |
| 158 | `src/dataIntegration/metaboAnnotator/buildMetStruct/replaceVMHIds.m` | `testReplaceVMHIds.m` | `test/verifiedTests/dataIntegration/testMetaboAnnotator/` | 264 | 8 |

Rows 1-10 are small functions for the first checkpoint; rows 11-150 have up to 150 code lines; rows 151-158 are the larger functions (User Story 3).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every function of the selection table either has a passing test file named per
  III-Naming or is reported as dropped, with the reason, in the receipt.
- **SC-002**: Each test reaches 100% of the executable lines of its function, or its header
  documents every uncovered line; the covered/total count is reported for all.
- **SC-003**: `git diff --stat -- src` prints nothing.
- **SC-004**: Running all the new tests together creates no files and takes under 10 minutes.
- **SC-005**: No test asserts a defective behaviour; every defect found is a complete
  III-Defects entry and appears once in the regenerated registry.
- **SC-006**: Work stops after the first ten tests and resumes only on maintainer approval.
- **SC-007**: Every function name appears in exactly one test file.
- **SC-008**: No personal information appears in any added file.

## Assumptions

- A MATLAB session with the toolbox initialised is available to probe, run and measure coverage.
- Line coverage is measured per function with MATLAB's coverage tooling; CI's own tooling stays
  authoritative.
- The static scan may over- or under-select; the probe is the authority.
- Test folders follow sibling convention; existing folders are used wherever one fits.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001..010 (rows 1-10) | the ten test files named in rows 1-10 | the functions in rows 1-10 |
| US2 / FR-001..010 (rows 11-150) | the test files named in rows 11-150 | the functions in rows 11-150 |
| US3 / FR-001..010 (rows 151-158) | the test files named in rows 151-158 | the functions in rows 151-158 |
| US4 / FR-005, FR-010, SC-005 | the new tests and the registry tool | — (no source function) |
