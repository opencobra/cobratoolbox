# Implementation Plan: Size-proportional peeling in `extractBondSubgraphs`

**Branch**: `20260928-100409-extract-bond-subgraphs-local-peeling` | **Date**: 2026-09-28 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20260928-100409-extract-bond-subgraphs-local-peeling/spec.md`

## Summary

The main path of `extractBondSubgraphs` does four things on every pass whose cost grows with the whole model:

- `subgraph(ATG, …)`;
- `subgraph(BIGCopy, …)`;
- `ismember(edgeIdx, bondIdProcessed)` against a list that keeps growing;
- `rmedge(BIGCopy, …)`.

It makes about 41,700 passes on the 1,960-reaction model. This plan replaces all four with structures built once, so each pass costs time in proportion to the component pair it processes:

- **Pair index** (the spec's edge-by-component-pair index): a sparse index from each component pair to its bucket of `BIG` edge rows, plus the same index for `ATG` edges.
- **`remaining` flag**: a logical flag over `BIG` edge rows, replacing `rmedge` and the `ismember` scan.
- **`first` pointer**: a pointer to the first remaining edge. Research R2 proved that the loop always processes the first remaining edge.
- **Direct tables**: the pair's edge and node tables, built directly in the row and node order that `subgraph` produces (research R1). Story 2 builds `combinedSubgraph` with the `graph`/`digraph` table constructors.

The per-layer peeling code is kept verbatim (FR-007). The fallback path and the precondition checks stay byte-identical (FR-008).

A research prototype reproduced the baseline outputs exactly on the CI fixture and on 300 randomised inputs (R6). On synthetic graphs, the scaling exponent fell from 1.10 to 0.83–0.96 (R7). The golden fixtures (Tyrosine, the nested subsets 332–1,960, and a synthetic CI fixture) are captured from the unchanged code before any source edit.

## Technical Context

**Language/Version**: MATLAB R2024b Update 8 (`/usr/local/MATLAB/R2024b`), which is the version used for research and golden capture. CI runs whichever MATLAB `.github` / `.artenolis.yml` configure. The ordering contract (R1) is asserted in the CI test so that any difference between versions fails loudly.

**Primary Dependencies**: base MATLAB graph functions only (`graph`, `digraph`, `conncomp`, `addedge`, and in the baseline also `subgraph`/`rmedge`), plus `unique`, `sortrows`, `accumarray` and `sparse`. No solver, toolbox or new dependency.

**Storage**: MAT files.

- **Committed CI data**: `test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphPeelingReference.mat`.
- **Local captures**: `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling/`.

**Testing**: `test/verifiedTests/analysis/testReactingMoieties/testExtractBondSubgraphs.m` is extended (III-Naming), and runs under `test/testAll.m`. There is also a non-CI reproducibility and benchmark script in this feature directory.

**Target Platform**: headless Linux (CI and local). The code is platform-independent.

**Project Type**: scientific MATLAB library (COBRA Toolbox), with one internal function changed.

**Performance Goals**:

- **SC-004 (hard gate)**: median of 3 runs on the 1,960 fixture is at most 15% of the baseline.
- **SC-005 (reported)**: scaling exponent at most 1.3, or scope-explained by output size.
- **SC-003**: zero calls to `rmedge` or `subgraph` from `extractBondSubgraphs` on the fast path.

**Constraints**:

- Outputs are identical under `isequaln` (FR-002).
- No message is changed.
- Extra memory is limited to linear one-time indices (FR-013, R11).
- The fallback path and the preconditions stay byte-identical.

**Scale/Scope**: the 1,960-reaction model has about 41,700 passes. The file under change is 339 lines. One source file is edited.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: the formulation is unchanged. The change is internal to `extractBondSubgraphs`, and its signature and both output arities are kept (FR-001, Principle II). The only caller is `identifyConservedReactingMoieties.m:847`, which is not edited. **PASS**
- **Testing and reproducibility**:
  - **Narrowest CI test**: `testExtractBondSubgraphs` is extended with a synthetic main-path fixture (FR-011), an ordering-contract assertion (R1), and a labelling-mismatch case (R2a). The existing CI and fallback cases stay unchanged.
  - **Non-CI evidence**: `extractBondSubgraphsPeelingCheck.m` covers golden equality (Tyrosine, 332 and 1,960), the SC-002 end-to-end check on 1,960, profiler counts, timing and scaling. Automation of this part is deferred because the fixtures are local and the full run takes hours. It is documented in this directory with its results file.

  **PASS**
- **User experience and diagnostics**: no `fprintf`, `warning` or `error` is added, removed or reworded. The only new code that raises an error calls `subgraph(BIG, pairAtoms)` to raise the baseline's own error at the same pass (R4). **PASS**
- **Performance and numerical integrity**: outputs are discrete graph and table data, compared with `isequaln` (spec clarification). No verification is skipped. Performance is subordinate to correctness: the contingency in R7 only allows FR-007-permitted changes that keep FR-002. Speed is measured by the benchmark, not assumed. **PASS**
- **External-solver configuration audit**: N/A. No solver is invoked. The graph-library defaults are audited in R12 (`conncomp` strong/weak, stable `sortrows`, `unique 'first'`). **PASS**
- **Spec-driven scope control**:
  - **Edited**: `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m` only: header `NOTE`, and the main-path body after line 73.
  - **Byte-identical**: lines 1–73 apart from the `NOTE` block (lines 24–32), and `extractBondSubgraphsByComponentScan`.
  - **Read-only**: `identifyConservedReactingMoieties.m`, every other `src/` file, `external/`, and the existing `bondSubgraphReference.mat`.
  - **New local functions** in the same file: `buildPairEdgeIndex` and `extractBondSubgraphsByEdgeScan` (the pre-change main-path loop, kept verbatim for R2a inputs). No new `src/` file.

  **PASS** (see Complexity Tracking)
- **MATLAB coding standards**:
  - no `evalc`;
  - no warning suppressed;
  - no `try/catch` added (the error-parity path in R4 raises through `subgraph` itself);
  - no `nargin`;
  - header keeps the openCOBRA format (VII-E), with `NOTE:` rewritten in the existing style (FR-010) and `.. Author:` provenance added;
  - naming follows VII-G.

  No MATLAB-conventions skill is registered in `.claude/skills/`, so per VII-F the implementer applies the MathWorks performance guidance in quickstart step 0: preallocate, vectorise index construction, read graph properties once, and use logical masks instead of `ismember` in loops. **PASS**
- **Parameter-setting fidelity**: N/A. There is no ported or literate output.
- **Artifact placement**:
  - **Source**: edited in place.
  - **Committed CI fixture**: beside its test in `test/.../testReactingMoieties/data/`.
  - **Scripts, baseline copy, results markdown and small golden summaries**: under `specs/20260928-100409-extract-bond-subgraphs-local-peeling/`.
  - **Large captures**: outside the repo, in the reconXmoieties results tree (as feature 20260921-154310 did).
  - **The 332 capture**: committed beside the CI fixture only if ≤ 1 MB (clarification Q2).
  - Nothing is written to `src/` or the repository root.

  **PASS**

**Post-design re-check (after Phase 1)**: all items still PASS. The design adds two local functions but no new file or dependency. R2a keeps FR-002 for inputs whose labellings don't match, without touching the fallback. After `/speckit-analyze`, the spec now names the fast path, adds FR-014 for the labelling-mismatch route, uses the edge-by-component-pair index, and allows the error-parity call in FR-004, so plan and spec agree.

## Design

The main path after line 73 becomes the following. Names are indicative; see [data-model.md](data-model.md) for the structures.

1. **`nodesByComp`**: unchanged, line 76.
2. **Labelling guard (R2a)**: if `~isequal(componentATG(:), atoms2component(:))`, return `extractBondSubgraphsByEdgeScan(BIG, ATG, compOfAtom, nodesByComp)`. That function is the current lines 79–202 moved verbatim into a local function, so it still contains `subgraph` and `rmedge`. It is never reached from `identifyConservedReactingMoieties`.
3. **One-time reads**: `BIGEdges = BIG.Edges; BIGNodes = BIG.Nodes; ATGNodes = ATG.Nodes; ATGEdges = ATG.Edges;` and `endNodes = BIGEdges.EndNodes` (already read at line 56).
4. **One-time indices** (`buildPairEdgeIndex`, used for both graphs): the `BIG` pair index keyed by `compOfAtom`, the `ATG` pair index keyed by `atoms2component`, `remaining = true(nEdges, 1)`, and the `localPos` and `localPosATG` scratch vectors.
5. **Loop**, `while first <= nEdges`:
   1. `component1`/`component2` from `endNodes(first, :)`, and `nodesInBothComponents`, keeping the existing guard and comment at lines 103–118.
   2. `combinedSubgraph`, built as in R5 (Story 2), or `subgraph(ATG, …)` until Story 2 lands.
   3. Error parity (R4).
   4. `rows` = the remaining rows of the pair's buckets. `GEdges`/`GNodes` are built as in R4.
   5. The layer-peeling block, verbatim from lines 129–179. The only difference is that `bondIdProcessed` is no longer built, because `remaining(rows) = false` replaces it.
   6. Mark `rows` as not remaining, then advance `first`.
6. **Removed**: `BIGCopy`, `bondIdProcessed`, `idsToRemove`, `rmedge`, `k`, `numBonds`, the outer `while`, and the `edgeIdx` mirror.

**Increments**:

- **(a) Story 1**: steps 3–6 with `combinedSubgraph = subgraph(ATG, nodesInBothComponents)` kept.
- **(b) Story 2**: replace that line with the R5 construction.

Each increment is checked against all golden fixtures before the next starts. If (b) fails FR-002 on any fixture and can't be fixed within the feature, (b) is reverted and recorded as deferred (clarification Q1).

## Project Structure

### Documentation (this feature)

```text
specs/20260928-100409-extract-bond-subgraphs-local-peeling/
├── spec.md
├── plan.md                                   # this file
├── research.md                               # R1–R12
├── research-prototype/                       # research probes + prototype (evidence only)
├── data-model.md                             # E1–E7
├── quickstart.md                             # validation steps 0–7
├── contracts/
│   └── extractBondSubgraphs.md               # public + ordering contract
├── checklists/requirements.md
├── extractBondSubgraphsBaseline.m            # NEW — verbatim b57404773 copy, renamed (R9)
├── captureExtractBondSubgraphsInputs.m       # NEW — dbstop condition helper (R8)
├── captureLocalPeelingFixtures.m             # NEW — builds synthetic CI fixture; captures tyr + nested subsets + 1,960 end-to-end baseline
├── extractBondSubgraphsPeelingCheck.m        # NEW — golden compare, profiler counts, median-of-3 timing, log-log fits, FR-009 status, end-to-end mode
├── fingerprintBondSubgraphOutputs.m          # NEW — SHA-256 fingerprints of outputs (local golden storage, research R8)
├── buildLowSymmetrySubsetModels.m            # NEW — nested-subset model builder shared by capture and check
├── extractBondSubgraphsBaselineAssertK.m     # NEW — FR-009 instrument (research R2)
├── matlab-practice-notes.md                  # NEW — VII-F practice notes (T005)
├── extractBondSubgraphsPeelingResults.md     # NEW — generated, append-only results
└── tasks.md                                  # /speckit-tasks output (not created here)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
└── extractBondSubgraphs.m                    # MODIFIED — NOTE text; main path after line 73; two local functions

