---

description: "Task list for removing the per-edge and per-component table hotspots in identifyConservedReactingMoieties"
---

# Tasks: Remove the per-edge and per-component table hotspots in `identifyConservedReactingMoieties`

**Input**: Design documents from `specs/20260929-111453-conserved-moiety-table-hotspots/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R8), data-model.md (E1–E4), contracts/extractPartitionSubgraphs.md, quickstart.md (steps 0–7)

**Tests**: Required. This is a behaviour-preserving change to a MATLAB function (Constitution III). Golden references are captured from unchanged source before the first edit (T011).

**Organization**:
- US1 is the reorientation, and is the MVP.
- US2 is the component subgraphs plus moiety-index propagation.
- US3 is the moiety graphs.
- The shared helper `extractPartitionSubgraphs` is foundational, because US2 and US3 both use it. Each story is revertible on its own (FR-007).

## Format: `[ID] [P?] [Story] Description`

## Path conventions

- `FEATURE` = `specs/20260929-111453-conserved-moiety-table-hotspots`
- `SRC` = `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
- `HELPER` = `src/analysis/topology/reactingMoieties/extractPartitionSubgraphs.m`
- `TESTDIR` = `test/verifiedTests/analysis/testReactingMoieties`
- `PREV` = `specs/20260928-100409-extract-bond-subgraphs-local-peeling`
- `EXT` = `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/conservedMoietyHotspots` (local only, never committed)
- `BASE` = commit `858feabc1`

Line numbers below refer to `SRC` at `BASE`.

Run MATLAB headless with absolute script paths: `/usr/local/MATLAB/R2024b/bin/matlab -batch "initCobraToolbox(false); run('/home/jackmcgoldrick/cobratoolbox/<path>')"`. Absolute paths are needed because `initCobraToolbox` may change the working directory.

---

## Phase 1: Setup

- [X] T001 From the repository root, confirm that `git rev-parse --short HEAD` is `858feabc1` or a descendant (`git merge-base --is-ancestor 858feabc1 HEAD`), and that `git diff --quiet 858feabc1 -- src/` succeeds. Create `EXT` with `mkdir -p`. Confirm that `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat` exists. Stop and report if any check fails.
- [X] T002 [P] Create `FEATURE/identifyConservedReactingMoietiesBaseline.m` with `git show 858feabc1:SRC`, changing only line 1 to `function [arm, moietyFormulae, reacting] = identifyConservedReactingMoietiesBaseline(model, BG, dATM, options)`. Verify with `diff <(git show 858feabc1:SRC | tail -n +2) <(tail -n +2 FEATURE/identifyConservedReactingMoietiesBaseline.m)`, which must print nothing (research R7).

---

## Phase 2: Foundational (captures, tests on unchanged source, check script, shared helper)

**No story may start until T011 passes.**

- [X] T003 Create `FEATURE/captureHotspotFixtures.m`.
  1. **Guard**: via `system`, run `git diff --quiet 858feabc1 -- SRC`. If it fails, raise the error `captureHotspotFixtures:srcModified`.
  2. **Part A (CI golden)**: build the six combinations below exactly as `TESTDIR/testConservedReactingMoieties.m` builds its fixtures: `buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, struct('directed', 0, 'sanityChecks', 1))` with `rxnFilesDir = TESTDIR/data/rxnFiles`. The combinations are:
     - `main` (Recon3D_301 `{'r0317'; 'ACONTm'; 'r0426'}`), conservedOnly, `sanityChecks` 0;
     - `main`, conservedOnly, `sanityChecks` 1;
     - `main`, default mode, `sanityChecks` 0;
     - `main`, default mode, `sanityChecks` 1;
     - `coaXBondKeySubmodel.mat`, conservedOnly, `sanityChecks` 0;
     - `crnMBondKeySubmodel.mat`, conservedOnly, `sanityChecks` 0.

     For each one, run the **unchanged** `identifyConservedReactingMoieties` and save a struct array `goldenCases` with fields:
     - `name`, `model`, `BG`, `dATM`, `options`;
     - `arm`, `moietyFormulae`, `reacting`;
     - `milpSolver`: `CBT_MILP_SOLVER` for default mode, `''` otherwise.

     Save it to `TESTDIR/data/conservedReactingMoietiesReference.mat` with `-v7`, and print its size in bytes. If it is larger than 1,048,576 bytes, print a warning and continue; the size is recorded in T006.
  3. **Part B (local n1960 inputs)**: `models = buildLowSymmetrySubsetModels(corpusDir, homeDir)` (add `PREV` to the path), then `[dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(models.n1960, '/media/JACK/repos/ctf/rxns/atomMapped_std', struct('directed', 0, 'sanityChecks', 0))`. Save `model` (`= models.n1960`), `BG` and `dATM` to `EXT/n1960-identifyInputs.mat` with `-v7.3`.
  4. **Selection**: environment variable `CBT_CMH_PARTS`, default `A,B`.
  5. Every `catch` reports `ME.message` plus `ME.stack(1).file` and `ME.stack(1).line` (VII-C).
