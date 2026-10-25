# Feature Specification: Tier-1 test coverage batch 3 (remaining plain-data functions)

**Feature Branch**: none (work stays on `develop`)

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: "Continue Tier 1: use Spec Kit to write tests for the rest of the Tier-1 functions."

This is a CHARACTERIZATION feature under Constitution Principle III (III-Characterization).
It applies III-Coverage (line-coverage goal, Tier 1, `prepareTest()` opening, memory
efficiency, readability), III-Naming (one `test<FunctionName>.m` per function) and
III-Defects (a defect found while testing is documented in the header in the standard format
and skipped, never asserted; every test passes). It follows batches 1 and 2 (features 025 and
026). It changes no `src` file.

## What "the rest of Tier 1" means here

A fresh scan of all toolbox functions that no test mentions found these groups: about 460 use
files, folders, the display, the system, the network or randomness; about 140 take a
genome-scale model (Tier 2, a later feature); about 70 depend on solvers or toolbox state;
the remainder are small or have no branches. The functions that work on plain data and
need none of those are listed below. The list comes from a static scan, so it is PROVISIONAL:
the probe in the plan phase confirms each function, and any that turn out to need files, a
model, a solver or a MATLAB toolbox are dropped and reported (no reserves remain).

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

Rows 11 to 64 (functions of up to 150 code lines), grouped by source folder.

**Independent Test**: each folder group passes and meets the coverage goal on its own.

**Acceptance Scenarios**:

1. **Given** the approved style, **When** a folder group is implemented, **Then** every test in
   it passes and meets the coverage goal.
2. **Given** a function that the probe shows is not Tier 1, **When** it is found, **Then** it is
   dropped and reported with the reason, never silently skipped.

---

### User Story 3 - Pin the ten largest functions (Priority: P3)

The last ten rows (more than 150 code lines each) are written after the others; if one is too
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

Method: untested by name, unique file name (also against `external/`), function name equals
file name, no model argument, no file, network, display, system, solver, random-number or
toolbox-state call (an `exist` check for optional arguments is allowed; one that looks up
files or folders is not), at least 8 code lines and one branch. Functions of earlier
batches' dropped list are not repeated.

