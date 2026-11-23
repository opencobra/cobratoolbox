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

## 4. findSExRxnInd (approved 2026-11-23, fixes 1-4)

**Fix.**
1. The ATP maintenance and demand names (ATPM, DM_atp(c), DM_atp_c_) are collected in one
   boolean, removed from both DMRxnBool and the heuristic exchange set. Before, each name check
   overwrote the same variable, so only DM_atp_c_ became internal.
2. A missing c is created with one entry per reaction (zeros(n, 1)), not per metabolite.
3. The prefix Ex_ is compared on three characters; on five it never matched.
4. "Found biomass reaction: ..." is printed only at printLevel > 0, as every other message.

The help has a NOTE describing the changes.

**Test.** testFindSExRxnInd is the full test written before the quarantine, extended with
DM_atp(c), Ex_, a model without c, each ATP name on its own, ATPM in an exchange subsystem, a
whole-body DM_atp(c) and Ex_, and the printed output at printLevel 0 and 1 (diary file in a
temporary folder): 116/118 lines, nothing left behind. It failed on the old code at the first
classification check. Exempt: line 65 (printLevel is the third input, so it is 0 whenever
nRealMet is absent) and line 282 (the sanity check compares an expression with itself); both
were already exempt before the quarantine.

**Impact: which outputs can change.**
- **SIntRxnBool and the metabolite booleans of a model with a reaction named DM_atp(c)** with more
  than one coefficient: the reaction becomes internal. Old and new outputs were compared on all
  37 shipped test models: only cardiac_mit_glcuptake_atpmax changes. DM_atp(c) (atp + h2o -> adp
  + h + pi) becomes internal, and adp, atp, h, h2o and pi move from "external" (SExMetBool) to
  "internal only" (SOnlyIntMetBool). Every other field and every other model is unchanged.
- **ATPM or DM_atp(c) marked as exchange by an HMR subsystem or compartment x:** now internal, as
  DM_atp_c_ already was. No shipped model.
- **Reactions named Ex_...:** ExchRxnBool true; with more than one coefficient they become
  external. No shipped model has the prefix.
- **A model without c:** the returned c has n entries. Classification unchanged (DAS and subDas,
  the shipped models without c, are square, so their outputs are identical).
- **printLevel 0 with biomassRxnAbbr matching one reaction:** one line less on screen.

Callers that use SIntRxnBool for stoichiometric consistency (checkStoichiometricConsistency,
findStoichConsistentSubset and those built on them) now check DM_atp(c) like any other internal
reaction; it is mass balanced, so a consistent model stays consistent.

23 tests that call findSExRxnInd or one of its callers were run after the fix: 18 pass
(testCheckModelPreFBA, testRelaxedFBA, testConservationAnalysis, testSubspaces,
testAddLoopLawConstraints, testCycleFreeFlux, testSetCommonZeroStandardGibbsEnergyOfFormation,
testCheckNullspaceBasis, testExtremePools, testGenerateFullRowRankFR, testGreedyExtremeRayBasis,
testIntegerizeS, testNullspaceAccuracyTarget, testWrite4ti2, testCheckModelProperties,
testModelManipulationOri, testTest4HumanFctExt, testStoichiometricConsistency), none fail; 5
are skipped by their declared requirements
(testConnectedComponents: Image Processing Toolbox; testEntropicFluxBalanceAnalysis: mosek;
testGenerateChemicalDatabase: cxcalc; testXomicsToModel_fastCore and _thermoKernel: full mode
only).

**Open item (pre-existing, not changed).** A model whose subSystems entries are not text stops
at line 165 (the HMR subsystem heuristic) with "Input A of class cell and input B of class double
must be ...". Two shipped models, AntCore and ME_matrix_GlcAer_WT, have empty numeric subSystems
entries; the old code stops in the same way. This breaks the COBRA field definition (a cell array
of text), so it is recorded here, not as a defect.

