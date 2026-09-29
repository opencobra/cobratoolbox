# Quickstart: validating size-proportional peeling in `extractBondSubgraphs`

**Prerequisites**:

- MATLAB R2024b at `/usr/local/MATLAB/R2024b`, and the COBRA Toolbox initialised (`initCobraToolbox(false)`).
- For the local fixtures: the atom-mapped corpus at `/media/JACK/repos/ctf/rxns/atomMapped_std`, `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/{vmh2_reconx_for_atom_mapping.mat,subsystemSubModels/subsystemSubModels.mat}`, and `~/repos/reconXmoieties/data/models/lowSymmetryRisk_2000rxn.mat`.

`FEATURE` below stands for `specs/20260928-100409-extract-bond-subgraphs-local-peeling`. Scripts are run headless with `matlab -batch "initCobraToolbox(false); run('<script>')"`.

## Step 0: MATLAB practice check (VII-F)

No MATLAB-conventions skill is registered. Before editing, apply the MathWorks performance guidance:

- preallocate;
- read graph properties (`G.Edges`, `G.Nodes`) once, outside loops;
- use logical masks and index vectors instead of `ismember` inside loops;
- use `sortrows` on numeric keys.

Then follow the openCOBRA style (VII-G).

## Step 1: Capture on unchanged source (before any `src/` edit)

Run `FEATURE/captureLocalPeelingFixtures.m`.

**Expected**:

- It refuses to run if `extractBondSubgraphs.m` differs from `b57404773`.
- It writes `test/.../data/bondSubgraphPeelingReference.mat` (synthetic fixture plus the R2a case).
- It writes the external captures `tyr`, `n332`, `n531`, `n1067`, `n1604` and `n1960` (`-inputs.mat` and `-golden.mat`), plus `n1960-endToEnd-golden.mat`.
- It prints the size of the 332 file. If the size is ≤ 1 MB, copy it into the test data file (clarification Q2).

This takes several hours, because the 1,960 end-to-end run alone takes about 1 hour. Environment variables choose a subset of fixtures, as in the previous feature's harness.

## Step 2: CI test passes on unchanged source

Run `runtests('testExtractBondSubgraphs')`, or run the script directly.

**Expected**: PASS. The new synthetic fixture, the ordering-contract assertions (contract rules 1–5), the R2a case, and the existing CI and fallback cases all hold for the pre-change code.

## Step 3: Harness self-check on unchanged source

Run `FEATURE/extractBondSubgraphsPeelingCheck.m`.

**Expected**:

- Every fixture reports new == baseline. This is trivially true here, and it validates the harness.
- The FR-009 assertion (`k` never advances, instrumented baseline) holds on every fixture.
- The baseline median-of-3 times are recorded in `extractBondSubgraphsPeelingResults.md`.

## Step 4: After increment (a), Story 1

Repeat steps 2 and 3.

**Expected**:

- All golden comparisons are identical (SC-001).
- Profiler counts of `rmedge` and `subgraph` on `BIG` are 0 (SC-003). `subgraph` on `ATG` still appears, one call per pass.

## Step 5: After increment (b), Story 2

Repeat steps 2 and 3.

**Expected**:

- Identical outputs.
- Total `subgraph` count from `extractBondSubgraphs` is 0.
- If anything differs, revert (b), record the deferral in the results file and the receipt, and continue with Story 1 only.

## Step 6: Full verification

Run `extractBondSubgraphsPeelingCheck.m` with the end-to-end mode enabled. Then run `testConservedReactingMoieties`, the rest of `test/verifiedTests/analysis/testReactingMoieties/`, `specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m` and `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`.

**Expected**:

- **SC-002**: on 1,960, `arm` and `moietyFormulae` are identical to `n1960-endToEnd-golden.mat`.
- **SC-004 gate**: on 1,960, new median ≤ 0.15 × baseline median.
- **SC-005, reported**: the time exponent across 332–1,960, and the output-size exponent (research R7).
- **SC-006**: all tests and checks pass.

## Step 7: Static review

Run `git diff b57404773 -- src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`.

**Expected**:

- Only the `NOTE` block, the `Author` line and the main path after line 73 change.
- `extractBondSubgraphsByComponentScan` and lines 54–73 are unchanged.
- No `fprintf`, `warning` or `error` text is changed.
