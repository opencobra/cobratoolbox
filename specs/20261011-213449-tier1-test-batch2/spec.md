# Feature Specification: Tier-1 test coverage batch 2 (50 functions)

**Feature Branch**: `026-tier1-test-batch2`

**Created**: 2026-10-11

**Status**: Draft

**Input**: User description: "Characterization feature (Constitution III-Characterization + III-Coverage + III-Naming, Tier 1 batch 2): add 50 test files for 50 currently untested Tier-1 functions in src/. Source functions must not be changed."

This is a CHARACTERIZATION feature under Constitution Principle III (III-Characterization).
It applies III-Coverage (line-coverage goal, Tier 1, `prepareTest()` opening, memory
efficiency, readability) and III-Naming (one `test<FunctionName>.m` per function) to
fifty further untested functions, following the pilot of five (feature 025). It changes
no `src` file. The rules themselves live in the constitution and are referenced, not
restated, here.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pin the first ten functions and validate the style (Priority: P1)

A maintainer wants the first ten of the fifty functions (chosen as the first ten rows of
the selection table, one folder group at a time) pinned by tests and reviewed before the
remaining forty are written, so that any style correction is made once.

**Why this priority**: A cheap early checkpoint prevents repeating a style mistake forty
more times. It is the MVP: ten finished, reviewed tests.

**Independent Test**: Run the ten test files through the real test harness; each passes and
reaches 100% line coverage of its function (or documents each uncovered line). The
maintainer reviews them and approves or requests changes.

**Acceptance Scenarios**:

1. **Given** the approved selection, **When** the first ten tests are written, **Then** each
   is named per III-Naming, opens per III-Coverage, passes under the harness runner and
   reports its covered/total line count.
2. **Given** the ten tests, **When** the maintainer reviews them, **Then** the remaining forty
   are not started until the maintainer approves.

---

### User Story 2 - Pin the remaining forty functions (Priority: P2)

After the checkpoint, the remaining forty functions are pinned, grouped by source folder.

**Why this priority**: Delivers the bulk of the coverage gain once the style is validated.

**Independent Test**: Each folder group can be written and verified on its own; all pass
under the harness runner with 100% (or documented) line coverage.

**Acceptance Scenarios**:

1. **Given** the approved style, **When** a folder group is implemented, **Then** every test in
   that group passes and meets the coverage goal.
2. **Given** a function that the behaviour probe shows is not Tier 1 after all (needs a
   model, a file, a solver or a display), **When** it is found, **Then** it is replaced by the
   next reserve (R1..R12) and the replacement is reported, never silently dropped.

---

### User Story 3 - Whole-batch verification and receipt (Priority: P3)

A maintainer wants evidence that the whole batch is consistent and leaves no side effects.

**Why this priority**: Closes the feature with proof, but depends on the tests existing.

**Independent Test**: Run all fifty through the harness runner, check that no `src` file
changed and no file was created by the tests, and read the implementation receipt.

**Acceptance Scenarios**:

1. **Given** all fifty tests, **When** they are run together, **Then** all pass and the total
   time is reported.
2. **Given** the finished batch, **When** `git diff --stat -- src` is run, **Then** it prints
   nothing.

---

### Edge Cases

- A function whose probe shows it errors, prints, or behaves unexpectedly for valid-looking
  input: the behaviour is pinned as it is and recorded as a known defect or quirk in the
  test header; the function is NOT fixed.
- A function with persistent or global state: the state is cleared before each case and
  at the end of the test.
- A function that prints to the console: the output is not suppressed and is recorded as a
  console-noise exemption in the header.
- A function with a branch that cannot be reached with Tier 1 inputs: the line is listed
  with its reason in the header as a coverage exemption.
- A source file whose file name and function name differ, or whose name exists in several
  folders: excluded from selection (the test would be ambiguous).
