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
2. **Time.** Function-level profiles (MATLAB profiler, unmodified toolbox, same model):
   - `findMassLeaksAndSiphons`, 13 931 x 24 291: 357 s, of which 346 s in `gurobi`: solver-bound.
   - `findStoichConsistentSubset`: 1 471 s, of which 1 443 s in `gurobi`; the remaining visible
     toolbox cost is `removeFieldEntriesForType` (14 s, the rule renumbering loop): solver-bound.
   - `findFluxConsistentSubset` (38 036 -> 24 291 rxns): 505 s under the profiler, of which
     357 s in `removeUnusedGenes` -> `removeFieldEntriesForType` (36 million `num2str` calls,
     one per removed gene and rule), 146 s in `gurobi`. This is the only large non-solver cost
     found in the extraction path.
   Under Constitution IV the solver path and problems cannot change, so the solver-bound stages
   are not targets.
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

## After (this feature)

Same machine, model, solver and 24 GB cap; one stage per process (`bench/`).

| Stage | Before | After | Output |
|-------|--------|-------|--------|
| removeTrivialStoichiometry + checkDuplicateRxn 'S' | 8.4 s, 1.03 GB | 7.4 s, 1.04 GB | identical |
| checkDuplicateRxn 'FR' (30 664 x 38 036) | killed above 24 GB | 7.4 s, 1.05 GB (647 duplicates) | identical to the old code on all models where the old code can run |
| findSExRxnInd + findFluxConsistentSubset (input: 38 036 rxns) | 366.1 s, 1.27 GB | 138.5 s, 1.28 GB | model after the stage: `isequaln` true |
| same, within the full chain after the 'FR' step (input: 37 389 rxns) | n/a | 136.2 s, 1.28 GB | |

Smaller models (differential run, old and new in the same process): 'FR' on 20 237 reactions
8.4 s -> 1.8 s; on 24 291 reactions 13.2 s -> 2.0 s.

Downstream stages after the 'FR' step start from a model with 647 fewer reactions, so their
times are not comparable with the baseline (which skipped that step): leaks and siphons 262 s,
stoichiometric consistency 1 580 s, feasibility check 8 808 s (8 781 s in `gurobi`). The solver
time depends on the model it is given; the toolbox share is below 1 % in each of these stages.

## Decisions (T020, selection rule of plan.md)

| Function | Decision |
|----------|----------|
| checkDuplicateRxn | changed (rule a: out of memory) |
| removeFieldEntriesForType | changed (rule b: 70 % of a stage outside the solver) |
| removeRxns, removeMetabolites, removeTrivialStoichiometry | measured, not worth changing (below 1 s in every stage) |
| findSExRxnInd | measured, not worth changing (not visible in any profile; a per-column loop of 38 000 iterations) |
| findFluxConsistentSubset, fastcc, findMassLeaksAndSiphons, findStoichConsistentSubset, maxCardinalityConservationVector | measured, not worth changing (98 to 99 % of time in `gurobi`; the solver path may not change) |
| renumbering loop in removeFieldEntriesForType (`strrep` per remaining gene, 13 s) | measured, not worth changing (below 1 % of a solver-bound stage, and the sequential marker-based replacement is order-sensitive) |

## checkModelProperties (third CI test)

`test_model_consistency_comparison` calls `checkModelProperties` on Recon3D and the three Recon4
variants and was still running when the CI job hit its 24 h limit. Profile on Recon3D
(8 399 x 13 543): 734 s in total, 715 s in `gurobi` (2 346 calls); the toolbox's own cost is about
19 s (`checkMassChargeBalance` 7 s, `removeFieldEntriesForType` 5 s, now faster). The rank steps
(`getRankLUSOL`) take 0.3 s on the 30 665 x 38 841 model. The function is solver-bound and
unchanged. The profile of a full run on a Recon4 variant was not obtainable: no function of that
call had returned after ten minutes (the first solver stage).
