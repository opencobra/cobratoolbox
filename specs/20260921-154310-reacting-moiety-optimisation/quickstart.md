# Quickstart: validating the reacting-moiety optimisation

How to show that the feature works from start to finish. What each check compares is defined in
[contracts/function-interface.md](contracts/function-interface.md); snapshot fields are in
[data-model.md](data-model.md).

## Prerequisites

- MATLAB R2024b (`/usr/local/MATLAB/R2024b/bin/matlab`), COBRA Toolbox initialised (`initCobraToolbox`).
- A MILP solver (gurobi preferred; record which one). Use the **same** solver for capture and compare.
- For the non-CI check only: the corpus `/media/JACK/repos/ctf/rxns/atomMapped_std` and
  `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`
  (the same paths as feature 029).

## Step 0: capture BEFORE any source change (blocking)

Run both of these on unmodified code (`git diff develop -- src/` must be empty):

```matlab
% 1. unit-test reference: BIG/ATG from the CI fixture (conditional breakpoint) + synthetic fallback cases
run('specs/20260921-154310-reacting-moiety-optimisation/captureBondSubgraphReferences.m')
% -> test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat

% 2. golden snapshots + before timings + console text, all 7 fixtures, default and conserved-only
run('specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m')
% 3. sanityChecks = 1 pass (ci, tyr)
setenv('CBT_RMO_SANITY', '1'); setenv('CBT_RMO_FIXTURES', 'ci,tyr');
run('specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m')
```

Expected: every fixture reports `CAPTURE`, and snapshots appear under `snapshots/` (or `.external.txt`
pointers). The results file gets one row per fixture and mode. Run
`git status -- src/` to confirm that nothing under `src/` changed.

## Step 1: CI tests (after implementation)

```matlab
cd test/verifiedTests/analysis/testReactingMoieties
testExtractBondSubgraphs            % SC-003
testFindAndExtractMolecularGraphs   % SC-003
testConservedReactingMoieties       % SC-002 (file must be unmodified)
```

Expected: all three finish without an assertion failure. Then run `git diff develop -- test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`,
which must print nothing.

## Step 2: reproducibility and timing (after implementation)

Re-run the same three commands as in step 0. With the snapshots now present, the check runs in COMPARE
mode.

Expected, per fixture and mode:
- `arm`, `moietyFormulae`, `reacting`: all `EQUAL` (SC-001), compared on value **and** class, sparsity and
  size. Any `DIFF` or `CLASS DIFF` lists the differing field paths and is a failure.
- console text `EQUAL` (SC-006).
- default mode: before and after medians, and the speed-up ratio, reported. After is not greater than
  before on any of the seven subsystem fixtures (SC-004); `ci` timing is reported as `TIMING (not gated)`. If a shortfall is within timing noise, repeat the run before treating
  it as a failure.
- bileacid: the targeted-stage profiler sums, before and after, reported (FR-012; not a gate).
- the synthetic re-indexing section (`CBT_RMO_MODE=synthetic`): all ten cases `EQUAL`, covering the one-edge,
  zero-edge and fallback cases of stage 14a, stage 14b and STEP 3 (tasks T022).
- a `SOLVER MISMATCH` row means the environment changed, not that the code regressed. Re-run with the
  captured solver.

## Step 3: static scope review (SC-005, FR-009)

```bash
git diff develop --stat
git diff develop -- src/ | grep -E '^[-+].*(error|warning|fprintf|sanityChecks)'
```

Expected:
- Files changed: `extractBondSubgraphs.m`, `findAndExtractMolecularGraphs.m`, and
  `identifyConservedReactingMoieties.m` (stage-09 call lines, the STEP B4 loops, the stage 14a/14b and
  STEP 3 blocks only), plus the two new tests, the test reference `.mat`, and `specs/` artefacts.
- In `src/`, the grep shows only **added** lines that repeat an original statement inside a fallback
  branch. No original `error`, `warning`, `fprintf` or sanity check line is removed or edited.
- No `*Fast.m` file and no new option field in `src/`.

## Step 4 (optional, not a gate): pufa timing (FR-014, SC-007)

```matlab
setenv('CBT_RMO_FIXTURES', 'pufa'); setenv('CBT_RMO_TIMING_ONLY', '1');
run('specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m')
```

Record the outcome, including non-completion within a stated wall-clock limit, in the results file.
There is no pufa golden snapshot, because the unmodified run did not finish.
