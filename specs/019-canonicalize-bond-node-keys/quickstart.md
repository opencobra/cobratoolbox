# Quickstart: Validating the Bond-Node Key Canonicalization Fix

**Feature**: 019-canonicalize-bond-node-keys

This guide documents how to run the validation for this fix once implemented. It does not
contain implementation code — see [data-model.md](./data-model.md) for the fields touched and
[contracts/buildAtomAndBondTransitionMultigraph-bond-key.md](./contracts/buildAtomAndBondTransitionMultigraph-bond-key.md)
for the behavioral contract being verified.

## Prerequisites

- MATLAB R2024b+ with the COBRA Toolbox initialized (`initCobraToolbox`).
- A MILP solver available (`prepareTest('needsMILP', true)` — the existing test already
  declares this requirement and will skip cleanly if none is installed).
- The fixture RXN files for `ELAIDCPT1`, `HMR_2634`, `HMR_2919` committed under
  `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/` (sourced per research R6 —
  a one-time content addition during implementation, not fetched at test run time).

## Primary regression: existing workflow test

Run the existing multi-function workflow test, which this feature extends (no new test file,
per research R7):

```matlab
testConservedReactingMoieties
```

Expected outcome:

- All pre-existing assertions pass unchanged (the `r0317`/`ACONTm`/`r0426` fixture is
  unaffected by this fix — spec US2).
- New assertions added by this feature pass: `crn[c]` resolves to exactly 25 `dBTM.Nodes` rows
  for a submodel containing `ELAIDCPT1`, `HMR_2634`, `HMR_2919`; no
  `Inconsistent directed bond transition multigraph` warning is emitted for these reactions.

## Targeted manual check (during implementation, before the fixture-backed test exists)

For a fast inner-loop check while implementing, build `dBTM` directly for the three reactions
and inspect node counts:

```matlab
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'Recon3D_301.mat']);
rxnList = {'ELAIDCPT1'; 'HMR_2634'; 'HMR_2919'};
subModel = extractSubNetwork(model, rxnList);

options.directed = 0;
options.sanityChecks = 1;
[~, ~, ~, ~, ~, ~, ~, dBTM] = buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, options);

crnBondRows = nnz(ismember(dBTM.Nodes.mets, 'crn[c]'));
assert(crnBondRows == 25, 'Expected 25 bond-graph nodes for crn[c], got %d', crnBondRows);
```

Expected outcome: `crnBondRows == 25` (currently 31 before the fix), and no
`Inconsistent directed bond transition multigraph` warning printed during the call.

## Regression check: previously-fixed bug interactions (spec US2, test plan item 3)

Re-run the same workflow test's assertions (or a targeted sub-check) against reactions known to
be sensitive from prior debugging on this pipeline, to confirm no interaction between this fix
and previously-fixed bugs:

- Symmetric-molecule handling (CoA in `AKGDm`/`CSm`): confirm `NumReactingBonds` (or equivalent
  reacting-bond count from `identifyConservedReactingSubgraphs`) stays in the previously
  established normal range.
- `tyr`, `bileacid`, `pufa` subsystems (previously fixed for the `extractBondSubgraphs`
  component-merge bug): confirm no new failures.

## Downstream-consumer spot check (spec US2, FR-007)

Compare `identifyConservedReactingMoieties`/`identifyConservedReactingSubgraphs` output before
vs. after the fix on a model containing a previously-affected metabolite (`crn[c]` via
`ELAIDCPT1`/`HMR_2634`/`HMR_2919`). Per research R3, no output change beyond the corrected node
counts is expected for these consumers.

## Full network run (spec SC-002, test plan item 6)

Once fixtures/models permit, rerun the complete moiety-identification pipeline and confirm the
count of `Inconsistent directed bond transition multigraph` warnings decreases relative to the
pre-fix baseline; manually spot-check any remaining warnings to confirm they stem from a cause
unrelated to bond-node-key ordering. This is a broader validation step appropriate for
implementation completion, not required to pass before every inner-loop iteration.
