# Feature Specification: Size-proportional peeling in `extractBondSubgraphs`

**Feature Branch**: `20260928-100409-extract-bond-subgraphs-local-peeling`

**Created**: 2026-09-28

**Status**: Draft

**Input**: User description: "Size-proportional peeling in `extractBondSubgraphs` (`src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`). Profiling of `identifyConservedReactingMoieties` on the 1,960-reaction `lowSymmetryRisk_2000rxn` model (reconXmoieties `findings/2026-09-25_conserved_moiety_runtime_scaling.md`): `extractBondSubgraphs` took 1,274 s, 35% of the conserved-moiety step, which scales at about n^1.84 across nested subsets and steepens with size. Four per-pass operations (lines 120, 125, 182, 185) cost time proportional to the whole model rather than to the component pair being processed. Remove them from the main path without changing any output."

<!--
  Not a characterization-mode feature (Constitution Principle III, "Characterization:
  Legacy Back-Fill Mode"): this is a behaviour-preserving performance change to a
  function that already has a regression test (testExtractBondSubgraphs.m).
-->

## Background

The main (lookup-array) path of `extractBondSubgraphs` repeatedly takes the first remaining edge of the bond instance graph (`BIGCopy`). For that edge's pair of atom-conservation components, it builds a combined atom subgraph, peels every remaining bond-instance edge among those atoms into layers, and then deletes the peeled edges from `BIGCopy`. On the 1,960-reaction model this loop ran **41,671** times.

On each pass, the loop performs four operations whose cost is proportional to the size of the **whole** model, not to the size of the component pair being processed:

| Line | Operation | Cost per pass |
|---|---|---|
| 120 | `subgraph(ATG, nodesInBothComponents)` | Scans the full atom transition graph |
| 125 | `subgraph(BIGCopy, combinedSubgraph.Nodes.AtomIndex)` | Scans the full remaining bond instance graph |
| 182 | `ismember(edgeIdx, bondIdProcessed)` | Scans all remaining edges against every edge processed so far (`bondIdProcessed` is reset only in the outer loop, so it grows across the whole run) |
| 185 | `rmedge(BIGCopy, idsToRemove)` | Rebuilds the full edge table of `BIGCopy` |

The number of passes grows with model size, and so does the cost of each pass, so the total is roughly quadratic. The profile agrees: exactly 41,671 calls each to `digraph.rmedge` (591.6 s total) and `digraph.subgraph`, plus about 86,000 `tabular.parenDelete` calls (about two per `rmedge`).

`BIGCopy` is used only as the input to the `subgraph` call on line 125. The code already mirrors its edge list in plain arrays (`endNodes`, `edgeIdx`).

**Observed control flow** (supported by reading the code; to be confirmed empirically during planning, see FR-009): both end atoms of the edge being processed (row `k`) lie in the selected component pair, so that edge is in `GBB`. The inner `while` loop peels every edge of `GBB`, so row `k` is always in `idsToRemove`. As a result, `ismember(k, idsToRemove)` is always true, `k` always resets to 1, the loop always processes the first remaining edge, and the outer `while` loop runs its body only once.

## Clarifications

### Session 2026-09-28

- Q: Should Story 2 (the `ATG` side) ship in the same feature as Story 1, or be split off? → A: **Same feature, but droppable.** Story 2 is planned as a separate, later increment. If planning or implementation cannot reproduce `subgraph(ATG, …)` exactly (FR-002) on every fixture, Story 2 is dropped from this feature and recorded as deferred, with the reason. Story 1 ships either way.
- Q: Where do the captured fixtures live? → A: **A small synthetic CI fixture is committed; the 332-reaction capture is committed only if small.** A small hand-built fixture covering the edge cases below is added to the existing `testExtractBondSubgraphs.m` data. The 332-reaction capture (`BIG`/`ATG` plus golden outputs) is committed alongside it only if it is at most about 1 MB. Otherwise it stays local. The Tyrosine and 531–1,960-reaction fixtures stay local.
- Q: Are SC-004 and SC-005 hard acceptance gates or reported targets? → A: **SC-004 is a hard gate; SC-005 is reported.** The feature is not complete unless SC-004 holds. The SC-005 exponent is measured and recorded (and explained if above 1.3), but it does not block completion.
- Q: Should "identical" in FR-002 use `isequal` or `isequaln`? → A: **`isequaln`, otherwise strict.** NaN compares equal to NaN. Graph class, variable names, variable order, variable types, row order and values must all still match. The existing `isequal`-based helper in `testExtractBondSubgraphs` may stay for CI fixtures that contain no NaN.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Peel bond-instance edges without rebuilding the full bond graph (Priority: P1)

As a researcher running conserved-moiety identification on genome-scale subsets, I need the bond-instance side of the peeling loop (lines 125, 182 and 185) to cost time in proportion to the component pair being processed, not the whole model. That way, runtime on a ~2,000-reaction model is minutes rather than tens of minutes, and larger models become feasible.

**Why this priority**: `rmedge` alone accounts for 592 s of the 1,274 s. Together with the `subgraph(BIGCopy, …)` and `ismember` calls, this is the largest part of the function's cost, and it is the most likely source of the superlinear scaling.

**Independent Test**: Run the new and baseline implementations on the same captured `(BIG, ATG)` inputs and compare all three outputs for exact equality (SC-001). Then compare wall-clock time on the 1,960-reaction fixture (SC-004).

**Acceptance Scenarios**:

1. **Given** captured `(BIG, ATG)` inputs from the Tyrosine benchmark, the 332-reaction nested subset and the 1,960-reaction model, **When** `extractBondSubgraphs` is called, **Then** `bondSubgraphs`, `BMG` and `bmgEdgeIndex` are identical (FR-002) to the golden snapshot produced by the pre-change implementation.
2. **Given** the 1,960-reaction fixture, **When** the new implementation runs under the profiler, **Then** `extractBondSubgraphs` makes no calls to `rmedge`, and no calls to `subgraph` on `BIGCopy` or `BIG`.
3. **Given** a `BIG` with zero edges, **When** called, **Then** all three outputs are empty `{}`, as now.
4. **Given** the committed synthetic CI fixture, **When** `testExtractBondSubgraphs` runs in CI, **Then** all three outputs are identical to that fixture's pre-change golden outputs.

---

### User Story 2 - Build each combined atom subgraph from its own components only (Priority: P2)

As the same researcher, I need `combinedSubgraph` (line 120) to be built from the nodes and edges of the two selected components only, without scanning the full atom transition graph on every pass.

**Why this priority**: This also scales with the whole model on every pass, but its share of the 636 s total for `graph.subgraph` is not yet measured: about 111,000 of the 152,500 calls come from elsewhere in `identifyConservedReactingMoieties`. Per the clarification, this story is droppable: if exact equality with `subgraph(ATG, …)` proves fragile, it is deferred and Story 1 ships alone.

**Independent Test**: The same equality check as Story 1, plus a profiler check that `extractBondSubgraphs` makes no `subgraph` calls on `ATG`.

**Acceptance Scenarios**:

1. **Given** the same fixtures as Story 1, **When** called, **Then** every `bondSubgraphs{i}` is identical to the golden snapshot: same graph class, same `Nodes` table (row order, variables and values), and same `Edges` table (row order, variables and values).
2. **Given** a bond whose two end atoms are in the same component (`component1 == component2`, as in bond-cleaving reactions), **When** processed, **Then** the node set is not duplicated and the output matches the baseline, as the existing guard (lines 114–118) ensures today.

---

### User Story 3 - Benchmark and scaling verification (Priority: P3)

As the researcher, I need a repeatable, non-CI benchmark script that times `extractBondSubgraphs` alone on captured inputs, running the old and new versions back to back. This is needed because end-to-end timings of the same model varied by about 50% between runs on 2026-09-25.

**Why this priority**: It provides the evidence for SC-004 and SC-005, but it adds no user-facing behaviour.

**Independent Test**: The script runs both implementations on each fixture three times, reports median times, checks equality, and fits the scaling exponent across the nested-subset fixtures.

**Acceptance Scenarios**:

1. **Given** the five nested-subset fixtures (332, 531, 1,067, 1,604 and 1,960 reactions, seed 1), **When** the benchmark runs, **Then** it reports per-fixture median times for both implementations and a fitted log-log exponent for each.
2. **Given** any fixture, **When** the benchmark runs, **Then** it also reports whether the outputs are identical, and whether the observed control flow (FR-009) held on every pass.

---

### Edge Cases

- **`BIG` has no edges**: return `{}` for all outputs (existing early return, unchanged).
- **Inputs that fail the lookup-array preconditions** (non-integer, non-positive or duplicated `AtomIndex`; component labels outside `1..nComps`; non-numeric end nodes; end atoms with no component): the fallback function `extractBondSubgraphsByComponentScan` must still be used, completely unchanged, so that such inputs give exactly the results, or raise exactly the errors, they always did. The existing fallback cases in `testExtractBondSubgraphs` cover this.
- **Parallel edges** (several bond instances with the same end atoms) and **repeated `BondIndex` values** within one component pair: the layer-peeling order (`unique(…, 'first')` on the current row order) must be reproduced exactly. That requires reproducing the edge row order that `subgraph` produces for `GBB`.
- **`component1 == component2`**: the node set is used once (existing guard).
- **A component shared by several pairs across passes** (for example A–B processed first, then A–C): the later pass must see only the edges that remain, so edges peeled in the earlier pass must not reappear in the later pass's `GBB`.
- **Bond-instance edges whose end atoms lie in the pair but whose other components differ**: only edges with **both** end atoms in the pair's node set belong to `GBB`. Edges with one end atom in the pair and the other outside it are excluded, as `subgraph` excludes them today.
- **`Component` labelling differs from `conncomp(ATG)`** (possible for inputs that pass the preconditions, never produced by the pipeline): the pre-change loop is used unchanged (FR-014), so outputs, or errors, are exactly as before.
- **Component pairs whose atoms have already had all their edges removed**: these never become the "first remaining edge", so they produce no output. This behaviour must be preserved.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The public signature must not change: `[bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG)`, including the two-output form (Constitution Principle II).
- **FR-002**: On the main path, all three outputs must be identical to those of the pre-change implementation for every input that satisfies the lookup-array preconditions. "Identical" means:
  - same cell array sizes;
  - for every element, the same graph class (`graph` or `digraph`);
  - `isequaln` `Nodes` and `Edges` tables (row order, variable names, variable order, variable types and values; NaN compares equal to NaN);
  - `isequaln` vectors for `bmgEdgeIndex`.
- **FR-003**: The fast path must not call `rmedge` on `BIGCopy` or `BIG`. Processed edges must be removed using a per-edge "remaining" flag, or an equivalent structure, whose update costs time proportional to the number of edges removed.
- **FR-004**: The fast path must not call `subgraph` on `BIGCopy` or `BIG`. The edges of `GBB`, and their local end-node numbering, must be built from an edge-by-component-pair index constructed once at the start. They must reproduce the node order and edge row order that `subgraph(BIGCopy, combinedSubgraph.Nodes.AtomIndex)` produces today. The one exception is that `subgraph(BIG, pairAtoms)` may be called only to raise the pre-change error when a pair's atom index exceeds `numnodes(BIG)`. That call is never reached on valid inputs.
- **FR-005**: The fast path must not run an `ismember` scan over all remaining edges on each pass. The lookup on line 182 against the growing `bondIdProcessed` list must be replaced by direct updates to the remaining-edge flag.
- **FR-006** *(Story 2, droppable)*: The fast path must not call `subgraph` on the full `ATG`. `combinedSubgraph` must be built from per-component node data and an ATG edge-by-component-pair index, both built once at the start, and must be identical to what `subgraph(ATG, nodesInBothComponents)` returns. For an undirected `ATG`, which is what the pipeline builds, components are connected components, so no ATG edge joins two components, and the combined subgraph is the union of the two components' subgraphs. For a `digraph` ATG, `conncomp` returns strong components, which edges can join. Those edges are included through the same pair index, so the result still equals `subgraph(ATG, nodesInBothComponents)`. If this cannot be made identical on every fixture, FR-006 is deferred, and the deferral and its reason are recorded in the implementation receipt.
- **FR-007**: For each component pair, the per-layer peeling logic (`unique(…, 'first')`, `digraph(EdgeTable, GNodes)` and `addedge` on `combinedSubgraph`) must produce identical results. Changing these small, pair-sized operations is optional, and only allowed where FR-002 still holds.
- **FR-008**: `extractBondSubgraphsByComponentScan`, and the precondition checks that route inputs to it (lines 54–73), must remain byte-identical.
- **FR-009**: Simplifying the loop control based on the observed always-reset-to-first-edge behaviour is allowed only if planning confirms that it holds for every input on the main path, both by argument and by an assertion run against all fixtures in the benchmark. Otherwise the existing `k` logic must be kept. Planning confirmed this for fast-path inputs (research R2). Inputs covered by FR-014 keep the existing `k` logic.
- **FR-010**: The function's `NOTE` help text must be updated to describe the new approach, in the same style as the existing note.
- **FR-011**: The existing test `testExtractBondSubgraphs.m` must be extended, not duplicated (Constitution Principle III-Naming), with a small synthetic main-path fixture and its pre-change golden outputs. The fixture must exercise: parallel edges, repeated `BondIndex` values, `component1 == component2`, a component shared by pairs across passes, and edges leaving the pair's node set. The fixture must be captured from the pre-change implementation before the function body is changed. If the 332-reaction capture is at most about 1 MB, it is added to the same test as well.
- **FR-012**: The narrowest reproducibility check that proves the feature is the golden-output equality in FR-002 on the Tyrosine, 332-reaction and 1,960-reaction fixtures, plus the end-to-end check in SC-002. It must be delivered as a documented, non-CI script under this feature's `specs/` directory, with its expected results recorded.
- **FR-013**: Performance and output-integrity constraints: no output value, order or type may change; no warning, diagnostic or error may be added, removed or reworded; and peak memory must not grow by more than the one-time index structures, which are linear in the number of `BIG` edges and `ATG` nodes and edges.
- **FR-014**: For main-path inputs whose `ATG.Nodes.Component` is not the `conncomp(ATG)` labelling, the pre-change main-path loop must be used unchanged. That loop may still call `rmedge` and `subgraph`. This keeps FR-002, because the always-first-edge argument (FR-009) depends on the two labellings agreeing.

### Key Entities *(include if feature involves data)*

- **`BIG`** (bond instance graph, `digraph`): nodes are atoms, numbered by `AtomIndex`. Edges are bond instances, with `EndNodes`, `EdgeIndex`, `BondIndex` and possibly other variables. It is consumed read-only.
- **`ATG`** (atom transition graph): its nodes table has `AtomIndex` and `Component`. Its connected components (`conncomp`) are the atom-conservation components.
- **Component pair**: the one or two components containing the end atoms of the current first remaining edge. This is the unit of work for each pass.
- **Fast path**: the main path for inputs whose `ATG.Nodes.Component` equals `conncomp(ATG)'`. This is always true in `identifyConservedReactingMoieties`, where `Component` is set from `conncomp(ATG)`.
- **Remaining-edge flag**: a new logical vector over the rows of `BIG.Edges`. It replaces physically deleting edges from `BIGCopy`.
- **Edge-by-component-pair index**: a new structure, built once, that groups the `BIG` edge rows by the unordered pair of components of their two end atoms. The edges of pair `{A, B}` are exactly the buckets `(A,A)`, `(B,B)` and `(A,B)`. Each pass therefore touches only its own pair's edges, even for a component that pairs with many others (research R3).
- **Golden snapshot**: the three outputs of the pre-change implementation for one captured `(BIG, ATG)` input, used as the reference for FR-002.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All three outputs are identical (FR-002) to golden snapshots on at least: the Tyrosine benchmark, the 332-reaction subset, the 1,960-reaction model, and the synthetic CI fixture.
- **SC-002**: The end-to-end `identifyConservedReactingMoieties` outputs (`arm`, `moietyFormulae`, and every other returned output, compared as in the `conservedOnly` mode of `reactingOptimisationReproducibilityCheck.m`, feature 20260921-154310) are identical to the baseline on the 1,960-reaction model.
- **SC-003**: The profiler, on the 1,960-reaction fixture, shows 0 calls to `rmedge`, and 0 calls to `subgraph` on `BIG`/`BIGCopy`, from `extractBondSubgraphs` on the fast path (the 1,960 fixture is a fast-path input). If Story 2 ships, it also shows 0 calls to `subgraph` on `ATG`.
- **SC-004** *(hard gate)*: `extractBondSubgraphs` wall-clock time on the 1,960-reaction fixture is at most 15% of the baseline, measured as the median of 3 back-to-back runs. The baseline was about 1,274 s under the profiler; the unprofiled baseline is re-measured by the Story 3 benchmark.
- **SC-005** *(reported, not a gate)*: The fitted log-log scaling exponent of `extractBondSubgraphs` time across the five nested-subset fixtures is at most 1.3. *Caveat:* the total size of the outputs is a lower bound on runtime, because each output graph contains both full components. If planning shows that output size itself grows superlinearly on these fixtures, this criterion is evaluated against output size instead (time divided by output size should be roughly flat), and the result is recorded as scope-explained. An exponent above 1.3 that is not scope-explained is recorded, with a likely cause, in the implementation receipt, but it does not block completion.
- **SC-006**: The existing tests under `test/verifiedTests/analysis/testReactingMoieties/` (including the unchanged fallback cases in `testExtractBondSubgraphs`) and the feature 021/022 reproducibility checks still pass.

## Assumptions

- `EdgeIndex` values in `BIG.Edges` are unique. The existing removal logic (`ismember(edgeIdx, bondIdProcessed)`) already relies on this.
- `rmedge` preserves the relative row order of the edges it keeps, and the edge order in `subgraph`'s output is determined by the local node order. The exact node-order and edge-order behaviour of `subgraph` for a non-sorted `nodeIDs` vector (as on line 120, where comp1's nodes are followed by comp2's) will be established empirically during planning on MATLAB R2024b (`/usr/local/MATLAB/R2024b`), and encoded as an assertion in `testExtractBondSubgraphs`.
- Golden inputs and outputs are captured once from the current runtime branch, by saving `BIG` and `ATG` at the call site inside `identifyConservedReactingMoieties` during a normal run, before any change to `extractBondSubgraphs`. The 1,960-reaction fixture is too large for CI and stays local (see Clarifications for the other fixtures).
- The benchmark script (Story 3) and the reproducibility check (FR-012) are Spec Kit artifacts under `specs/20260928-100409-extract-bond-subgraphs-local-peeling/`, not toolbox source (Constitution Principle IX). The pre-change implementation used for back-to-back timing is a verbatim copy that is kept only with those artifacts.
- The reconXmoieties nested-subset models (seed 1) are available locally to regenerate captures.

## Out of Scope

- `classifySubgraphIsomorphism.m` (label-extraction overhead in `isisomorphic`). This will be a separate feature.
- The remaining ~1,300 s of table overhead elsewhere in `identifyConservedReactingMoieties`, including the ~111,000 other `graph.subgraph` calls.
- Any change to what `bondSubgraphs`/`BMG` contain (for example, not storing full component pairs per layer). That would change outputs and the downstream contract.
- The fallback path `extractBondSubgraphsByComponentScan`.
- The parked CoA-thioester symmetry runtime issue.

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 AS4 / FR-001, FR-002, FR-011, SC-001 (synthetic CI fixture) | testExtractBondSubgraphs.m (extended) | extractBondSubgraphs |
| US1 AS3, Edge Cases (fallback) / FR-008, SC-006 | testExtractBondSubgraphs.m (existing fallback cases, unchanged) | extractBondSubgraphs |
| US1 AS1, US2 AS1–AS2 / FR-002, FR-004, FR-006, FR-007, FR-012, SC-001 | golden-snapshot reproducibility check (Tyrosine, 332, 1,960) | extractBondSubgraphs |
| SC-002 | end-to-end `conservedOnly` golden check (as in feature 20260921-154310) on the 1,960-reaction model | identifyConservedReactingMoieties |
| FR-014, Edge Cases (labelling mismatch) | testExtractBondSubgraphs.m (`labelMismatch` case) | extractBondSubgraphs |
| US1 AS2 / FR-003, FR-004, FR-005, FR-006, SC-003 | profiler call-count report in the reproducibility check | extractBondSubgraphs |
| US3 AS1–AS2 / FR-009, SC-004, SC-005 | non-CI benchmark script (median of 3, log-log fit, control-flow assertion) | extractBondSubgraphs |
| FR-010, FR-013 | -- (static `git diff` review of help text, messages and memory structures; no test of its own) | -- (no source function) |
| SC-006 | testConservedReactingMoieties.m and the other tests in testReactingMoieties/ (unmodified) | identifyConservedReactingMoieties |