test/verifiedTests/analysis/testReactingMoieties/
├── testExtractBondSubgraphs.m                # MODIFIED — synthetic main-path fixture, ordering contract, R2a case, (332 if ≤ 1 MB)
└── data/
    ├── bondSubgraphReference.mat             # UNCHANGED
    └── bondSubgraphPeelingReference.mat      # NEW — synthetic (and optionally 332) inputs + pre-change golden outputs
```

External (not committed): `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling/{tyr,n332,n531,n1067,n1604,n1960}-inputs.mat`, `*-golden.mat` (fingerprints, research R8), `*-passcount.mat`, `n332-ci-candidate.mat`, and `n1960-endToEnd-golden.mat`.

**Structure Decision**: the single MATLAB toolbox layout. The one source edit stays in the existing `reactingMoieties` folder. The CI data sits beside the existing test data. Everything non-CI lives in the feature directory or in the external results tree.

## Implementation order (for `/speckit-tasks`)

1. **Baseline and capture, on unchanged `src/`**:
   1. Generate `extractBondSubgraphsBaseline.m` from `b57404773`.
   2. Write the capture helpers.
   3. Build the synthetic CI fixture (FR-011 edge cases, plus one R2a case) and save its golden outputs.
   4. Capture `tyr` and the five nested-subset inputs with the baseline golden outputs. For 1,960, also save the end-to-end `arm`/`moietyFormulae` golden outputs.
   5. Record the 332 file size and decide whether to commit it.

   **Gate**: all captures exist; the capture script's `git diff --quiet b57404773 -- <file>` guard passed.
2. **Tests first**: extend `testExtractBondSubgraphs.m` with the synthetic fixture, the ordering-contract assertion (R1) and the R2a case. They must pass on the unchanged source.
3. **Benchmark harness**: write `extractBondSubgraphsPeelingCheck.m` and run it once on unchanged `src/` (new == baseline). This records the unprofiled baseline medians and checks the harness itself.
4. **Increment (a), Story 1**: edit `extractBondSubgraphs.m` (steps 2–6 of Design). Run the CI tests and then the golden compare on all fixtures. Stop on any difference.
5. **Increment (b), Story 2**: R5 construction. Same checks, and revert it if it fails (clarification Q1).
6. **`NOTE` text (FR-010)**, `.. Author:` provenance, and a static `git diff` review: lines 1–23, 33–73 and the fallback function are byte-identical, and no message has changed.
7. **Full check**: profiler counts (SC-003), median-of-3 timing (SC-004 gate), scaling fits (SC-005), SC-002 end-to-end on 1,960, and the existing `testReactingMoieties/` tests plus the 021/022 checks (SC-006).
8. **If SC-004 fails**: apply the contingency in R7 under FR-007/FR-002, then repeat step 7.
9. **Implementation receipt** in `agent-runs/`.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
|------|------------|--------------------------------------|
| `extractBondSubgraphsByEdgeScan`: pre-change main loop kept verbatim as a local function (R2a) | FR-002 requires identical outputs for **every** input that passes the preconditions. The "always the first edge" argument holds only when `ATG.Nodes.Component` equals `conncomp(ATG)`. | Routing those inputs to `extractBondSubgraphsByComponentScan` might not give identical outputs, and FR-008 forbids changing the routing checks. Emulating the `k`-advance in the new loop adds complexity to a path the pipeline never takes. |
| Pair-keyed edge index (spec Key Entity, updated after analysis) | Keeps each pass pair-sized even for hub components (R3) | A per-component list rescans a hub's whole edge list on every pass it takes part in, which brings back the cost pattern this feature removes |
