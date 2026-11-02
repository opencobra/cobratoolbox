# Feature Specification: Fix the safe Tier-1 known defects and document the rest

**Feature Branch**: `20261102-140321-tier1-safe-defect-fixes`

**Created**: 2026-11-02

**Status**: Draft

**Input**: User description: "Fix the Tier-1 known defects whose fix cannot change any result produced by existing toolbox code (functions with no caller, defects that currently raise an error, console-only defects, defects whose trigger is unreachable from every caller, and defects shown to have no numerical effect), write the tests for the formerly skipped inputs, regenerate test/known-defects.md, and document — without fixing — the remaining defects that need maintainer attention (they change results in reachable paths but do not affect Tier-2 model-manipulation tests), together with the new problems found by the 2026-11-02 impact analysis."

## Why this feature exists

The Tier-1 test batches recorded 90 defects in 73 functions (registry `test/known-defects.md`,
Constitution III-Defects). Tier-2 tests are about to record first-run reference values
(III-Coverage Tier 5), so a defect that silently changes a Tier-2 result would be frozen into a
reference. An impact analysis (2026-11-02; caller graph over `src/`, `tutorials/`, `papers/`,
call-site reading, and MATLAB runs comparing each original function with a one-line fix) found:

- no known defect can silently change a Tier-2 (model-manipulation) result;
- 62 defects in 52 functions can be fixed without changing any result that existing toolbox
  code, tutorials or papers currently produce (table A; planning research moved 2 defects,
  `searcher` and `bilinearDecomposition`, from A to B under FR-007);
- 28 defects in 24 functions change results in reachable paths and need a maintainer decision
  before they are fixed (table B);
- 8 further problems that are not in the registry (section "New problems").

This feature fixes table A, rewrites the affected tests to cover the formerly skipped inputs,
regenerates the registry, and documents table B and the new problems for maintainers.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Safe defects are fixed and tested (Priority: P1)

A maintainer can rely on every function in table A behaving as its header documents, because
each defect is fixed and the input that the test previously skipped is now asserted.

**Why this priority**: it removes 62 known defects at no risk to existing results.

**Independent Test**: run the test file of each function in table A; every test passes, its
header lists no defect for the fixed entries, and the formerly skipped input is asserted.

**Acceptance Scenarios**:

1. **Given** a defect in table A, **When** the feature is complete, **Then** the source function
   behaves as the entry's EXPECTED field (or the documented corrected behaviour) and the test
   asserts that behaviour on the entry's TRIGGER input.
2. **Given** a fixed function, **When** its test runs, **Then** every pre-existing assertion still
   passes (behaviour outside the trigger is unchanged).
3. **Given** a defect whose correct behaviour cannot be established unambiguously from the
   function header, its callers and domain references, **When** this is found, **Then** the
   defect is NOT fixed; it moves to table B with the reason.

---

### User Story 2 - Attention defects and new problems are documented (Priority: P1)

A maintainer can read, in one document, each defect that changes results in a reachable path:
which toolbox paths, tutorials or papers it reaches, what changes when it is fixed (measured
where possible), why it does not affect Tier-2 tests, and the recommended action.

**Why this priority**: these defects need a maintainer or community decision; documenting them
is the deliverable the maintainer asked for.

**Independent Test**: the document exists in the feature directory and has one entry for each
row of table B and each new problem, each with path, measured or assessed effect, Tier-2
exposure and recommendation.

**Acceptance Scenarios**:

1. **Given** table B, **When** the document is read, **Then** every row has an entry and no
   function in table B was changed.
2. **Given** the new problems, **When** the document is read, **Then** each has location,
   reproduction, effect and recommendation.

---

### User Story 3 - The registry reflects the fixes (Priority: P2)

**Independent Test**: regenerate `test/known-defects.md`; it lists exactly the defects of
table B (28) and nothing from table A; the generator exits successfully.

**Acceptance Scenarios**:

1. **Given** all test headers updated, **When** the registry is regenerated, **Then** the count
   line reads 28 known defects in 24 functions (fewer only if a table-B entry is resolved by a
   table-A fix, which is reported), and the generator reports no invalid entry.

### Edge Cases

