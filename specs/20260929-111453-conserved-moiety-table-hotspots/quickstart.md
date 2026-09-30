# Quickstart: validating the table-hotspot removal in `identifyConservedReactingMoieties`

**Prerequisites**: the same as feature 20260928-100409's quickstart (MATLAB R2024b, `initCobraToolbox(false)`, the `atomMapped_std` corpus, the VMH2 model, and the `lowSymmetryRisk_2000rxn` selection). You also need the local file `…/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat`.

`FEATURE` below stands for `specs/20260929-111453-conserved-moiety-table-hotspots`. Scripts are run headless with `matlab -batch "initCobraToolbox(false); run('<absolute path>')"`. Use absolute paths, because `initCobraToolbox` may change the working directory.

## Step 0: MATLAB practice notes

Apply `specs/20260928-100409-extract-bond-subgraphs-local-peeling/matlab-practice-notes.md` (VII-F).

## Step 1: Capture on unchanged source

Run `FEATURE/captureHotspotFixtures.m`.

**Expected**:
- It refuses to run if `identifyConservedReactingMoieties.m` differs from `858feabc1`.
- It writes the CI golden file `test/.../data/conservedReactingMoietiesReference.mat` (size printed, target ≤ 1 MB).
- It writes the local `…/conservedMoietyHotspots/n1960-identifyInputs.mat`.

## Step 2: Tests on unchanged source

Run `runtests` on `testConservedReactingMoieties`.

**Expected**: PASS, which confirms the golden comparisons against the code that produced them.

## Step 3: Check-script self-check

Run `FEATURE/conservedMoietyHotspotsCheck.m`.

**Expected**:
- n1960 outputs are `isequaln` to the golden.
- The profiler shows `graph.subgraph` = 110,832 and `graph.subsasgn` = 271,845 from `identifyConservedReactingMoieties`.
- The baseline medians are recorded.

## Step 4: Helper

Run `runtests('testExtractPartitionSubgraphs')`.

**Expected**: PASS. Every part equals `subgraph`'s, including single-node parts, `digraph` inputs, parallel edges and edge masks.

## Step 5: Stories 1, 2 and 3, one at a time

After each story, run both tests and the check script with timing off.

**Expected**:
- Identical outputs.
- The story's profiler counts drop:
  - Story 1: `graph.subsasgn` no longer scales with edges;
  - Story 2: `graph.subgraph` falls by 79,832;
  - Story 3: `graph.subgraph` falls by a further 30,999.
- A patch is saved after each story.
- If anything differs, revert to the previous patch and record the reason (FR-007).

## Step 6: Full verification

1. Run the check script with timing on.
   **Expected**: SC-003 ratio ≤ 0.65 (the gate), and the SC-004 block timings are reported.
2. Run `reactingOptimisationReproducibilityCheck.m` with `CBT_RMO_NO_TIMING_GATE=1` (16 comparisons), then again with `CBT_RMO_SANITY=1`.
   **Expected**: all EQUAL.
3. Run all tests in `testReactingMoieties/`.
   **Expected**: PASS.

## Step 7: Static review

Run `git diff 858feabc1 -- src/`.

**Expected**:
- Changes only at the three sites and the `.. Author:` line, plus the new helper.
- No message text changes.
- No `evalc`, `nargin` or new `try/catch`.
