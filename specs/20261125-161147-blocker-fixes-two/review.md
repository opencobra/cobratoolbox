# Review: impact of the three fixes

One section per approved fix (spec.md, decisions 1-3), written by the helper that implemented it and checked by the lead. After review the lead recorded further cosmetic defects of optimizeCardinality (missing fields, the && size check, the o warning) and two defects of changeGeneAssociation (a newly created rxnGeneMat marks only the changed reaction; the help's addRxnGeneMat default), each reproduced on 2026-11-25 and documented in the test headers.

## Review: optimizeCardinality (decision 1, approved 2026-11-25)

Tasks T002-T005 of [tasks.md](tasks.md).

### Fix

`src/base/solvers/cardOpt/sparseLP/optimizeCardinality.m` (CRLF line endings kept):

- The status switch of the DCA loop (line 906 before, 912 now) read `case 1 || 3`. MATLAB evaluates
  `1 || 3` to `true`, so the case matched stat 1 only and an LP status 3 (solution exists, not proven
  optimal) fell to `otherwise`: the iterations ended with `solution.stat = -1` and the previous
  iterate. It is now `case {1, 3}`. The sub-problem (line 1165, which prints "proceeding") and the
  final report (line 1065, `solution.stat == 1 || solution.stat == 3`) already treated 1 and 3 the
  same way.
- A dated NOTE in the help (VII-E): an LP status 3 of a sub-problem continues the iterations, and
  `solution.stat` is 3 when the last sub-problem returned 3. The NOTE adds 6 lines, so every line
  after 110 moved down by 6.
- Not changed: the cosmetic defect "The random warm start is not protected against infinite bounds"
  (now line 747). It stays recorded in the test header.

### Test

`test/verifiedTests/base/testCardOpt/testOptimizeCardinality.m`: the quarantine file is replaced by a
full Tier 3 test (`prepareTest('needsLP', true)`; the default LP solver; any LP solver works, glpk
included). It uses small hand-built problems with 1 to 4 variables: minimal cardinality of x, maximal
cardinality of y, the one norm of z, x and y together, Boolean columns with `xyz`, weights and their
defaults, all six warm starts, complementarity problems (total and partial), the printed report, the
feasibility check, every error, and every warning that returns status -1. The assertions check the
status, the constraints and bounds within `10 * feasTol` (the solver's feasibility tolerance, with
rows of up to four entries), and the cardinality of the solution. Where the DC iterations can stop
at a local optimum, the test checks only the invariants. Stand-ins for `solveCobraLP` and
`solveCobraQP` are written to a `tempname` folder placed first on the path. They are removed with
`rmpath`, the folder is deleted, and `clear` and `rehash` run after both. The stand-ins give the
statuses -1, 0, 2, 3, 3 then 1, an unknown status (4, with and without `origStatText`), the l1/l2
warm-start statuses, both feasibility-check outcomes, the relaxed re-solve printout, and a
complementarity violation. The random seed is fixed (`rng(0)`). There is no `evalc`, warnings are
not suppressed, and the global variables that the test creates are cleared at the end.

- **Coverage** (`coverage-optimizeCardinality.jsonl`, run_coverage.sh with gurobi): passed, 627
  executable lines, 581 hit, 46 missed. Every missed line is unreachable code and is listed in the
  header's "Coverage exemptions": `if 0` / `&& 0` / `& 0` blocks, the `else` of `if 1`, statements
  after `error`, the duplicate `nbMaxIteration` default, the inner check of a scalar p, a non-scalar
  `&&` operand that MATLAB rejects first, and checks of a missing q, r, b or csense or of lb > ub /
  lb2 > ub2 that an earlier statement makes unreachable. No leftover.
- **On the old code** the test failed at `assert(solution.stat == 3)` (the first stand-in section).
  With a stand-in `solveCobraLP` that returns status 3, the old code printed "LPsolution.stat == 3,
  proceeding ..." and then returned `stat -1`, `origStat 103` and the start point `x = [0 0 0]` after
  one sub-problem. Every earlier section passed on the old code.
- **On the new code** it passes with gurobi and with glpk as the LP solver (the default QP solver,
  gurobi, ran the 'l2' warm start).
- **Header**: the quarantine entry for status 3 is removed and a note says it was fixed and tested.
  The cosmetic entry is kept, with its line numbers updated to 747 and 742-745.
  `known_defects.py` parses the header without errors.
- **Ledger record**: `inventory/results/optimizeCardinality.jsonl` (TESTED, tier 3).

### Outputs that can change

Only runs in which an LP sub-problem returns status 3. Through `mapSolverStatus` (and
`parseMskResult`), these LP solvers can return status 3: `ibm_cplex` (codes 5, 6, 10-12, 21, 22),
`tomlab_cplex` / `cplexlp` (5, 6), `matlab` linprog (exitflag -1) and `mosek` (near optimal). gurobi,
glpk, pdco, lp_solve, mosek_linprog and dqqMinos/quadMinos never return 3, so results with these
solvers are unchanged. With a solver that returns 3, optimizeCardinality now keeps iterating. It
returns `stat 3`, or 1 if the last sub-problem returned 1, together with the last sub-problem's
`x`, `y`, `z`, `obj` and (for Boolean p) `xyz`. Before, it returned `stat -1`, the previous iterate
and no `obj` or `xyz`.

Direct callers in `src` (outside `old/` and `deprecated/`; `findGenesFromMets` calls it only in a
comment). Any of them can see status 3, because the status depends on the LP solver and not on how
the caller calls the function:

| Caller | What changes when status 3 is returned |
|---|---|
| optimizeCbModel (minNorm 'zero') | Before, `solCard.xyz` was missing after stat -1, so the read of `solCard.xyz` would stop with an error. Now it returns stat 3 with the almost-optimal solution (its stat 3 branch). |
| findSparsePathway, optCardThermo, fitExperimentalFlux | Pass the status on: 3 instead of -1. fitExperimentalFlux retries and warns "sol.stat == 3". optCardThermo checks `~= 1` in two places (unchanged there). |
| leakTest, findMassLeaksAndSiphons, findFluxConsistentSubset, maxCardinalityConservationVector, minCardinalityConservationRelaxationVector | They test `stat == 1`. Status 3 is handled like -1 was, apart from the status that leakTest passes on (3 instead of -1). |
| findMinimalLeakageMode, findMinimalLeakageModeMet | Switch on cases 0/1/2. Status 3 matches no case, as -1 did; `statp`/`statn` now record 3. |
| findMinimalLeakageModeRxn | Has a `case 3` branch in its first switch, which is now reached by a real status 3 (before, only its own relabelling reached it). |
| findRxnsFromMets, checkThermoFeasibility, optimalConservationVectors | Use the returned vectors without checking the status: the last sub-problem's solution instead of the previous iterate. |

### Callers' tests run with the fixed code

One MATLAB session, `changeCobraSolver('gurobi', 'all', 0)`, each test through `runScriptFile`:

| Test | Result |
|---|---|
| testOptimizeCardinality | passed |
| testFindRxnsFromMets | passed |
| testFindSparsePathway | passed |
| testOptimizeCbModel | passed |
| testOptimizeCbModelCardinality | passed |
| testMaxCardConservationVector | passed |
| testCheckModelProperties (findMassLeaksAndSiphons) | passed |
| testConstrainRxns (fitExperimentalFlux) | passed |
| testValidateCompartments (findRxnsFromMets) | passed |
| testSparseLP (listed in T005; does not call optimizeCardinality) | passed |
| testSparseFBA (listed; does not call it) | passed |
| testFindSparseMode (listed; does not call it) | passed |
| testRelaxedFBA (listed; calls optimizeCbModel without minNorm 'zero') | passed |

None were skipped and none failed. The callers leakTest, findMinimalLeakageMode,
findMinimalLeakageModeMet, findMinimalLeakageModeRxn, findMassLeaksAndSiphons (except through
testCheckModelProperties), findFluxConsistentSubset, minCardinalityConservationRelaxationVector,
optimalConservationVectors, checkThermoFeasibility and optCardThermo have no test. The solvers used
here (gurobi, glpk) never return LP status 3, so these runs show that nothing else changed. They do
not exercise the status-3 path in the callers; the stand-in sections of testOptimizeCardinality do.

## Review: checkMassChargeBalance (decision 2, revised version; T006-T009)

### Fix

`src/reconstruction/modelGeneration/massBalance/checkMassChargeBalance.m`, as approved on
2026-11-25:

- Kept: `imBalancedMass = []` when every reaction is mass balanced (lines 211-213, formerly
  200-202), the pre-2017 convention (Principle II).
- Lines 246 (printLevel -1) and 271 (printLevel 2), formerly 235 and 260: the test is now
  `(isempty(imBalancedMass) || strcmp(imBalancedMass{q, 1}, ''))`. An empty `imBalancedMass`
  means every reaction is mass balanced, so it is no longer indexed.
- Line 271: the printLevel 2 loop over `q` now uses `imBalancedMass{q, 1}`, not the stale index
  `p` that was left over from the loop at line 191.
- Help: `imBalancedMass` now says "empty (`[]`) if every reaction is mass balanced", and
  `imBalancedCharge` no longer says "empty if no imbalanced reactions" (it is always nRxn x 1). A
  `NOTE:` dated 2026-11-25 describes the changes.
- Line endings were checked before and after (ASCII, LF). Interfaces and output shapes are
  unchanged.

### Test

`test/verifiedTests/reconstruction/testMassChargeBalance/testMassChargeBalance.m` (legacy test).
The toy-model loop and all of its assertions are kept. It now opens with `prepareTest()`, and its
clean-up also removes `mass_balanced_charge_imbalanced_reactions.txt`, which the loop's printLevel
-1 runs wrote into the test folder. The clean-up uses `delete` instead of `system('rm ...')`. New
`%%` sections:

- A createModel model without exchange reactions, every reaction mass balanced and R2 charge
  imbalanced. At printLevel 0, `imBalancedMass` is `[]`, `imBalancedCharge` is `[0; 1]`,
  massImbalance is all zero, and imBalancedRxnBool, missingFormulaeBool, balancedMetBool and
  elements are checked.
- The same model at printLevel -1, with a modelName prefix in a tempname folder: the file
  `[modelName 'mass_balanced_charge_imbalanced_reactions.txt']` lists exactly R2, and no mass
  imbalance file is written.
- The same model at printLevel 2, with output captured by `diary`: R2, with its metabolite lines,
  is listed under "Mass balanced, but charged imbalanced reactions:", and R1 is not.
- A three-reaction model: R1 mass balanced and charge imbalanced, R2 mass and charge imbalanced,
  R3 balanced and last. printLevel 2 lists R1 only under the heading and prints R2 with `1 H`
  before it. printLevel -1 writes R2 (with its metabolites) to the mass file and R1 to the charge
  file. A two-reaction model whose last reaction is the mass imbalanced one still lists R1.
- `SIntRxnBool` with an exchange: its mass imbalance is set to 1 for every element, and it is
  listed in neither printed list nor either file.
- A metabolite with a formula but no charge: the charge imbalance is NaN, and printLevel 2 prints
  the metabolite and shows the warning.
- A 1000-reaction chain without `rxns`: the generated name `rxn1000` is printed, NaN charges are
  returned without `metCharges`, and balancedMetBool is checked.

Header: the three entries of 2026-11-23 are removed. Two were fixed, and the third (`[]`) is the
documented convention, so it was resolved by the help correction. Purpose, Tier (2), Authors and
Coverage exemptions are updated, and the "Function under test:" line is kept. Writing the test
found three new cosmetic defects, now recorded in the header in the standard format. None was
fixed, because none is part of the approved fix:

- **"metabolites_without_charge.txt is left open"** (lines 229-234). The fid opened at line 231
  is never closed; `openedFiles` still lists it after the call. The printLevel -1 input with an
  uncharged metabolite is skipped.
- **"the printLevel -1 message names a file that is not written"** (line 249). The message says
  `charge_imbalanced_reactions.txt`, but the file written is
  `mass_balanced_charge_imbalanced_reactions.txt`.
- **"the progress line every 1000 reactions is never printed"** (lines 157-159). `'%n'` is not an
  fprintf conversion, so nothing is printed; the line is also not gated by printLevel. The test
  reaches it and asserts nothing about its output.

**On the old code** (run 2026-11-25, R2025a), the test failed with "Brace indexing is not
supported for variables of this type." at checkMassChargeBalance line 235: printLevel -1 on the
all-mass-balanced model. Each later section was also run on the old code separately:

- printLevel 2 on the same model stopped with the same error at line 260.
- On the three-reaction model, printLevel 2 listed R1 **and R2** under the heading. R2 is mass
  imbalanced; the stale `p` was 3 (R3, balanced).
- On the model whose last reaction is mass imbalanced, printLevel 2 listed **nothing** under the
  heading (`p` was 2, mass imbalanced). The legacy toy-model loop shows the same thing: its
  charge-imbalanced variants printed the heading with nothing under it, because `p` was Ex_E.

**On the new code** the test passes: runScriptFile, 1 s, nothing left in the test folder or
tempdir, and no file left open.

**Coverage** (`coverage-checkMassChargeBalance.jsonl`, `run_coverage.sh`): status passed, no
leftover, 108 of 112 executable lines. The missed lines are 230, 231, 233 and 234, exactly the
exemption in the header (the skipped printLevel -1 input of the defect "metabolites_without_charge.txt
is left open").

### Outputs that can change

Only calls with printLevel -1 or 2 change, in two ways:

1. Every reaction mass balanced (so `imBalancedMass = []`) and some internal reaction charge
   imbalanced. The call used to stop with an indexing error. Now printLevel -1 writes
   `[modelName 'mass_balanced_charge_imbalanced_reactions.txt']`, printLevel 2 prints the list,
   and the outputs are returned. They are identical to those at printLevel 0.
2. printLevel 2 with some reaction mass imbalanced: the printed list under "Mass balanced, but
   charged imbalanced reactions:" now holds exactly the internal reactions that are mass balanced
   and charge imbalanced. It used to hold either all charge imbalanced reactions or none,
   depending on the last reaction. Printed text only; no returned value changes.

No returned output changes in any call: `imBalancedMass` stays `[]` when every reaction is mass
balanced. printLevel 0 and 1 behave exactly as before.

Callers in `src` (outside `old/` and `deprecated/`):

| Caller | printLevel passed | Affected? |
|---|---|---|
| verifyModel (line 164) | 0 | no |
| generateMetaboScore (line 194) | 0 | no |
| testModelMassChargeBalance (demeter suite, line 58) | default 0 | no. It still indexes `imBalancedMass` as a cell and stops on an all-balanced model: the convention is kept, so this is the caller's own handling of `[]` |
| findStoichConsistentSubset (lines 190, 201, 215) | 0 | no |
| findStoichConsistentSubset (lines 725, 758, 777, 796) | -1 | Only with a non-empty `fileName` and massBalanceCheck. It also needs `modelTmp.SIntRxnBool` all true (every reaction in the listed subset) and every reaction mass balanced; otherwise `imBalancedMass` is not empty. No src caller passes `fileName`: checkStoichiometricConsistency passes `[]`, and the rest pass two or three arguments. Only direct user calls can reach it, and they now get the file instead of an error |
| checkRankFR (line 138) | its own printLevel (default 1) | Yes with printLevel -1 or 2 (case 1 or 2 above). No src caller of checkRankFR outside old/ and deprecated/ |
| driver_createTrainingModel (thermo/trainingModel/new, line 41) | -1 | A driver script in a `new/` folder that initCobraToolbox removes from the path. If run, case 1 can apply |

### Callers' tests run with results

Run 2026-11-25 with runScriptFile, gurobi as the LP/QP solver and the fixed code:

| Test | Reaches checkMassChargeBalance through | Result |
|---|---|---|
| testMassChargeBalance | direct | passed |
| testVerifyModel | verifyModel (printLevel 0) | passed |
| testStoichiometricConsistency | findStoichConsistentSubset (massBalanceCheck 0) | passed |
| testGenerateMetaboReport | generateMetaboScore / report | passed |
| testCheckDatabaseIDs | generateMetaboScore path | passed |
| testCheckModelProperties | checkModelProperties -> findStoichConsistentSubset | passed |
| testCheckModelPreFBA | checkModelPreFBA -> findStoichConsistentSubset | passed |
| testCheckNullspaceBasis | checkNullspaceBasis -> findStoichConsistentSubset(model, 1, 0) | passed |
| testGreedyExtremeRayBasis | greedyExtremeRayBasis -> findStoichConsistentSubset(model, 1, 0) | passed (85 s) |
| testNullspaceAccuracyTarget | findStoichConsistentSubset (0, 0) | passed |
| testMakeModelPropertiesTable | model properties table | passed |
| testCycleFreeFlux | cycleFreeFlux -> findStoichConsistentSubset (0, 0) | passed |
| testEntropicFluxBalanceAnalysis | entropicFluxBalanceAnalysis -> findStoichConsistentSubset | skipped (mosek required, not available) |

No test of checkRankFR, findStoichConsistentSubset with a fileName, or the demeter
testModelMassChargeBalance exists, so the affected paths of the callers are covered only by the
direct sections of testMassChargeBalance.

## Review: changeGeneAssociation (approved 2026-11-25, decision 3, fixes a-c)

### Fix

`src/reconstruction/refinement/changeGeneAssociation.m` (CRLF line endings kept). The three defects
come from the 2017 refactoring `5f8e82a086`, which replaced the gene-by-gene loop with `parseGPR`.

- **a. New genes extend the other gene fields.** `nGenes = length(model.genes)` after the new genes
  are appended, so `extendModelFieldsForType(model, 'genes', ...)` now runs and gives `proteins`
  (`COBRAProtein<i>`), `geneNames` (the gene identifier) and every other gene field their defaults.
  The call is moved before the reaction's row of `rxnGeneMat` is set, so `rxnGeneMat` (which has
  `nGenesInit` columns at that point) is extended once, by `extendModelFieldsForType`.
- **b. Translation before the look-up.** With `geneNameList` and `systNameList`, the rule is
  preparsed (`preparseGPR`) and each gene token is replaced by its systematic name, found by its own
  position in `geneNameList` (a name not in the list is kept), before `parseGPR` looks the genes up
  in `model.genes`. A translated gene already in the model is reused. The unused local function
  `convertGeneID` was rewritten to do the per-name translation (it is now used); the whole-token
  regular expression is the one `parseGPR` uses, so names with `.`, `_`, `-` are handled.
- **c. A requested rxnGeneMat is reactions x genes.** When `addRxnGeneMat` is true and the model has
  no `rxnGeneMat`, it is created as `sparse(numel(model.rxns), nGenes)` before the row is set.

A dated NOTE (2026-11-25) in the help describes the three changes. No argument, nargin, evalc or
warning handling was changed.

### Test

`test/verifiedTests/reconstruction/testRefinement/testChangeGeneAssociation.m` replaces the
quarantine file with a full Tier 2 test (hand-built three-reaction model via `createModel`, no
solver). It covers: an existing gene; new genes in an and/or rule; nested parentheses; replacing an
existing association; an empty rule; the translation lists (both recorded triggers, a name not in
the list, a translated name already in the model, a name equal to a model gene, names with `.`,
`_`, `-` and row lists, an empty rule with lists, a missing `systNameList`); `rxnGeneMat` absent
(not created), requested (reactions x genes), requested without a new gene, and present with
`addRxnGeneMat` false; a model without genes, rules and grRules; rules missing with grRules present;
genes present with rules and grRules missing; the error for an unknown reaction. A local helper
asserts after each call that every gene field has one entry per gene, `rules`/`grRules` one per
reaction, `grRules` is `rules` written with the gene names, and `rxnGeneMat` (when present) is
reactions x genes and marks exactly the genes of each rule.

- **Old code:** fails at line 77 (`proteins` not extended for the new genes, defect a). On the old
  code the recorded triggers also give: genes `{'g1';'B';'A'}` and grRule `B and A` for
  `'a and b'` with `{'b';'a'} -> {'B';'A'}`; "Index exceeds the number of array elements" at line 72
  for `{'x';'a'} -> {'X';'A'}`; a requested `rxnGeneMat` of size `[1 2]` on a three-reaction model.
- **New code:** passes, no warning.
- **Coverage:** 43/43 executable lines (`coverage-changeGeneAssociation.jsonl`), no exemption.

### Outputs that can change

Callers in `src/` outside `old/` and `deprecated/`:

| Caller | Call | What changes |
|---|---|---|
| addReaction | `changeGeneAssociation(model, rxnID, grRule)` or with `geneNameList`, `systNameList` | a. gene fields extended for new genes; b. translation (`geneNameList`/`systNameList` options) |
| addMultipleReactions (and its copy addMultipleReactionsIT) | per reaction with a non-empty grRule | a. gene fields extended for new genes; createModel goes through this path |
| prepareModelNutrientGeneMCS | one artificial gene per exchange | a. gene fields extended |
| addReactionsHH | `..., {}, {}, 0)` | a. gene fields extended; with an existing `rxnGeneMat` and `addRxnGeneMat` 0, its columns are now extended to the new number of genes (the row of the changed reaction is still not updated, as before) |
| getOrgansFromHarvey | `..., 0)` (0 as `geneNameList`, no `systNameList`) | a. only; no translation, `rxnGeneMat` default as before |

ReconstructionCreator only names the function in a comment.

1. **Gene fields (a).** Every model with gene fields other than `genes` (for example `proteins`,
   `geneNames`, the gene annotation fields) that gets a new gene through these callers now keeps
   them as long as `genes`. Before, they stayed short and the model failed `verifyModel`. Checked on
   the shipped `Ec_iAF1260_flux1.mat` (2382 reactions, 1261 genes, `geneNames` and `proteins`),
   `addReaction` with rule `b0241 and newGeneX`:

   | | genes | geneNames | proteins | verifyModel simpleCheck |
   |---|---|---|---|---|
   | old | 1262 | 1261 | 1261 | 0 (fails) |
   | new | 1262 | 1262 (last `newGeneX`) | 1262 (last `COBRAProtein1262`) | 1 |

   Models without other gene fields (ecoli_core_model, Recon3DModel_301, the AGORA model
   Abiotrophia_defectiva_ATCC_49176) give the same genes, grRules and `rxnGeneMat` before and after.
2. **Translation (b).** Only addReaction passes the lists (its `geneNameList`/`systNameList`
   options). Example, `addReaction(..., 'geneRule', 'commonA or commonB', 'geneNameList',
   {'commonB'; 'commonA'}, 'systNameList', {<existing gene>; 'sysA'})`:

   | Model | old | new |
   |---|---|---|
   | ecoli_core_model | 139 genes (b0114 added a second time), grRule `b0114 or sysA` | 138 genes, grRule `sysA or b0114` |
   | Recon3DModel_301 | 2250 genes, `26.1 or sysA` | 2249 genes, `sysA or 26.1` |
   | Ec_iAF1260_flux1 | 1263 genes, `b0929 or sysA` | 1262 genes, `sysA or b0929` |

   The old results were wrong (wrong names, duplicated genes); a list in which a gene is not first
   stopped with an indexing error.
3. **rxnGeneMat size (c).** Only a call with `addRxnGeneMat` true on a model without `rxnGeneMat`
   changes: the matrix is now reactions x genes instead of (changed reaction) x genes. None of the
   callers in `src/` passes `addRxnGeneMat` true. A newly created matrix marks only the changed
   reaction's genes (other reactions' rules are not entered), as before 2017; this is not changed
   here.