- A function with several defects, only some in table A (`getMolecularWeight`, `setMosekParam`,
  `getInchiData`): only the table-A defect is fixed; the other entry stays in the header.
- A defect whose fix needs a choice between documented behaviours (for example the header says
  one thing and the code another for an isolated function): the header is the contract unless
  the header is itself wrong on scientific grounds, in which case the reference is cited.
- A fix that would make a pre-existing assertion fail: the assertion pinned defective behaviour
  outside the recorded trigger; stop and report rather than weaken either.
- A fix that turns an error into a result: the result is the one documented in EXPECTED.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every defect in table A is fixed in its source function with the smallest change
  that produces the EXPECTED behaviour; nothing else in the function changes.
- **FR-002**: No function in table B is changed, and no table-B defect entry is removed.
- **FR-003**: For each fixed defect, the test file of the function (III-Naming, one file per
  function) asserts the corrected behaviour on the entry's TRIGGER input, removes the defect
  entry from the header (writing "None found." when no entry remains), updates the coverage
  exemptions, and states in the header that the defect was fixed by this feature.
- **FR-004**: All pre-existing assertions of the affected tests still pass unchanged, unless an
  assertion pinned the defect itself; any such case is reported.
- **FR-005**: Each fix follows the MATLAB and openCOBRA conventions (Principle VII): no `evalc`
  suppression, warnings stay visible, help headers are updated when the documented behaviour
  changes, and optional-argument handling uses `exist`/`isempty` checks.
- **FR-006**: Public interfaces are preserved (Principle II): no function name, argument order
  or output order changes. The behaviour changes approved by this feature are exactly: inputs
  that previously raised an error now return the EXPECTED result; console text; and results of
  functions that no toolbox code, tutorial or paper calls.
- **FR-007**: A table-A defect whose correct behaviour cannot be established unambiguously is
  moved to table B with the reason instead of being fixed (no speculative fix).
- **FR-008**: The known-defects registry is regenerated with its tool and lists only table-B
  defects (and any defect moved there under FR-007).
- **FR-009**: The attention document in the feature directory covers every table-B row and every
  new problem with: affected paths, measured or assessed effect, whether published tutorial or
  paper results are affected, Tier-2 exposure, and recommended action.
- **FR-010**: Each changed test passes through the harness runner; line coverage of each fixed
  function is measured and reported (covered/total) and is not lower than before.
- **FR-011**: Commits use the maintainer's git identity with no automated co-author line, follow
  the commit-message convention, include only files of this feature (never the unrelated
  submodule pointers), and the feature branch is pushed to the maintainer's fork.
- **FR-012**: The contributor reports files changed, checks run, tests passed or failed, defects
  moved to table B, and behaviours not verified, and writes the implementation receipt.

### Key Entities

- **Table-A defect**: registry entry approved for fixing, with the reason it is safe.
- **Table-B defect**: registry entry that stays documented, with its reachable paths and effect.
- **New problem**: a defect found by the impact analysis that has no registry entry.
- **Attention document**: `attention-defects.md` in this feature directory.

## Table A — defects fixed by this feature (62 defects, 52 functions)

