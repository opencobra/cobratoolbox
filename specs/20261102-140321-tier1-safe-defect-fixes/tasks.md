---
description: "Tasks for the safe Tier-1 defect fixes"
---

# Tasks: Fix the safe Tier-1 known defects and document the rest

**Input**: Design documents from `specs/20261102-140321-tier1-safe-defect-fixes/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: every fix extends the function's existing Tier-1 test (spec FR-003); the attention
document and registry are checked by reading and by the registry tool.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 fixes, US2 attention document, US3 registry

## Procedure for every US1 fix task (applies to T004-T055)

1. Re-read the source function and its test (Constitution III-Defects re-check). Confirm the
   entry still describes the current source; if not, report it.
2. Baseline: run the test with the throwaway coverage helper
   `runWithCoverage.m` (a throwaway helper, not kept in the repository)
   (`initCobraToolbox(false)` first, then `addpath` of that folder, then
   `runWithCoverage(which('test<Name>'), which('<name>'))`); record covered/total.
3. Fix the source with the smallest change that produces EXPECTED (research R3/R4). Do not
   change the signature, argument order or output order. Keep the openCOBRA header format; update
   the header when the documented behaviour changes. No `evalc`, no warning suppression, no new
   `nargin` logic (use `exist`/`isempty`).
4. Before finishing, confirm that no input that succeeds today, outside the TRIGGER, changes its
   output. If one would, revert the fix, leave the header entry, and report the defect as moved to
   table B (FR-007) with the reason.
5. Test: add a `%%` section asserting EXPECTED on the TRIGGER input (equality only for discrete
   values; justified tolerance for floats; `verifyCobraFunctionError` for a documented error).
   Remove the fixed entry from "Known defects documented (NOT tested, NOT fixed here):" (write
   "None found." when none remains), update the coverage exemptions, and add to the Purpose block:
   "Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: <titles>." Do not weaken
   any pre-existing assertion; if one fails because it pinned the defect, report it.
6. Run the test with the coverage helper again: it must pass and covered/total must not drop.
   Report: function, defects fixed or moved, baseline and final coverage, missed lines.
7. Touch only the two files of the task. Do not commit.

## Phase 1: Setup

- [X] T001 Confirm the branch `20261102-140321-tier1-safe-defect-fixes` is based on `upstream/develop` and that `git status` shows only the five pre-existing submodule pointers besides this feature's files
- [X] T002 Confirm the coverage helper runs: `runWithCoverage(which('testWaterGibbsEnergyOfFormation'), which('waterGibbsEnergyOfFormation'))` reports `passed`

## Phase 2: Foundational

- [X] T003 Copy the spec's table A/B classification into the working notes of the implementation run (specs/20261102-140321-tier1-safe-defect-fixes/spec.md) so every task uses the same list; no file change

## Phase 3: User Story 1 — safe defects fixed and tested (Priority: P1)

**Goal**: the 62 table-A defects are fixed and their formerly skipped inputs are asserted.

**Independent Test**: each group's tests pass with coverage not lower than baseline.

### Group G1 — analysis/exploration, igemRNA, sampling

- [X] T004 [P] [US1] Fix `numToFormattedString` in src/analysis/exploration/surfNetSubfunctions/numToFormattedString.m and extend test/verifiedTests/analysis/testExploration/testNumToFormattedString.m. Defect(s): "Width argument ignored for array input" (unusable-option) — TRIGGER: a non-scalar input together with the width argument nChar — EXPECTED: every element formatted with the requested width — LINES 48.
- [X] T005 [P] [US1] Fix `printMetRxnInfo` in src/analysis/exploration/surfNetSubfunctions/printMetRxnInfo.m and extend test/verifiedTests/analysis/testExploration/testPrintMetRxnInfo.m. Defect(s): "Matrix values are separated by a comma without a space" (cosmetic) — TRIGGER: a numeric matrix value — EXPECTED: 1.5, 2; 3, 4 — LINES 38; "Other value types print as an unreadable character or error" (limitation) — TRIGGER: a value that is a logical, or a nested cell — EXPECTED: a readable text for such values or a clear error — LINES 42-45.
- [X] T006 [P] [US1] Fix `findGenesAboveThresholdGT1` in src/analysis/igemRNA/GT1/findGenesAboveThresholdGT1.m and extend test/verifiedTests/analysis/testGT1/testFindGenesAboveThresholdGT1.m. Defect(s): "Errors when no gene qualifies" (error) — TRIGGER: a threshold that no expression value passes — EXPECTED: an empty list — LINES 24-33.
- [X] T007 [P] [US1] Fix `findGenesBelowThresholdGT1` in src/analysis/igemRNA/GT1/findGenesBelowThresholdGT1.m and extend test/verifiedTests/analysis/testGT1/testFindGenesBelowThresholdGT1.m. Defect(s): "Errors when no gene qualifies" (error) — TRIGGER: a threshold that no expression value passes — EXPECTED: an empty list — LINES 24-33.
- [X] T008 [P] [US1] Fix `removeCorrelRxns` in src/analysis/sampling/ACHR/removeCorrelRxns.m and extend test/verifiedTests/analysis/testSampling/testRemoveCorrelRxns.m. Defect(s): "A reaction whose own correlation is below the cutoff gets an empty group and no name" (wrong-result) — TRIGGER: a correlation matrix whose diagonal entry for a reaction is below the cutoff (for example 0.5) and that is not selected with any other reaction — EXPECTED: the reaction is listed as its own group with its identifier as name — LINES 67-70.
- [X] T009 [P] [US1] Fix `chrrParseModel` in src/analysis/sampling/CHRR/chrrParseModel.m and extend test/verifiedTests/analysis/testSampling/testChrrParseModel.m. Defect(s): "Extra constraints with a less-than or equality sense cannot be used" (error) — TRIGGER: model.C, model.d and model.dsense with an L or E entry, or with dsense given as a cell array — EXPECTED: L entries are kept, G entries are negated, and E entries raise the documented "not supported" error — LINES 49-56.
- [X] T010 [P] [US1] Fix `calcSampleDifference` in src/analysis/sampling/calcSampleDifference.m and extend test/verifiedTests/analysis/testSampling/testCalcSampleDifference.m. Defect(s): "Default number of difference profiles does not match the documentation" (cosmetic) — TRIGGER: calcSampleDifference called without nPts — EXPECTED: the header states that the default is 10% of the samples — LINES 30-32. Note: Correct the header to state the actual default (25 times the number of samples in the first set); do not change the code.
- [X] T011 [P] [US1] Fix `identifyCorrelSets` in src/analysis/sampling/identifyCorrelSets.m and extend test/verifiedTests/analysis/testSampling/testIdentifyCorrelSets.m. Defect(s): "The function stops with an error when no reactions are correlated" (error) — TRIGGER: a correlation matrix (or sample) in which no pair of reactions reaches the threshold — EXPECTED: empty outputs — LINES 65-79.

### Group G2 — analysis/subspaces, thermo, topology

- [X] T012 [P] [US1] Fix `echelonNullspace` in src/analysis/subspaces/nullspace/echelonNullspace.m and extend test/verifiedTests/analysis/testSubspaces/testEchelonNullspace.m. Defect(s): "The returned null-space matrix L is built with P instead of its transpose" (wrong-result) — TRIGGER: any matrix whose QR pivoting permutes the rows (left) or columns (right), e.g. [1 0 1 2; 0 1 1 3; 1 1 2 5] — EXPECTED: L*S = 0 for the left and S*L = 0 for the right null space — LINES 95, 145. Note: Research R3: set L = [-L0 I]*P' in both branches and correct the header formulas to P^T; assert norm(L*S)<tol (left) and norm(S*L')<tol (right).
- [X] T013 [P] [US1] Fix `nullspaceLUSOLapply2Modes` in src/analysis/subspaces/nullspace/nullspaceLUSOLapply2Modes.m and extend test/verifiedTests/analysis/testNullspace/testNullspaceLUSOLapply2Modes.m. Defect(s): "Mode 2 is not the transpose of mode 1 for a general column permutation" (wrong-result) — TRIGGER: a null-space structure whose column permutation p is not its own inverse (for example p = [2; 3; 1]) — EXPECTED: mode 2 returns Z V, so both inner products are equal — LINES 71-73. Note: Research R3: in mode 2 replace `V(p,:) = V;` with `V = V(p,:);` and remove the uncertainty comments; assert <Z V1, V2> == <V1, Z' V2> for the non-involutive permutation p = [2;3;1].
- [X] T014 [P] [US1] Fix `projectOntoSubspace` in src/analysis/subspaces/subspaceProjection/projectOntoSubspace.m and extend test/verifiedTests/analysis/testSubspaces/testProjectOntoSubspace.m. Defect(s): "Omitting the row or column selection makes the call fail" (error) — TRIGGER: a call without rowBool and colBool, or without colBool, together with a non-empty vf — EXPECTED: the defaults (all rows, all columns) used — LINES 67, 88-90; "The forward flux is not projected onto the row space" (wrong-result) — TRIGGER: any call with a non-empty forward flux vf — EXPECTED: vfR = PR*vf, so that vfN + vfR = vf — LINES 166-169; "The two consistency checks only catch one direction" (limitation) — TRIGGER: a net flux that is smaller than vf - vr, or a potential with u - u0 - lnx below zero — EXPECTED: an error for any difference larger than the tolerance in either direction — LINES 67, 73. Note: Research R3: move both sanity checks after the defaults (rowBool/colBool) are created, use abs() in both checks, and set vfR(colBool)=PR*vf(colBool).
- [X] T015 [P] [US1] Fix `assignQualDir` in src/analysis/thermo/directionalityReport/assignQualDir.m and extend test/verifiedTests/analysis/testThermo/testAssignQualDir.m. Defect(s): "Reverse reactions are reported as forward" (wrong-result) — TRIGGER: a reaction with both bounds negative (for example lb = -5, ub = -1) — EXPECTED: qualDir equals -1 for reactions that are irreversible in the reverse direction, as the header states — LINES 27-29. Note: Create the result as a numeric (double) vector so -1 is stored.
- [X] T016 [P] [US1] Fix `getMolecularWeight` in src/analysis/thermo/inchi/getMolecularWeight.m and extend test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m. Defect(s): "Warnings are printed without a line break" (cosmetic) — TRIGGER: an empty InChI or an element that is not in the table, with warnings switched on — EXPECTED: each warning on its own line — LINES 37, 54. Note: Fix ONLY the missing line breaks (add \n). The hydrogen defect stays documented (table B): keep its header entry unchanged.
- [X] T017 [P] [US1] Fix `acidDissociationConstant` in src/analysis/thermo/reactantContribution/acidDissociationConstant.m and extend test/verifiedTests/analysis/testThermo/testAcidDissociationConstant.m. Defect(s): "Ka and pKa are returned as square matrices with only the first entries filled" (cosmetic) — TRIGGER: a metabolite with p species — EXPECTED: vectors of length p-1 — LINES 62-63.
- [X] T018 [P] [US1] Fix `waterGibbsEnergyOfFormation` in src/analysis/thermo/reactantContribution/waterGibbsEnergyOfFormation.m and extend test/verifiedTests/analysis/testThermo/testWaterGibbsEnergyOfFormation.m. Defect(s): "The Gibbs energy of formation uses the absolute entropy of water instead of the entropy of formation" (wrong-result) — TRIGGER: any temperature, for example T = 298.15 K — EXPECTED: about -237.1 kJ/mol at 298.15 K, the tabulated standard Gibbs energy of formation of liquid water — LINES 39-46. Note: Use research R3: dfG(T) = dfH(T) - T*dfS(T), with H2 and O2 Shomate coefficients given there; assert -237.14 kJ/mol at 298.15 K (tolerance 0.05 kJ/mol, rounding of tabulated coefficients) and -235.19 at 310.15 K.
- [X] T019 [P] [US1] Fix `integerizeS` in src/analysis/topology/integerizeS.m and extend test/verifiedTests/analysis/testTopology/testIntegerizeS.m. Defect(s): "A reaction with a single non-integer coefficient stops the function with an error" (error) — TRIGGER: a reaction with exactly one non-zero stoichiometric coefficient that is not an integer, among the reactions to be integerised (for example an exchange reaction 0.5 A ->, with internalRxnsOnly = 0) — EXPECTED: the factor is the denominator of the single coefficient — LINES 105.
- [X] T020 [P] [US1] Fix `createBIGraph` in src/analysis/topology/reactingMoieties/createBIGraph.m and extend test/verifiedTests/analysis/testTopology/testCreateBIGraph.m. Defect(s): "No edges left after removing the energy node errors" (error) — TRIGGER: a bond graph whose edges all touch the energy node E — EXPECTED: an edgeless bond-instance graph — LINES 81.

### Group G3 — analysis/wholeBody

- [X] T021 [P] [US1] Fix `calculateFoodScore` in src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateFoodScore.m and extend test/verifiedTests/analysis/testWholeBody/testCalculateFoodScore.m. Defect(s): "Default translation assigned when nargin < 3" (error) — TRIGGER: fewer than four inputs, for example calculateFoodScore(originalFood, labelMacros, measuredMacros) — EXPECTED: a default translation that works with three inputs (the check should be nargin < 4) — LINES 45-46. Note: The nargin test should be nargin < 4 and the default translation must be usable by the following lines.
- [X] T022 [P] [US1] Fix `calculateMacroOriginalDiet` in src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateMacroOriginalDiet.m and extend test/verifiedTests/analysis/testWholeBody/testCalculateMacroOriginalDiet.m. Defect(s): "A diet in which every amount is zero stops the function with an error" (error) — TRIGGER: a diet whose amounts are all zero, for example {bread, 0} — EXPECTED: zero amounts for all nutrients — LINES 33-37.
- [X] T023 [P] [US1] Fix `compareDiets` in src/analysis/wholeBody/Nutrition_Modelling_Toolbox/compareDiets.m and extend test/verifiedTests/analysis/testWholeBody/testCompareDiets.m. Defect(s): "Direction false errors" (error) — TRIGGER: direction argument one2Two = false — EXPECTED: the signs of the flux changes reversed (diet 1 minus diet 2) — LINES 73-74.
- [X] T024 [P] [US1] Fix `compareBounds2Models` in src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m and extend test/verifiedTests/analysis/testWholeBody/testCompareBounds2Models.m. Defect(s): "Reactions missing from a model are collected in a character matrix, which fails for names of different lengths" (error) — TRIGGER: two or more reactions missing from the same model whose identifiers have different lengths — EXPECTED: the missing reactions returned in a cell array — LINES 48-50; "The numbers of mismatched bounds are displayed instead of returned" (cosmetic) — TRIGGER: any call — EXPECTED: the counts returned or not displayed — LINES 84-85.
- [X] T025 [P] [US1] Fix `convertATPflux2StepNumer` in src/analysis/wholeBody/PSCMToolbox/convertATPflux2StepNumer.m and extend test/verifiedTests/analysis/testWholeBody/testConvertATPflux2StepNumer.m. Defect(s): "The function name inside the file differs from the file name" (cosmetic) — TRIGGER: any call — EXPECTED: the declared name equal to the file name — LINES 1. Note: Make the declared function name equal the file name (convertATPflux2StepNumer); MATLAB already dispatches by file name.
- [X] T026 [P] [US1] Fix `setSimulationConstraints` in src/analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/setSimulationConstraints.m and extend test/verifiedTests/analysis/testWholeBody/testSetSimulationConstraints.m. Defect(s): "Warnings stay switched off after the call" (cosmetic) — TRIGGER: any call — EXPECTED: the warning state is restored before returning — LINES 2. Note: Save the warning state at entry (s = warning;) and restore it before every return (onCleanup is acceptable).

### Group G4 — base (io, solvers, utilities)

- [X] T027 [P] [US1] Fix `parseSBMLAnnotationField` in src/base/io/utilities/parseSBMLAnnotationField.m and extend test/verifiedTests/base/testIO/testUtilities/testParseSBMLAnnotationField.m. Defect(s): "ChEBI ID keeps a stray 3A prefix in the urn:miriam notation" (wrong-result) — TRIGGER: annotation text containing urn:miriam:obo.chebi:CHEBI%3A15422 — EXPECTED: 15422 — LINES 36-37.
- [X] T028 [P] [US1] Fix `inspectMosekProb` in src/base/solvers/mosek/inspectMosekProb.m and extend test/verifiedTests/base/testSolvers/testInspectMosekProb.m. Defect(s): "A constraint matrix without rows or columns stops the inspection with an error" (error) — TRIGGER: prob.a or prob.f with zero rows or zero columns, for example zeros(0, 2) — EXPECTED: a report for the empty matrix, with NaN statistics — LINES 137-153; "A matrix field of an integer class stops the inspection with an error" (limitation) — TRIGGER: prob.a or prob.f of class int8 (or another integer class) — EXPECTED: a report, as for a double matrix with the same values — LINES 144.
- [X] T029 [P] [US1] Fix `setMosekParam` in src/base/solvers/mosek/setMosekParam.m and extend test/verifiedTests/base/testSolvers/testSetMosekParam.m. Defect(s): "The SCLP profiles fail when feasTol or numTol is not supplied" (error) — TRIGGER: param.mosekParam set to an SCLP_* profile (other than SCLP_default) without param.feasTol or without param.numTol — EXPECTED: documented defaults used for the absent tolerances — LINES 596-601, 640-644. Note: Fix ONLY the SCLP profiles: default feasTol/numTol when absent, using the defaults documented in the header (or the values the cobra profile uses when the header gives none). The strict-option entry stays documented (table B).
- [X] T030 [P] [US1] Fix `StopCritBDCA` in src/base/solvers/varKin/BDCAmethods/StopCritBDCA.m and extend test/verifiedTests/base/testSolvers/testStopCritBDCA.m. Defect(s): "Outputs unassigned for a criterion outside 1 to 5" (error) — TRIGGER: Stopping_Crit not in 1..5 — EXPECTED: defined outputs or a clear error message — LINES 31-82; "Stopping criterion 1 uses an undefined variable" (error) — TRIGGER: Stopping_Crit = 1 — EXPECTED: the residual nfxk compared with epsilon — LINES 33-41.
- [X] T031 [P] [US1] Fix `InitialDuplo` in src/base/solvers/varKin/derFreeMethods/InitialDuplo.m and extend test/verifiedTests/base/testSolvers/testInitialDuplo.m. Defect(s): "Option flag_x_error can never be set" (unusable-option) — TRIGGER: options.flag_x_error given — EXPECTED: the given value returned — LINES 121-122.
- [X] T032 [P] [US1] Fix `StopCritDuplo` in src/base/solvers/varKin/derFreeMethods/StopCritDuplo.m and extend test/verifiedTests/base/testSolvers/testStopCritDuplo.m. Defect(s): "Outputs unassigned for a criterion outside 1 to 5" (error) — TRIGGER: Stopping_Crit not in 1..5 — EXPECTED: defined outputs or a clear error message — LINES 30-81; "Stopping criterion 1 uses an undefined variable" (error) — TRIGGER: Stopping_Crit = 1 — EXPECTED: the residual nfxk compared with epsilon — LINES 32-40.
- [X] T033 [P] [US1] Fix `getDefaultValue` in src/base/utilities/getDefaultValue.m and extend test/verifiedTests/base/testTools/testGetDefaultValue.m. Defect(s): "No default for struct and function-handle input" (error) — TRIGGER: struct or function handle input — EXPECTED: a default of the same type or a clear error — LINES 13-29.
- [X] T034 [P] [US1] Fix `isvar` in src/base/utilities/isvar.m and extend test/verifiedTests/base/testTools/testIsvar.m. Defect(s): "Index is 1 for a structure even when the field is missing" (limitation) — TRIGGER: a structure and a name that is not one of its fields — EXPECTED: an empty index when the field does not exist — LINES 24-27.
- [X] T035 [P] [US1] Fix `mapAontoB` in src/base/utilities/mapAontoB.m and extend test/verifiedTests/base/testTools/testMapAontoB.m. Defect(s): "The check that Akey and Bkey have the same class is broken" (error) — TRIGGER: Akey and Bkey of different classes, for example {'a'} and 1 — EXPECTED: the error: class of Akey and Bkey must be the same — LINES 43-45; "Without Ain the matched keys of B are returned wrongly" (wrong-result) — TRIGGER: a call with only Akey and Bkey — EXPECTED: {b,[],c} — LINES 121-135.

### Group G5 — dataIntegration

- [X] T036 [P] [US1] Fix `compareXomicsModels` in src/dataIntegration/XomicsToModel/analysis/compareXomicsModels.m and extend test/verifiedTests/dataIntegration/testXomicsToModel/testCompareXomicsModels.m. Defect(s): "Fewer than two models give no outputs" (error) — TRIGGER: a structure with a single model, with outputs requested — EXPECTED: an empty result or a clear error message — LINES 93-95.
- [X] T037 [P] [US1] Fix `coreMetRxnAnalysis` in src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m and extend test/verifiedTests/dataIntegration/testXomicsToModel/testCoreMetRxnAnalysis.m. Defect(s): "The deleted reactions are not computed when the old model is empty and no deletion lists are given" (error) — TRIGGER: an empty old model and no deletedRxns (and no deletedMets), for example coreMetRxnAnalysis([], model, coreMets, coreRxns) — EXPECTED: an empty list of deleted reactions — LINES 48-52.
- [X] T038 [P] [US1] Fix `getInchiData` in src/dataIntegration/chemoInformatics/inchi/getInchiData.m and extend test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m. Defect(s): "Several layers containing the letter p error" (error) — TRIGGER: an InChI with two layers that contain the letter p — EXPECTED: the proton layers added up — LINES 63. Note: Fix ONLY the error for several layers containing p (sum the proton layers). The negative-charge entry stays documented (table B).
- [X] T039 [P] [US1] Fix `sortAtomMappingIdx` in src/dataIntegration/chemoInformatics/reactions/sortAtomMappingIdx.m and extend test/verifiedTests/dataIntegration/testChemoInformatics/testSortAtomMappingIdx.m. Defect(s): "The flag for a non-ascending file is overwritten and the function always returns the file text" (cosmetic) — TRIGGER: any call, including product atoms whose mapping number has no substrate partner — EXPECTED: the documented flag or text, not a mix of both — LINES 36-45.
- [X] T040 [P] [US1] Fix `Combination` in src/dataIntegration/fluxomics/c13solver/Combination.m and extend test/verifiedTests/dataIntegration/testFitC13Data/testCombination.m. Defect(s): "Negative parameters print a message and return empty" (cosmetic) — TRIGGER: n < 0 or k < 0 — EXPECTED: a clear error instead of console text — LINES 17-20; "k = 0 errors" (error) — TRIGGER: Combination(n, 0) — EXPECTED: one empty combination — LINES 23.
- [X] T041 [P] [US1] Fix `cdv2idv` in src/dataIntegration/fluxomics/c13solver/cdv2idv.m and extend test/verifiedTests/dataIntegration/testC13solver/testCdv2idv.m. Defect(s): "Asking for zero carbons fails once the cache holds an entry" (error) — TRIGGER: cdv2idv(0) called after the cache has been filled for any n >= 1 — EXPECTED: the identity for zero carbons, as when the cache is empty — LINES 5-10.
- [X] T042 [P] [US1] Fix `cleanUpMetabolite_structure` in src/dataIntegration/metaboAnnotator/buildMetStruct/cleanUpMetabolite_structure.m and extend test/verifiedTests/dataIntegration/testMetaboAnnotator/testCleanUpMetabolite_structure.m. Defect(s): "Loop index printed to the console" (cosmetic) — TRIGGER: any call — EXPECTED: no console output — LINES 38.
- [X] T043 [P] [US1] Fix `sanityCheckMetIds` in src/dataIntegration/metaboAnnotator/buildMetStruct/sanityCheckMetIds.m and extend test/verifiedTests/dataIntegration/testMetaboAnnotator/testSanityCheckMetIds.m. Defect(s): "Metabolites without a charge field make the check fail" (limitation) — TRIGGER: a metabolite structure without the field charge — EXPECTED: a missing charge treated like any other optional field — LINES 35.
- [X] T044 [P] [US1] Fix `mapExpressionToModel` in src/dataIntegration/transcriptomics/rFASTCORMICS/mapExpressionToModel.m and extend test/verifiedTests/dataIntegration/testRFASTCORMICS/testMapExpressionToModel.m. Defect(s): "Invalid input is reported by a message and leaves the output unassigned" (error) — TRIGGER: a dictionary that is not a table, row names with empty entries, or row names that match nothing in the dictionary, when the output is requested — EXPECTED: an error with a clear message, or an empty mapping — LINES 35-50.

### Group G6 — design, reconstruction

- [X] T045 [P] [US1] Fix `augmentBOF` in src/design/augmentBOF.m and extend test/verifiedTests/design/testDesign/testAugmentBOF.m. Defect(s): "The outputs are not assigned when the function cannot augment the objective" (error) — TRIGGER: a target reaction whose metabolite takes part in three or more reactions, called with output arguments — EXPECTED: the unchanged model and an empty reaction name — LINES 41-47.
- [X] T046 [P] [US1] Fix `compareModels` in src/reconstruction/comparison/compareModels.m and extend test/verifiedTests/reconstruction/testComparison/testCompareModels.m. Defect(s): "Two arguments with the same variable name make the function stop" (limitation) — TRIGGER: compareModels called with arguments that have the same variable name, for example compareModels(A, A) — EXPECTED: a table with distinct column names — LINES 16-19.
- [X] T047 [P] [US1] Fix `buildRxnEquationsFromName` in src/reconstruction/comparison/modelBorgifier/buildRxnEquationsFromName.m and extend test/verifiedTests/reconstruction/testModelBorgifier/testBuildRxnEquationsFromName.m. Defect(s): "Backward-only reactions list the substrate on both sides" (wrong-result) — TRIGGER: a reaction with lower bound < 0 and upper bound <= 0 — EXPECTED: (2) A <-- C — LINES 59.
- [X] T048 [P] [US1] Fix `findRxnMatch` in src/reconstruction/comparison/modelBorgifier/findRxnMatch.m and extend test/verifiedTests/reconstruction/testModelBorgifier/testFindRxnMatch.m. Defect(s): "The separators between joined metabolites lose their blank" (cosmetic) — TRIGGER: a reaction with several reactants or products, or the score and index of a match — EXPECTED: the separators written in the code: a; b and 0.9; 2 — LINES 37, 41-47, 91.
- [X] T049 [P] [US1] Fix `mergeTrxns` in src/reconstruction/comparison/modelBorgifier/mergeTrxns.m and extend test/verifiedTests/reconstruction/testModelBorgifier/testMergeTrxns.m. Defect(s): "A call with nothing to merge fails" (error) — TRIGGER: an empty list of reactions to merge — EXPECTED: the model returned unchanged — LINES 51, 133.
- [X] T050 [P] [US1] Fix `checkInputData` in src/reconstruction/demeter/src/integration/checkInputData.m and extend test/verifiedTests/reconstruction/testDemeter/testCheckInputData.m. Defect(s): "Header name listed in removedStrains" (cosmetic) — TRIGGER: the first-column header of the data differs from that of the strain information — EXPECTED: only strain names — LINES 27-28; "Unknown strain row not removed when the headers are equal" (wrong-result) — TRIGGER: data and strain information with the same first-column header — EXPECTED: the row removed — LINES 29.
- [X] T051 [P] [US1] Fix `assignRxnWeights` in src/reconstruction/fastGapFill/AuxillaryFiles/assignRxnWeights.m and extend test/verifiedTests/reconstruction/testFastGapFill/testAssignRxnWeights.m. Defect(s): "The NoWeight argument never has an effect" (unusable-option) — TRIGGER: the optional argument NoWeight (or its default 1000) for reactions that are neither metabolic, exchange nor transport — EXPECTED: NoWeight for those reactions — LINES 45, 54. Note: Remove the line that resets the weights to zero so NoWeight applies to reactions that are neither metabolic, exchange nor transport.
- [X] T052 [P] [US1] Fix `checkPresentFields` in src/reconstruction/modelGeneration/modelVerification/checkPresentFields.m and extend test/verifiedTests/reconstruction/testModelGeneration/testCheckPresentFields.m. Defect(s): "A numeric size requirement stops the function with an error" (error) — TRIGGER: a field property row whose second or third column is a number instead of a field name — EXPECTED: the expected size compared with the actual size — LINES 53-56.
- [X] T053 [P] [US1] Fix `flipRxnOrientation` in src/reconstruction/refinement/flipRxnOrientation.m and extend test/verifiedTests/reconstruction/testRefinement/testFlipRxnOrientation.m. Defect(s): "The message for reactions that are not in the model has no line break" (cosmetic) — TRIGGER: a reaction list with identifiers that are not in the model — EXPECTED: one message per line — LINES 31.
- [X] T054 [P] [US1] Fix `getMetAbbr` in src/reconstruction/refinement/getMetAbbr.m and extend test/verifiedTests/reconstruction/testModelManipulation/testGetMetAbbr.m. Defect(s): "IDs without brackets are silently dropped" (wrong-result) — TRIGGER: a metabolite list containing an ID without [compartment] — EXPECTED: an entry or an error for every input — LINES 35-37.
- [X] T055 [P] [US1] Fix `updateMetNames` in src/reconstruction/refinement/updateMetNames.m and extend test/verifiedTests/reconstruction/testRefinement/testUpdateMetNames.m. Defect(s): "The wipe option is always overwritten with false" (unusable-option) — TRIGGER: a call with the third argument true, for example updateMetNames(referenceModel, modelToUpdate, true) — EXPECTED: the existing metabolite names removed when wipeExisting is true — LINES 27-29.

## Phase 4: User Story 2 — attention document (Priority: P1)

**Goal**: maintainers have one document for the table-B defects and the new problems.

**Independent Test**: one entry per table-B row (28) and per new problem (8), in the format of
data-model.md.

- [X] T056 [US2] Write specs/20261102-140321-tier1-safe-defect-fixes/attention-defects.md: an introduction (scope, date, method), a summary table, then one entry per table-B defect (spec table B plus any defect moved under FR-007 during US1) and per new problem, each with severity, reached-from, effect of a fix, published results affected, Tier-2 exposure, recommendation; order by priority (combineChildren, processConcConstraints, gapfillRefinedGenomeReactions first)

## Phase 5: User Story 3 — registry regenerated (Priority: P2)

**Goal**: the registry lists only table-B defects.

**Independent Test**: the generator exits 0 and the count line matches table B.

- [X] T057 [US3] Run `python3 .github/scripts/known_defects.py` to regenerate test/known-defects.md and confirm the count line (28 defects in 24 functions, adjusted for any FR-007 move) and that no table-A title remains

## Phase 6: Polish & cross-cutting

- [X] T058 Scope check: `git diff --name-only upstream/develop -- src` lists only table-A files and none of the table-B files (SC-006)
- [X] T059 Run all 52 changed tests once more in one MATLAB session through `runScriptFile`; record pass/fail
- [X] T060 Write specs/20261102-140321-tier1-safe-defect-fixes/agent-runs/<UTC>-implement/implementation-receipt.md (Prompt, Final response, Diff summary, Tests, Unresolved issues)
- [X] T061 Commit with the maintainer identity (no co-author line), staging only this feature's files, and push the branch to `origin` with upstream tracking

## Dependencies & execution order

- Setup (T001-T002) → Foundational (T003) → US1 tasks (all [P], independent files) → US2 (needs
  the final list of FR-007 moves) → US3 (needs all headers final) → Polish.
- US1 groups G1-G6 can run fully in parallel; within a group, tasks touch different files.

## Parallel example

```text
Run groups G1, G2, G3, G4, G5, G6 concurrently, one agent per group; each agent executes its
tasks in order using the procedure above and reports per-function results.
```

## Implementation strategy

MVP = US1 group G2 (the scientific fixes) verified first; then the remaining groups in
parallel; then US2, US3 and polish.