Cost: `extendModelFieldsForType` now runs once per call that adds a gene (as before 2017), for
example once per new-gene reaction in addMultipleReactions.

### Callers' tests run with results

Run in one MATLAB session on the new code and again with the old function first on the path.
`PASS` means the test script ran to the end; no test was skipped. 27 exercising tests plus
testChangeGeneAssociation:

| Test | New | Old |
|---|---|---|
| testChangeGeneAssociation | PASS | FAIL (line 77, defect a) |
| testAddReactionGEM, testBatchAddition, testRemoveDuplicateRxn, testGenerateRules, testUpdateGenes, testDynamicModelFieldModification, testMergeTwoModels, testModelManipulationOri | PASS | PASS |
| testAddReactionsHH, testCreateModelNewCompartment, testCreateEcosystemModel, testEcosystemToy | PASS | PASS |
| testAddGenes, testExtendModelFieldsForType, testGetModelFieldsForType, testGPRLogic, testFindGeneIDs, testFindGPRFromRxns, testFindSubSystemsFromGenes, testCalculateGeneKOMatrix, testReadBooleanRegModel, testSolveBooleanRegModel | PASS | PASS |
| testAddMetabolite, testAddMultipleMetabolites, testSetRxnSubSystems, testAddSubSystemsToReactions, testRemoveSubSystemsFromRxns | PASS | PASS |