- [X] T004 Run T003 with both parts. Confirm the CI golden file and `EXT/n1960-identifyInputs.mat` exist. Record the sizes.
- [X] T005 Extend `TESTDIR/testConservedReactingMoieties.m` (III-Naming: extend, not duplicate). Add a golden-comparison block that loads `data/conservedReactingMoietiesReference.mat` and re-runs `identifyConservedReactingMoieties(c.model, c.BG, c.dATM, c.options)` for each case `c`. Assertions (messages name the case and the field):
  1. **Conserved-only cases** (`c.options.conservedMoietiesOnly` true): `isequaln(arm, c.arm)` and `isequaln(moietyFormulae, c.moietyFormulae)`, and `isequaln(reacting, c.reacting)`. Place this block **before** the existing `prepareTest('needsMILP', true)` gate, so it runs on runners without a MILP solver.
  2. **Default-mode cases** (`sanityChecks` 0 and 1): place them **after** the gate. Assert `isequaln` on `arm` and `moietyFormulae`, and on `reacting` only when `strcmp(c.milpSolver, <current MILP solver>)`. Otherwise print one line saying that the `reacting` comparison was skipped because the MILP solver differs (MILP optima need not be unique across solvers).
  3. Update the `Purpose:` comment (feature `20260929-111453`, FR-002, FR-008) and `Authors:`. Keep the existing assertions unchanged.
- [X] T006 [P] Create `FEATURE/conservedMoietyHotspotsCheck.m`, the non-CI check (research R7).
  1. **Setup**: add `FEATURE` and `PREV` to the path. Load `EXT/n1960-identifyInputs.mat` and `…/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat`.
  2. **Equality**: run `identifyConservedReactingMoieties(model, BG, dATM, struct('sanityChecks', 0, 'conservedMoietiesOnly', true))`, and compare `arm`, `moietyFormulae` and `reacting` with the golden using `isequaln`. On failure, report the first differing top-level field of `arm`.
  3. **Profiler (SC-002)**: under `profile on`, run the same call once. From `profile('info').FunctionTable`, take the row(s) whose `FileName` is `SRC`. Sum the `NumCalls` of children whose `FunctionName` is `graph.subgraph`, `graph.subsasgn` and `extractPartitionSubgraphs`, reported separately.
  4. **Timing (SC-003, unless `CBT_CMH_NO_TIMING=1`)**: alternate `identifyConservedReactingMoietiesBaseline` and `identifyConservedReactingMoieties`, 3 runs each (`CBT_CMH_TIMING_RUNS` overrides), on the same inputs and options, using `tic`/`toc`. Report the medians and the ratio; the gate is ratio ≤ 0.65.
  5. **Block micro-benchmark (SC-004, reported)**: run `FEATURE/research-prototype/probeHotspots.m` logic as a local function: old block code against the new code on the real ATG, reporting each block's old/new seconds. Load the ATG from `~/…/extractBondSubgraphsPeeling/n1960-inputs.mat`. The block benchmark covers the reorientation and the per-component subgraphs on the real ATG. The moiety graphs are measured on the component stand-in partition (research R1), because the real moiety indices only exist later in the run. The propagation block (FR-004a) has no stand-alone harness, so its SC-004 figure is the before/after sum of its line times from the T007 and T022 profiler runs. Record the source of each figure next to it.
  6. **Output**: append a dated section to `FEATURE/conservedMoietyHotspotsResults.md`, with the source state (commit, `+modified`), equality, counts, timings and the gate result. Create the file with a heading on first use. Include a section recording the T004 sizes.
  7. **Failure**: raise `conservedMoietyHotspotsCheck:mismatch` when outputs differ, and `conservedMoietyHotspotsCheck:sc003` when the gate fails, both after writing the results.
- [X] T007 Run the checks on **unchanged** source:
  1. `runtests('testConservedReactingMoieties')` must PASS.
  2. `CBT_CMH_NO_TIMING=1 conservedMoietyHotspotsCheck` must report identical outputs, and profiler counts of 110,832 `graph.subgraph` and 271,845 `graph.subsasgn` (±1; record the exact values).

  Record the results in the results file.
