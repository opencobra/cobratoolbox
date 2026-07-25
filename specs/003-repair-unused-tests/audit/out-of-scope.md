# Out-of-scope outcomes and follow-ups

Tests that were investigated but NOT changed, with the reason (per FR-002: never weaken
an assertion; FR-003: no function-under-test change beyond a minimal test-bug fix).

## Attempted but reverted — assertions are solver-specific (can't fix without weakening)

- **testFVA** — the first, core FVA value assertion (`maxFluxT(i) <= maxFlux(i)+tol`, tol=1e-4)
  fails on gurobi: the stored `testFVAData.mat` reference does not match gurobi's result
  within tolerance. Fixing would require regenerating the reference or loosening the
  tolerance — both forbidden. Left failing (as before this feature).
- **testComputeMetFormulae** — fails at the cplex-specific `TimeLimit=0` behaviour
  assertion (expects the diary to contain "Critical failure: no feasible solution is
  found."), which gurobi does not reproduce. The requirement was reverted to its original
  (skips locally). Left as a clean skip.

## Attempted but reverted — requirement-broadening unvalidatable here

- **testMoomin** — dropping the cplex requirement leaves only mosek MILP, and **mosek is
  not a working MILP solver in this configuration** (`changeCobraSolver('mosek','MILP',0)`
  returns 0), so it still skips; and running moomin on mosek was never author-validated.
  Reverted.
- **testMgPipe** — broadening the solver to a generic LP is plausible (mgPipe uses generic
  FBA), but it still requires the Parallel Computing Toolbox (absent here), so it cannot be
  validated locally; broadening an unvalidatable test risks a failure elsewhere. Reverted.

## Genuinely dependency-bound — remain clean skips (dependency unobtainable here)

- CPLEX-only: testFastFVA, testGeneMCS, testMtFVA, testTuneParam, testfindMIIS,
  testSolveCobraLPCPLEX (mex/java/conflict-refiner/param-tuning — no generic path).
- NLP: testOptimizeCbModelNLP, testSolveCobraNLP (need an NLP backend — matlab/fmincon
  Optimization Toolbox or tomlab_snopt, none licensed).
- Other: testGenerateChemicalDatabase (needs commercial `cxcalc`), testCreatePanModels
  (needs Parallel Computing Toolbox).

## Function/layout bugs — separate feature (editing src/ is out of this feature's scope)

- **isCompatible.m** — `fopen`/`fgetl` throw when `CBTDIR` is unset (should guard `fid==-1`);
  also its parser reads only old grid-table rows while `compatMatrix.rst` is now a
  `list-table`, so it returns "untested" (2) for every solver. Test itself is correct.
- **TwoSidedBarrier class shadowing** — `papers/2023_BarrierRound/.../TwoSidedBarrier.m`
  (no `extraHessian` property) shadows the `src/` class; this is what errors
  testSampleCbModelRHMC where statistics_toolbox is present. De-dup/rename or path-exclude
  the stale `papers/` copies.