**Unblocked.** findSExRxnInd was one of the blockers of 248 functions; 8 have no blocker left:
findRXNFilesPlain, findRXNFiles, checkRXNFiles, buildAtomTransitionMultigraph,
findBondsBrokenAndFormed, findEnthalpyChange, obtainAtomMappingsRDT and consistentPotentials.
PENDING: 109. Registry: 826 defects.

## 5. getFilesInDir (approved 2026-11-23, fixes 1-3)

**Fix.**
1. Empty names are dropped after the listing: an empty git listing gives an empty cell array,
   not the folder itself (`[dirToList filesep]`), and type 'all' in a repository without
   untracked files lists no folder entry.
2. checkSubFolders defaults to true, as documented. In a git repository the old default '' already
   behaved as true; outside git only the top level was listed.
3. Outside git, the folders returned by rdir are dropped: only files are listed, as in a git
   repository.

The help has a NOTE describing the changes.

**Test.** testGetFilesInDir is a full test, written new: 72/72 lines, nothing left behind. It
requires git and builds, in a tempname folder (GIT_CEILING_DIRECTORIES set to it, restored after),
a folder outside git and git repositories made with git init (no commit, no network): every type,
checkSubFolders, restrictToPattern, the default folder, the switch of ignoredByCOBRA to ignored for
a cobratoolbox.git remote, empty listings and the invalid options. It failed on the old code at the
default call outside git (subfolders missing).

**Impact: which outputs can change.** Callers: initCobraToolbox (snapshot of CBTDIR, type all),
removeTempFiles (deletes the files listed after but not before), changeCobraSolver (validation
level 2, type ignoredByCOBRA without subfolders) and test/testAll (type all, and tracked .m files).
- **Inside a git checkout (developers, CI):** unchanged, except that a listing that was empty
  now is empty instead of holding the folder path. removeTempFiles could only try to delete that
  path, which fails with a warning and a false status; it no longer tries.
- **A COBRA copy not under git (for example a zip download):** initCobraToolbox's snapshot now
  holds the files of the subfolders. Its final removeTempFiles(CBTDIR, ...) lists recursively, so
  before the fix every file in a subfolder matching a COBRA .gitignore pattern (for example *.log)
  looked new and was deleted, even if it was there before initCobraToolbox ran; now only files
  that are new are deleted. Folders are no longer listed, so removeTempFiles no longer tries to
  delete folders.

Tests run after the fix: testChangeCobraSolver (which runs the validation-level-2 path through
getFilesInDir and removeTempFiles) and the 13 other tests of test/verifiedTests/base/testInstall:
13 pass, testInitCobraToolboxAgentMode is skipped (mosek required).

**Unblocked.** getFilesInDir was one of the blockers of 245 functions; 3 have no blocker left:
removeTempFiles, getCobraSolver and CPLEXParamSet. PENDING: 112. Registry: 823 defects.

## 6. checkBalance (approved 2026-11-23, fix and help correction)

**Fix.** Line 92 (now 98) finds the reactions that use a metabolite without a usable formula with
any(..., 1), column by column. With exactly one such metabolite, any() of the 1 x n row was a
scalar, so reaction 1 was set to NaN and the reactions that use the metabolite kept a number
(that metabolite counted as 0 atoms). The help now gives the code's default printLevel, 1 (it said
0). The help has a NOTE describing the change.

**Test.** testCheckBalance is a full test, written new: 37/37 lines, nothing left behind. E and dE
are counted by hand for C, Co, H and an absent element on a seven-metabolite model, with no, one
(not in reaction 1) and two metabolites without a formula, a non-standard formula, a given
missingFormulaeBool, the printed list (default and printLevel 1, silent at 0), the printLevel -1
file, and the errors. It failed on the old code at the case of exactly one missing formula.

**Impact: which outputs can change.** dE of a model with exactly one metabolite without a usable
formula (with none, any() of the 0 x n matrix and, with two or more, any() of the rows already
worked by column). Of the shipped test models, Recon3DModel_301 and Recon3D_301 (protein[c], no
formula). checkMassChargeBalance(model, 0) with the old and new checkBalance:
- **massImbalance**, three reactions, all 19 elements: 10FTHF5GLUtl (reaction 1) from NaN to 0
  (it is balanced); PROTEIN_BS from numbers (for example -32.57 C, -66.04 for the first element)
  to NaN; DM_PROTEIN from 0 to NaN.