- [X] T008 [P] Create `HELPER` = `extractPartitionSubgraphs.m`, following `FEATURE/contracts/extractPartitionSubgraphs.md`. Signature: `function parts = extractPartitionSubgraphs(G, nodeLabel, keepEdge)`.
  1. **Optional input**: `if ~exist('keepEdge', 'var') || isempty(keepEdge), keepEdge = true(numedges(G), 1); end` (VII-D).
  2. **One-time reads**: `nodeTable = G.Nodes; edgeTable = G.Edges; [s, t] = findedge(G); ends = [s(:), t(:)];`.
  3. **Grouping**: `[labels, ~, nodeGroup] = unique(nodeLabel(:));` then `nodesByPart = accumarray(nodeGroup, (1:numel(nodeGroup))', [numel(labels) 1], @(v) {sort(v)});`.
  4. **Eligible edges**: `inPart = keepEdge(:) & nodeGroup(ends(:,1)) == nodeGroup(ends(:,2));` then `edgesByPart = accumarray(nodeGroup(ends(inPart,1)), find(inPart), [numel(labels) 1], @(v) {sort(v)});` (empty cells for parts without edges). Handle `numnodes(G) == 0` by returning `parts = {}`, and `numedges(G) == 0` or no eligible edge by giving every part `zeros(0,1)` rows.
  5. **Local numbering**: a `localPos = zeros(numnodes(G),1)` scratch vector.
  6. **Per part `k`**:
     1. `rows = [zeros(0,1); edgesByPart{k}]` (ascending);
     2. set `localPos(nodes)`, read `localEnds = reshape(localPos(ends(rows,:)), [], 2)`, then reset `localPos(nodes) = 0`;
     3. for `graph`, `localEnds = [min(localEnds,[],2) max(localEnds,[],2)]`;
     4. `e = edgeTable(rows,:); e.EndNodes = localEnds;`;
     5. `parts{k,1} = graph(e, nodeTable(nodes,:))`, or `digraph(...)` for a `digraph` `G`.
  7. **Header**: openCOBRA help (`USAGE`, `INPUTS`, `OPTIONAL INPUT`, `OUTPUT`, `NOTE` citing the ordering contract, `.. Author:`).

  Named graphs (a `Name` node variable) are handled because `findedge` returns numeric indices.
- [X] T009 [P] Create `TESTDIR/testExtractPartitionSubgraphs.m`: `prepareTest()`, `rng(1)`. For 50 random cases, alternating `graph` and `digraph`:
  - 10–40 nodes;
  - labels with 1–8 distinct values, **including single-node parts and parts without edges**;
  - parallel edges;
  - extra node and edge variables (numeric and cell);
  - with and without a random `keepEdge`.

  For each case, assert for every part `k` that `parts{k}` equals the reference: `H = subgraph(G, find(nodeLabel == u(k)))`, then filter `H.Edges` by `keepEdge` on the kept rows. The kept rows are identified by carrying an original-row-index edge variable through `subgraph`, then removing it before comparison. Build the reference with the same constructor. Compare with `isequal` on `class`, `Nodes` and `Edges`, and assert `numel(parts) == numel(unique(nodeLabel))`. Add fixed cases for:
  - an empty graph (`parts` is `{}`);
  - a graph with nodes but no edges;
  - a `Name`d graph.

  The header states the purpose (feature 20260929-111453, contract rules) per III.
- [X] T010 Run `runtests('testExtractPartitionSubgraphs')`. It must PASS. The helper is not called by `SRC` yet.
- [X] T011 **Checkpoint**: T007 and T010 pass. References are frozen, and edits to `SRC` may begin.

---

## Phase 3: User Story 1 — Reorient atom transitions in one pass (Priority: P1) 🎯 MVP

**Goal**: FR-003. Replace the loop at `SRC` lines 425–435.

**Independent Test**: T013 and T014.

- [X] T012 [US1] In `SRC`, replace lines 425–435 (the `for i=1:nTrans … end` loop; keep the comment on lines 423–424) with the following (research R2):

  ```matlab
  reorientedBool = orientationATG2dATM == -1;
  if any(reorientedBool)
      edgesATG = ATG.Edges;
      newHeadAtom = edgesATG.TailAtom(reorientedBool);
      newTailAtom = edgesATG.HeadAtom(reorientedBool);
      headAtomIndex = edgesATG.HeadAtomIndex;
      headAtomIndex(reorientedBool) = edgesATG.EndNodes(reorientedBool, 2);
      % … TailAtomIndex, HeadAtom, TailAtom likewise …
      transNames = edgesATG.Trans;
      transNames(reorientedBool) = cellfun(@(headAtom, tailAtom) [headAtom '#' tailAtom], ...
          newHeadAtom, newTailAtom, 'UniformOutput', false);
      ATG.Edges.HeadAtomIndex = headAtomIndex;
      % … the other four whole-column writes …
  end
  ```

  Comment it in the surrounding style, noting that the swap is done in one pass instead of per edge.
