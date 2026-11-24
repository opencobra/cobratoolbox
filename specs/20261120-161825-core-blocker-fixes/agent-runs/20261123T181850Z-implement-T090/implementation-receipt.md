# Implementation receipt — 20261120-161825-core-blocker-fixes (T090: tests for the unblocked functions)

## Prompt

The maintainer, 2026-11-23, after the seven fixes: "Do all three" (push the fixes; write tests for
the functions the fixes unblocked; rank the wrong-result defects), then "ok continue with writing
the remaining tests. see you tommorrow". Task T090 (and T092, the records) of this feature, run with
the wave procedure W of feature 20261113-142115-test-backfill-tiers: helper agents write the tests
of each slice; the lead confirms every quarantine and its reach, dry-runs each apply on a copy of
the ledger, applies, re-runs the wave with coverage and commits. No push.

## Final response

All 258 functions the fixes unblocked now have a final status, and nothing has been pushed.
- **Tested:** 33 functions, covering 1,233 more lines. Among them are `deleteModelGenes`, `fastSNP`, `findMinNull`, `swiftcc`, `MTA_MIQP` and `consistentPotentials`.
- **Quarantined:** 39 functions with confirmed defects; I checked each one myself, by reading the code or reproducing it in MATLAB.
- **Excluded:** 3 functions.
- **Blocked again:** the rest, by new defects found along the way.
- **Checks:** no previously tested function lost its test, and every wave passes with coverage. There are 8 commits on the branch (7 wave commits and the records), and the registry now has 913 defects.

**Decisions for you:**
1. **Three new defects now block most of what's left, and each is a one-line fix:**

| Function | Functions blocked | The bug |
|---|---|---|
| `optimizeCardinality` | 247 | `case 1 \|\| 3` evaluates to `case true`, so an LP status 3 is thrown away |
| `checkMassChargeBalance` | 239 | it returns `[]` instead of a cell when every reaction is mass balanced |
| `changeGeneAssociation` | 128, via `addReaction` | new genes don't extend `proteins` or `geneNames` |

   Fixing them, as we fixed the seven, would unblock most of those functions.
2. **Gradings where I overruled or decided:**
   - **`readCobrapyJSONModel`: error.** Valid cobrapy files make it stop: Python writes non-ASCII IDs as `\u` escapes, IDs can contain braces, and a model can be empty. This also blocks `loadEcosystemScenario`.
   - **`preprocessingOmicsModel`: error.** It can't read an `.xlsx` written by MATLAB's own `writetable`.
   - **`LP3` and `LP7`: cosmetic.** Their warm-start `basis` input is switched off on purpose in the code, so only the help is stale.
3. **The wrong-result ranking is ready.** #1 is `optimizeCbModel`, which maximises a minimisation model when it is given a parameter structure.

Details are in [review.md](specs/20261120-161825-core-blocker-fixes/review.md), in the section "T090". Shall I push the 8 commits?

## Diff summary

Seven commits, 968b27c53 to 8f0c772f7, plus this receipt (feature records of
20261120-161825-core-blocker-fixes: review.md section "T090", tasks.md T090/T092,
wrong-result-ranking.md and pr-note.md came with the first wave commit).
- **Tests:** 36 new test files under test/verifiedTests (33 full tests, the rest in the
  quarantine layout), and the header of the legacy testMassChargeBalance.m (two defect entries
  and the Function under test line; assertions unchanged); two test files written by helpers and
  removed by the late-edge rule (testTestModelMassChargeBalance) before commit.
- **Back-fill records:** ledger.tsv, results/wave28-a to wave37-a, waves/wave28 to wave37 (wave34
  formed by hand), coverage/wave28-29 to wave36-37, quarantine-seeds.tsv (seeds or NONE for 13
  defects), existing-defective.tsv (checkMassChargeBalance), quarantine.md and summary.md,
  review/quarantined-full-tests/ (readCobrapyJSONModel, colorRxnsFromGenes).
- **Registry:** test/known-defects.md regenerated (821 -> 913 defects).
- **No change to src/.**

## Tests

- Every wave re-run together with coverage (run_coverage.sh): 14, 5, 6, 34, 6, 5 and 3 tests, all
  passing, nothing left behind; update_ledger.py --verify-coverage: 0 problems for every wave;
  --check: 0 issues after every apply.
- Each quarantine confirmed by the lead (confirmed_by in the records): by reading the code, and
  by MATLAB reproduction for moveRxn, preprocessingOmicsModel, checkMassChargeBalance (printLevel
  -1 and 2) and the column-c defect of addCOBRAConstraints.
- testMassChargeBalance re-run after its header change: passes.

## Unresolved issues

- The three blockers above (optimizeCardinality, checkMassChargeBalance, changeGeneAssociation) and
  the gradings listed in the final response await the maintainer.
- update_ledger.py --next-wave does not re-issue rows listed in an earlier wave file (worked around
  by hand for wave 34).
- The seven wave commits and the records commit are not pushed.
