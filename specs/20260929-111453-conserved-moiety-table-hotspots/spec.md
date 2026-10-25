# Feature Specification: Remove the per-edge and per-component table hotspots in `identifyConservedReactingMoieties`

**Feature Branch**: `20260929-111453-conserved-moiety-table-hotspots`

**Created**: 2026-09-29

**Status**: Draft

**Input**: User description: "Remove the remaining per-edge and per-component table/graph hotspots in `identifyConservedReactingMoieties` without changing any output. Three targets, one user story each, independently verifiable and droppable: (1) the ATG edge reorientation loop; (2) the two per-component `subgraph(ATG, atoms2component==i)` loops; (3) the per-moiety `subgraph(ABG, …)` loop. Outputs must be identical (`isequaln`) to the pre-change function; reuse the ordering contract, fixtures and verification approach of feature 20260928-100409. Success targets to be decided in clarify. Out of scope: `classifySubgraphIsomorphism`/`isisomorphic` label extraction, the `extractBondSubgraphs` residual, `findAndExtractMolecularGraphs`, the parked CoA-thioester symmetry issue, the latent non-termination in the preserved `extractBondSubgraphs` loop, and the stale 021/022 corpus paths."

<!--
  Not a characterization-mode feature (Constitution Principle III, "Characterization:
  Legacy Back-Fill Mode"): a behaviour-preserving performance change to a function that
  already has a test (testConservedReactingMoieties.m).
-->

## Background

After feature 20260928-100409, the conserved-moiety step on the 1,960-reaction `lowSymmetryRisk_2000rxn` model takes **817 s** unprofiled and 1,072 s profiled, and finds 736 moiety classes. The profile is at `~/repos/reconXmoieties/experiments/moietySizing/results/profile_conservedMoiety_lowSymmetryRisk_2000rxn_20260929_095230`, and it was taken at commit `858feabc1`.

Three places in `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` repeat work whose cost is proportional to a whole graph once per edge, per component or per moiety. Line numbers refer to commit `858feabc1`; profiled times are shown.

| Target | Lines | Repeats | Profiled time | What is repeated |
|---|---|---|---|---|
| 1. Reorient atom-transition edges | 424–435 | 19,952 reoriented edges | 319 s (30%) | Seven per-element writes and reads into `ATG.Edges` per edge (`HeadAtomIndex(i)`, `TailAtomIndex(i)`, `HeadAtom{i}`, `TailAtom{i}`, `Trans{i}`). Each write rebuilds the edge table inside the graph object. |
| 2. Per-component subgraphs | 594 and 1043 | 39,916 components, twice | 173 s (16%) | `subgraph(ATG, atoms2component==i)` scans the whole atom transition graph for every component, and the whole set is rebuilt a second time after moiety indices are added. |
| 3. Per-moiety graphs | 1152–1177 | 30,999 moieties | 115 s (11%) | `find(ABG.Nodes.MoietyIndex == m)` over all atoms, `subgraph(ABG, …)` over the whole atom-bond graph, then edge filtering and a graph rebuild, for every moiety. |

Together these are about 607 s of the 1,072 s profiled run (57%). All three have the same shape as the cost removed in feature 20260928-100409, where the equivalent change made `extractBondSubgraphs` 10× faster with identical outputs.

**Adjacent block** (not in the user's list): the moiety-index propagation at lines 1046–1066 takes about 64 s profiled (6%). It is a double loop over isomorphism classes × components (29,378,176 checks of `I2C(i,j)`), and an `ismember(ATG.Nodes.AtomIndex, …)` over every atom, once for each atom of every non-first component. Both parts grow roughly quadratically with model size. The block consumes the second set of per-component subgraphs (target 2). **It is included in Story 2** (see Clarifications), which brings the total targeted cost to about 671 s of the 1,072 s profiled run (63%).

## Clarifications

### Session 2026-09-29

- Q: Should the moiety-index propagation block (lines 1046–1066) be included in this feature? → A: **Yes, as part of Story 2.** It is the same pattern in the same code region, and it consumes the rebuilt component subgraphs.
- Q: What end-to-end target should the conserved-moiety step on the 1,960-reaction model meet? → A: **At most 65% of 817 s (about 531 s), median of 3 unprofiled runs, as a hard gate.**

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reorient atom-transition edges in one pass (Priority: P1)

As a researcher identifying conserved moieties on genome-scale subsets, I need the reoriented atom transitions to be updated in a single pass over the edge table rather than edge by edge. That way, the largest remaining cost in the conserved-moiety step (about 30% of the profiled run) disappears.

**Why this priority**: it is the single largest target, and it is the simplest to verify. The atom transition graph after this block must be exactly the same, and every later step reads from it.

**Independent Test**: run the pre-change and new functions on the same inputs, and compare the atom transition graph right after this block (all edge variables, row order and types), plus all outputs of `identifyConservedReactingMoieties`.

**Acceptance Scenarios**:

1. **Given** the CI fixture and the captured real-model inputs, **When** the conserved-moiety step runs, **Then** `arm`, `moietyFormulae` and `reacting` are identical to the pre-change function, in default and conserved-moieties-only modes.
2. **Given** inputs where some atom transitions are reoriented and others are not, **When** the block runs, **Then** exactly the reoriented edges have head and tail atom index, head and tail atom label, and transition label swapped. Every other edge, and every other variable, is unchanged.
3. **Given** inputs where no atom transition is reoriented, **When** the block runs, **Then** the atom transition graph is unchanged.

---

### User Story 2 - Build per-component subgraphs from their own rows, and propagate moiety indices without whole-graph scans (Priority: P2)

As the same researcher, I need each atom-conservation component's subgraph to be built from that component's own atoms and transitions, instead of scanning the whole atom transition graph once per component, twice. I also need the moiety indices of the first component in each isomorphism class to be copied to the other components of that class, and back into the atom transition graph, without the quadratic loops over classes × components and atoms × atoms.

**Why this priority**: the second-largest target: 16% for the subgraphs, plus 6% for the propagation. It uses the ordering contract proven in feature 20260928-100409.

**Independent Test**: compare each per-component subgraph with what the pre-change code produced (graph class, node table and edge table, including row order), and compare all outputs.

**Acceptance Scenarios**:

1. **Given** the same fixtures, **When** the conserved-moiety step runs, **Then** all outputs are identical to the pre-change function.
2. **Given** any component, **When** its subgraph is built, **Then** it equals the pre-change subgraph of that component: same nodes in the same order, and same edges in the same order with the same variables and values. This holds for both the first set (before isomorphism classification) and the second set (after moiety indices are added).
3. **Given** a component consisting of a single atom with no transitions, **When** its subgraph is built, **Then** it equals the pre-change one-node, zero-edge subgraph.
4. **Given** isomorphism classes with several member components, **When** moiety indices are propagated, **Then** `ATG.Nodes.MoietyIndex` and the second set of component subgraphs, including their `MoietyIndex` values, are identical to the pre-change result.

---

### User Story 3 - Build per-moiety graphs from their own rows (Priority: P3)

As the same researcher, I need each moiety's molecular graph to be built from that moiety's own atoms and internal bonds, instead of searching all atoms and extracting a subgraph of the whole atom-bond graph once per moiety.

**Why this priority**: the third target (11%). It produces a user-visible output, `arm.MG`.

**Independent Test**: compare `arm.MG` element by element with the pre-change output, and compare all other outputs.

**Acceptance Scenarios**:

1. **Given** the same fixtures, **When** the conserved-moiety step runs, **Then** `arm.MG` has the same number of graphs, in the same order, and every graph has the same class and the same node and edge tables (row order, variables, values) as before.
2. **Given** a moiety whose atoms have no internal bonds, **When** its graph is built, **Then** it matches the pre-change graph with no edges.
3. **Given** atoms whose moiety index is 0, if any exist, **When** the moiety graphs are built, **Then** the handling of index 0 is identical to the pre-change loop, which iterates over every distinct `MoietyIndex` value.

---

### Edge Cases

- **No reoriented edges** (Story 1): the atom transition graph is unchanged. The `warning` about reoriented edges earlier in the function is untouched.
- **Every edge reoriented** (Story 1): all rows are swapped.
- **Empty or multi-character atom labels** (Story 1): the transition label is exactly `[HeadAtom '#' TailAtom]`, character for character, with no trimming of whitespace.
- **Parallel atom transitions** within a component (Story 2): edge row order matches the pre-change subgraph (ties kept in original row order).
- **Single-atom components and components without transitions** (Story 2).
- **The component list must not be taken from the wrong labelling**: `atoms2component` comes from `conncomp(ATG)`, and ATG is undirected here, so no transition joins two components.
- **Moiety index 0** (Story 3): atoms not assigned to any moiety, if present, form their own group exactly as `unique(ABG.Nodes.MoietyIndex)` gives it today.
- **Bonds between different moieties or reacting bonds** (Story 3): they have `MoietyBondIndex` 0 (or another moiety's index) and never appear in another moiety's graph. This is unchanged.
- **`sanityChecks = 1`**: every sanity check still runs, reads the same values and raises the same errors or warnings.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The public signature of `identifyConservedReactingMoieties` and its outputs must not change (Constitution Principle II).
- **FR-002**: For every input, `arm`, `moietyFormulae` and `reacting` must be identical (`isequaln`, with the same field names, graph classes, and table variables, types, row order and values) to those of the pre-change function (commit `858feabc1`), in default and `conservedMoietiesOnly` modes, with `sanityChecks` 0 and 1.
- **FR-003** *(Story 1)*: The reorientation of atom transitions must not write to `ATG.Edges` once per edge. It must produce an atom transition graph identical to the pre-change one immediately after that block. The cost must be proportional to the number of edges, with a constant number of whole-table reads and writes.
- **FR-004** *(Story 2)*: Building the per-component subgraphs must not call `subgraph` on the whole atom transition graph once per component. Each component's subgraph must be built from that component's own node and edge rows, grouped once. It must be identical to what `subgraph(ATG, atoms2component==i)` returns, in both places where the component subgraphs are built.
- **FR-004a** *(Story 2)*: The moiety-index propagation (lines 1046–1066 at `858feabc1`) must not loop over every isomorphism class × every component, and must not search all atoms once per atom. It must give an identical `ATG.Nodes.MoietyIndex`, and identical second-set component subgraphs, including their `MoietyIndex` values. Its cost must be linear in the number of atoms and components.
- **FR-005** *(Story 3)*: Building the per-moiety graphs must not search all atoms or call `subgraph` on the whole atom-bond graph once per moiety. Each moiety's graph must be built from that moiety's own atoms and internal bonds, grouped once, and must be identical to the pre-change `MG{i}`.
- **FR-006**: Every `warning`, `error` and printed message must keep its text, its condition and its order. Every `sanityChecks` block must still run on identical data.
- **FR-007**: Each story must be independently revertible. If a story cannot meet FR-002 on every fixture, it is removed from the feature, and the reason is recorded in the implementation receipt. The other stories still ship.
- **FR-008**: The existing test `testConservedReactingMoieties.m` must be extended, not duplicated (Constitution III-Naming). It must compare the outputs of the CI fixture with a golden reference captured from the pre-change function before the source is edited, and it must cover reoriented edges and moieties without internal bonds, which the coaX and crnM fixtures contain (research R6). Single-atom components, `digraph` inputs and parallel edges never occur in pipeline fixtures. They are covered by the unit test of the shared partition-subgraph helper, `testExtractPartitionSubgraphs.m` (a new file, per Constitution III: a new module ships with its test).
- **FR-009**: The narrowest reproducibility check that proves the feature is the output equality in FR-002 on:
  - the CI fixture;
  - the 8 subsystem fixtures of `reactingOptimisationReproducibilityCheck.m` (feature 20260921-154310), default and conserved-only modes;
  - the 1,960-reaction model, end to end.

  It is delivered as a documented, non-CI script in this feature's directory, reusing the approach of feature 20260928-100409: golden outputs captured from unchanged code, fingerprints for large outputs, and a verbatim pre-change copy for back-to-back timing.
- **FR-010**: Any new data structure must be linear in the number of atoms, transitions and bonds. No structure may be built whose size is the product of two of these (Constitution Principle IV).
- **FR-011**: The function's help text must be updated where it describes behaviour that changed, in the existing style (Constitution VII-E). If no described behaviour changes, a `.. Author:` provenance line is added only.

### Key Entities *(include if feature involves data)*

- **Atom transition graph (ATG)**: an undirected graph of atoms (nodes) and atom transitions (edges). Edge variables include `EndNodes`, `HeadAtomIndex`, `TailAtomIndex`, `HeadAtom`, `TailAtom`, `Trans`, `orientationATG2dATM` and others. Node variables include `AtomIndex`, `mets`, `Element`, `MoietyIndex`, `Component`, `IsomorphismClass` and `IsCanonical`.
- **Reorientation mask**: the atom transitions whose orientation relative to the directed atom transition multigraph is −1. These are the only rows that Story 1 changes.
- **Atom-conservation component**: a connected component of ATG (`atoms2component`). There are 39,916 on the 1,960-reaction model. It is the unit of Story 2.
- **Atom-bond graph (ABG)**: an undirected graph with ATG's nodes and BIG's bond edges plus `MoietyBondIndex`. It is the source of the moiety graphs in Story 3.
- **Partition-subgraph helper** (`extractPartitionSubgraphs`, new, internal): given a graph, a label per node and optionally a mask of eligible edges, it returns the subgraph of every part, in ascending label order, identical to what `subgraph` gives for that part's nodes. Stories 2 and 3 both use it. It has no other caller.
- **Moiety graph (`MG{i}`, output as `arm.MG`)**: one per distinct `MoietyIndex` value, containing that moiety's atoms and the bonds with `MoietyBondIndex` equal to it. There are 30,999 on the 1,960-reaction model.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `arm`, `moietyFormulae` and `reacting` are identical to the pre-change function on the CI fixtures (main in both modes with `sanityChecks` 0 and 1; coaX and crnM, conserved-only), on all 8 subsystem fixtures in both modes, plus the tyr and ci sanity snapshots, and on the 1,960-reaction model in conserved-only mode. Default mode on the 1,960-reaction model is not run: its reacting-moiety MILP stage is outside this feature's runtime scope, and the changed blocks run identically before that stage in both modes.
- **SC-002**: The profiler on the 1,960-reaction model shows no per-edge writes to the atom transition graph in the reorientation block, 0 calls to `subgraph` on the whole atom transition graph from the per-component loops, and 0 calls to `subgraph` on the atom-bond graph from the per-moiety loop. Calls are counted only for the stories that ship.
- **SC-003** *(hard gate)*: The unprofiled conserved-moiety step on the 1,960-reaction model takes at most 65% of its pre-change time: about 531 s against 817 s. The pre-change time is re-measured back to back by this feature's benchmark as the median of 3 runs, so the gate is a ratio of at most 0.65.
- **SC-004** *(reported, not a gate)*: Each shipped story's block, measured on its own on the 1,960-reaction model, is reported as a new/old time ratio. Research R1 projects about 0.003 for the reorientation, about 0.23 per component-subgraph set, and about 0.11 for the moiety graphs. The last two are limited by the `graph` constructor that identical outputs require. A ratio above 0.30 for any block is investigated before completion.
- **SC-005**: All tests under `test/verifiedTests/analysis/testReactingMoieties/` pass, including the extended `testConservedReactingMoieties`.

## Assumptions

- **Base commit**: `858feabc1` (the committed 20260928-100409 feature). Golden references are captured from it before any source edit.
- **ATG is undirected**: `identifyConservedReactingMoieties` builds it with `graph(...)`, so connected components are closed under its edges, and the ordering contract for `graph` from feature 20260928-100409 applies: node order follows the index list, and edge rows are stable-sorted by local `[min max]` end nodes.
- **Existing captures**: the 1,960-reaction captures and the subset model builder from feature 20260928-100409 are available locally. New captures for this feature go into a sibling directory of that feature's results tree.
- **Environment**: MATLAB R2024b Update 8 is the reference environment. Its `graph` table constructor and `subgraph` ordering are CI-tested by `testExtractBondSubgraphs`.

## Out of Scope

- `classifySubgraphIsomorphism` and `isisomorphic` label-extraction overhead (22% of the profiled run); planned as a separate feature.
- The remaining cost of `extractBondSubgraphs` (10%) and of `findAndExtractMolecularGraphs` (5%).
- The parked CoA-thioester symmetry issue.
- The latent non-termination of the preserved `extractBondSubgraphs` loop for mismatched component labels.
- The stale corpus paths in the feature 021 and 022 reproducibility checks.
- Any change to the content or structure of the outputs.

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1–US3 / FR-001, FR-002, FR-008, SC-001 (CI fixture) | testConservedReactingMoieties.m (extended, golden comparison) | identifyConservedReactingMoieties |
| US1 AS2–AS3, US2 AS2–AS4, US3 AS2–AS3 / FR-003, FR-004, FR-004a, FR-005 | testConservedReactingMoieties.m (extended: reoriented edges, moieties without internal bonds, multi-member classes); testExtractPartitionSubgraphs.m (single-node parts, parts without edges, `digraph`, parallel edges, edge masks) | identifyConservedReactingMoieties, extractPartitionSubgraphs |
| FR-004, FR-005 (helper contract) | testExtractPartitionSubgraphs.m (new) | extractPartitionSubgraphs |
| FR-002, FR-009, SC-001 (8 subsystems, 1,960 reactions) | non-CI reproducibility check in this feature's directory, plus reactingOptimisationReproducibilityCheck.m | identifyConservedReactingMoieties |
| SC-002, SC-003, SC-004 | non-CI benchmark and profiler call counts in this feature's directory | identifyConservedReactingMoieties |
| FR-006, FR-010, FR-011 | -- (static `git diff` review; no test of its own) | -- (no source function) |
| FR-007 | -- (per-story revert points recorded in the results file) | -- (no source function) |
| SC-005 | all tests in testReactingMoieties/ | identifyConservedReactingMoieties and callers |
