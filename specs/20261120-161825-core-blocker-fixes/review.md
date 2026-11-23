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
