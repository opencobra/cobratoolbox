---

description: "Task list for size-proportional peeling in extractBondSubgraphs"
---

# Tasks: Size-proportional peeling in `extractBondSubgraphs`

**Input**: Design documents from `specs/20260928-100409-extract-bond-subgraphs-local-peeling/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md (E1–E7), contracts/extractBondSubgraphs.md, quickstart.md (steps 0–7)

**Tests**: Required. This is a behaviour-preserving change to a MATLAB function (Constitution III). The narrowest CI test is the extended `testExtractBondSubgraphs.m`. The non-CI evidence is `extractBondSubgraphsPeelingCheck.m`. Every golden reference is captured from **unchanged** `src/` before the first source edit (T014).

**Organization**: Phase 2 captures the references and writes the tests. US1 (Story 1, bond-instance side) is the MVP. US2 (Story 2, ATG side) can be dropped (clarification Q1). US3 (the benchmark) does not depend on the source edits and supplies the SC-004 gate.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1, US2 or US3 (spec user stories 1–3)

## Path conventions

- `FEATURE` = `specs/20260928-100409-extract-bond-subgraphs-local-peeling`
- `SRC` = `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`
- `TESTDIR` = `test/verifiedTests/analysis/testReactingMoieties`
- `EXT` = `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling` (local only, never committed)
- `BASE` = commit `b57404773`, the feature's base, where `SRC` is the pre-change implementation

Run MATLAB headless: `/usr/local/MATLAB/R2024b/bin/matlab -batch "initCobraToolbox(false); <command>"`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: baseline copies and capture helpers, all under `FEATURE`. No `src/` or `test/` edit.

- [X] T001 Verify the starting state from the repository root:
  - `git merge-base --is-ancestor b57404773 HEAD` succeeds;
  - `git diff --quiet b57404773 -- src/analysis/topology/reactingMoieties/` succeeds.

  Stop and report if either fails. Create the local output directory `EXT` (`mkdir -p`).
- [X] T002 [P] Create `FEATURE/extractBondSubgraphsBaseline.m`:
  1. Run `git show b57404773:src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`.
  2. Change **only** line 1, to `function [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphsBaseline(BIG, ATG)`. Everything else stays verbatim, including the local function `extractBondSubgraphsByComponentScan` (research R9).
  3. Check with `diff <(git show b57404773:SRC | tail -n +2) <(tail -n +2 FEATURE/extractBondSubgraphsBaseline.m)`, which must print nothing.
- [X] T003 Create `FEATURE/extractBondSubgraphsBaselineAssertK.m`, the FR-009 instrument (research R2):
  1. Copy `FEATURE/extractBondSubgraphsBaseline.m`.
  2. Rename the function to `extractBondSubgraphsBaselineAssertK`.
  3. In the **main-path** loop only (first function; the line `k = k + 1; % Increment to next edge` near original line 199), replace that statement with `error('extractBondSubgraphsPeeling:kAdvanced', 'k advanced past the first remaining edge (k = %d).', k);`.
  4. Leave the identical line inside `extractBondSubgraphsByComponentScan` untouched.
  5. Confirm with `grep -n kAdvanced`: exactly one hit, inside the first function.
- [X] T004 [P] Create `FEATURE/captureExtractBondSubgraphsInputs.m`, modelled on `specs/20260921-154310-reacting-moiety-optimisation/captureStageNineInputs.m`:
  - signature `tf = captureExtractBondSubgraphsInputs(BIG, ATG)`;
  - saves `BIG` and `ATG` with `save(file, 'BIG', 'ATG', '-v7.3')` to the file named by the environment variable `CBT_EBS_CAPTURE_FILE`, raising an error with identifier `captureExtractBondSubgraphsInputs:noCaptureFile` if the variable is unset;
  - always returns `false`, so the conditional breakpoint never stops;
  - openCOBRA help header (`USAGE:`, `INPUTS:`, `OUTPUT:`, `NOTE:`) per VII-E.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: golden references from unchanged code, the extended CI test, and the equality/profiler harness. **No user-story task may start until T013 passes.**

- [X] T005 VII-F practice check (quickstart step 0):
  1. Confirm no MATLAB-conventions skill exists (`ls .claude/skills`).
  2. Write a short summary of the MathWorks performance rules that apply to this change: preallocation; reading `G.Edges`/`G.Nodes` once outside loops, because each property read copies the whole table; logical masks instead of `ismember` in loops; stable numeric `sortrows`; no Python-style refactors.
  3. Note in it that a project MATLAB-practice skill is proposed.

  Save it as `FEATURE/matlab-practice-notes.md`, to be cited in the implementation receipt.
- [X] T006 Create `FEATURE/captureLocalPeelingFixtures.m`, **part A: CI fixtures**. The script starts with the guard `git diff --quiet b57404773 -- src/analysis/topology/reactingMoieties/extractBondSubgraphs.m` (via `system`) and errors with `captureLocalPeelingFixtures:srcModified` if the file differs. Part A builds, deterministically:
  - **(A1) Hand-built main-path case** `handBuilt`. It uses an undirected `graph` ATG with `Nodes` variables `AtomIndex` (a non-identity permutation of 1..n) and `Component` (set to `conncomp(ATG)'`), and 5–7 components of 1–5 atoms, including one single-atom component. It uses a `digraph` BIG with `Edges` variables `EndNodes`, `EdgeIndex` (unique, not 1..m), `BondIndex` and `Weight`, and one more BIG node than ATG atoms. It must contain:
    - two parallel BIG edges with the same end atoms and the same `BondIndex`;
    - a `BondIndex` value repeated on edges with different end atoms;
    - an edge whose two end atoms share a component (`component1 == component2`);
    - a component A that pairs with B on the first pass and with C on a later pass;
    - an edge with one end in the first pass's pair and the other in a third component.

    Add a comment on each edge saying which spec edge case it exercises.
  - **(A2) Randomised cases** `randomCases(1:20)`: port the local function `makeSynthetic(seed)` verbatim from `FEATURE/research-prototype/runPrototypeEquivalence.m` (research R6) for seeds 1–20, with `rng(seed)` before each. Seeds 7 and 14 produce `digraph` ATGs.
  - **(A3) Labelling-mismatch case** `labelMismatch` (research R2a): copy A1 and swap `Component` labels 1 and 2 in `ATG.Nodes`, so it still passes the lookup-array preconditions but `Component ~= conncomp(ATG)'`. Keep only the BIG bonds that join components 1 and 2 or avoid both. With other bonds, the pre-change loop does not terminate (research R2a, found in T008).
  - **(A4) Error-parity case** `atomBeyondBIG` (research R4): copy A1 and pick an ATG atom that is **not** an end node of any BIG edge but lies in a component that has BIG edges. Set its `AtomIndex` to `numnodes(BIG) + 2`. No BIG edge references the changed atom, so `compOfAtom(endNodes)` stays positive and the case still passes the lookup-array preconditions. Assert that before saving. Record the pre-change outcome, which is expected to be an error raised by `subgraph`, not by the fallback.

  For every case, run `extractBondSubgraphsBaseline` with three outputs inside `try/catch ME`. Record either `outcome = 'ok'` with `bondSubgraphs`, `BMG` and `bmgEdgeIndex`, or `outcome = 'error'` with `ME.identifier` and `ME.message`, in the same struct layout as `fallbackCases` in `TESTDIR/data/bondSubgraphReference.mat`. For every A1/A2 case, also run `extractBondSubgraphsBaselineAssertK` and assert it does not raise `kAdvanced`. Save to `TESTDIR/data/bondSubgraphPeelingReference.mat` with `-v7`.
- [X] T007 Add **part B: local captures** to `FEATURE/captureLocalPeelingFixtures.m`, selected by the environment variable `CBT_EBS_FIXTURES` (comma list from `synthetic,tyr,n332,n531,n1067,n1604,n1960`; default all). For each real fixture:
  1. **Build the model.**
     - `tyr`: the `tyr` sub-model from `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`, loaded exactly as in `specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m`.
     - Nested subsets: follow sections 2, 2b and 7 of `~/repos/reconXmoieties/experiments/moietySizing/scripts/exp_measure_conserved_moiety_runtime_2000rxn.mlx`. Load the model, strip the `R_`/`M_` prefixes with anchored `regexprep`, keep the reactions that have an RXN file in `/media/JACK/repos/ctf/rxns/atomMapped_std`, extract the `lowSymmetryRisk_2000rxn.mat` selection, remove the RXN files that `scanRXNFileIssues` reports as blocked, take the first subsystem of each reaction, then `rng(1)`, shuffle the unique subsystems, and take whole subsystems until the cumulative count reaches 250, 500, 1000 or 1500. `n1960` is the full `runModel`.
     - Assert that the reaction counts are 332, 531, 1,067, 1,604 and 1,960, and warn and record them if they differ.
  2. **Build the graphs**: run `buildAtomAndBondTransitionMultigraph(model, atomMappedDir, struct('directed', 0, 'sanityChecks', 0))`.
  3. **Capture the inputs.**
     1. Find the line of `identifyConservedReactingMoieties.m` whose trimmed text equals `[bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG);`, and assert there is exactly one.
     2. Set `CBT_EBS_CAPTURE_FILE` to `EXT/<name>-inputs.mat`, and set `dbstop in identifyConservedReactingMoieties at <line> if captureExtractBondSubgraphsInputs(BIG, ATG)`.
     3. Run `identifyConservedReactingMoieties(model, BG, dATM, struct('directed', 0, 'sanityChecks', 0, 'conservedMoietiesOnly', true))`.
     4. Clear the breakpoint and environment variable in an `onCleanup`.
     5. For `n1960` only, save `arm`, `moietyFormulae` and every other returned output to `EXT/n1960-endToEnd-golden.mat`, with the git commit and the elapsed time.
  4. **Produce the golden outputs**: load the inputs, run `extractBondSubgraphsBaseline` (three outputs), and save to `EXT/<name>-golden.mat` their SHA-256 fingerprints (`FEATURE/fingerprintBondSubgraphOutputs.m`), the output count and output size, with provenance (commit, MATLAB version, reaction count). Full outputs are not stored, because they would take many GB (research R8, changed in T009). The pass count is recorded later, from the baseline `rmedge` count in T013. Also run `extractBondSubgraphsBaselineAssertK` on the inputs, and record whether FR-009 held.
  5. **Check the 332 size**: for `n332`, save inputs and golden outputs together with `-v7` to a temporary file and print its size in bytes.

  Every `catch` must report `ME.message` plus `ME.stack(1).file` and `ME.stack(1).line` (VII-C). Warnings stay visible (VII-B).
- [X] T008 Run part A: `CBT_EBS_FIXTURES=synthetic`. Confirm that `TESTDIR/data/bondSubgraphPeelingReference.mat` exists, that `handBuilt`, all 20 random cases and `labelMismatch` have `outcome = 'ok'`, that the `atomBeyondBIG` outcome is recorded (expected: `error`), and that the `kAdvanced` assertion held for A1 and A2. For `atomBeyondBIG`, confirm that the recorded error comes from `subgraph` (check the saved identifier and message), not from `extractBondSubgraphsByComponentScan`.
- [X] T009 Run part B for `tyr,n332,n531,n1067,n1604,n1960`. This takes hours; run it in the background with `diary` to `EXT/capture.log`. Confirm all 6 `-inputs.mat` and `-golden.mat` files plus `n1960-endToEnd-golden.mat` exist, and that FR-009 held on every fixture. If FR-009 failed anywhere, **stop**: research R2 is disproved, and the plan needs revisiting.
- [X] T010 Apply clarification Q2. If the `n332` `-v7` file from T007 step 5 is ≤ 1,048,576 bytes, add `n332Inputs`/`n332Expected` to `TESTDIR/data/bondSubgraphPeelingReference.mat`. Otherwise do not commit it. Record the size and decision in `FEATURE/extractBondSubgraphsPeelingResults.md`, creating it with a heading and a provenance line.
- [X] T011 Extend `TESTDIR/testExtractBondSubgraphs.m`. Extend the existing file; do not create a new test file (III-Naming). Update the `Purpose:` comment to name this feature.
  1. Load `data/bondSubgraphPeelingReference.mat`.
  2. For `handBuilt`, each `randomCases(k)`, `labelMismatch` and `n332` (if present), assert that the two-output and three-output forms equal the reference, using the existing `areGraphCellsEqual`, plus `isequal` on `bmgEdgeIndex`. Messages name the case.
  3. For `atomBeyondBIG`, assert the same error identifier and message, following the existing `fallbackCases` error pattern.
  4. Add a local function `checkSubgraphOrderingContract()` that builds, with a fixed `rng(1)`, a 12-node multigraph with parallel edges, both as `digraph` and as `graph`, and `ids = [7 3 11 1 9]'`. It asserts rules 1–5 of `FEATURE/contracts/extractBondSubgraphs.md` ("Ordering contract"), and each failure message names the rule number.

  Keep the existing assertions unchanged. `prepareTest()` needs no requirements.
- [X] T012 Create `FEATURE/extractBondSubgraphsPeelingCheck.m`, the **core** of the non-CI harness (Story 3 adds timing in T025). Behaviour:
  1. Add `FEATURE` to the path.
  2. For each fixture in `CBT_EBS_FIXTURES` (default `tyr,n332,n531,n1067,n1604,n1960`), load `EXT/<name>-inputs.mat` and `-golden.mat`.
  3. Run `extractBondSubgraphs` (the current `SRC`) with three outputs.
  4. Compare with the golden fingerprints. If any fingerprint differs, run `extractBondSubgraphsBaseline` on the same inputs and decide by FR-002: same cell sizes; per element, same `class`, `isequaln` on `Nodes` and `Edges`; `isequaln` on `bmgEdgeIndex`. On failure, report the first differing index and whether `Nodes` or `Edges` differed.
  5. Run once under `profile on`. From `profile('info').FunctionTable`, take **every** row whose `FileName` is `SRC` (the main function and its local functions, which the profiler lists as separate rows), and sum the `NumCalls` of their `Children` whose names contain `rmedge` or `subgraph`, reported separately (research R10). Report the pass count as well: for the baseline, this is its `rmedge` call count (one per pass), taken from the T013 profiler run and stored per fixture in the results file.
  6. Append one table row per fixture to `FEATURE/extractBondSubgraphsPeelingResults.md`, with the UTC timestamp, commit, fixture, reaction count, equality result, `rmedge` count, `subgraph` count and notes.
  7. If any comparison fails, end by raising `extractBondSubgraphsPeelingCheck:mismatch`.
- [X] T013 Run the checks on the **unchanged** `SRC` (quickstart steps 2 and 3):
  1. Run `runtests('testExtractBondSubgraphs')`. It must PASS, which validates the references and the ordering contract.
  2. Run `extractBondSubgraphsPeelingCheck`. Every fixture must be identical, and the counts must show nonzero `rmedge`/`subgraph` calls; this validates the harness.

  Record the results in `FEATURE/extractBondSubgraphsPeelingResults.md`.

**Checkpoint**: references frozen and harness validated. From here on, `SRC` may be edited.

---

## Phase 3: User Story 1 — Peel bond-instance edges without rebuilding the full bond graph (Priority: P1) 🎯 MVP

**Goal**: remove `subgraph(BIGCopy, …)`, `ismember(edgeIdx, bondIdProcessed)` and `rmedge(BIGCopy, …)` from the main path (FR-003–FR-005, FR-009). `combinedSubgraph = subgraph(ATG, nodesInBothComponents)` is still used.

**Independent Test**: T018 and T019. The CI test passes; the golden comparison is identical on `tyr`, `n332` and `n1960`; the profiler shows 0 `rmedge` calls, and `subgraph` calls equal to the number of passes (ATG only).

### Implementation for User Story 1

- [X] T014 [US1] (FR-014) In `SRC`, move the current main-path body (from `% Initialize cell arrays to store all combined subgraphs`, line 79, to the end of the outer `while`, line 202) **verbatim** into a new local function placed **between** the main function and `extractBondSubgraphsByComponentScan`:

  ```matlab
  function [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphsByEdgeScan(BIG, ATG, compOfAtom, nodesByComp, endNodes, edgeIdx)
  ```

  Give it a short comment header in the style of the existing fallback's comment: it is the previous main-path loop, kept for inputs whose `ATG.Nodes.Component` is not the `conncomp(ATG)` labelling (research R2a). In the main function, just after `nodesByComp` (line 76), add:

  ```matlab
  if ~isequal(componentATG(:), atoms2component(:))
      [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphsByEdgeScan(BIG, ATG, compOfAtom, nodesByComp, endNodes, edgeIdx);
      return
  end
  ```

  Lines 1–76 other than the `NOTE` block, and `extractBondSubgraphsByComponentScan`, must not change (FR-008).
- [X] T015 [US1] In `SRC`, add the local function `[edgesByBucket, bucketId] = buildPairEdgeIndex(compLo, compHi, nComps)` (research R3, data-model E3). It groups rows `1:numel(compLo)` by the pair `(compLo, compHi)` using `unique([compLo compHi], 'rows')`, `accumarray(..., @(v) {sort(v)})` and `sparse(lo, hi, bucket, nComps, nComps)`. Handle zero rows by returning `{}` and `sparse(nComps, nComps)`. Place it after `extractBondSubgraphsByEdgeScan`. Add a comment header with inputs and outputs.
- [X] T016 [US1] In `SRC`, after the R2a guard, write the new main-path loop for Story 1 (plan "Design" steps 3–6; data-model E3, E5, E6, E7):
  1. **One-time reads**: `BIGEdges = BIG.Edges; BIGNodes = BIG.Nodes; nBIGNodes = numnodes(BIG); nEdges = size(endNodes, 1);`.
  2. **Pair index**: `edgeComp = compOfAtom(endNodes)` reshaped to nEdges×2; `[edgesByBucket, bucketId] = buildPairEdgeIndex(min(edgeComp, [], 2), max(edgeComp, [], 2), nComps)`.
  3. **State**: `remaining = true(nEdges, 1)`, `localPos = zeros(max(max(atomIndexATG), nBIGNodes), 1)`, `first = 1`, and the empty output cells and `subgraphIndex = 1` as before.
  4. **Loop** `while first <= nEdges`:
     1. Set `component1`/`component2` from `endNodes(first, :)`. Keep the existing `nodesInBothComponents` block **with its comment** (old lines 103–118), and `combinedSubgraph = subgraph(ATG, nodesInBothComponents);`.
     2. Set `pairAtoms = atomIndexATG(nodesInBothComponents)`, then call the error-parity step (T017).
     3. Collect the bucket ids `bucketId(lo, lo)`, `bucketId(hi, hi)` and `bucketId(lo, hi)`, using `full`, keeping those > 0, `unique`. Set `rows = vertcat(edgesByBucket{buckets})` (ensure a column even when empty), then `rows = rows(remaining(rows))`.
     4. Set `localPos(pairAtoms) = 1:numel(pairAtoms)`, then `localEnds = reshape(localPos(endNodes(rows, :)), [], 2)`, then `localPos(pairAtoms) = 0`.
     5. Run `[~, order] = sortrows([localEnds rows])`, then `rows = rows(order)`, `GEdges = BIGEdges(rows, :)`, `GEdges.EndNodes = localEnds(order, :)` and `GNodes = BIGNodes(pairAtoms, :)`.
     6. Copy the layer-peeling block and the storing loop **verbatim** from old lines 129–179, deleting only the `bondIdProcessed = [bondIdProcessed; layerEdgeIdx];` line.
     7. Set `remaining(rows) = false;` then `while first <= nEdges && ~remaining(first), first = first + 1; end`.
  5. **Removed from the main function**: `BIGCopy`, `bondIdProcessed`, `idsToRemove`, `rmedge`, `k`, `numBonds`, the outer `while`, and the `endNodes`/`edgeIdx` row deletions.

  Keep the comment density and naming of the surrounding code.
- [X] T017 [US1] In `SRC`, add the error-parity step (research R4) inside the loop, right after `pairAtoms` is set:

  ```matlab
  if any(pairAtoms > nBIGNodes)
      subgraph(BIG, pairAtoms);
  end
  ```

  Add a comment saying that this raises the error the previous `subgraph(BIGCopy, ...)` call raised for such inputs, and that it is never reached on valid inputs.
- [X] T018 [US1] Run `runtests('testExtractBondSubgraphs')` and `runtests('testConservedReactingMoieties')`. Both must PASS. On failure, fix `SRC`; never edit a reference.
- [X] T019 [US1] Run `extractBondSubgraphsPeelingCheck` on all six fixtures. Every fixture must be identical (SC-001), `rmedge` must be 0, and `subgraph` must equal the pass count (ATG side only). Record the results in `FEATURE/extractBondSubgraphsPeelingResults.md` under the heading "Increment (a) — Story 1". Stop on any mismatch. Then save increment (a) with `git diff b57404773 -- SRC > FEATURE/increment-a-story1.patch`. This is the revert point for T021. Don't commit unless the user asks.

**Checkpoint**: Story 1 is complete, and it is shippable alone if US2 is dropped.

---

## Phase 4: User Story 2 — Build each combined atom subgraph from its own components only (Priority: P2)

**Goal**: replace `subgraph(ATG, nodesInBothComponents)` with a pair-sized construction (FR-006; research R5; data-model E4). This story can be dropped (clarification Q1).

**Independent Test**: T021. Outputs are identical on every fixture, and the total `subgraph` count from `extractBondSubgraphs` is 0 (SC-003).

### Implementation for User Story 2

- [X] T020 [US2] In `SRC`, before the loop:
  1. Read `ATGNodes = ATG.Nodes; ATGEdges = ATG.Edges; atgEnds = ATGEdges.EndNodes; isDirectedATG = isa(ATG, 'digraph');`.
  2. Build `[atgEdgesByBucket, atgBucketId] = buildPairEdgeIndex(min(c,[],2), max(c,[],2), nComps)`, where `c = reshape(atoms2component(atgEnds), [], 2)`. Guard the case of an ATG with no edges.
  3. Create `localPosATG = zeros(numel(atoms2component), 1)`.

  Inside the loop, replace `combinedSubgraph = subgraph(ATG, nodesInBothComponents);` with:
  1. Set `localPosATG(nodesInBothComponents) = 1:numel(nodesInBothComponents)`.
  2. Gather `atgRows` from buckets `(lo,lo)`, `(hi,hi)` and `(lo,hi)` of `atgBucketId`, keeping them a column when empty.
  3. Set `ends = reshape(localPosATG(atgEnds(atgRows, :)), [], 2)`. If `~isDirectedATG`, normalise to `[min(ends,[],2), max(ends,[],2)]`.
  4. Run `[~, order] = sortrows([ends atgRows])`, then `cEdges = ATGEdges(atgRows(order), :)` and `cEdges.EndNodes = ends(order, :)`.
  5. Reset `localPosATG(nodesInBothComponents) = 0`.
  6. Build `combinedSubgraph` as `digraph(cEdges, ATGNodes(nodesInBothComponents, :))` if `isDirectedATG`, else `graph(...)`.

  Comment each step, citing the ordering rules that make it identical to `subgraph`.
- [X] T021 [US2] Repeat T018 and T019, and record the results under the heading "Increment (b) — Story 2".

  **Expected**: identical on all fixtures and all CI cases, including the `digraph`-ATG random seeds 7 and 14; total `subgraph` = 0.

  **If anything differs and can't be fixed so that FR-002 holds**: revert T020 by restoring increment (a) exactly: `git checkout b57404773 -- SRC && git apply FEATURE/increment-a-story1.patch`. Then re-run T018 and T019 to confirm the restored state. Record "Story 2 deferred: <reason>" in the results file and in the implementation receipt, and continue with Phase 5 on Story 1 only.

**Checkpoint**: Stories 1 and 2 are complete, or Story 2 is deferred with its reason recorded.

---

## Phase 5: User Story 3 — Benchmark and scaling verification (Priority: P3)

**Goal**: back-to-back, median-of-3 timing of the new and baseline code on every fixture, the SC-004 gate, and the SC-005 fits with output-size normalisation (research R7).

**Independent Test**: T025 reports per-fixture medians for both implementations, the equality result, the FR-009 status and the fitted exponents.

### Implementation for User Story 3

- [X] T022 [P] [US3] Extend `FEATURE/extractBondSubgraphsPeelingCheck.m` with a timing section, enabled unless `CBT_EBS_NO_TIMING=1`:
  1. For each fixture, alternate runs: baseline (`extractBondSubgraphsBaseline`), new (`extractBondSubgraphs`), for `nRuns = 3` (override with `CBT_EBS_TIMING_RUNS`), timing each with `tic`/`toc` outside the profiler.
  2. Record the median for each.
  3. Compute `outputSize = sum(numnodes + numedges)` over `bondSubgraphs` and `BMG`.
  4. Append the columns `baseline median s`, `new median s`, `ratio`, `outputSize` and `passes` to the results table.

  This task edits only the harness, so it can run in parallel with Phase 3/4 edits to `SRC`.
- [X] T023 [P] [US3] Extend `FEATURE/extractBondSubgraphsPeelingCheck.m` with a scaling section over the fixtures `n332`–`n1960` that are present:
  1. Fit `polyfit(log(nRxns), log(t), 1)` for baseline time, new time and `outputSize`.
  2. Evaluate SC-005 as follows. If the new-time exponent is ≤ 1.3, it passes. Otherwise, if the output-size exponent is > 1.1, report the exponent of new time / `outputSize`, and mark it "scope-explained" if that exponent is ≤ 0.3. Otherwise mark it "above target (reported, not a gate)".
  3. Evaluate SC-004 on `n1960`: `new median ≤ 0.15 × baseline median`, reported as PASS or FAIL.
  4. Write both to the results file. SC-005 never raises an error; SC-004 FAIL raises `extractBondSubgraphsPeelingCheck:sc004` at the end, after everything is written.
- [X] T024 [US3] Add the FR-009 status to the harness: for each fixture, record `k-always-first = yes/no` in the table. *As implemented*: the value is the one recorded when `captureLocalPeelingFixtures.m` ran `extractBondSubgraphsBaselineAssertK` on the same inputs (`golden.kAlwaysFirst`). The pre-change copy is fixed, so re-running it would give the same answer at about 20 min more per n1960 run. This task edits `FEATURE/extractBondSubgraphsPeelingCheck.m`, so it runs after T022 and T023.
- [X] T025 [US3] Run the full harness (quickstart step 6, timing part) on all six fixtures against the final `SRC` (after T019, or after T021 if Story 2 shipped). Record the SC-004 gate result and the SC-005 exponents in `FEATURE/extractBondSubgraphsPeelingResults.md`.
- [X] T026 [US3] *(Not needed: T025 SC-004 PASS, ratio 0.100.)* **Only if T025 reports SC-004 FAIL**, apply the contingency in research R7, and only changes that FR-007 allows. For example, index the pair's `GEdges` columns into plain arrays once per pass, and build each layer's `EdgeTable` from a row index of the pair table instead of deleting rows from `GEdges` repeatedly. The `unique(..., 'first')` semantics on the current remaining order must be exactly preserved. After each change, re-run T018, T019 (or T021) and T025. If SC-004 still fails after the contingency, stop and report the measured ratio to the user. Do not take output-changing shortcuts.

**Checkpoint**: all user stories are complete and the SC-004 gate is decided.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T027 In `SRC`, rewrite the `NOTE:` block (current lines 24–32) in the same style (FR-010). It should say that:
  - the bond instance graph is peeled component pair by component pair, then layer by layer;
  - a component-pair index of bond-instance edges (and of atom-transition edges, if Story 2 shipped) and a per-edge "remaining" flag are built once, so each pair costs time proportional to its own size, instead of rebuilding or scanning the whole graphs;
  - outputs are identical to the original implementation;
  - the original algorithm is used for inputs outside the lookup-array preconditions (keep the existing list);
  - the previous peeling loop is used when `ATG.Nodes.Component` is not the `conncomp(ATG)` labelling.

  Add a `.. Author:` line crediting this feature (VII-E). Do not change `USAGE:`, `INPUTS:`, `OUTPUTS:` or `OPTIONAL OUTPUT:`.
- [X] T028 Static review of `git diff b57404773 -- SRC` (quickstart step 7; FR-001, FR-008, FR-013):
  1. The signature line is unchanged.
  2. `extractBondSubgraphsByComponentScan` is byte-identical. Check with `diff` of the text from its `function` line to end of file in `git show b57404773:SRC` and in `SRC`.
  3. The old lines 34–76 are byte-identical.
  4. The body of `extractBondSubgraphsByEdgeScan` equals old lines 79–202 apart from indentation. Show this with a whitespace-insensitive diff.
  5. No `fprintf`, `warning` or `error` string was added, removed or reworded, apart from nothing new.
  6. No `evalc`, `nargin`, `try/catch` or warning suppression was added.
  7. Every new one-time structure is linear in size.

  Record the outcome in `FEATURE/extractBondSubgraphsPeelingResults.md`.
- [X] T029 [P] SC-002 end-to-end check. Rebuild `n1960` as in T007 (no breakpoint) and run `identifyConservedReactingMoieties(model, BG, dATM, struct('directed', 0, 'sanityChecks', 0, 'conservedMoietiesOnly', true))` on the final `SRC`. Compare every saved output with `EXT/n1960-endToEnd-golden.mat` using `isequaln`. Record the result and elapsed time next to the golden run's elapsed time. Implement this as an `endToEnd` mode of `FEATURE/extractBondSubgraphsPeelingCheck.m`, enabled with `CBT_EBS_END_TO_END=1`.
- [X] T030 [P] SC-006:
  1. Run every test in `TESTDIR/` (`runtests('test/verifiedTests/analysis/testReactingMoieties')`).
  2. Run `specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m`.
  3. Run `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`.

  All must pass. Record the pass/fail list with any failure output in the results file.

  *As run*: the 021 and 022 checks stop at start-up with `tyrosineReproducibilityCheck:RxnFilesNotFound`, because both hard-code the old corpus path `/media/JACK/repos/ctf/rxns/atomMapped_standardised`, which is now `atomMapped_std`. At the user's decision (2026-09-29), they are recorded as not run. `specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m` is run instead, with `CBT_RMO_NO_TIMING_GATE=1`. It already uses `atomMapped_std`, and it compares `arm`/`moietyFormulae`/`reacting` with golden snapshots for tyr, ci and six more subsystems, in default and conservedOnly modes.
- [X] T031 Run quickstart.md steps 2–7 in order against the final state, and confirm each "Expected" line. Note any step not run, with the reason.
- [X] T032 Report to the user:
  - files changed;
  - checks run;
  - tests passed and failed, with output;
  - the SC-004 ratio;
  - the SC-005 exponent and status;
  - whether Story 2 shipped;
  - whether the 332 fixture was committed;
  - behaviours not verified.
- [X] T033 Create the implementation receipt at `FEATURE/agent-runs/<UTC-timestamp>-extract-bond-subgraphs-local-peeling/implementation-receipt.md`, with the sections Prompt, Final response (T032's response, **verbatim**), Diff summary (every changed file), Tests, Unresolved issues, and an optional Other information section. Other information cites `matlab-practice-notes.md` and any Story 2 deferral.

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (T001–T004)**: T001 first; then T002 and T004 in parallel; T003 after T002 (it copies T002's output).
- **Phase 2 (T005–T013)**: depends on Phase 1. T006 → T007 (same file). T008 needs T006. T009 needs T007. T010 needs T009. T011 needs T008 and T010. T012 can be written in parallel with T009's long run. T013 needs T011 and T012. **Blocks all stories.**
- **Phase 3, US1 (T014–T019)**: after T013. T014 → T015 → T016 → T017 → T018 → T019 (all edit `SRC`, in sequence).
- **Phase 4, US2 (T020–T021)**: after T019 (it builds on the Story 1 loop).
- **Phase 5, US3**: T022 and T023 can start right after T013 (harness only, in parallel with Phases 3 and 4). T024 comes after T022 and T023. T025 needs the final `SRC` (T019, or T021 if Story 2 is kept). T026 only if T025 fails.
- **Phase 6**: T027 after the final `SRC` logic (T021 or its revert, and T026 if run). T028 after T027. T029 and T030 in parallel after T028. T031 → T032 → T033.

### User story dependencies

- **US1**: needs only the Foundational phase. It is the MVP.
- **US2**: needs US1's loop (same code region). It can be dropped without affecting US1.
- **US3**: the harness does not depend on US1 or US2. Its gate run (T025) measures whatever final `SRC` exists.

## Parallel Example

```text
# After T013 passes:
Stream A (SRC):     T014 → T015 → T016 → T017 → T018 → T019 → T020 → T021
Stream B (harness): T022 ∥ T023 → T024
# After both streams:
T025 (→ T026 if needed) → T027 → T028 → (T029 ∥ T030) → T031 → T032 → T033
```

## Implementation Strategy

### MVP (User Story 1 only)

Phases 1 and 2 → Phase 3 → T022–T025 (gate) → Phase 6. Story 1 removes the `rmedge` cost (592 s), the per-pass `subgraph(BIGCopy, …)` and the growing `ismember`, which together are the largest part of the 1,274 s.

### Incremental delivery

1. Freeze the references (Phase 2). Nothing is edited before T013 passes.
2. Increment (a), Story 1: verify with T018/T019.
3. Increment (b), Story 2: verify with T021, or drop and record.
4. Benchmark gate (T025), then polish.

Each increment is checked against every golden fixture before the next one starts, so a failure can be traced to one increment.
