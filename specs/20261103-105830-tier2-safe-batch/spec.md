# Feature Specification: Tier-2 tests for every safe untested model-manipulation function

**Feature Branch**: `20261103-105830-tier2-safe-batch` (stacked on `20261102-142225-tier2-test-pilot`)

**Created**: 2026-11-03

**Status**: Draft

**Input**: User description: "can you find all of the Tier 2 functions that do not get impact from defect functions and are safe and write tests for all of them?"

This is a CHARACTERIZATION feature under Constitution Principle III (III-Characterization),
applying III-Coverage (Tier 2, Tier 4 model loading, Tier 5 first-run references), III-Naming
and III-Defects, in the style of the Tier-2 pilot (`specs/20261102-142225-tier2-test-pilot/`).
It changes no `src` file.

## How the functions were found

Scan of 2026-11-03 over `src/` (excluding `old/`, `new/`, `deprecated/`, `external/`, class folders
and DEMETER suite "test" functions):

1. **Model-first and untested**: the first input is a model and the function name appears in no
   file under `test/`.
2. **Safe = no solver, file, plot, GUI, network or MATLAB-toolbox call anywhere in the static call
   closure** (calls resolved by name across `src/` and `external/`, local variables excluded).
   Four hubs whose solver or file path needs an explicit option were verified and not traversed:
   `removeRxns` (solver only with the `'infeasible'` constraint method), `verifyModel` (solver only
   with `fluxConsistency`), `removeFieldEntriesForType`, `printRxnFormula` (file only with a file
   name); `getDefinedFieldProperties`/`descFileRead` read only the toolbox's own field
   definitions. 134 candidates reach a solver, file or toolbox (Tier 3 or later) and are out of
   scope.
3. **Not impacted by a known defect**: no function in the closure has a registered defect of
   severity wrong-result, limitation or unusable-option whose trigger is reachable (an `error`
   defect cannot produce a wrong reference value). Excluded: `applyEFluxConstraints`
   (`combineChildren`, `selectGeneFromGPR`), `findMetabolicJunctions` and `findNeighborRxns`
   (`parseMetNames`). Nine functions that reach `createEmptyFields` are kept: its limitation needs
   caller-supplied definitions with two dimensions above 1, and its only such caller
   (`addMIRIAMAnnotations`) passes a second dimension of 1.

The result is the 30 functions below. The list is PROVISIONAL: the probe in each task drops a
function that, when run, needs a solver, a file or data the toolbox does not distribute, or a model
that `getDistributedModel` does not provide (for example whole-body models); every drop is
reported with its reason.

## Decisions taken without maintainer input (pilot style note, open questions 1-5)

The maintainer did not answer the pilot's style questions; this feature uses the pilot's pattern:
(1) structural checks stay inline (no new shared helper); (2) when genes are removed or renumbered,
GPRs are compared after rewriting `x(i)` to gene names; (3) a function that changes global state
(warnings, path) has that state restored by the test after the call, which is not suppression;
(4) only debug leftovers (printing a loop index, unterminated debug output) are recorded as
cosmetic defects, not ordinary verbose output; (5) only documented inputs are tested. A later
maintainer decision can refactor these tests.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every safe untested model function is pinned (Priority: P1)

**Independent Test**: each test passes through the harness runner, reaches 100% line coverage or
documents every uncovered line, and calls no solver (verified with solver spies during
development).

**Acceptance Scenarios**:

1. **Given** a selected function, **When** its test runs, **Then** it loads the smallest
   distributed model that reaches its branches once, and asserts structural consistency, content
   agreement with the input model and Tier-5 first-run values, as in the pilot.
2. **Given** a function that the probe shows needs a solver, an undistributed model or external
   data, **When** found, **Then** it is dropped and reported with the reason.
3. **Given** a defect found while writing a test, **Then** it is recorded per III-Defects, its
   input skipped, and the test passes.

### User Story 2 - Large functions (Priority: P2)

Functions over 150 code lines are written after the others; one too costly for a faithful test is
reported and left for a later feature rather than weakened.

### User Story 3 - Registry and summary (Priority: P2)

The registry is regenerated (generator exits 0) and a summary lists tests written, functions
dropped with reasons, defects found and runtimes.

### Edge Cases

- A function that needs fields the distributed model lacks: build them from the loaded model
  (documented in the header), unless they are scientific data the toolbox does not ship (then drop).
