# Quickstart: validating the build-function runtime reductions

All commands run from the repository root with MATLAB R2024b, headless. Paths and
fixtures: research R7. Entities: `data-model.md`. Contract: `contracts/public-contract.md`.

## Prerequisites

- `initCobraToolbox` works in `matlab -batch`.
- External data present (non-CI steps only):
  `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`
  and `/media/JACK/repos/ctf/rxns/atomMapped_std`.
- `git show 64efe1dc8:src/analysis/topology/reactingMoieties/addBondMappingsRXNFile.m`
  succeeds (baseline revision reachable).

## Step 1 — capture, BEFORE any source edit

```bash
matlab -batch "initCobraToolbox(false); cd specs/20260921-160105-build-function-runtime; buildRuntimeReproducibilityCheck('capture')"
```

Expected: `snapshots/<fixture>-golden-snapshot.mat` for the 7 fixtures, `ci`, `ci_missing` and `ci_unparsable`; the two
`data/*Expected.mat` files beside the tests; a "capture" section in
`reproducibility-results.md` with provenance, before timings, `readABRXNFile` calls
(bileacid: 718) and `energy` constructions (bileacid: one per iterated `bondMappings` row, 96,691).
The harness refuses to capture if any of the three source files differs from `64efe1dc8`.
Stop and ask if `snapshots/` exceeds 10 MB.

## Step 2 — new CI tests against the unmodified source

```bash
matlab -batch "initCobraToolbox(false); cd test/verifiedTests/analysis/testReactingMoieties; testCheckABRXNFiles; testAddBondMappingsRXNFile"
```

Expected: `testCheckABRXNFiles` passes. `testAddBondMappingsRXNFile` fails only at the
four-input call (the inputs do not exist yet), which shows the test exercises the new form.

## Step 3 — after the source edit: CI tests

```bash
matlab -batch "initCobraToolbox(false); cd test/verifiedTests/analysis/testReactingMoieties; testConservedReactingMoieties; testBuildAtomAndBondTransitionMultigraph; testCheckABRXNFiles; testAddBondMappingsRXNFile"
```

Expected: all four pass; `git diff 64efe1dc8 -- test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` is empty (SC-002).

## Step 4 — compare against the golden snapshots

```bash
matlab -batch "initCobraToolbox(false); cd specs/20260921-160105-build-function-runtime; buildRuntimeReproducibilityCheck('compare')"
```

Expected, per fixture, appended to `reproducibility-results.md`:

- outputs default and dense `isequaln`, class/sparsity equal; `checkABRXNFiles` fields and
  every `bondMappings` equal (SC-001) — zero mismatches;
- console rule of research R5 holds (SC-006), with differing stack frames listed;
- tyr's bond residual 3 and its printed report unchanged;
- alternating timing: modified median ≤ original median + noise (SC-004), repeated once on a
  shortfall;
- bileacid: `readABRXNFile` calls ≤ 431 (expected 430), `energy` constructions = energy rows
  (SC-005);
- `ci_missing`/`ci_unparsable`: each pass's own failure line appears as often as in the snapshot;
- peak memory: modified ≤ original + max(5% of original, 50 MB) (research R6).

A "corpus changed since capture" line means provenance moved; re-capture from the baseline
copies, do not treat it as a regression.

## Step 5 — static checks

```bash
git diff --stat 64efe1dc8 -- src test
git diff 64efe1dc8 -- src | grep -nE '^[-+].*(warning|error|fprintf|disp)\('
```

Expected: only the three `src/` files and the two new tests plus their `.mat` data change
(SC-007); every matched line is a moved `energy` statement or an unchanged message on a
re-indented line, none alters message text (FR-008).

## Step 6 (optional) — pufa

Capture `pufa` in step 1 (`buildRuntimeReproducibilityCheck('capture', {'pufa'})`, before
any source edit), then:

```bash
matlab -batch "initCobraToolbox(false); cd specs/20260921-160105-build-function-runtime; buildRuntimeReproducibilityCheck('compare', {'pufa'})"
```

Recorded, not gated (FR-014, SC-008).