| # | Function | Severity | Defect (registry title) | Why fixing it changes no existing result |
|---|----------|----------|-------------------------|------------------------------------------|
| 1 | `numToFormattedString` | unusable-option | Width argument ignored for array input | only console text of surfNet changes |
| 2 | `printMetRxnInfo` | cosmetic | Matrix values are separated by a comma without a space | console text only |
| 3 | `printMetRxnInfo` | limitation | Other value types print as an unreadable character or error | console text only |
| 4 | `findGenesAboveThresholdGT1` | error | Errors when no gene qualifies | currently raises an error; the fix turns the error into a result |
| 5 | `findGenesBelowThresholdGT1` | error | Errors when no gene qualifies | currently raises an error; the fix turns the error into a result |
| 6 | `removeCorrelRxns` | wrong-result | A reaction whose own correlation is below the cutoff gets an empty group and no name | no caller in src/, tutorials/ or papers/ |
| 7 | `chrrParseModel` | error | Extra constraints with a less-than or equality sense cannot be used | currently raises an error; the fix turns the error into a result |
| 8 | `calcSampleDifference` | cosmetic | Default number of difference profiles does not match the documentation | no caller in src/, tutorials/ or papers/ |
| 9 | `identifyCorrelSets` | error | The function stops with an error when no reactions are correlated | no caller in src/, tutorials/ or papers/ |
| 10 | `echelonNullspace` | wrong-result | The returned null-space matrix L is built with P instead of its transpose | no caller in src/, tutorials/ or papers/ |
| 11 | `nullspaceLUSOLapply2Modes` | wrong-result | Mode 2 is not the transpose of mode 1 for a general column permutation | no caller in src/, tutorials/ or papers/ |
| 12 | `projectOntoSubspace` | error | Omitting the row or column selection makes the call fail | no caller in src/, tutorials/ or papers/ |
| 13 | `projectOntoSubspace` | wrong-result | The forward flux is not projected onto the row space | no caller in src/, tutorials/ or papers/ |
| 14 | `projectOntoSubspace` | limitation | The two consistency checks only catch one direction | no caller in src/, tutorials/ or papers/ |
| 15 | `assignQualDir` | wrong-result | Reverse reactions are reported as forward | no caller in src/, tutorials/ or papers/ |
| 16 | `getMolecularWeight` | cosmetic | Warnings are printed without a line break | console text only |
| 17 | `acidDissociationConstant` | cosmetic | Ka and pKa are returned as square matrices with only the first entries filled | no caller in src/, tutorials/ or papers/ |
| 18 | `waterGibbsEnergyOfFormation` | wrong-result | The Gibbs energy of formation uses the absolute entropy of water instead of the entropy of formation | no caller in src/, tutorials/ or papers/ |
| 19 | `integerizeS` | error | A reaction with a single non-integer coefficient stops the function with an error | currently raises an error; the fix turns the error into a result |
| 20 | `createBIGraph` | error | No edges left after removing the energy node errors | currently raises an error; the fix turns the error into a result |
| 21 | `calculateFoodScore` | error | Default translation assigned when nargin < 3 | currently raises an error; the fix turns the error into a result |
| 22 | `calculateMacroOriginalDiet` | error | A diet in which every amount is zero stops the function with an error | no caller in src/, tutorials/ or papers/ |
| 23 | `compareDiets` | error | Direction false errors | no caller in src/, tutorials/ or papers/ |
| 24 | `compareBounds2Models` | error | Reactions missing from a model are collected in a character matrix, which fails for names of different lengths | no caller in src/, tutorials/ or papers/ |
| 25 | `compareBounds2Models` | cosmetic | The numbers of mismatched bounds are displayed instead of returned | no caller in src/, tutorials/ or papers/ |
| 26 | `convertATPflux2StepNumer` | cosmetic | The function name inside the file differs from the file name | MATLAB resolves the file name; declared name has no effect |
| 27 | `setSimulationConstraints` | cosmetic | Warnings stay switched off after the call | only the warning state (console) changes |
| 28 | `parseSBMLAnnotationField` | wrong-result | ChEBI ID keeps a stray 3A prefix in the urn:miriam notation | no caller in src/, tutorials/ or papers/ |
| 29 | `inspectMosekProb` | error | A constraint matrix without rows or columns stops the inspection with an error | no caller in src/, tutorials/ or papers/ |
| 30 | `inspectMosekProb` | limitation | A matrix field of an integer class stops the inspection with an error | no caller in src/, tutorials/ or papers/ |
| 31 | `setMosekParam` | error | The SCLP profiles fail when feasTol or numTol is not supplied | currently raises an error; the fix turns the error into a result |
| 32 | `StopCritBDCA` | error | Outputs unassigned for a criterion outside 1 to 5 | currently raises an error; the fix turns the error into a result |
| 33 | `StopCritBDCA` | error | Stopping criterion 1 uses an undefined variable | currently raises an error; the fix turns the error into a result |
| 34 | `InitialDuplo` | unusable-option | Option flag_x_error can never be set | callers (BDF, CSDF, DBDF) are used by no tutorial or paper; option silently ignored today |
| 35 | `StopCritDuplo` | error | Outputs unassigned for a criterion outside 1 to 5 | currently raises an error; the fix turns the error into a result |
| 36 | `StopCritDuplo` | error | Stopping criterion 1 uses an undefined variable | currently raises an error; the fix turns the error into a result |
| 37 | `getDefaultValue` | error | No default for struct and function-handle input | currently raises an error; the fix turns the error into a result |
| 38 | `isvar` | limitation | Index is 1 for a structure even when the field is missing | every caller uses only the first output |
| 39 | `mapAontoB` | error | The check that Akey and Bkey have the same class is broken | currently raises an error; the fix turns the error into a result |
| 40 | `mapAontoB` | wrong-result | Without Ain the matched keys of B are returned wrongly | every caller passes Ain and same-class keys |
| 41 | `compareXomicsModels` | error | Fewer than two models give no outputs | currently raises an error; the fix turns the error into a result |
| 42 | `coreMetRxnAnalysis` | error | The deleted reactions are not computed when the old model is empty and no deletion lists are given | currently raises an error; the fix turns the error into a result |
| 43 | `getInchiData` | error | Several layers containing the letter p error | currently raises an error; the fix turns the error into a result |
| 44 | `sortAtomMappingIdx` | cosmetic | The flag for a non-ascending file is overwritten and the function always returns the file text | no caller in src/, tutorials/ or papers/ |
| 45 | `Combination` | cosmetic | Negative parameters print a message and return empty | no caller in src/, tutorials/ or papers/ |
| 46 | `Combination` | error | k = 0 errors | no caller in src/, tutorials/ or papers/ |
| 47 | `cdv2idv` | error | Asking for zero carbons fails once the cache holds an entry | no caller in src/, tutorials/ or papers/ |
| 48 | `cleanUpMetabolite_structure` | cosmetic | Loop index printed to the console | console text only |
| 49 | `sanityCheckMetIds` | limitation | Metabolites without a charge field make the check fail | currently raises an error; the fix turns the error into a result |
| 50 | `mapExpressionToModel` | error | Invalid input is reported by a message and leaves the output unassigned | currently raises an error; the fix turns the error into a result |
| 51 | `augmentBOF` | error | The outputs are not assigned when the function cannot augment the objective | currently raises an error; the fix turns the error into a result |
| 52 | `compareModels` | limitation | Two arguments with the same variable name make the function stop | no caller in src/, tutorials/ or papers/ |
| 53 | `buildRxnEquationsFromName` | wrong-result | Backward-only reactions list the substrate on both sides | no caller in src/, tutorials/ or papers/ |
| 54 | `findRxnMatch` | cosmetic | The separators between joined metabolites lose their blank | output only fills the GUI table |
| 55 | `mergeTrxns` | error | A call with nothing to merge fails | currently raises an error; the fix turns the error into a result |
| 56 | `checkInputData` | cosmetic | Header name listed in removedStrains | no caller in src/, tutorials/ or papers/ |
| 57 | `checkInputData` | wrong-result | Unknown strain row not removed when the headers are equal | no caller in src/, tutorials/ or papers/ |
| 58 | `assignRxnWeights` | unusable-option | The NoWeight argument never has an effect | the affected weights belong to core reactions, which fastCoreWeighted never reads |
| 59 | `checkPresentFields` | error | A numeric size requirement stops the function with an error | currently raises an error; the fix turns the error into a result |
| 60 | `flipRxnOrientation` | cosmetic | The message for reactions that are not in the model has no line break | no caller in src/, tutorials/ or papers/ |
| 61 | `getMetAbbr` | wrong-result | IDs without brackets are silently dropped | no caller in src/, tutorials/ or papers/ |
| 62 | `updateMetNames` | unusable-option | The wipe option is always overwritten with false | no caller in src/, tutorials/ or papers/ |