| # | Source function | Test file | Test folder | Code lines | Branch keywords |
|---|-----------------|-----------|-------------|-----------:|----------------:|
| 1 | `src/analysis/exploration/surfNetSubfunctions/isValidPrintFields.m` | `testIsValidPrintFields.m` | `test/verifiedTests/analysis/testExploration/` | 11 | 3 |
| 2 | `src/analysis/exploration/surfNetSubfunctions/printHyperlink.m` | `testPrintHyperlink.m` | `test/verifiedTests/analysis/testExploration/` | 13 | 3 |
| 3 | `src/analysis/exploration/surfNetSubfunctions/printMetRxnInfo.m` | `testPrintMetRxnInfo.m` | `test/verifiedTests/analysis/testExploration/` | 29 | 8 |
| 4 | `src/analysis/igemRNA/GT1/findGenesAboveThresholdGT1.m` | `testFindGenesAboveThresholdGT1.m` | `test/verifiedTests/analysis/testGT1/` | 11 | 2 |
| 5 | `src/analysis/igemRNA/GT1/findGenesBelowThresholdGT1.m` | `testFindGenesBelowThresholdGT1.m` | `test/verifiedTests/analysis/testGT1/` | 11 | 2 |
| 6 | `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | `testConvertVMHIDName.m` | `test/verifiedTests/analysis/testPersephone/` | 107 | 18 |
| 7 | `src/analysis/persephone/additionalFunctions/getVMHID.m` | `testGetVMHID.m` | `test/verifiedTests/analysis/testPersephone/` | 50 | 8 |
| 8 | `src/analysis/persephone/fdrBHadjustment.m` | `testFdrBHadjustment.m` | `test/verifiedTests/analysis/testPersephone/` | 12 | 1 |
| 9 | `src/analysis/persephone/performRegressions.m` | `testPerformRegressions.m` | `test/verifiedTests/analysis/testPersephone/` | 135 | 26 |
| 10 | `src/analysis/persephone/runNonparametricTests.m` | `testRunNonparametricTests.m` | `test/verifiedTests/analysis/testPersephone/` | 99 | 13 |
| 11 | `src/analysis/QFCA/mergeFullyCoupled.m` | `testMergeFullyCoupled.m` | `test/verifiedTests/analysis/testQFCA/` | 14 | 2 |
| 12 | `src/analysis/topology/reactingMoieties/addBondMappingsRXNFile.m` | `testAddBondMappingsRXNFile.m` | `test/verifiedTests/analysis/testReactingMoieties/` | 96 | 14 |
| 13 | `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m` | `testExtractBondSubgraphs.m` | `test/verifiedTests/analysis/testReactingMoieties/` | 73 | 13 |
| 14 | `src/analysis/topology/reactingMoieties/mapAontoBOld.m` | `testMapAontoBOld.m` | `test/verifiedTests/analysis/testReactingMoieties/` | 21 | 6 |
| 15 | `src/analysis/topology/reactingMoieties/minimumSetCoverPlain.m` | `testMinimumSetCoverPlain.m` | `test/verifiedTests/analysis/testReactingMoieties/` | 115 | 17 |
| 16 | `src/analysis/topology/reactingMoieties/tabulatePlain.m` | `testTabulatePlain.m` | `test/verifiedTests/analysis/testReactingMoieties/` | 18 | 2 |
| 17 | `src/analysis/sampling/ACHR/mixFraction.m` | `testMixFraction.m` | `test/verifiedTests/analysis/testSampling/` | 16 | 1 |
| 18 | `src/analysis/subspaces/fourFundamentalSubpaces.m` | `testFourFundamentalSubpaces.m` | `test/verifiedTests/analysis/testSubspaces/` | 32 | 3 |
| 19 | `src/analysis/subspaces/lsqr/lsqraprod.m` | `testLsqraprod.m` | `test/verifiedTests/analysis/testSubspaces/` | 12 | 3 |
| 20 | `src/analysis/subspaces/nullspace/echelonNullspace.m` | `testEchelonNullspace.m` | `test/verifiedTests/analysis/testSubspaces/` | 50 | 8 |
| 21 | `src/analysis/subspaces/nullspace/nullSpaceOperatorApply.m` | `testNullSpaceOperatorApply.m` | `test/verifiedTests/analysis/testSubspaces/` | 14 | 1 |
| 22 | `src/analysis/subspaces/rowReduce/rowReduce.m` | `testRowReduce.m` | `test/verifiedTests/analysis/testSubspaces/` | 47 | 10 |
| 23 | `src/analysis/subspaces/subspaceProjection/projectOntoSubspace.m` | `testProjectOntoSubspace.m` | `test/verifiedTests/analysis/testSubspaces/` | 89 | 19 |
| 24 | `src/analysis/thermo/formulae/checkFormulae.m` | `testCheckFormulae.m` | `test/verifiedTests/analysis/testThermo/` | 21 | 5 |
| 25 | `src/analysis/thermo/groupContribution/wang/createFragmentIncidenceMatrix.m` | `testCreateFragmentIncidenceMatrix.m` | `test/verifiedTests/analysis/testThermo/` | 20 | 3 |
| 26 | `src/analysis/thermo/protons/moleFraction.m` | `testMoleFraction.m` | `test/verifiedTests/analysis/testThermo/` | 32 | 7 |
| 27 | `src/analysis/thermo/reactantContribution/acidDissociationConstant.m` | `testAcidDissociationConstant.m` | `test/verifiedTests/analysis/testThermo/` | 37 | 6 |
| 28 | `src/analysis/thermo/thermoFBA/connectedRxnsInNullSpace.m` | `testConnectedRxnsInNullSpace.m` | `test/verifiedTests/analysis/testThermo/` | 16 | 2 |
| 29 | `src/analysis/thermo/trainingModel/Transform.m` | `testTransform.m` | `test/verifiedTests/analysis/testThermo/` | 13 | 2 |
| 30 | `src/base/io/convertCobraLP2mps.m` | `testConvertCobraLP2mps.m` | `test/verifiedTests/base/testIO/` | 40 | 5 |
| 31 | `src/base/io/definitions/getAnnotationFieldName.m` | `testGetAnnotationFieldName.m` | `test/verifiedTests/base/testIO/` | 30 | 4 |
| 32 | `src/base/io/utilities/SBML/convertSBMLID.m` | `testConvertSBMLID.m` | `test/verifiedTests/base/testIO/testUtilities/` | 21 | 2 |
| 33 | `src/base/io/utilities/SBML/parseCVTerms.m` | `testParseCVTerms.m` | `test/verifiedTests/base/testIO/testUtilities/` | 12 | 1 |
| 34 | `src/base/io/utilities/mergeTextDataAndData.m` | `testMergeTextDataAndData.m` | `test/verifiedTests/base/testIO/testUtilities/` | 85 | 32 |
| 35 | `src/base/solvers/cplex/getParamList.m` | `testGetParamList.m` | `test/verifiedTests/base/testSolvers/` | 76 | 17 |
| 36 | `src/base/solvers/rescale/splitRow.m` | `testSplitRow.m` | `test/verifiedTests/base/testSolvers/` | 21 | 1 |
| 37 | `src/base/solvers/varKin/BDCAmethods/FuncGradHessSub.m` | `testFuncGradHessSub.m` | `test/verifiedTests/base/testSolvers/` | 26 | 1 |
| 38 | `src/base/solvers/varKin/levMarMethods/Rate_function1.m` | `testRate_function1.m` | `test/verifiedTests/base/testSolvers/` | 14 | 2 |
| 39 | `src/base/createDeltaMatchMatrix.m` | `testCreateDeltaMatchMatrix.m` | `test/verifiedTests/base/testTools/` | 16 | 1 |
| 40 | `src/base/utilities/countUnique.m` | `testCountUnique.m` | `test/verifiedTests/base/testTools/` | 9 | 1 |
| 41 | `src/base/utilities/dispMatrix.m` | `testDispMatrix.m` | `test/verifiedTests/base/testTools/` | 19 | 7 |
| 42 | `src/base/utilities/isvar.m` | `testIsvar.m` | `test/verifiedTests/base/testTools/` | 11 | 1 |
| 43 | `src/base/utilities/mapAontoB.m` | `testMapAontoB.m` | `test/verifiedTests/base/testTools/` | 85 | 25 |
| 44 | `src/base/utilities/updateStructData.m` | `testUpdateStructData.m` | `test/verifiedTests/base/testTools/` | 12 | 3 |
| 45 | `src/dataIntegration/fluxomics/c13solver/idv2idv.m` | `testIdv2idv.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 13 | 2 |
| 46 | `src/dataIntegration/fluxomics/calcMDVfromSamp.m` | `testCalcMDVfromSamp.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 63 | 9 |
| 47 | `src/dataIntegration/fluxomics/compareTwoMDVs.m` | `testCompareTwoMDVs.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 19 | 2 |
| 48 | `src/dataIntegration/fluxomics/naturallabel.m` | `testNaturallabel.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 12 | 3 |
| 49 | `src/dataIntegration/fluxomics/score_KS.m` | `testScore_KS.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 15 | 1 |
| 50 | `src/dataIntegration/metaboAnnotator/buildMetStruct/addField2MetStructure.m` | `testAddField2MetStructure.m` | `test/verifiedTests/dataIntegration/testMetaboAnnotator/` | 17 | 3 |
| 51 | `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m` | `testConvertOld2NewHMDB.m` | `test/verifiedTests/dataIntegration/testMetaboAnnotator/` | 10 | 2 |
| 52 | `src/dataIntegration/XomicsToModel/analysis/compareXomicsModels.m` | `testCompareXomicsModels.m` | `test/verifiedTests/dataIntegration/testXomicsToModel/` | 75 | 10 |
| 53 | `src/dataIntegration/XomicsToModel/metabolomics/metsToKeep.m` | `testMetsToKeep.m` | `test/verifiedTests/dataIntegration/testXomicsToModel/` | 56 | 8 |
| 54 | `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m` | `testGapfillRefinedGenomeReactions.m` | `test/verifiedTests/reconstruction/testDemeter/` | 149 | 8 |
| 55 | `src/reconstruction/fastGapFill/AuxillaryFiles/assignRxnWeights.m` | `testAssignRxnWeights.m` | `test/verifiedTests/reconstruction/testFastGapFill/` | 29 | 6 |
| 56 | `src/reconstruction/modelGeneration/massBalance/ispolymer.m` | `testIspolymer.m` | `test/verifiedTests/reconstruction/testMassChargeBalance/` | 8 | 1 |
| 57 | `src/reconstruction/comparison/modelBorgifier/compareMatricies.m` | `testCompareMatricies.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 24 | 2 |
| 58 | `src/reconstruction/comparison/modelBorgifier/countC.m` | `testCountC.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 12 | 2 |
| 59 | `src/reconstruction/comparison/modelBorgifier/mergeTrxns.m` | `testMergeTrxns.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 82 | 17 |
| 60 | `src/reconstruction/modelGeneration/stoichConsistency/optimalConservationVectors.m` | `testOptimalConservationVectors.m` | `test/verifiedTests/reconstruction/testStoichiometricConsistency/` | 20 | 2 |
| 61 | `src/visualization/metabolicCartography/addFluxWidthAndColor.m` | `testAddFluxWidthAndColor.m` | `test/verifiedTests/visualization/testMetabolicCartography/` | 77 | 13 |
| 62 | `src/visualization/metabolicCartography/removeMapMol.m` | `testRemoveMapMol.m` | `test/verifiedTests/visualization/testMetabolicCartography/` | 62 | 11 |
| 63 | `src/visualization/metabolicCartography/visualizeFluxFromFile.m` | `testVisualizeFluxFromFile.m` | `test/verifiedTests/visualization/testMetabolicCartography/` | 9 | 1 |
| 64 | `src/visualization/SAMMIM/makeSAMMIparseVector.m` | `testMakeSAMMIparseVector.m` | `test/verifiedTests/visualization/testSammi/` | 14 | 3 |
| 65 | `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m` | `testPerformStatisticalAnalysis.m` | `test/verifiedTests/analysis/testMultiSpeciesModelling/` | 164 | 37 |
| 66 | `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m` | `testAdjustBaselinesInAlberty2006.m` | `test/verifiedTests/analysis/testThermo/` | 185 | 50 |
| 67 | `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | `testCreateComputedSpeciesData.m` | `test/verifiedTests/analysis/testThermo/` | 163 | 31 |
| 68 | `src/analysis/topology/FR/bilinearDecomposition.m` | `testBilinearDecomposition.m` | `test/verifiedTests/analysis/testTopology/` | 193 | 38 |
| 69 | `src/base/solvers/mosek/inspectMosekNumerics.m` | `testInspectMosekNumerics.m` | `test/verifiedTests/base/testSolvers/` | 158 | 22 |
| 70 | `src/base/solvers/mosek/inspectMosekProb.m` | `testInspectMosekProb.m` | `test/verifiedTests/base/testSolvers/` | 215 | 39 |
| 71 | `src/base/solvers/mosek/parseMskResult.m` | `testParseMskResult.m` | `test/verifiedTests/base/testSolvers/` | 155 | 26 |
| 72 | `src/base/solvers/mosek/setMosekParam.m` | `testSetMosekParam.m` | `test/verifiedTests/base/testSolvers/` | 394 | 92 |
| 73 | `src/dataIntegration/fluxomics/runHiLoExp.m` | `testRunHiLoExp.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 169 | 38 |
| 74 | `src/dataIntegration/metaboAnnotator/buildMetStruct/sanityCheckMetIds.m` | `testSanityCheckMetIds.m` | `test/verifiedTests/dataIntegration/testMetaboAnnotator/` | 184 | 42 |

Rows 1-64 have up to 150 code lines; rows 65-74 are the larger functions (User Story 3).

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
| US2 / FR-001..010 (rows 11-64) | the test files named in rows 11-64 | the functions in rows 11-64 |
| US3 / FR-001..010 (rows 65-74) | the test files named in rows 65-74 | the functions in rows 65-74 |
| US4 / FR-005, FR-010, SC-005 | the new tests and the registry tool | — (no source function) |
