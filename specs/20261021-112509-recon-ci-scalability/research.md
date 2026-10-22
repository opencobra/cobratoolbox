# Research: CI scalability of COBRA functions

## Method

Unmodified toolbox at `35918b372` (origin/develop of the maintainer's fork), MATLAB R2025a,
Gurobi 11.0.3, 12 cores, 31 GB RAM. Model: `models/20261001/12_56/original_models/20261001T105846Z_Recon4_VMH.mat`
of the ReconXKG repository (30 665 mets x 38 841 rxns, 177 752 non-zeros). Each stage runs in
its own MATLAB process under `systemd-run --user --scope -p MemoryMax=24G -p MemorySwapMax=0`;
peak memory is `VmHWM` from `/proc/<pid>/status`; the calls mirror `extractFeasibleModel` and
`checkFeasibilityConditions` in the ReconXKG repository. The harness (`stageRun.m`,
`runChain.sh`, `profRun.m`) lives outside both repositories; its copy is kept in this folder
under `bench/` once the implementation phase starts.

## Baseline (before any change)

| Stage | Seconds | Peak GB | Notes |
|-------|--------:|--------:|-------|
| removeTrivialStoichiometry + checkDuplicateRxn 'S' + removeRxns | 8.4 | 1.03 | 38 841 -> 38 036 rxns |
| checkDuplicateRxn 'FR' | killed (rc 137) | > 24 | out of memory |
| findSExRxnInd + findFluxConsistentSubset (null_fastcc) | 366.1 | 1.27 | run without the 'FR' removal; 24 291 rxns after |
| findMassLeaksAndSiphons ('dc') | 361.4 | 1.20 | |
| findStoichConsistentSubset | 1607.3 | 1.39 | |
| checkFeasibilityConditions | 2765.3 | 1.43 | repeats the three solver stages above |

The chain without the 'FR' step totals about 5 100 s.

## Findings

1. **Memory.** `checkDuplicateRxn(model,'FR',...)` is the only COBRA call that exceeds 1.5 GB.
   Cause (source lines): `A * diag(1 ./ sumA1)` builds a dense nRxn x nRxn matrix
   (38 036^2 doubles = 11.6 GB, and the product is dense too); then
   `for n = 1:nRxn, bool = (ic == n)` scans a length-nRxn vector per reaction (O(nRxn^2)),
   again in the 'S' branch.
2. **Time.** Profile of `findMassLeaksAndSiphons` on the 13 931 x 24 291 model: 357 s in
   total, 346 s inside `gurobi` (45 calls); toolbox code accounts for about 1 s. The stage is
   solver-bound. Under Constitution IV the solver path and problems cannot change, so it is not
   a target. The profiles of the flux-consistency and stoichiometry stages are recorded below
   when complete.
3. **Repetition.** `checkFeasibilityConditions` (ReconXKG repository) re-runs
   `findStoichConsistentSubset`, `findMassLeaksAndSiphons` and `findFluxConsistentSubset` on the
   model that `extractFeasibleModel` has just processed. This is the largest single block of
   time (2765 s of about 5100 s) but it is outside the toolbox and outside this feature.

## Legacy test naming

`test/verifiedTests/reconstruction/testModelManipulation/testRemoveDuplicateRxn.m` calls
`checkDuplicateRxn` (methods 'FR' and 'S') but is named after a function that is not in `src/`.
It is left untouched; the III-Naming test for `checkDuplicateRxn` is the new
`testCheckDuplicateRxn.m`.

## External-solver configuration audit (Constitution IV)

No solver call changes in this feature. Gurobi options and defaults reached through
`solveCobraLP` are unchanged; the audit result is "not applicable: no solver-facing change".