## Table B — defects documented, not fixed (28 defects, 24 functions)

None of these is reachable from a Tier-2 model-manipulation path (analysis 2026-11-02:
`checkPresentFields` and `getDefaultValue` are the only defective functions reached from
`addReaction`/`removeRxns`-type functions, and both are in table A; `combineChildren` is reached
only through CNF conversion, which no manipulation function performs).

| # | Function | Severity | Defect (registry title) | Reachable path and effect |
|---|----------|----------|-------------------------|---------------------------|
| 1 | `calculateMetrics` | wrong-result | Bray-Curtis wrong for a single taxon | runMars (Persephone): Bray-Curtis for a single-taxon table |
| 2 | `compareConditions` | limitation | Sample-point count taken from the first metabolite of the first list | rumba: sample-point count used for every metabolite |
| 3 | `convRevSamples` | wrong-result | Bounds of a reverse-only reaction are not exchanged correctly | sampleCbModel (ACHR): bounds of the returned model |
| 4 | `checkFormulae` | limitation | Elements other than C, H, O, P, S, K, Na and N are ignored | DEMETER removeFutileCycles, mgPipe createPanModels: periplasm heuristic (one artefact flip measured) |
| 5 | `getMolecularWeight` | wrong-result | Hydrogens are lost for an InChI whose formula starts with H | addThermoToModel -> balanceReactionsInTrainingData (old/): molecular weight of water |
| 6 | `isValidVmhID` | limitation | Identifiers with surrounding blanks are rejected although they are trimmed for the other checks | BLS / FRIDA / USDA food-database builders, getDietEnergy |
| 7 | `getDataBases` | wrong-result | Mixed matching and non-matching resources return nothing | every SBML import (readSBML -> parseCVTerms); no change measured on 7 files |
| 8 | `getDataBases` | error | Third output unassigned when nothing matches | every SBML import (readSBML -> parseCVTerms); no change measured on 7 files |
| 9 | `parseMetNames` | limitation | Mixed or longer compartment notations are not parsed | readCbModel (SimPheny), extractCompModel, extractMetModel, exploration functions |
| 10 | `processConcConstraints` | cosmetic | Documented defaults for the concentration unit and the maximum concentration differ from the code | entropic FBA fluxConc / fluxConcNorm with MOSEK: external stoichiometry B is wrong (0 of 43 non-zeros on E. coli core) |
| 11 | `processConcConstraints` | unusable-option | The case dxReplacement always stops with an error | entropic FBA fluxConc / fluxConcNorm with MOSEK: external stoichiometry B is wrong (0 of 43 non-zeros on E. coli core) |
| 12 | `processConcConstraints` | wrong-result | The default row selection indexes the first row repeatedly | entropic FBA fluxConc / fluxConcNorm with MOSEK: external stoichiometry B is wrong (0 of 43 non-zeros on E. coli core) |
| 13 | `processConcConstraints` | error | The parameter printLevel is required although it is documented as optional | entropic FBA fluxConc / fluxConcNorm with MOSEK: external stoichiometry B is wrong (0 of 43 non-zeros on E. coli core) |
| 14 | `setMosekParam` | wrong-result | The strict option never switches MOSEK to a free solve form | solveCobraLP/QP with MOSEK and param.strict |
| 15 | `updateStructData` | limitation | A structure update is ignored when the original field is not a structure | solveCobraLP/QP/MILP/MIQP/NLP parameter merging |
| 16 | `editChemicalFormula` | cosmetic | Element with zero atoms stays in the formula | generateChemicalDatabase, compareInchis, metDatabaseStatus: formula strings |
| 17 | `getInchiData` | wrong-result | Negative charge layer gives NaN | generateChemicalDatabase hydrogen count, compareInchis charge check |
| 18 | `convertOld2NewHMDB` | limitation | Identifiers of 12 or more characters give an empty result | metaboAnnotator checkAbbrExists |
| 19 | `selectGeneFromGPR` | wrong-result | With minSum the reported gene does not belong to the selected alternative | mapExpressionToReactions minSum=true: gene_used label only |
| 20 | `charpos` | wrong-result | The letters i and j count as digits | modelBorgifier cleanTmodel, mergeTrxns |
| 21 | `countC` | wrong-result | Elements whose symbol starts with C are counted as carbon | modelBorgifier reactionCompareGUI |
| 22 | `gapfillRefinedGenomeReactions` | wrong-result | The first gap-filled row overwrites the last annotation row | DEMETER prepareInputData (tutorial_demeter): one annotation row lost per run |
| 23 | `setConstraintsIrrevModel` | wrong-result | Reactions with names of one or two characters get the wrong sign | OptKnock, reaction IDs of one or two characters |
| 24 | `combineChildren` | wrong-result | Identical generated clauses delete the earlier clause | GPRparser(model,true) -> mapExpressionToReactions minSum=true -> applyEFluxConstraints (default): wrong CNF in 1-17 reactions per AGORA/Recon model, expression changes up to 866% |
| 25 | `makeColorGradient` | wrong-result | A channel that is equal in both colours becomes 0 | ReconMap buildFluxDistLayout: colours |
| 26 | `addFluxWidthAndColor` | limitation | Map reactions without flux data get no colour entry | visualizeFluxTimeseriesFromFile: colours |
| 27 | `bilinearDecomposition` | error | A lone reaction with one substrate and three products gives inconsistent sizes | checkRankFR, checkModelProperties: two branches put the fake metabolite at nMet+x+1 instead of nMet+x, so the fake-metabolite chain is broken for inputs that succeed today; a fix changes B for those (moved from table A under FR-007) |
| 28 | `searcher` | unusable-option | Non-iterative search type cannot run | searcher (wholeBody nutrition): the cumulative branch mixes table and cell access and filters the wrong variable; the intended database format cannot be determined (moved from table A under FR-007) |

