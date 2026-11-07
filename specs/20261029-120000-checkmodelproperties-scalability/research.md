# Research: checkModelProperties on Recon4-size models

Question: does `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` use
runtime or memory that the toolbox itself, and not the solver, can save on a Recon4-size model?
Machine: 12 cores, 31 GB, MATLAB R2025a, Gurobi 11.0.3, toolbox at upstream/develop `5e8170e12`.

## Correction of an earlier statement

An earlier note (CI scalability feature, 2026-10-28) said that the dense products
`diag(1./sumA2)*A` (line 275) and `A*diag(1./sumA1)` (line 301) would need about 11.6 GB on the
38 841-reaction models. That is wrong: both lines are inside `if checkTrivial`, and `checkTrivial` is
set to `0` at line 116 and never changed, so they never run. No argument reaches them.

## Measurements

1. The function's own matrix code, on the raw Recon4 VMH model (30 665 x 38 841, 177 752 non-zeros),
   one process, 14 GB cap (`bench/ownCode.m`):

   | Step | Time | Peak memory |
   |---|---|---|
   | build F and R | 0.0 s | 1.02 GB (model loading included) |
   | rank of [F R] (30 557) | 0.2 s | 1.15 GB |
   | rank of [F;R] (34 106) | 0.1 s | 1.22 GB |
   | rank of S (26 774) | 0.1 s | 1.25 GB |
   | row dependency solve, 108 dependent rows | 0.1 s | 1.39 GB |
   | column dependency solve, 4 735 dependent columns | 3.5 s | 1.73 GB |

2. The whole function on the stored Recon4 Source feasible model (`20261001T183729Z`, bench/cmpRun.m,
   14 GB cap, 3 h limit): not finished after 3 h (stopped by the limit); peak resident memory
   2.5 GB. The log shows the time went into `findMassLeaksAndSiphons` (about 30 min),
   `findStoichConsistentSubset`, `findFluxConsistentSubset` and then
   `findThermoConsistentFluxSubset` (`cycleFreeFlux`), all of which solve linear programmes.

## Decision

Measured, not worth changing. The code that belongs to this function takes seconds and under
2 GB on the largest model; all of the hours are inside solver calls, which Principle IV and FR-005
forbid changing. The deliverable is the characterization test
`test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m`
(219 of 340 runnable lines; the rest are constant-switched or unreachable, listed in its header).
The source function is unchanged, so the test needs no re-run after an enhancement.