- [X] T013 [US1] Run `runtests('testConservedReactingMoieties')` and `runtests('testExtractPartitionSubgraphs')`. Both must PASS; coaX (159 reoriented edges) and crnM (26) exercise the block.
- [X] T014 [US1] Run `CBT_CMH_NO_TIMING=1 conservedMoietyHotspotsCheck`.
  - **Expected**: n1960 identical. Record the exact `graph.subsasgn` and `graph.subgraph` counts from `SRC`, and confirm that `graph.subsasgn` fell, because it no longer scales with reoriented edges.
  - **On success**: save `git diff 858feabc1 -- SRC > FEATURE/story1-reorientation.patch`, and record the result under the heading "Story 1".
  - **On failure**: revert `SRC` to `BASE`, record "Story 1 deferred: <reason>", and continue with US2 from `BASE` (FR-007).

---

## Phase 4: User Story 2 — Component subgraphs from their own rows, and propagation without whole-graph scans (Priority: P2)

**Goal**: FR-004, FR-004a.

**Independent Test**: T017 and T018.

- [X] T015 [US2] In `SRC`, replace both per-component loops with `subgraphs = extractPartitionSubgraphs(ATG, atoms2component);`, keeping the preceding comment lines:
  - lines 592–595 (`subgraphs=cell(nComps,1); for i = 1:nComps … end`);
  - lines 1041–1044, the same code.

  Add one comment line at the first site: "parts come in ascending component order, so subgraphs{i} is component i".
- [X] T016 [US2] In `SRC`, replace the propagation at lines 1046–1066 (keep the two comment blocks) per research R5.
  1. **Class loop**:

     ```matlab
     for i=1:nIsomorphismClasses
         MoietyIndices = subgraphs{firstSubgraphIndices(i)}.Nodes.MoietyIndex;
         memberComps = find(I2C(i,:)==1);
         for j=memberComps(memberComps~=firstSubgraphIndices(i))
             subgraphs{j}.Nodes.MoietyIndex=MoietyIndices;
         end
     end
     ```

  2. **Compile**: if `numel(unique(ATG.Nodes.AtomIndex)) == numel(ATG.Nodes.AtomIndex)`, build `nodesOfComponent = accumarray(atoms2component, (1:nAtoms)', [nComps 1], @(v) {sort(v)})`, and for every `i` not in `firstSubgraphIndices` collect `nodesOfComponent{i}` and `subgraphs{i}.Nodes.MoietyIndex`. Then do **one** write, `moietyIndex = ATG.Nodes.MoietyIndex; moietyIndex(collectedNodes) = collectedValues; ATG.Nodes.MoietyIndex = moietyIndex;`.
  3. **Otherwise**: keep the original nested `ismember` loop verbatim.

  Comment each part.
- [X] T017 [US2] Run T013's tests. Both must PASS.
- [X] T018 [US2] Run the check with timing off.
  - **Expected**: identical; `graph.subgraph` from `SRC` falls by exactly 79,832 (two sets of 39,916); `extractPartitionSubgraphs` is called twice. Record the exact `graph.subsasgn` count and confirm it fell.
  - **On success**: save `FEATURE/story2-components.patch` (a cumulative diff from `BASE`), and record the result under "Story 2".
  - **On failure**: `git checkout 858feabc1 -- SRC && git apply FEATURE/story1-reorientation.patch` (if Story 1 shipped), re-run T013, and record the deferral (FR-007).

---

## Phase 5: User Story 3 — Moiety graphs from their own rows (Priority: P3)

**Goal**: FR-005.

**Independent Test**: T020 and T021.