## New problems (not in the registry; documented, not fixed)

1. `prepareFastGapFill` errors on the three example models of the fastGapFill tutorial
   (`iTZ479_v2`, `iJN678_Published`: line 157; `IEC1907`: line 178).
2. `entropicFluxBalanceAnalysis` with `fluxConc`/`fluxConcNorm` and the `pdco` solver errors
   (`z_ve` undefined, line 1781).
3. `numAtomsOfElementInFormula` errors on MATLAB R2025a when a formula has several zeros after a
   letter (line 51); 15 of 1693 reaction pairs compared by DEMETER/mgPipe.
4. `sampleCbModel` (ACHR): the rename that protects reactions ending in `_r` is undone before
   `convRevSamples` runs.
5. `GPRparser` errors on `test/models/mat/Recon2.v04.mat` (Node/getFunctionalGeneSets line 288).
6. `papers/2018_DecisionsTranscriptomicIntegration` passes `minSum` as the text 'true'/'false';
   'false' is true in MATLAB, so the GM1 arm runs GM2 (1419 of 7785 Recon 2.2 reactions differ).
7. Registry line numbers for `processConcConstraints` are stale (116-118 is now 137-138).
8. CNF conversion of GPR rules grows exponentially; uncapped conversion of Recon1 did not finish
   in about 15 minutes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 62 of 62 table-A defects are fixed, or each one not fixed is listed in table B with
  a reason (FR-007).
