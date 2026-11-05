# Implementation receipt — 20261104-115314-test-coverage-100

## Prompt

"Next job: Use speckit. and for all the current tests in testAll in the COBRA Toolbox develop branch make their code coverage 100 with respect to exeptions in the constitution. Naturally we cannot make the code coverage 100% for all the tests, the exemptions are listed in constitution" (Follow-up prompts about an interrupted run are omitted: they described the local machine.)

Run by `/speckit-implement`; ten batches were delegated to helper agents, and each was verified from its measurement records before being committed.

## Final response

**The coverage work is finished and pushed: 497 of the 527 tests with a single function under test now meet the constitution's rule, up from 357.** Every line those 497 tests don't run is documented in the test header with a reason. The other 30 can't reach that here: 27 skip on this machine and 3 fail. `src` wasn't changed, and the branch `20261104-115314-test-coverage-100` is on your fork. I haven't opened a PR, and the new tests have not run on CI yet.

| | Before | After |
|---|---:|---:|
| Tests meeting the rule | 357 | 497 |
| Lines covered, across all 527 | 27,699 | 32,399 |
| Known defects in the registry | 110 | 252 |

The 497 cover 31,714 of 34,979 lines; the other 3,265 are exempted or tied to a recorded defect. Most exempted lines are branches for solvers missing here (CPLEX, TOMLAB, MOSEK) or code no input can reach. The final figures come from a fresh run of all 527 tests, with the last two tests measured just after it. The 78 tests with no single function under test stay out of scope, as the spec defines.

(A section about the local machine is removed from this copy of the response. This repository is public.)

## Tests that passed without testing anything
About a dozen tests were passing without really running their function. Examples are tests hardcoding `tomlab_cplex`, `testConstrainRxns` (its checks never ran under `testAll`) and `testAddKeyToKnownHosts` (it called a different function). All are fixed.

`testAddKeyToKnownHosts` also edited the known-hosts file of whoever ran it; it now runs in a temporary folder.

## Defects you should look at
Writing these tests added 142 defects to [test/known-defects.md](test/known-defects.md). As the constitution requires, I recorded them and did not fix them. These can give wrong results without any error:
- **`OptKnock`:** without `constrOpt`, the inner growth maximisation is lost, so it returns a wrong optimum.
- **`GDLS`:** with more than one design, every design reports the last knockout set's values.
- **`optimizeCbModel`:** `param.osenseStr` is ignored.
- **`cycleFreeFlux`:** lower bounds are only checked if an upper bound is violated.
- **`isReactionInSubSystem`:** reactions listed out of model order get each other's answers.
- **`verifyModel`:** `problematicFields` lists the valid fields.
- **`changeCobraSolver`:** a failed validation with `printLevel` above 0 leaves the failed solver selected.

## Still failing or skipped
- **`testGenerateFullRowRankFR`:** the local copy of a large model file is an HTML page from a failed download. Replacing that file should clear the error.
- **`testClassifySubgraphIsomorphism` and `testExtractBondSubgraphs`:** they compare MATLAB's exact error text, recorded on an earlier release, and R2025a words or identifies those errors differently. I left them alone because they deliberately check parity with the old code.
- **The 27 skipped tests:** they need CPLEX or MOSEK, a paid toolbox, an NLP or EP solver, or `cxcalc`.

## Check when you review
- **Stand-ins:** some branches are reached through stand-ins for `webread`, `lrs` or `solveCobraLP`, not the real thing. Each test header or the receipt says so, and those branches show the code path works, not that the outside tool does.
- **Reference values that pin wrong behaviour:** three existing ones remain, kept as they were: `printInRecon3Dmap`, `findSubsystemOfGenes` and the MOOMIN JSON output.
- **Header clean-up:** 52 exempted lines in 21 tests actually ran. That overstates the gap and hides nothing.
- **`test4HumanFctExt`:** 716 of its lines are exempt only because the `IECOri` path always errors; fixing that defect makes them reachable.
- **Unexplained failure:** `testOptForce` failed once at baseline. It passes now in its own folder, but I never confirmed the cause.

**Your next step:** open the PR so CI runs the tests. Do you want the defects above fixed next? That would be a new Spec Kit feature, and the `OptKnock` and `GDLS` fixes could change published results.

## Diff summary

- `test/verifiedTests`: 140 tests extended (about 12,000 lines added). All changed tests are listed in `coverage-inventory.md`. Headers gained Function under test, Tier, Coverage exemptions and Known defects blocks; `prepareTest` added where missing.
- `test/known-defects.md`: regenerated, 110 to 252 defects in 134 functions.
- Feature folder: `spec.md`, `plan.md`, `research.md` (R1 to R5), `tasks.md`, `coverage-inventory.md`, `test-map.json`, `coverage-runs/*.jsonl`, `tools/` (`measureCoverage.m`, `measureProfile.m`, `runCoverage.py`, `build_inventory.py`).
- `src/`: no changes.

## Tests

- Full re-measurement of all 527 mapped tests, Gurobi, MATLAB R2025a: no test killed; 497 COMPLETE, 27 SKIPPED, 3 FAILING. Two tests (testJoinModelsPairwiseFromList, testOptForce) were measured separately afterwards, and three functions that the coverage plugin cannot read are measured with the profiler (research R5).
- Not run on CI.

## Unresolved issues

- 3 failing tests and 27 skipped tests, reasons in `coverage-inventory.md`.
- 252 recorded defects, not fixed (III-Characterization).
- 52 exempted lines in 21 tests were executed: stale header entries that overstate the gap.
- Three existing reference values pin defective behaviour: printInRecon3Dmap, findSubsystemOfGenes, MOOMIN JSON output.
- The cause of testOptForce's single baseline failure was not confirmed.
- Reference values on the crafted model in testTest4HumanFctExt are first-run values (Tier 5).
- changeCobraSolver('tomlab_cplex') on a TOMLAB without a licence leaves TOMLAB's gurobi.m first on the path and breaks later gurobi calls in that session.
