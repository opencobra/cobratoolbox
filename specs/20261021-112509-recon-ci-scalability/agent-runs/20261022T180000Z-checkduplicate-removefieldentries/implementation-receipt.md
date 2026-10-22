# Implementation receipt: CI scalability of COBRA functions

## Prompt

The maintainer asked to investigate and enhance, for runtime scalability and memory efficiency, the COBRA
Toolbox functions used by the ReconXKG CI (which timed out at 24 h on Recon4 models), using MATLAB and Gurobi
on the machine; to update the local clone; to write, for every function touched, a test covering all lines
(per the constitution) before changing it, then improve the function and re-run the test unchanged with
identical results; to measure memory and runtime before and after; and to commit and push to the
maintainer's fork (no pull request). Authority to run the Spec Kit workflow including the implementation
phase was given in the session on 2026-10-21 ("I give you authority to implement every change needed to the
cobra toolbox using spec kit workflow").

## Final response

Two COBRA functions were changed, test-first, with identical results. Pushed to your fork (no PR):
branch 20261021-112509-recon-ci-scalability on github.com/farid-zare/cobratoolbox.

Findings:
- Only two COBRA functions had a real non-solver problem. Everything else in the CI path is Gurobi-bound
  (98-99 % of time in gurobi: leaks/siphons, stoichiometric consistency, flux consistency, the feasibility
  re-check, and checkModelProperties from the third CI test: 715 of 734 s on Recon3D), so under the
  constitution's no-solver-change rule there is nothing to optimise there.
- checkDuplicateRxn, method FR: built a dense nRxn x nRxn matrix. On the 30 664 x 38 036 Recon4 VMH model it
  was killed above 24 GB; now 7.4 s and 1.05 GB peak. At 24 291 reactions: 13.2 s -> 2.0 s.
- removeFieldEntriesForType (called through removeRxns -> removeUnusedGenes): 36 million num2str calls,
  70 % of findFluxConsistentSubset. That stage: 366 s -> 138 s, same memory, output model identical.

Verification: each function got a test written first against the unmodified code (testCheckDuplicateRxn,
testRemoveFieldEntriesForType; all lines covered except documented exemptions); the same files, byte-identical,
pass after the change. Old and new implementations were compared on 9 004 randomised cases and on stored
Recon4 models: identical outputs.

Not done / caveats:
- The CI clones opencobra/cobratoolbox develop, so the CI only benefits after these changes reach it. I did not
  edit .gitlab-ci.yml (e.g. to clone your fork branch); say if you want that pushed to cidev.
- The 5.9 h extraction and the 17+ h third test are dominated by Gurobi solves. Without a solver change the
  run time will remain long; Gurobi thread/method settings would be the lever, outside this feature.
- Two defects found while writing tests are recorded in the test headers, not fixed: checkDuplicateRxn
  'rxnAbbr' method and 3+ member FR groups; removeFieldEntriesForType with grRules but no rules.
- The test header of testCheckDuplicateRxn names source line 161 for one exemption; it is line 162 after the
  change (the test file was deliberately not edited).

## Diff summary

- src/reconstruction/modelGeneration/checkDuplicateRxn.m (sparse scaling, abs(S), grouped scan, local helper)
- src/reconstruction/refinement/removeFieldEntriesForType.m (one-pass rule scan, local helper)
- test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m (new)
- test/verifiedTests/reconstruction/testRemoveFieldEntriesForType/testRemoveFieldEntriesForType.m (new)
- specs/20261021-112509-recon-ci-scalability/ (spec, plan, tasks, research, checklist, bench/, this receipt)

## Tests

- testCheckDuplicateRxn: passes on the unmodified function and, byte-identical (sha256 93e54f7d...), on the
  changed one; uncovered lines: documented exemptions only.
- testRemoveFieldEntriesForType: same (sha256 2620bd6b...); documented exemptions only.
- Existing tests run on the changed toolbox: testRemoveDuplicateRxn, testConstraintModifciation,
  testDynamicModelFieldModification, testModelManipulationOri, testGapFind, testGrowthExpMatch, testFASTCORE,
  testMinSpan pass; testEntropicFluxBalanceAnalysis (mosek missing) and testEFlux (bioinformatics toolbox
  missing) could not run in this environment.
- Differential comparisons old vs new: 7 804 checkDuplicateRxn cases and 5 stored models; 1 200
  removeFieldEntriesForType cases and the flux-consistency stage output: all identical.

## Unresolved issues

- test/testAll.m and the CI pipelines were not run; coverage was measured with the MATLAB profiler.
- The full CI job was not re-run; the benefit reaches CI only when the changes are in the toolbox it clones.
- Upstream opencobra/develop has 3 commits not merged into this branch.

## Other information

Spec Kit gate: spec, plan and tasks were written before any src edit; implementation was run on the
maintainer's explicit authorisation above. Benchmarks: unmodified toolbox 35918b372, MATLAB R2025a, Gurobi
11.0.3, 12 cores, 24 GB cap per stage (research.md).