- **SC-002**: 100% of the test files of the 52 table-A functions pass; none weakens a
  pre-existing assertion.
- **SC-003**: The regenerated registry contains 0 table-A defects and all table-B defects.
- **SC-004**: Line coverage of every fixed function is equal to or higher than before.
- **SC-005**: The attention document has an entry for 100% of table-B rows and new problems.
- **SC-006**: 0 functions in table B are modified (checked from the diff).

## Assumptions

- The classification comes from the 2026-11-02 impact analysis (static caller graph plus MATLAB
  runs). A caller that builds a function name at run time (`feval` of a string) would not be
  seen; none is known for the table-A functions.
- "No caller" means no call in `src/`, `tutorials/` or `papers/`; users' own scripts may call
  these functions and will see the corrected behaviour, which this feature approves.
- Tests stay Tier 1 (no solver, no model file), as when they were written.
- The feature branch is based on `upstream/develop` and pushed to the maintainer's fork.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-003, FR-004 | the 52 `test<Function>.m` files of table A | the 52 table-A functions |
| US1 / FR-007 | attention document, table B update | — (no source function) |
| US2 / FR-009 | `attention-defects.md` review against tables B and New problems | — (no source function) |
| US3 / FR-008 | `python3 .github/scripts/known_defects.py` | — (no source function) |
| FR-002 / SC-006 | `git diff --stat` against the base, checked for table-B files | — (no source function) |
| FR-010 / SC-004 | harness runner with line coverage per function | the 52 table-A functions |
| FR-011 | `git log` author and message check | — (no source function) |