- A function that writes to the console heavily: not suppressed; noted in the summary.
- A function that changes global state: the test restores it after the call.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: One test file per kept function, named per III-Naming, in the folder of the
  selection table, run by `test/testAll.m`.
- **FR-002**: Tier 2 declared; `prepareTest()` opening; models only through `getDistributedModel`,
  each loaded once per file; smallest model that reaches the branches (E. coli core by default).
- **FR-003**: Assertions as in the pilot (structural consistency, content agreement, Tier-5
  counts with exact equality, justified tolerances for floats, `assert(verifyCobraFunctionError(...))`
  for documented errors).
- **FR-004**: No solver is called: each test is run once during development with spy functions
  shadowing `solveCobraLP`, `solveCobraQP`, `solveCobraMILP`, `solveCobraMIQP`, `solveCobraNLP`,
  `solveCobraEP` and `optimizeCbModel` that raise an error if called.
- **FR-005**: 100% line coverage or every uncovered line listed with its reason.
- **FR-006**: No `src` change; defects recorded per III-Defects and skipped; every test passes.
- **FR-007**: Memory efficient, no files created, no global state left, output not suppressed.
- **FR-008**: Functions dropped by the probe are reported with the reason (solver at run time,
  undistributed model, external data, toolbox).
- **FR-009**: Registry regenerated; summary written; implementation receipt written.
- **FR-010**: Commits with the maintainer identity, no co-author line, only this feature's files;
  branch pushed to the maintainer's fork.

### Key Entities

- **Selected function**, **Dropped function** (with reason), **Reference value**, **Defect entry**.

## Existing Contract *(characterization mode)*

- **Function(s) under test**: the functions of the selection table that the probe keeps.
- **Current inputs / outputs**: as in each source function's header.
- **Invariants & expected results**: as in FR-003.
- **Coverage gap**: none of these names appears in any file under `test/` (scan of 2026-11-03).

### Selection (PROVISIONAL; ≤150 code lines first, then larger)

