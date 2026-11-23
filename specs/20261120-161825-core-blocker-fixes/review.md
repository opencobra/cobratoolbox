# Review: fixes of the core blocking functions

## 1. getCobraSolverParams (approved 2026-11-20)

**Fix.** `overRideDefaults` is split into `useGlobals` and `returnStructure`:
- the two-input form reads the global settings;
- `'default'` does not read them;
- a structure input does both, as before.

The help for paramStructureOut is corrected, and a NOTE is added.
testGetCobraSolverParams is now a full test (73/73 lines, nothing left behind); it failed on the
old code at the two-input call after changeCobraSolverParams. Three defect entries are removed, and
the registry lists 834 defects.

**Unblocked.** 12 functions now have no blocker left. They are PENDING, and their tests come in the
final phase:
- checkSolFeas, buildCplexProblemFromCOBRAStruct, SteadyComCplex;
- quanQualAcc, plotExperimentalvsPredictedExchange, preprocessingOmicsModel, metUtilisation;
- plotRelaxedFBA, decomposeMoietyVectors;
- findMustLL, findMustUL, findMustUU.

### Impact: which outputs can change

Only the two-input form behaves differently. It is used by 63 functions outside old/ and deprecated/.
The parameters they read are:

| Parameter | Callers |
|---|---|
| feasTol | 59 (optimizeCbModel's tolerances excepted) |
| optTol | 3 (biomassPrecursorCheck, plotRelaxedFBA, sparseFBA) |
| minNorm | 1 (optimizeCbModel, when minNorm is not given) |
| intTol | 1 (fluxVariability, MILP) |
| objTol | 1 (optimizeTwoCbModels) |

Their output changes only when a global setting exists for that parameter. The global settings are
empty after initCobraToolbox (checked for LP, MILP and QP), so a new session gives the same results
as before. A global setting exists:

1. **When the user calls changeCobraSolverParams.** The setting now takes effect in those 63
   functions, as documented, where it was ignored before.
2. **When a function of src/ sets one in the same session.** Of the 14 calls in src/, only these
   touch a parameter read in the two-input form:
   - optCardThermo, `feasTol`: inside `if 0`, never run;
   - setThermoReactionDirectionalityiAF1260, `minNorm = 0` and `printLevel = 0`: run by
     secondPassDirectionalityAssignment.

   The others set logFile or primalOnly, which no two-input caller reads.

**Regression found: global minNorm = 0 in optimizeCbModel.** changeCobraSolverParams documents
`minNorm` 0 as "off". optimizeCbModel turns 0 into "off" (`[]`) only for its input (lines 302-304),
not for the global value read at line 321.

| Case | Result |
|---|---|
| Global minNorm 0, a model without objective (or with every objective reaction fixed) | after the fix: `Unrecognized field name "stat"` (MATLAB R2025a, glpk) |
| Same model, no global setting | stat 1 |
| Same global setting, a model with an objective | correct |

Before the fix the global value was never read, so this did not occur. The companion fix
(T007) adds the same 0 → [] step after line 321. It needs the maintainer's approval.

**Tests of the callers.** The 21 two-input callers with a test were run (runScriptFile, empty global
settings): 20 passed and testFastGapFill was skipped (solver not installed). They are:
- optimizeCbModel, biomassPrecursorCheck, mdFBA, relaxedFBA, findSparsePathway, cycleFreeFlux;
- writePajekNet, sparseLP, optimizeTwoCbModels, constrainRxns, pruneModel;
- fastcc, fastcore, partition, rFastcormics;
- GDLS, OptKnock, multiProductionEnvelope, checkModelPreFBA, checkModelProperties.

### Companion fix: optimizeCbModel and a global minNorm of 0 (approved 2026-11-20, T007)

After reading the global minNorm (line 321), optimizeCbModel now turns 0 into `[]` (no norm), as
lines 302-304 already do for the minNorm input. testOptimizeCbModel has a new section: a global
minNorm of 0, the toy pathway without an objective (f = 0) and with it (f = 10, no f2). It passes
with coverage of 382/410 lines (before: 380/408; the two new lines are reached, and the 28 missed
lines are the same as before), and nothing is left behind.

**Impact.** Compared with the toolbox before this feature, a global minNorm of 0 again means no norm,
which is what the old code did when it ignored the global value. So the two fixes together change
optimizeCbModel's output only when a user sets a global minNorm above 0, as documented.

## 2. getModelFieldsForType (approved 2026-11-23)

**Fix.** Line 104 read `length(type-1)`, the length of the whole type name, so in a model with 0 or
1 elements of the type, custom fields named after the type (`rxnCustom`, ...) were not found. It
now reads `length(type)-1`, as the comment and line 184 intend. Before the fix, the maintainer and
the lead checked this against the 80 standard COBRA fields:
- all 80 are in the field definitions;
- every one that starts with a type's prefix belongs to that type;
- the one overlap (rxnNames with the map type rxnName) matched already before the fix.

**Guiding error (maintainer's choice).** Writing the test found a second defect, older than this
fix. An undefined field named after the type, square in the type's size, in a model where another
type has the same size, got the dimension -1. Callers then failed, for example removeRxns with
"Array indices must be positive integers or logical values." (reproduced on the old and the new
code). The name cannot settle such a field: rxnPairMat (rxns x rxns) and rxnMetMat (rxns x mets)
look the same at 2 x 2. So instead of a guess, the function raises
`getModelFieldsForType:ambiguousField`. The message names the field, says why its dimension cannot
be determined, and asks the user to use the standard COBRA field names (getDefinedFieldProperties,
documentation/source/guides/COBRAModelFields.rst) or to rename or remove the field. It is
documented in the help.

**Test.** testGetModelFieldsForType is a full test, written new: 94/94 lines, nothing left behind,
no exemptions. A helper wrote it; the lead verified it and added the error section. It fails on the
old function (the one-reaction rxnCustom check) and passes on the fix. It covers:
- input errors;
- an empty model;
- one-reaction and one-metabolite models with the standard fields, and no field of another type;
- the former trigger, compared with a two-reaction model;
- a non-standard 1 x 1 field named after the type (listed, as the documented rule says);
- square fields with and without another type of the same size, including the guiding error and
  removeRxns stopping with it;
- rxnNotes;
- the fieldSize option.

**Impact: which outputs can change.**
1. A model with 0 or 1 elements of a type that has custom fields named after the type: those fields
   are now edited along with the type (as in larger models).
2. A model with an ambiguous custom square field: the indexing error becomes the guiding error.

Nothing else changes. Standard fields are found through their definitions either way. The tests of
the 5 direct callers that have one (searchModel, mergeModelFieldPositions, mergeTwoModels,
removeFieldEntriesForType, updateFieldOrderForType) pass. So do 13 older tests that use the
model-editing functions most:
- testModelManipulationOri (63 editing calls), testEcosystemToy, testBatchAddition;
- testDynamicModelFieldModification, testFastLeakTest, testUpdateGenes, testElementalBalance;
- testBiomassPrecursorCheck, testNeighborRxn2data, testRemoveDuplicateRxn, testGenerateRules;
- testConstraintModifciation, testAddReactionsHH.

All of them were run before and after the guiding error was added.

**Unblocked.** 46 functions now have no blocker left, among them createModel, addReaction,
addMetabolite, addMultipleReactions, addMultipleMetabolites, addGenes, convertToIrreversible,
extendModelFieldsForType, moveRxn, deleteModelGenes, addExchangeRxn, addDemandReaction and
addSinkReactions. With the 12 from #1, 58 functions are PENDING; their tests come in the final
phase. The registry lists 833 defects.

## 3. setGurobiParam (approved 2026-11-23, fixes 1-3)

**Fix.**
1. Every field is optional. OutputFlag = 0 and DisplayInterval = 1 are set directly when absent:
   every printLevel case set these values, so the output is unchanged. FeasibilityTol and
   OptimalityTol are copied from feasTol and optTol only if those are given; otherwise Gurobi's
   defaults apply.
2. timelimit is copied to TimeLimit only when TimeLimit is absent, as the help says.
3. The warning for an unknown lpmethod names param.lpmethod.

The help text and a NOTE describe the changes.

**Test.** testSetGurobiParam is a full test, written new: 243/244 lines, nothing left behind. It
failed on the old code with `Unrecognized field name "printLevel"`. Line 419 is exempt: it removes
a field logFile, but the filter of Gurobi parameter names before it (LogFile) always removes that
field first, so the line is unreachable.

**Impact: which outputs can change.** The only callers are solveCobraLP and solveCobraQP (Gurobi
branch), which pass the merged COBRA parameters. Those always contain printLevel, feasTol and
optTol, and never both timelimit and TimeLimit, so their Gurobi settings are unchanged:
- **A direct call without those fields:** works, where it stopped with an error.
- **A call with both timelimit and TimeLimit:** keeps TimeLimit.
- **The lpmethod warning:** names the right field.

Eight tests that solve with Gurobi pass after the fix: testSolveCobraLP, testSolveCobraQP,
testOptimizeCbModel, testFVA, testGurobiQP, testGurobiSettings, testGurobiWarmstartBasis and
testBuildGurobiProblemFromModel.

**Open item (not included, maintainer 2026-11-23).** COBRA's camel-case `timeLimit`, which
solveCobraLP/QP document ("if supported by the solver") and which is always present (default
1e36 s), is not translated: setGurobiParam drops it, so a COBRA time limit has no effect with
Gurobi.

**Unblocked.** 43 functions, among them sparseFBA, optimizeCardinality, swiftcc, fastSNP,
findMinNull, the FASTCORE LP routines (LP3, LP7, LP9weighted, LP10, LP10weighted),
findSparseMode, checkFluxConsistency, leakTest and the minimal-leakage-mode functions. PENDING:
101. Registry: 830 defects.
