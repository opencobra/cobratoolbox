# Quickstart: validating sparse bond matrices

**Feature**: `20260921-125236-sparse-bond-matrices`

Order matters: step 1 MUST run before any edit to `src/`.

## Prerequisites

- MATLAB with the COBRA Toolbox on the path (`initCobraToolbox(false)`).
- `test/models/mat/Recon3D_301.mat` present (as for `testConservedReactingMoieties.m`).
- For the tyrosine fixture only: `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`
  and the corpus `/media/JACK/repos/ctf/rxns/old/atomMapped_standardised` (research R7).

## 1. Capture the golden snapshot (unmodified source)

```matlab
assert(system('git diff --quiet develop -- src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m') == 0, ...
    'Capture must run against the unmodified function.');
run('specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m')
```

Expected: `golden-snapshot.mat` created beside the script; console reports one
captured entry per fixture, the original classes of `M2BiE`/`M2BiW`/`BTi2R` (full
`double`), the before fill median for tyrosine, and the snapshot size (stop and ask if
> 10 MB). No results file is written in this mode.

## 2. Implement, then run the CI tests

```matlab
cd test/verifiedTests/analysis/testReactingMoieties
testBuildAtomAndBondTransitionMultigraph   % new, FR-015 (a)-(f)
testConservedReactingMoieties              % unmodified, SC-002
```

Expected: both complete without assertion failure. The new test's console shows the
atom and bond "Inconsistent ..." warnings twice (once per mode) for the deliberately
inconsistent fixture — that is the expected output of assertion (e), not a failure.

## 3. Compare against the snapshot

```matlab
run('specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m')
```

Expected: a new `## Run ...` section appended to `reproducibility-results.md` with
PASS for SC-001 (every fixture, both modes), SC-003, SC-004 (tyrosine storage ratio
≤ 10%, figures reported), SC-005 (after median ≤ before median, both reported), and
unchanged corpus provenance. Any FAIL or `reproducibilityCheck:CorpusChanged` error
stops the feature.

## 4. Static checks (SC-002, SC-006, SC-007)

```bash
git diff --stat develop -- src/ test/
git diff develop -- test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m   # must be empty
git diff develop -- src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m | grep -E '^[-+].*(error|warning|fprintf)\('   # must be empty
```

Expected: only `buildAtomAndBondTransitionMultigraph.m` changed under `src/`; only the
new test file added under `test/`; hunks limited to the options block, header, and the
matrix-construction block; header documents `denseBondMatrices`.

## 5. Optional: full-VMH demonstration (FR-014, SC-008)

Not a gate. If run, record outcome, peak memory and wall-clock in
`reproducibility-results.md` under a `## Full-VMH demonstration` heading.
