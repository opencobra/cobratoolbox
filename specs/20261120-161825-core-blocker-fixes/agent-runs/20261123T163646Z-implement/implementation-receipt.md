# Implementation receipt — 20261120-161825-core-blocker-fixes (the seven fixes)

## Prompt

The maintainer, 2026-11-20 to 2026-11-23: "ok now lets go through the 8 problematic functions one
by one", then "ok lets fix it with respect to your suggestion. we need to push these 7 function
fixes to a new branch. Yes use speckit to fix it. report to me if any output would be affected."
Each function was reviewed in conversation and fixed only after its own approval:
1. getCobraSolverParams: "ok lets fix it with respect to your suggestion"; companion fix in
   optimizeCbModel: "Yes lets add it".
2. getModelFieldsForType: "yes apply it", with a guiding error for ambiguous fields ("Yes also in
   the error refer to the standard field names and encourage the user to use that").
3. setGurobiParam: "ok apply one to 3".
4. findSExRxnInd: "ok apply all four".
5. getFilesInDir: "ok apply all three".
6. checkBalance: "apply both suggetions" (the fix and the help correction).
7. setCplexParametersForProblem: "apply A".
Then "Do all three": push the fixes, write tests for the unblocked functions (T090, a separate run
with its own receipt) and rank the wrong-result defects by scientific impact.

Run inline with /speckit-implement on tasks T001-T037; this receipt covers the seven fixes and the
push of the branch.

## Final response

No. Those seven were the most important *blockers*, not necessarily the most important *defects*. I chose them by how many other functions each one stopped from being tested. The 7 fixes are committed on `20261120-161825-core-blocker-fixes`, which isn't pushed yet.

**What's left in the registry (821 defects):**

| Severity | Count | What it means |
|---|---|---|
| wrong-result | 303 | runs, but gives a wrong answer |
| error | 258 | crashes on documented input |
| unusable-option | 73 | a documented option has no effect |
| cosmetic | 124 | text or printing only |
| limitation | 63 | documented gap, not a bug |

For results, the 303 wrong-result defects matter most. Most of them sit in specialised functions (one pathway, one file format, one toolbox) and block nothing else. That's why they didn't rank in the blocker list, but some may well matter more scientifically than #5 or #7 did.

**What the seven fixes did:**
- **Unblocking:** 215 more functions are now testable. 258 are waiting for tests, and 171 are still blocked.
- **Results that changed in shipped models:**
  - Recon3D's mass balance (#6).
  - `DM_atp(c)` in the cardiac model (#4).
  - Global solver settings now being honoured (#1).

**The next blockers by count are much smaller:**

| Function | Blocks | Notes |
|---|---|---|
| `readSimPhenyGprText`, `readSimPhenyCMPD` | 40 each | the same 40 functions, an old SimPheny import path |
| `issueConfirmationWarning` | 31 | |
| `useDiet` | 25 | |
| `getFormulaFromInChI`, `getChargeFromInChI` | 17 each | |
| everything else | under 10 each | |

**Options for what comes next:**
1. **Push now.** You asked for these 7 fixes on a new branch. I'd write the implementation receipt, run the privacy scan and push `20261120-161825-core-blocker-fixes`.
2. **Write tests for the 258 newly testable functions (T090).** That is big enough for its own feature and branch.
3. **Rank the 303 wrong-result defects by scientific impact** (core FBA, FVA, model editing, mass balance first), so we can review the ones that matter most for results, one by one as we did here.

My suggestion is 1 now, then 3. Shall I push?

## Diff summary

Base: the docs branch head (416de7ae8). 47 files, 2379 insertions, 843 deletions.
- **Source (8 files):** getCobraSolverParams.m, optimizeCbModel.m, getModelFieldsForType.m,
  setGurobiParam.m, findSExRxnInd.m, getFilesInDir.m, checkBalance.m,
  setCplexParametersForProblem.m. Each change is described in review.md, with a NOTE in the
  function's help.
- **Tests (8 files):** full tests for the seven functions (testGetCobraSolverParams,
  testGetModelFieldsForType, testSetGurobiParam, testFindSExRxnInd, testGetFilesInDir,
  testCheckBalance, testSetCplexParametersForProblem) and a new section in testOptimizeCbModel.
- **Records:** test/known-defects.md (regenerated, 830 -> 821 defects), the back-fill ledger
  (seven rows TESTED; the seven names removed from the blocked reasons; 215 rows BLOCKED ->
  PENDING), and the feature folder: spec.md (one decision per function), plan.md, tasks.md, review.md
  (impact report per function), checklists, coverage lists and records, ledger result records.

## Tests

- Each full test was seen to fail on the old code and pass on the new code. Coverage:
  getCobraSolverParams 73/73, getModelFieldsForType 94/94, setGurobiParam 243/244 (1 exempt),
  findSExRxnInd 116/118 (2 exempt), getFilesInDir 72/72, checkBalance 37/37,
  setCplexParametersForProblem 120/129 (9 exempt dead lines); optimizeCbModel 382/410.
- Caller tests after each fix, all passing or skipped by their declared requirements: #1 21
  tests; #2 5 caller tests and 13 legacy editing tests; #3 8 Gurobi tests; #4 18 pass, 5 skipped;
  #5 13 pass, 1 skipped; #6 12 pass, 2 skipped; #7 5 solver tests.
- Old and new outputs compared on the 37 shipped test models for #4 (findSExRxnInd) and #6
  (checkMassChargeBalance on Recon3D).
- update_ledger.py --verify-coverage: 0 problems for every record; --check: one ordering issue
  (chrrExpSampler before its callee fluxVariability, now PENDING), which clears with T090.

## Unresolved issues

- COBRA's camel-case timeLimit is not translated by setGurobiParam (no effect with Gurobi).
- findSExRxnInd stops on models whose subSystems entries are not text (AntCore,
  ME_matrix_GlcAer_WT; the old code too).
- checkBalance stops when a given missingFormulaeBool leaves an empty formula unmarked.
- setCplexParametersForProblem: MIQP method names set lpmethod while numeric codes set qpmethod,
  and the mapping warning is issued on every MIQP call; the effect on a CPLEX solve could not be
  run (CPLEX not installed).
- T090 (tests for the 258 PENDING functions) is a separate run with its own receipt.