- A selected function that the probe reveals needs a model or a file: replaced by a reserve.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The feature MUST add exactly one test file per selected function, named
  `test<FunctionName>.m` per III-Naming, in the folder given in the selection table, and
  each MUST run within `test/testAll.m`.
- **FR-002**: Each test MUST follow III-Coverage: aim for 100% line coverage, declare Tier 1
  in its header, open with `prepareTest()` after the `cd(fileDir)` lines, use hand-built
  inputs only, and list any uncovered line with its reason.
- **FR-003**: Each test header MUST state purpose, function under test, Tier 1, coverage
  exemptions, known defects pinned and not fixed, and authors/date; the body MUST have a `%%`
  section per behaviour or branch with a comment on every assertion group; variables shared
  by sections MUST be defined before the first `%%` section.
- **FR-004**: Assertions MUST be `assert`-based; exact equality only for discrete values;
  floating-point comparisons MUST use a justified tolerance; expected-failure paths MUST use
  `verifyCobraFunctionError`.
- **FR-005**: Expected values MUST come from reading the source and from a recorded probe of
  current behaviour, not from guesses.
- **FR-006**: Tests MUST be memory efficient, create no files, and leave no persistent or
  global state behind; console output of the function under test MUST NOT be suppressed.
- **FR-007**: The feature MUST NOT change any file under `src/`; defects are only documented.
- **FR-008**: The first ten tests MUST be completed and verified, then work MUST stop for
  maintainer validation before the remaining forty are written.
- **FR-009**: Each test MUST be verified by running it through the real harness runner and by
  measuring line coverage of its function; the covered/total count MUST be reported per
  function.
- **FR-010**: The selection MUST be recorded in this spec, verified by search against all
  files under `test/`, and any replacement from the reserve list MUST be recorded.
- **FR-011**: The spec, plan, tasks, research notes and receipt MUST NOT contain personal
  information about the contributor (names, email addresses, account names), because they
  are published in the public repository.
- **FR-012**: The contributor MUST report files changed, checks run, tests passed or failed,
  and behaviours not yet verified, and write the implementation receipt.

### Key Entities

- **Selected function**: a source function with its test file name, test folder, size and
  branch count.
- **Reserve function**: a Tier-1 candidate that replaces a selected function found not to be
  Tier 1 by the probe.
- **Coverage exemption**: a header entry naming an uncovered line and its reason.

## Existing Contract *(characterization mode)*

- **Function(s) under test**: the fifty functions in the selection table below.
- **Current inputs / arities**: as in each source function; recorded per function during
  the research phase.
- **Current outputs**: as in each source function; recorded per function by the probe.
- **Invariants & expected results**: derived from the source and confirmed by the probe;
  tolerances only where floating-point results occur, each justified.
- **Coverage gap**: none of the fifty function names appears in any file under `test/`
  (checked by word search over all test files); each function name is unique under `src/`.

### Selection (PROVISIONAL, for maintainer approval before tasks are generated)

Method: untested by name, unique file name, function name equals file name, 15-60 code
lines, at least 3 branch keywords, no model argument, and no use of file, network, display,
plotting, Java/Python, solver, random-number or environment calls (static scan; the probe in
the plan phase confirms each). "New" folders do not exist yet; all others do.