- **imBalancedRxnBool**: unchanged (the same reactions are listed as imbalanced).
Every other output and model is unchanged.

14 tests of checkMassChargeBalance and its callers (verifyModel, findStoichConsistentSubset,
checkRankFR, generateMetaboScore) were run after the fix: 12 pass (testMassChargeBalance,
testVerifyModel, testStoichiometricConsistency, testCycleFreeFlux, testCheckNullspaceBasis,
testGreedyExtremeRayBasis, testNullspaceAccuracyTarget, testConvertOldStyleModel,
testBuildOptProblemFromModel, testModelManipulationOri, testBatchAddition,
testExtractMetModel), none fail; 2 are skipped (testGeneMCS: ibm_cplex;
testEntropicFluxBalanceAnalysis: mosek).

**Open item (not a defect, not changed).** A given missingFormulaeBool that leaves an empty
formula unmarked stops with "Index exceeds array bounds" (line 63, the '(' check reads the first
character of the empty formula). The input contradicts itself, and the only caller passes the
function's own third output, which marks every empty formula.

**Unblocked.** checkBalance was one of the blockers of 240 functions; 2 have no blocker left:
checkMassChargeBalance and the DEMETER test testModelMassChargeBalance. PENDING: 114. Registry:
822 defects.

## 7. setCplexParametersForProblem (approved 2026-11-23, option A)

**Fix.** The barrier default for lpmethod (4 for every problem type other than LP, "best benchmark
performance on Harvetta") is not applied when, for MIQP, lpmethod was just set from a name given
in problemTypeParams.method. Before, the name was always replaced by the barrier. The help NOTE
states when lpmethod is 4. Option A was chosen over B (names setting qpmethod, as the numeric
legacy codes do); not changed: names set lpmethod while numeric codes set qpmethod, and the
warning "check the problemTypeParams.method mapping to algorithm numbers is correct" on every
MIQP call.

**Test.** testSetCplexParametersForProblem is a full test, written new: 120/129 lines, nothing left
behind. A hand-built structure (setDefault, Param, DisplayFunc, Start) stands in for the Cplex
object, as in testSetCplexParam: display settings, the four log destinations (a log file in a
tempname folder, appended to), tolerances, MIP parameters, lpmethod and qpmethod (codes and
names), the legacy MIQP method codes with their warning, the MIQP method names, the solver-specific
fields and the advanced start. It failed on the old code at the MIQP method names. Exempt: lines
320 and 329 (the condition of line 313 ends in "&& 0") and 371-384 (inside "if 0").

**Impact: which outputs can change.** Only solveCobraMIQP with ibm_cplex and a named method: CPLEX
gets the named lpmethod instead of 4. LP, QP, MILP, and MIQP with a numeric or no method, get the
same parameters as before. CPLEX is not installed on this machine, so the effect on a CPLEX solve
could not be run; the parameter structure is checked by the test. testSetCplexParam,
testSolveCobraLP, testSolveCobraQP, testSolveCobraMILP and testSolveCobraMIQP pass (their CPLEX
parts are skipped where CPLEX is absent).

**Unblocked.** setCplexParametersForProblem was one of the blockers of 239 functions; 144 have no
blocker left, among them fluxVariability, singleGeneDeletion, doubleGeneDeletion,
singleRxnDeletion, linearMOMA, removeRxns, removeMetabolites, extractSubNetwork, GIMME,
fastCoreWeighted, phenotypePhasePlane, doubleRobustnessAnalysis, the optForce, optEnvelope and
metabotools functions, and most of the DEMETER refinement functions. PENDING: 258. Registry: 821
defects.

**Ledger check.** `--check` reports one ordering issue: chrrExpSampler (QUARANTINED for its own
defect) precedes its callee fluxVariability, now PENDING. It clears when fluxVariability is tested
(T090).