Also run, but quarantine files of the back-fill campaign that assert nothing yet (pass trivially):
testChangeRxnMets, testCalculateMCS, testNormaliseGPRs, testAssignGPRA, testIsSameCobraModel,
testMoveRxn, testConvertToIrreversible, testModel2xls, testAssignSubSystems,
testConvertCbModelToCNAModel, testAnnotateModel.

No caller test asserted the old behaviour. addMultipleReactionsIT, prepareModelNutrientGeneMCS and
getOrgansFromHarvey have no test of their own. In the batch run, testEcosystemToy printed two
warnings on the new code that it did not print on the old ("Metabolites have been added ...
isolatedMet", "Incomplete basis ..."); run alone, old then new in one session, its output is
identical, so they come from the state left by earlier tests in the batch, not from the fix.

## Unblocking

After the three fixes, 162 ledger rows reach no defect any more and are PENDING (21 Tier 2, 141 Tier 3); 192 remain BLOCKED. No TESTED row lost its test.

## T016: tests for the unblocked functions (waves 38-43)

Every one of the 162 unblocked rows now has a final status. Helpers wrote the tests (one slice
each, at most three MATLAB sessions); the lead confirmed every quarantine (by reading the code, and
by MATLAB reproduction where the record alone did not settle it), decided each reach, applied,
ran the joint coverage of every slice, regenerated the registry and committed.

| Result | Rows |
|---|---|
| TESTED (kept) | 33, covering 1,406 more lines |
| QUARANTINED | 56 |
| EXCLUDED (own earlier test, or MOSEK on every call) | 7 |
| Tests removed by the late-edge rule | 2 (modelMultipleObjectives, debugInfeasibleEntropyFBA: they reach the minCardinalityConservationRelaxationVector defect through entropicFluxBalanceAnalysis) |

Ledger at the end: 259 TESTED, 373 QUARANTINED, 195 EXCLUDED, 258 BLOCKED, 0 PENDING.
Registry: 1,052 defects.

**Reach decisions.** Defects confined to an input or call form that no src caller uses got the
seed NONE (linearMOMA, identifyFastBlockedRxns, normalizePoints, createHRWarmup, processingLLCs,
optimizeWBModel, findMassLeaksAndSiphons) or a seed list (singleGeneDeletion:
analyzeSingleGeneDeletion). Data-dependent defects keep the default reach. The static call graph
links verifyModel to findStoichConsistentSubset, but verifyModel calls it only with
'stoichiometricConsistency', true, which no src caller passes; without a stop, three defects
(minCardinalityConservationRelaxationVector, removeRxns, removeMetabolites) reached every function
that solves an LP and would have removed 15 to 18 new tests. update_ledger.py gained the seed form
`name<TAB>!file` (the reach stops at a caller whose call form avoids the defect).

**New defects worth the maintainer's attention.**

- removeRxns: the default ctrsRemoveMethod 'exclusive' removes every coupling constraint that
  involves a removed reaction (what the help and the code comments call 'inclusive'). Removing a
  coupling constraint with its reaction may be the wanted behaviour, so whether the help or the
  code is wrong is the maintainer's decision.
- addReaction (subSystems of an existing reaction reset; metaboliteList without stoichCoeffList)
  and addMultipleReactions (existing IDs added again; 'rules' read from the old model) now block
  most of what remains, with removeRxns and removeMetabolites.
- New error defect recorded in testOptimizeCbModel: solveWBMmethod 'QP' or 'QRLP' with minNorm 0
  stops at line 847 (line 447 bypasses the 0 -> [] normalisation). No src caller uses it.
- Gradings to check: computeRescuedGenes (code counts a growth drop above 10%, help says 50%),
  findMustL/findMustU (wrong mutant flux only in the documented _Info output files).

**Current blockers** (blocked rows reaching each; fixing them in this order frees 13, 28, 41, 51
and 61 rows): addMultipleReactions 89, addReaction 68, removeRxns 117, removeMetabolites 86,
minCardinalityConservationRelaxationVector 34.
