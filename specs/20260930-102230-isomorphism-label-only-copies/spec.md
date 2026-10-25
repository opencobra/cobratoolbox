# Feature Specification: Classify isomorphism on label-only copies

**Feature Branch**: `20260930-102230-isomorphism-label-only-copies`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "classify isomorphism on label-only copies". Context: re-profile of the 1,960-reaction model at commit `f4a62639e`, and a research probe run on 2026-09-30.

<!--
  Not a characterization-mode feature (Constitution Principle III, "Characterization:
  Legacy Back-Fill Mode"): a behaviour-preserving performance change to a function that
  already has a test (testClassifySubgraphIsomorphism.m).
-->

## Background

After features 20260928-100409 and 20260929-111453, the conserved-moiety step on the 1,960-reaction `lowSymmetryRisk_2000rxn` model takes about 364 s (median) unprofiled. The re-profile at `f4a62639e` is in `~/repos/reconXmoieties/experiments/moietySizing/results/profile_conservedMoiety_lowSymmetryRisk_2000rxn_20260930_094259`. It shows `classifySubgraphIsomorphism` at **350 s of 603 s profiled (58%)**.

Almost all of that is `isisomorphic`: 122,451 calls, 328 s. Of this, 273 s (45% of the whole run) is MATLAB's `extractVarProp`, which re-reads the label variable out of each graph's full node or edge table on every call. The subgraphs being compared carry every variable of their parent graph (8 node variables and 19 edge variables for the component subgraphs), but only one variable takes part in the comparison.

`classifySubgraphIsomorphism` is the shared classification helper for three callers:

| Caller | Comparison | Profiled time |
|---|---|---|
| `identifyConservedReactingMoieties` (component subgraphs, 39,916) | `'NodeVariables', 'mets'` | 309 s |
| `identifyIsomorphicClasses` (conserved bond subgraphs) | `'EdgeVariables', 'mets'` | 29 s |
| `findAndExtractMolecularGraphs` (bond subgraphs) | plain structure, no label variables | 12 s |

**Research probe** (`research-prototype/probeIsomorphismLabels.m`, real n1960 data): classifying the 39,916 component subgraphs took **248.8 s** unprofiled on the full subgraphs. On copies that carry only the `mets` node variable it took **25.5 s**: 7.7 s to build the copies plus 17.8 s to classify, a ratio of 0.10. The classification was **identical**: the same 736 classes, the same first members and the same class numbers. Node and edge counts were preserved in every copy.

## Clarifications

### Session 2026-09-30

- Q: What end-to-end gate should the conserved-moiety step on the 1,960-reaction model meet? → A: **At most 0.60 of the pre-change time, median of 5 alternating unprofiled runs, as a hard gate.**

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Compare only the labels that matter (Priority: P1)

As a researcher running conserved-moiety identification on genome-scale models, I need the isomorphism classification to compare graphs that carry only the variables used in the comparison. The comparison then no longer pays, on every candidate pair, for tables of variables it ignores, and the largest remaining cost of the conserved-moiety step (58% of the profiled run) mostly disappears.

**Why this priority**: it is the single largest target. All three callers benefit through the one shared helper, with no change to the callers.

**Independent Test**: classify the same subgraphs with the pre-change and new helper, compare all three outputs exactly, and compare the end-to-end outputs of `identifyConservedReactingMoieties`.

**Acceptance Scenarios**:

1. **Given** the 39,916 real component subgraphs of the 1,960-reaction model, **When** they are classified with `'NodeVariables', 'mets'`, **Then** `isomorphismClasses`, `firstSubgraphIndices` and `subsequentSubgraphIndices` are identical to the pre-change helper.
2. **Given** subgraphs compared with `'EdgeVariables', 'mets'`, or with no label variables, **When** they are classified, **Then** the outputs are identical to the pre-change helper.
3. **Given** the CI fixtures, the 8 subsystem fixtures and the 1,960-reaction model, **When** `identifyConservedReactingMoieties` runs, **Then** `arm`, `moietyFormulae` and `reacting` are identical to the pre-change function.
4. **Given** the diagnostic call counter (`'resetCallCount'`, `'getCallCount'`), **When** the same subgraphs are classified, **Then** the counter reports the same number of `isisomorphic` calls as before.

---

### Edge Cases

- **Directed graphs** (`digraph`): the label-only copy is a `digraph` with the same edges and directions.
- **Multigraphs and self-loops**: parallel edges and self-loops are kept exactly, so the copy has the same node count and edge count and the same adjacency.
- **Option values that are not a single name**: the pre-change helper reads the label invariant with a dynamic table reference, so a cell value such as `{'mets'}` (and therefore any multi-variable value) already raises `MATLAB:table:IllegalVarSubscript`. A string scalar such as `"mets"` works. Both behaviours are kept exactly (research R3).
- **Both node and edge variables requested**: both are kept.
- **No label variables** (plain structural comparison): the copy keeps no variables beyond the edges.
- **Named nodes**: node names are not part of an `isisomorphic` comparison unless requested, so the copy keeps a `Name` variable only when it is one of the requested variables.
- **A requested variable missing from a subgraph**: the error is raised exactly as before (same message, same point), before any pair is compared.
- **Empty inputs** (0 or 1 subgraphs), the diagnostic actions (`'resetCallCount'`, `'getCallCount'`), and unknown actions behave exactly as before.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The public signature and outputs of `classifySubgraphIsomorphism` must not change (Constitution Principle II), and nor must those of its three callers.
- **FR-002**: For every input, `isomorphismClasses`, `firstSubgraphIndices` and `subsequentSubgraphIndices` must be identical (`isequal`) to those of the pre-change helper (commit `f4a62639e`).
- **FR-003**: Every `isisomorphic` comparison must be made on copies of the two subgraphs that carry only the variables named in the call's `NodeVariables` and `EdgeVariables` options (none when neither is given). Each copy has the same graph class, node count, edges, edge directions, parallel edges and self-loops as the original. Each copy is built once per subgraph, not once per comparison.
- **FR-004**: The structural invariants (node count, edge count, sorted label multisets) and the order and set of candidate pairs must be unchanged, so the diagnostic `isisomorphic` call count is unchanged.
- **FR-005**: Any error raised for invalid input (for example a requested label variable missing from a subgraph) must keep its identifier, message and the point at which it is raised.
- **FR-006**: No message text changes. The outputs of `identifyConservedReactingMoieties`, `identifyIsomorphicClasses` and `findAndExtractMolecularGraphs` must be identical to before on every input.
- **FR-007**: The existing test `testClassifySubgraphIsomorphism.m` must be extended, not duplicated (Constitution III-Naming). It must cover `graph` and `digraph` inputs, parallel edges, self-loops, subgraphs with many extra node and edge variables, each of the three comparison modes, a cell-valued option (same error as before), a string-valued option, the missing-variable error, and the call-count diagnostic. Each case compares against expected classifications computed with the pre-change helper, captured before the source is edited.
- **FR-008**: The narrowest reproducibility check that proves the feature is:
  - the classification equality in FR-002 on the real 1,960-reaction component subgraphs;
  - end-to-end output equality on the 1,960-reaction model;
  - `reactingOptimisationReproducibilityCheck.m` (8 subsystems, default and conserved-only);
  - the golden comparisons in `testConservedReactingMoieties`.

  It is delivered as a documented, non-CI script in this feature's directory, reusing the approach and local fixtures of features 20260928-100409 and 20260929-111453.
- **FR-009**: Any extra memory must be linear in the total size of the subgraphs: one label-only copy per subgraph.
- **FR-010**: The helper's `NOTE` help text must describe the label-only comparison, in the existing style (Constitution VII-E).

### Key Entities *(include if feature involves data)*

- **Subgraph list**: the cell array of `graph`/`digraph` objects passed to `classifySubgraphIsomorphism`, each with arbitrary node and edge variables.
- **Label-only copy**: one per subgraph. It has the same graph class, nodes and edges, and carries only the requested `NodeVariables`/`EdgeVariables`. It is used only for the `isisomorphic` comparisons and never returned.
- **Comparison options**: the `NodeVariables`/`EdgeVariables` name-value pairs forwarded to `isisomorphic` (a variable name, or several).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Classification outputs are identical to the pre-change helper on the real 1,960-reaction component subgraphs and on every new CI case. The outputs of `identifyConservedReactingMoieties` are identical on the CI golden cases, on the 8 subsystem fixtures in both modes, and on the 1,960-reaction model in conserved-only mode.
- **SC-002**: The classification of the 39,916 component subgraphs of the 1,960-reaction model, including building the copies, takes at most 20% of its pre-change time, unprofiled. The research probe measured 10%. This is reported, not a gate.
- **SC-003** *(hard gate)*: The unprofiled conserved-moiety step on the 1,960-reaction model takes at most 60% of its pre-change time (about 218 s against about 364 s). Both are measured back to back by this feature's benchmark as the median of 5 alternating runs, so the gate is a ratio of at most 0.60. The research projects about 0.40. A gate run whose timings are inconsistent (any run more than 1.5× the median of its siblings, for example because of other load on the machine) is repeated rather than judged, and both runs are recorded.
- **SC-004**: The diagnostic `isisomorphic` call count is unchanged: 39,204 at the component call site, and the same total across all three call sites in one end-to-end run on the 1,960-reaction model (the profile recorded 122,451).
- **SC-005**: All tests under `test/verifiedTests/analysis/testReactingMoieties/` pass, including the extended `testClassifySubgraphIsomorphism`.

## Assumptions

- **Base commit**: `f4a62639e`. Expected classifications and golden references are captured from it before any source edit.
- **`isisomorphic` behaviour**: with `NodeVariables`/`EdgeVariables` it compares only the named variables, and without them it compares structure only. Variables it doesn't name have no effect on the answer. The research probe confirmed this on real data, and the new CI cases assert it.
- **Reusable fixtures**: the local 1,960-reaction captures of the previous two features (component subgraphs rebuilt from `n1960-inputs.mat`; identify inputs `n1960-identifyInputs.mat`; end-to-end golden `n1960-endToEnd-golden.mat`) are reused. Feature 20260929-111453 proved that its outputs equal that golden.
- **Environment**: MATLAB R2024b Update 8 is the reference environment.

## Out of Scope

- The remaining costs of `extractBondSubgraphs` (about 18% profiled), `extractPartitionSubgraphs` (about 12%) and the repeated `.Edges` reads in `findAndExtractMolecularGraphs` (about 24 s).
- The pre-existing `sanityChecks` defect in `identifyIsomorphicClasses.m:34`.
- The parked CoA-thioester symmetry issue.
- Any change to the classification algorithm itself (pair order, invariants, class numbering).

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 AS1–AS2, AS4 / FR-002–FR-005, FR-007, SC-001, SC-004 (CI cases) | testClassifySubgraphIsomorphism.m (extended) | classifySubgraphIsomorphism |
| US1 AS3 / FR-006, SC-001 (CI golden) | testConservedReactingMoieties.m (existing golden comparison) | identifyConservedReactingMoieties |
| US1 AS1, AS3 / FR-008, SC-001, SC-004 (1,960-reaction model, 8 subsystems) | non-CI check in this feature's directory, plus reactingOptimisationReproducibilityCheck.m | classifySubgraphIsomorphism, identifyConservedReactingMoieties |
| SC-002, SC-003 | non-CI benchmark in this feature's directory | classifySubgraphIsomorphism, identifyConservedReactingMoieties |
| FR-001, FR-009, FR-010 | -- (static `git diff` review) | -- (no source function) |
| SC-005 | all tests in testReactingMoieties/ | classifySubgraphIsomorphism and callers |
