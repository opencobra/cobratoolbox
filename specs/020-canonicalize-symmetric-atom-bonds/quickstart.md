# Quickstart: Validating the Symmetry/Resonance-Equivalence Canonicalization Fix

**Feature**: 020-canonicalize-symmetric-atom-bonds

This guide documents how to run the validation for this fix once implemented. It does not contain
implementation code — see [data-model.md](./data-model.md) for the fields/structures touched and
[contracts/symmetry-equivalence-canonicalization.md](./contracts/symmetry-equivalence-canonicalization.md)
for the behavioral contract being verified.

## Prerequisites

- MATLAB R2024b+ with the COBRA Toolbox initialized (`initCobraToolbox`).
- `develop` includes feature 019 (`canonicalBondKey.m`, the FR-008 sanity check) — confirmed
  merged during this feature's planning (research R5). If working from a fresh checkout, confirm
  `src/analysis/topology/reactingMoieties/canonicalBondKey.m` exists before proceeding.
- A MILP solver available (`prepareTest('needsMILP', true)` — the existing test already declares
  this and skips cleanly if none is installed).
- New fixture RXN files for `PPACOAATREVm`, `HMR_3173`, `HYPGCOAHLm`, `DDCDATMTCOAHLx`,
  `FAOXC2442246x`, `PTCA3ZCOAHLx`, `VITEATENCOXCOAxr`, `DCA4Z7ZCOAr`, `STCOAATr` committed under
  `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/` (sourced per research R10 from
  `~/repos/reconXmoieties/chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/` — a
  one-time content addition during implementation, not fetched at test run time). `HMR_2634` is
  already vendored (feature 019).

## Primary regression: existing workflow test, extended

Run the existing multi-function workflow test, which this feature extends (no new file for the
workflow-level proof, per research R9):

```matlab
testConservedReactingMoieties
```

Expected outcome:

- All pre-existing assertions pass unchanged, including feature 019's `crn[c]`
  (`ELAIDCPT1`/`HMR_2634`/`HMR_2919`, 25 nodes) and the `r0317`/`ACONTm`/`r0426` fixture (spec
  US2, FR-006).
- New assertions added by this feature pass:
  - `coa[m]` (`PPACOAATREVm`/`HMR_3173`/`HYPGCOAHLm`) resolves to exactly 82 `dBTM.Nodes` rows.
  - `coa[x]` (`DDCDATMTCOAHLx`/`FAOXC2442246x`/`PTCA3ZCOAHLx`/`VITEATENCOXCOAxr`) resolves to
    exactly 82 rows.
  - `coa[r]` (`DCA4Z7ZCOAr`/`STCOAATr`) resolves to exactly 82 rows.
  - `crn[m]` (`HMR_2634`/`PPACOAATREVm`) resolves to exactly 25 rows.
  - No `does not match its true bond count` (FR-008) warning is emitted for any of the above.

## New unit-level test: the equivalence-class helper

```matlab
testIdentifyAtomEquivalenceClasses
```

Expected outcome (spec FR-001–005, FR-011; research R6):

- A known symmetric group (e.g. CoA's gem-dimethyl pair, from a vendored `coa[m]` molblock)
  detects as one Symmetry-Equivalence Class and canonicalizes to a single shared atom number.
- Two atoms sharing an element but not truly symmetric are NOT merged into the same class
  (collision-free check).
- A metabolite with multiple independent classes (e.g. `crn[m]`'s trimethylammonium and
  carboxylate groups) detects both correctly and simultaneously.
- A resonance bond-type disagreement between two representations resolves deterministically to
  the first-encountered file's bond type.
- A deliberately inconclusive/malformed input triggers the FR-011 warn-and-fall-back path: a
  visible warning naming the metabolite, a fallback to the identity (plain atom-number) canonical
  map, and no error raised.

## Targeted manual check (during implementation, before the fixture-backed tests exist)

For a fast inner-loop check while implementing, build `dBTM` directly for the `coa[m]` reactions
and inspect node counts:

```matlab
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'Recon3D_301.mat']);
rxnList = {'PPACOAATREVm'; 'HMR_3173'; 'HYPGCOAHLm'};
subModel = extractSubNetwork(model, rxnList);

options.directed = 0;
options.sanityChecks = 1;
[~, ~, ~, ~, ~, ~, ~, dBTM] = buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, options);

coaBondRows = nnz(ismember(dBTM.Nodes.mets, 'coa[m]'));
assert(coaBondRows == 82, 'Expected 82 bond-graph nodes for coa[m], got %d', coaBondRows);
```

Expected outcome: `coaBondRows == 82` (currently 86 before the fix), and no
`does not match its true bond count` warning printed during the call. Repeat analogously for
`crn[m]` (`HMR_2634`/`PPACOAATREVm`, expect 25) once its own fixtures are vendored.

## Downstream-consumer spot check (spec US2, FR-010, SC-006)

Compare `identifyConservedReactingMoieties`/`identifyConservedReactingSubgraphs` output before vs.
after the fix on a model containing a previously-affected metabolite (e.g. `coa[m]` via
`PPACOAATREVm`/`HMR_3173`/`HYPGCOAHLm`). Per research R6/the contract's downstream-consumer
section, no output change beyond the corrected node counts is expected for these consumers.

## Full-network confirmation (spec SC-005)

Re-run the sibling `reconXmoieties` repository's existing scan
(`~/repos/reconXmoieties/experiments/moietySizing/scan_symmetric_atoms.py`, research R8 — no
in-repo `cobratoolbox` equivalent is created by this feature) against the same
16,485-file corpus used for FR-009's pre-implementation scoping pass, and confirm the count of
mismatching metabolites attributable to this bug class has dropped to zero (or that any remaining
mismatches are manually confirmed to stem from a cause outside this feature's scope). This is a
broader validation step appropriate for implementation completion, not required to pass before
every inner-loop iteration.
