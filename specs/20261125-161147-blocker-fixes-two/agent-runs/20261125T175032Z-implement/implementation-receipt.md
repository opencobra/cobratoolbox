# Implementation receipt — 20261125-161147-blocker-fixes-two

## Prompt

Maintainer, 2026-11-25, after reviewing the blocking defects one by one ("walk me through each
defect one by one"; #1 optimizeCardinality "yes I agree with the fix lets continue to the next";
#2 checkMassChargeBalance "ok I agree with the fix for mass balance function", the revised fix that
keeps []; #3 changeGeneAssociation "yes I agree with all three, next one"): "write the unblocked
tests sofar and write every test that we can sofar and push the tests".

## Final response

All 162 functions that the three fixes unblocked now have a final status, and everything is pushed.

- **Fixes** (`bf9c603f9`): optimizeCardinality (`case {1, 3}`), checkMassChargeBalance (keeps `[]`,
  printLevel -1/2 fixed, `p` -> `q`, help), changeGeneAssociation (fixes a-c). Each has a full test
  that failed on the old code; all callers' tests pass.
- **Tests:** 33 tested (+1,406 lines), 56 quarantined (each confirmed by me), 7 excluded. Two new
  tests were removed again by the late-edge rule (modelMultipleObjectives,
  debugInfeasibleEntropyFBA).
- **Ledger:** 259 tested, 373 quarantined, 195 excluded, 258 blocked, 0 waiting. Registry: 1,052
  defects.
- **Pushed:** 15 commits on `20261125-161147-blocker-fixes-two`, and the c13 coverage fix on
  `20261125-154813-c13-tests-coverage`.
- **Tool change:** the ledger's seed file accepts `name<TAB>!file`, a caller whose call form avoids
  the defect. Without it, `verifyModel`'s static link to `findStoichConsistentSubset` made three
  defects reach every function that solves an LP.

**Decisions for you:**
1. **removeRxns:** the default `ctrsRemoveMethod` `'exclusive'` removes every coupling constraint that
   involves a removed reaction, which the help and the code's comments call `'inclusive'`. Removing
   the constraint with its reaction may be what you want; is the help or the code wrong?
2. **The next blockers:** addMultipleReactions (89), addReaction (68), removeRxns (117),
   removeMetabolites (86), minCardinalityConservationRelaxationVector (34). Fixing all five frees 61
   functions.
3. **Gradings to check:** computeRescuedGenes (code: growth drop above 10%, help: 50%), findMustL/U
   (wrong number only in the `_Info` files), changeGeneAssociation (a rxnGeneMat it creates fills
   only the changed reaction).
4. **readSimPhenyCMPD** (#4 of the ranking) still waits for your decision.

## Diff summary

- src: optimizeCardinality.m, checkMassChargeBalance.m, changeGeneAssociation.m (approved fixes,
  NOTEs).
- test/verifiedTests: the three fixed functions' full tests; 89 new test files of waves 38-43
  (33 full tests kept, 56 in the quarantine layout); headers of testOptimizeCbModel.m and
  testPaint4Net_draw_by_rxn.m (one defect each); two wave-39 tests removed (late edge).
- test/known-defects.md regenerated (913 -> 1,052).
- specs/20261113-142115-test-backfill-tiers: tools/update_ledger.py ('!file' stop), inventory
  (ledger, quarantine-seeds, existing-defective, extra-edges, waves 38-43, results, coverage,
  quarantine.md, summary.md).
- specs/20261125-161147-blocker-fixes-two: spec, plan, tasks, review.md, coverage records, results,
  this receipt.

## Tests

- The three fixed functions' tests failed on the old code and pass on the new one (coverage:
  581/627 with dead code exempt, 108/112 with one defect input exempt, 43/43); callers' tests 13,
  12 and 27 passed, none failed.
- Every wave slice re-run together with coverage (run_coverage.sh): all passed, nothing left behind;
  update_ledger.py --verify-coverage 0 problems for every slice; --check 0 issues at the end.
- Every reach decision dry-run on a copy of the ledger before it was applied.

## Unresolved issues

- removeRxns ctrsRemoveMethod: help or code (maintainer).
- Gradings listed above (maintainer).
- The legacy testPaint4Net_draw_by_rxn.m leaves a figure open (not changed).
- ensureWBMfeasibility: four suspected defects need whole-body models to confirm (record notes).
- update_ledger.py --next-wave still does not re-issue rows of earlier waves (wave 43 formed by
  hand).