| # | Source function | Test file | Test folder | Code lines |
|---|-----------------|-----------|-------------|-----------:|
| 1 | `src/analysis/exploration/generateHyperlinkedModel.m` | `testGenerateHyperlinkedModel.m` | `test/verifiedTests/analysis/testExploration/` | 62 |
| 2 | `src/analysis/exploration/surfNetSubfunctions/generateGrRules.m` | `testGenerateGrRules.m` | `test/verifiedTests/analysis/testExploration/` | 49 |
| 3 | `src/analysis/mdFBA/buildMDFBAProblem.m` | `testBuildMDFBAProblem.m` | `test/verifiedTests/analysis/testMDFBA/` | 32 |
| 4 | `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m` | `testAddMicrobeCommunityBiomass.m` | `test/verifiedTests/analysis/testMultiSpeciesModelling/` | 19 |
| 5 | `src/analysis/thermo/vonBertalanffy/estimateDfGt0.m` | `testEstimateDfGt0.m` | `test/verifiedTests/analysis/testThermo/` | 113 |
| 6 | `src/analysis/thermo/vonBertalanffy/estimateDrGt0.m` | `testEstimateDrGt0.m` | `test/verifiedTests/analysis/testThermo/` | 108 |
| 7 | `src/analysis/topology/findCyclicRxns.m` | `testFindCyclicRxns.m` | `test/verifiedTests/analysis/testTopology/` | 3 |
| 8 | `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | `testCreateModelNewCompartment.m` | `test/verifiedTests/analysis/testWholeBody/` | 62 |
| 9 | `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m` | `testAddReactionsHH.m` | `test/verifiedTests/analysis/testWholeBody/` | 57 |
| 10 | `src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m` | `testSetDietConstraints.m` | `test/verifiedTests/analysis/testWholeBody/` | 103 |
| 11 | `src/base/io/KEGG/mapKEGGID2Model.m` | `testMapKEGGID2Model.m` | `test/verifiedTests/base/testIO/testKEGG/` | 30 |
| 12 | `src/base/io/KEGG/mapMetName2KEGGID.m` | `testMapMetName2KEGGID.m` | `test/verifiedTests/base/testIO/testKEGG/` | 45 |
| 13 | `src/base/io/utilities/SBML/makeSBMLAnnotationString.m` | `testMakeSBMLAnnotationString.m` | `test/verifiedTests/base/testIO/testUtilities/` | 97 |
| 14 | `src/base/io/utilities/SBML/mapAnnotationsToFields.m` | `testMapAnnotationsToFields.m` | `test/verifiedTests/base/testIO/testUtilities/` | 28 |
| 15 | `src/base/io/utilities/initFBAFields.m` | `testInitFBAFields.m` | `test/verifiedTests/base/testIO/testUtilities/` | 53 |
| 16 | `src/dataIntegration/XomicsToModel/prepareData/regulariseMitochondrialReactions.m` | `testRegulariseMitochondrialReactions.m` | `test/verifiedTests/dataIntegration/testXomicsToModel/` | 45 |
| 17 | `src/design/TrimGdel/geneReactionMILP.m` | `testGeneReactionMILP.m` | `test/verifiedTests/design/testTrimGdel/` | 63 |
| 18 | `src/design/TrimGdel/modelSetting.m` | `testModelSetting.m` | `test/verifiedTests/design/testTrimGdel/` | 24 |
| 19 | `src/reconstruction/modelGeneration/modelVerification/checkDatabaseIDs.m` | `testCheckDatabaseIDs.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 24 |
| 20 | `src/reconstruction/refinement/assignGPRA.m` | `testAssignGPRA.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 7 |
| 21 | `src/reconstruction/refinement/assignSubSystems.m` | `testAssignSubSystems.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 11 |
| 22 | `src/analysis/persephone/additionalFunctions/physiologicalConstraintsHMDBbasedTEMP.m` | `testPhysiologicalConstraintsHMDBbasedTEMP.m` | `test/verifiedTests/analysis/testPersephone/` | 624 |
| 23 | `src/analysis/thermo/reactantContribution/setCommonZeroStandardGibbsEnergyOfFormation.m` | `testSetCommonZeroStandardGibbsEnergyOfFormation.m` | `test/verifiedTests/analysis/testThermo/` | 221 |
| 24 | `src/analysis/thermo/reactantContribution/thermodynamicAdjustmentToStoichiometry.m` | `testThermodynamicAdjustmentToStoichiometry.m` | `test/verifiedTests/analysis/testThermo/` | 153 |
| 25 | `src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased.m` | `testPhysiologicalConstraintsHMDBbased.m` | `test/verifiedTests/analysis/testWholeBody/` | 635 |
| 26 | `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m` | `testSetFeedingFastingConstraints.m` | `test/verifiedTests/analysis/testWholeBody/` | 151 |
| 27 | `src/base/solvers/varKin/optimizeVKmodel0.m` | `testOptimizeVKmodel0.m` | `test/verifiedTests/base/testSolvers/` | 368 |
| 28 | `src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m` | `testConditionSpecificGapFilling.m` | `test/verifiedTests/reconstruction/testDemeter/` | 371 |
| 29 | `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m` | `testRebuildBiomassReaction.m` | `test/verifiedTests/reconstruction/testDemeter/` | 240 |
| 30 | `src/reconstruction/refinement/addReactionGEM.m` | `testAddReactionGEM.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 164 |


## Scope extension (2026-11-03, maintainer: "make as much tests as possible as long as they are not dependent on defect functions")

Widening the scan to every untested function with at least one input (any argument name, model
or not), under the same safety rule (no solver, file, plot, GUI, network or toolbox in the static
closure; no reachable silent defect), adds 30 functions and no further model-taking function:
every other model-taking function reaches a solver, file or toolbox (Tier 3 or later) or a silent
defect (`addToTmodel`, `cleanTmodel` via `charpos`; `applyEFluxConstraints`;
`findMetabolicJunctions`, `findNeighborRxns`). Eight are excluded before probing:

- `getCobraSolverVersion`: queries installed solvers
- `compile`: builds MEX files
- `py_addpath`: changes the Python path
- `py_rmpath`: changes the Python path
- `resolvePickleProxies`: needs Python pickle objects
- `loadModular`: changes the MATLAB path (dropped in batch 4 for a sibling)
- `printFunctionIO`: scans the repository source files
- `Rate_function`: two files share the name; one test file cannot address both

The remaining 22 are probed and written with the same procedure; a function that takes no model
gets a Tier-1 test (hand-built inputs, no model) instead of a Tier-2 test.

| # | Source function | Test file | Test folder | Code lines |
|---|-----------------|-----------|-------------|-----------:|
| X1 | `src/analysis/ecosystem/constrainEcosystemPoint.m` | `testConstrainEcosystemPoint.m` | `test/verifiedTests/analysis/testWholeBody/` | 36 |
| X2 | `src/analysis/persephone/performRegressions.m` | `testPerformRegressions.m` | `test/verifiedTests/analysis/testPersephone/` | 135 |
| X3 | `src/analysis/persephone/validatePersephoneInputs.m` | `testValidatePersephoneInputs.m` | `test/verifiedTests/analysis/testPersephone/` | 74 |
| X4 | `src/analysis/sampling/BarrierRound/PolytopeSimplifier/TwoSidedBarrier.m` | `testTwoSidedBarrier.m` | `test/verifiedTests/analysis/testSampling/` | 101 |
| X5 | `src/analysis/sampling/BarrierRound/utils/TableDisplay.m` | `testTableDisplay.m` | `test/verifiedTests/analysis/testSampling/` | 84 |
| X6 | `src/analysis/subspaces/lsqr/lsqrtest.m` | `testLsqrtest.m` | `test/verifiedTests/analysis/testSubspaces/` | 17 |
| X7 | `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m` | `testAdjustBaselinesInAlberty2006.m` | `test/verifiedTests/analysis/` | 185 |
| X8 | `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | `testCreateComputedSpeciesData.m` | `test/verifiedTests/analysis/testThermo/` | 163 |
| X9 | `src/analysis/topology/FR/connectedFR.m` | `testConnectedFR.m` | `test/verifiedTests/analysis/testTopology/` | 30 |
| X10 | `src/analysis/topology/FR/largestConnectedFR.m` | `testLargestConnectedFR.m` | `test/verifiedTests/analysis/testTopology/` | 45 |
| X11 | `src/base/io/definitions/descFileRead.m` | `testDescFileRead.m` | `test/verifiedTests/base/testIO/` | 22 |
| X12 | `src/base/utilities/issueConfirmationWarning.m` | `testIssueConfirmationWarning.m` | `test/verifiedTests/base/testTools/` | 12 |
| X13 | `src/base/utilities/removeIndicesInDimenion.m` | `testRemoveIndicesInDimenion.m` | `test/verifiedTests/base/testTools/` | 6 |
| X14 | `src/dataIntegration/chemoInformatics/RXN/readRXNFile.m` | `testReadRXNFile.m` | `test/verifiedTests/dataIntegration/testChemoInformatics/` | 104 |
| X15 | `src/dataIntegration/fluxomics/getBinsOfFluxes.m` | `testGetBinsOfFluxes.m` | `test/verifiedTests/dataIntegration/testFitC13Data/` | 92 |
| X16 | `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitL.m` | `testCreateFitL.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 9 |
| X17 | `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitR.m` | `testCreateFitR.m` | `test/verifiedTests/dataIntegration/testRFASTCORMICS/` | 9 |
| X18 | `src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m` | `testMakeNamesUnique.m` | `test/verifiedTests/reconstruction/testModelBorgifier/` | 75 |
| X19 | `src/reconstruction/modelGeneration/massBalance/ispolymer.m` | `testIspolymer.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 8 |
| X20 | `src/visualization/cellDesigner/readCD.m` | `testReadCD.m` | `test/verifiedTests/visualization/testCellDesigner/` | 22 |
| X21 | `src/visualization/cellDesigner/updateCD.m` | `testUpdateCD.m` | `test/verifiedTests/visualization/testCellDesigner/` | 89 |
| X22 | `src/visualization/metabolicCartography/removeMapMol.m` | `testRemoveMapMol.m` | `test/verifiedTests/visualization/testMetabolicCartography/` | 62 |

## Success Criteria *(mandatory)*

- **SC-001**: Every function of the table has a passing test or is reported as dropped with a reason.
- **SC-002**: Each test reaches 100% line coverage or lists every uncovered line.
- **SC-003**: No test calls a solver (spy check) and each loads each model at most once.
- **SC-004**: The registry tool exits successfully after regeneration.
- **SC-005**: The diff contains no file under `src/`.

## Assumptions

- The static call graph is name-based; a call built at run time (`feval` of text) is not seen.
  The solver spies (FR-004) close that gap for the tested inputs.
- Tier-2 tests may run longer than Tier-1 tests; no CI time budget (III-Coverage).

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1, US2 / FR-001..FR-007 | the `test<Function>.m` files of the selection table | the kept functions |
| FR-008 / US3 | `summary.md` in this feature folder | — (no source function) |
| FR-009 | `python3 .github/scripts/known_defects.py` | — (no source function) |
| SC-005 | `git diff --name-only` against the base, no `src/` path | — (no source function) |
| FR-010 | `git log` author and message check | — (no source function) |