- [X] T019 [US3] In `SRC`, replace lines 1152–1177 (from `% Initialize an array to store the MoietySubgraphs` through the loop's `end`) with the following (research R3, data-model E3):

  ```matlab
  % Moiety graphs: each moiety's atoms and the bonds internal to it (MoietyBondIndex equal
  % to the moiety index of both end atoms), built from their own rows, in the order
  % subgraph gives them
  moietyOfNode = ABG.Nodes.MoietyIndex;
  [bondSource, bondTarget] = findedge(ABG);
  moietyBondIndexABG = ABG.Edges.MoietyBondIndex;
  isInternalBond = moietyBondIndexABG == moietyOfNode(bondSource) & moietyBondIndexABG == moietyOfNode(bondTarget);
  MG = extractPartitionSubgraphs(ABG, moietyOfNode, isInternalBond);
  ```

  Keep `MG = {}` semantics for an ABG with no nodes; the helper returns `{}`.
- [X] T020 [US3] Run T013's tests. Both must PASS; coaX has 20 moiety graphs without edges and crnM has 6.
- [X] T021 [US3] Run the check with timing off.
  - **Expected**: identical, including `arm.MG`; `graph.subgraph` from `SRC` falls by exactly a further 30,999, to ≤ 1. Record the exact counts.
  - **On success**: save `FEATURE/story3-moiety-graphs.patch` (cumulative), and record the result under "Story 3".
  - **On failure**: revert to the previous patch and record the deferral.

---

## Phase 6: Polish, gate and cross-cutting

- [X] T022 Run the full check with timing on (quickstart step 6). Record the SC-003 ratio (gate ≤ 0.65), the SC-004 block timings (reported) and the SC-002 counts. Also run the check once with the profiler on the final code, and report the propagation block's line-time sum against the T007 profile. If the gate fails, stop and report the measured ratio to the user; there is no contingency within this spec.
- [X] T023 [P] Run `reactingOptimisationReproducibilityCheck.m` twice:
  - with `CBT_RMO_NO_TIMING_GATE=1` (16 comparisons, default and conservedOnly);
  - with `CBT_RMO_SANITY=1 CBT_RMO_NO_TIMING_GATE=1` (sanity snapshots).

  Use the absolute path `specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m`. All must be EQUAL. Record the results in `FEATURE/conservedMoietyHotspotsResults.md`.
- [X] T024 [P] Run `runtests('TESTDIR')` (all tests). They must all PASS. Record the list.
- [X] T025 In `SRC`, add the `.. Author:` provenance line for this feature to the help header (FR-011). No described behaviour changes, so there is no `NOTE` rewrite.
- [X] T026 Static review of `git diff 858feabc1 -- src/` (quickstart step 7):
  1. Changes are only at the three sites, the propagation block and the author line, plus the new `HELPER`.
  2. No `fprintf`/`warning`/`error` text is added, removed or reworded.
  3. No `evalc`, no `nargin` and no new `try/catch`.
  4. Every `sanityChecks` block is byte-identical.
  5. The new structures are linear in size (FR-010).

  Record the results.
- [X] T027 Run quickstart.md steps 1–7 in order against the final state, and record the status of each step in the results file.
- [X] T028 Report to the user:
  - files changed;
  - checks run;
  - tests passed and failed, with output;
  - the SC-003 ratio;
  - SC-004 per block;
  - the SC-002 counts;
  - which stories shipped;
  - the CI golden file size;
  - behaviours not verified.
- [X] T029 Create the implementation receipt at `FEATURE/agent-runs/<UTC-timestamp>-conserved-moiety-table-hotspots/implementation-receipt.md`, with the sections Prompt, Final response (T028's response, verbatim), Diff summary (all files), Tests, Unresolved issues, and Other information (cite `PREV/matlab-practice-notes.md` for VII-F).

---

## Dependencies & Execution Order

- **Phase 1**: T001, then T002.
- **Phase 2**: T003 → T004 → T005 → T007 (T007 also needs T006). T006 can be written in parallel with T004's long run. T008 and T009 are in parallel with T003–T007 (new files, no `SRC` edit), then T010. T011 needs T007 and T010.
- **US1** (T012–T014) after T011.
- **US2** (T015–T018) after US1 is resolved (shipped or deferred), because it edits the same file and uses cumulative patches.
- **US3** (T019–T021) after US2 is resolved.
- **Phase 6** after US3 is resolved. T023 and T024 run in parallel after T022; do not run them during T022's timing runs. Then T025 → T026 → T027 → T028 → T029.

## Parallel Example

```text
Stream A (captures/tests): T003 → T004 (long) → T005 → T007
Stream B (helper):         T008 ∥ T009 → T010
Stream C (check script):   T006 (written during T004)
Then: T011 → US1 → US2 → US3 → T022 → (T023 ∥ T024) → T025 → T026 → T027 → T028 → T029
```

## Implementation Strategy

- **MVP**: Phases 1–2 and US1. Reorientation alone saves about 181 s of 817 s unprofiled (research R1).
- **Incremental**: US2 then US3, each verified against the same references and saved as a cumulative patch, so any story can be reverted without affecting the others (FR-007).
- **Gate**: the SC-003 gate is measured only on the final combination.