| # | Source function | Test file | Test folder | Code lines | Branch keywords |
|---|-----------------|-----------|-------------|-----------:|----------------:|
| 1 | `src/analysis/exploration/findMatchingFieldEntries.m` | `testFindMatchingFieldEntries.m` | `test/verifiedTests/analysis/testExploration/` | 29 | 5 |
| 2 | `src/analysis/exploration/surfNetSubfunctions/numToFormattedString.m` | `testNumToFormattedString.m` | `test/verifiedTests/analysis/testExploration/` | 51 | 17 |
| 3 | `src/analysis/persephone/calculateMetrics.m` | `testCalculateMetrics.m` | `test/verifiedTests/analysis/testPersephone/` (new folder) | 35 | 9 |
| 4 | `src/analysis/rumba/compareConditions.m` | `testCompareConditions.m` | `test/verifiedTests/analysis/testRumba/` (new folder) | 34 | 4 |
| 5 | `src/analysis/sampling/compareTwoSamplesStat.m` | `testCompareTwoSamplesStat.m` | `test/verifiedTests/analysis/testSampling/` | 46 | 12 |
| 6 | `src/analysis/subspaces/gmscale.m` | `testGmscale.m` | `test/verifiedTests/analysis/testSubspaces/` | 57 | 7 |
| 7 | `src/analysis/thermo/componentContribution/reaction2sparse.m` | `testReaction2sparse.m` | `test/verifiedTests/analysis/testThermo/` | 37 | 6 |
| 8 | `src/analysis/thermo/utilities/maxstar.m` | `testMaxstar.m` | `test/verifiedTests/analysis/testThermo/` | 54 | 9 |
| 9 | `src/analysis/topology/reactingMoieties/createBIGraph.m` | `testCreateBIGraph.m` | `test/verifiedTests/analysis/testTopology/` | 44 | 11 |
| 10 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateFoodScore.m` | `testCalculateFoodScore.m` | `test/verifiedTests/analysis/testWholeBody/` (new folder) | 45 | 4 |
| 11 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/compareDiets.m` | `testCompareDiets.m` | `test/verifiedTests/analysis/testWholeBody/` (new folder) | 37 | 9 |
| 12 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/convertNutrientsToMmol.m` | `testConvertNutrientsToMmol.m` | `test/verifiedTests/analysis/testWholeBody/` (new folder) | 35 | 8 |
| 13 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/normalizeDiet.m` | `testNormalizeDiet.m` | `test/verifiedTests/analysis/testWholeBody/` (new folder) | 33 | 7 |
| 14 | `src/analysis/wholeBody/PSCMToolbox/calculateBMR.m` | `testCalculateBMR.m` | `test/verifiedTests/analysis/testWholeBody/` (new folder) | 16 | 3 |
| 15 | `src/analysis/wholeBody/PSCMToolbox/compareMaleFemale.m` | `testCompareMaleFemale.m` | `test/verifiedTests/analysis/testWholeBody/` (new folder) | 30 | 4 |
| 16 | `src/base/solvers/cardOpt/sparseLP/evalObj.m` | `testEvalObj.m` | `test/verifiedTests/base/testCardOpt/` | 33 | 12 |
| 17 | `src/base/solvers/cardOpt/sparseLP/updateObj.m` | `testUpdateObj.m` | `test/verifiedTests/base/testCardOpt/` | 37 | 11 |
| 18 | `src/base/io/utilities/SBML/getDataBases.m` | `testGetDataBases.m` | `test/verifiedTests/base/testIO/testUtilities/` | 21 | 6 |
| 19 | `src/base/io/utilities/parseSBMLAnnotationField.m` | `testParseSBMLAnnotationField.m` | `test/verifiedTests/base/testIO/testUtilities/` | 48 | 16 |
| 20 | `src/base/io/utilities/parseSBMLAnnotationFieldRxn.m` | `testParseSBMLAnnotationFieldRxn.m` | `test/verifiedTests/base/testIO/testUtilities/` | 18 | 5 |
| 21 | `src/base/solvers/param/parseSolverParameters.m` | `testParseSolverParameters.m` | `test/verifiedTests/base/testSolvers/` | 53 | 14 |
| 22 | `src/base/solvers/varKin/BDCAmethods/StopCritBDCA.m` | `testStopCritBDCA.m` | `test/verifiedTests/base/testSolvers/` | 48 | 12 |
| 23 | `src/base/solvers/varKin/derFreeMethods/StopCritDuplo.m` | `testStopCritDuplo.m` | `test/verifiedTests/base/testSolvers/` | 48 | 12 |
| 24 | `src/base/solvers/varKin/levMarMethods/Initialization.m` | `testInitialization.m` | `test/verifiedTests/base/testSolvers/` | 57 | 11 |
| 25 | `src/base/hyperlink.m` | `testHyperlink.m` | `test/verifiedTests/base/testTools/` | 15 | 4 |
| 26 | `src/base/parseGPR.m` | `testParseGPR.m` | `test/verifiedTests/base/testTools/` | 32 | 6 |
| 27 | `src/base/parseMetNames.m` | `testParseMetNames.m` | `test/verifiedTests/base/testTools/` | 17 | 5 |
| 28 | `src/base/preparseGPR.m` | `testPreparseGPR.m` | `test/verifiedTests/base/testTools/` | 24 | 5 |
| 29 | `src/base/utilities/calcDist.m` | `testCalcDist.m` | `test/verifiedTests/base/testTools/` | 37 | 4 |
| 30 | `src/dataIntegration/chemoInformatics/editChemicalFormula.m` | `testEditChemicalFormula.m` | `test/verifiedTests/dataIntegration/testChemoInformatics/` | 41 | 8 |
| 31 | `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` | `testGetInchiData.m` | `test/verifiedTests/dataIntegration/testChemoInformatics/` | 50 | 9 |
| 32 | `src/dataIntegration/fluxomics/c13solver/Combination.m` | `testCombination.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 45 | 10 |
| 33 | `src/dataIntegration/fluxomics/c13solver/errorComputation2.m` | `testErrorComputation2.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 24 | 5 |
| 34 | `src/dataIntegration/fluxomics/c13solver/errorComputation2_grad.m` | `testErrorComputation2_grad.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 55 | 10 |
| 35 | `src/dataIntegration/fluxomics/c13solver/solveLin.m` | `testSolveLin.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 24 | 4 |
| 36 | `src/dataIntegration/fluxomics/score_ridge.m` | `testScore_ridge.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 26 | 4 |
| 37 | `src/dataIntegration/metaboAnnotator/buildMetStruct/removeSmilesInchiKey.m` | `testRemoveSmilesInchiKey.m` | `test/verifiedTests/dataIntegration/testMetaboAnnotator/` (new folder) | 34 | 6 |
| 38 | `src/design/analyzeRxns.m` | `testAnalyzeRxns.m` | `test/verifiedTests/design/` | 26 | 5 |
| 39 | `src/design/optEnvelope/seperateTransposeJoinOE.m` | `testSeperateTransposeJoinOE.m` | `test/verifiedTests/design/` | 50 | 5 |
| 40 | `src/reconstruction/demeter/src/integration/checkInputData.m` | `testCheckInputData.m` | `test/verifiedTests/reconstruction/testDemeter/` (new folder) | 52 | 10 |
| 41 | `src/reconstruction/demeter/src/integration/mapMediumData2AGORA.m` | `testMapMediumData2AGORA.m` | `test/verifiedTests/reconstruction/testDemeter/` (new folder) | 26 | 5 |
| 42 | `src/reconstruction/comparison/modelBorgifier/buildRxnEquations.m` | `testBuildRxnEquations.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 53 | 12 |
| 43 | `src/reconstruction/comparison/modelBorgifier/buildRxnEquationsFromName.m` | `testBuildRxnEquationsFromName.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 54 | 12 |
| 44 | `src/reconstruction/comparison/modelBorgifier/newCompsNewMets.m` | `testNewCompsNewMets.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 25 | 6 |
| 45 | `src/reconstruction/comparison/modelBorgifier/removeDuplicateNames.m` | `testRemoveDuplicateNames.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 27 | 5 |
| 46 | `src/reconstruction/comparison/modelBorgifier/removeProblematicCharacters.m` | `testRemoveProblematicCharacters.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 56 | 9 |
| 47 | `src/reconstruction/refinement/GPRLogic/combineChildren.m` | `testCombineChildren.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 37 | 9 |
| 48 | `src/reconstruction/refinement/convertIrrevFluxDistribution.m` | `testConvertIrrevFluxDistribution.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 15 | 3 |
| 49 | `src/reconstruction/refinement/reassignFwBwMatch.m` | `testReassignFwBwMatch.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 18 | 4 |
| 50 | `src/visualization/maps/ReconMap/makeColorGradient.m` | `testMakeColorGradient.m` | `test/verifiedTests/visualization/testReconMap/` | 17 | 3 |

Why Tier 1: each function takes plain data (numbers, strings, cell arrays, matrices, small
structs) and returns plain data, with no solver, genome-scale model, file, network or display
access, per the static scan above.

New test folders requested (no existing folder matches the domain):
- `test/verifiedTests/analysis/testPersephone/`
- `test/verifiedTests/analysis/testRumba/`
- `test/verifiedTests/analysis/testWholeBody/`
- `test/verifiedTests/dataIntegration/testMetaboAnnotator/`
- `test/verifiedTests/reconstruction/testDemeter/`

### Reserve list (replacements if the probe demotes a selected function)

| Reserve | Source function | Code lines | Branch keywords |
|---------|-----------------|-----------:|----------------:|
| R1 | `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m` | 77 | 18 |
| R2 | `src/base/solvers/cplex/getParamList.m` | 76 | 17 |
| R3 | `src/base/io/utilities/parseSBMLNotesField.m` | 67 | 17 |
| R4 | `src/analysis/thermo/groupContribution/new/regulariseGroupIncidenceMatrix.m` | 59 | 17 |
| R5 | `src/analysis/rumba/classifyRxns.m` | 71 | 16 |
| R6 | `src/base/solvers/varKin/derFreeMethods/InitialDuplo.m` | 77 | 15 |
| R7 | `src/dataIntegration/metaboAnnotator/buildMetStruct/cleanUpMetabolite_structure.m` | 47 | 15 |
| R8 | `src/base/solvers/varKin/BDCAmethods/InitialBDCA.m` | 72 | 14 |
| R9 | `src/base/solvers/cplex/buildCplexProblemFromCOBRAStruct.m` | 63 | 13 |
| R10 | `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m` | 73 | 13 |
| R11 | `src/visualization/metabolicCartography/addFluxWidthAndColor.m` | 77 | 13 |
| R12 | `src/analysis/sampling/BarrierRound/PolytopeSimplifier/lewisCenter.m` | 79 | 12 |

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 50 test files exist, each named per III-Naming, and all 50 pass when run through
  the harness runner on the unmodified source.
- **SC-002**: Each test reaches 100% of the executable lines of its function, or its header
  documents every uncovered line; the covered/total count is reported for all 50.
- **SC-003**: `git diff --stat -- src` prints nothing.
- **SC-004**: Running all 50 tests together creates no files and completes in under 5 minutes.
- **SC-005**: A reviewer can identify purpose, tier, exemptions and known defects of any test
  from its first screen, without reading the source function.
- **SC-006**: Work stops after the first ten tests and resumes only on maintainer approval.
- **SC-007**: Every one of the 50 function names appears in exactly one test file.
- **SC-008**: No personal information appears in any file added under `specs/`.

## Assumptions

- A MATLAB session with the toolbox initialized is available to probe, run and measure
  coverage.
- Line coverage is measured per function with MATLAB's code-coverage tooling; CI's own
  coverage tooling remains authoritative.
- The static scan may over- or under-select; the research-phase probe is the authority on
  whether a function is Tier 1, and reserves cover demotions.
- Test folders follow sibling convention; folders marked "new" are created only for domains
  with no existing test folder.
- Execution order follows the table: folder groups in the order shown.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001..009 (first ten rows of the table) | the ten test files named in rows 1-10 | the ten functions in rows 1-10 |
| US2 / FR-001..009 (rows 11-50) | the test files named in rows 11-50 | the functions in rows 11-50 |
| US3 / FR-007, SC-003, SC-004 (batch checks) | all 50 test files run together | all 50 functions |
