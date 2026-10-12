# Feature Specification: Exact isomorphism for near-symmetric bond components, and reading RXN reactions with no bonds

**Feature Branch**: `20261012-093525-symmetric-iso-zero-bond`

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: target two COBRA-side blockers found in reconXmoieties while removing hydrogens from atom-mapped RXN files (KI-001): (1) the unlabelled `isisomorphic` call in `classifySubgraphIsomorphism` does not finish on large, sparse, near-identical bond components that arise from parallel stereoisomeric branches, even with hydrogens removed; (2) `readABRXNFile` fails on a reaction in which no molecule has a bond (water, ammonium, ion transports in implicit-hydrogen form). Maintainer decision 2026-10-12 (reconXmoieties spec 033, FR-006): fix the reader here, on the same branch as the classifier fix.

**Evidence**: reconXmoieties exploration `specs/20261012-080033-ki001-hydrogen-stripping/exploration.md` (branch `explore/ki001-hydrogen-stripping`), entries E7 and E9–E11, and the feasibility tests of 2026-10-12 recorded under Background.

## Background

`KNOWN_ISSUES.md` KI-001 records that the bond-level stage of `identifyConservedReactingMoieties` can fail to finish because two bond components that differ only in arbitrary hydrogen pairing defeat `isisomorphic`. reconXmoieties removed hydrogens from the RXN files as a test. That made the bond-level stage finish on pufa n = 495 and on fatty acid synthesis, but the full pufa subsystem still did not finish:

- smallest failing prefix n = 514 (trigger `15DPGJ2GCSHL`); the stuck unlabelled call compares two bond components of 318 nodes and 337 edges (309 O, 9 C) spanning 227 eicosanoid metabolites, which differ only in 6 glutathione-conjugate metabolites of mirrored branches;
- restricted to one element, both components are isomorphic and decided in under 0.1 s; the whole-graph unlabelled call does not return within 60 min;
- feasibility, on the saved pair (MATLAB R2024b, N = 1 each): joint 1-WL colour refinement takes 0.06 s and gives equal colour histograms, but `isisomorphic` with those colours as node labels still does not finish in 15 min; an exact individualisation–refinement test decides the pair (isomorphic) in 0.33 s with 163 search nodes, the returned permutation verifies, a random permutation of the same graph is decided in 0.26 s, and a one-edge change is rejected in 0.003 s.

Separately, in implicit-hydrogen form water, ammonium, hydroxide, sulfide and metal ions are single heavy atoms with no bonds. `readABRXNFile` fails ("Array indices must be positive integers or logical values", around the bond-table construction) on a reaction in which no molecule has a bond; 31 such reactions exist in the reconXmoieties std corpus once hydrogens are absent.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The bond-level classification finishes on near-symmetric components (Priority: P1)

A researcher runs `identifyConservedReactingMoieties` with `computeMoietyGraphs = true` on a lipid-heavy network whose bond components include large, near-identical pairs. The classification decides every pair exactly and finishes.

**Why this priority**: Without it, moiety graphs (conserved-bond topologies) cannot be computed for lipid-heavy networks, with or without hydrogens; this is the remaining blocker after KI-001's hydrogen part.

**Independent Test**: Call `classifySubgraphIsomorphism` on the saved stuck pair (as a two-subgraph cell array) and check it returns one isomorphism class within the time bound; then run the pufa prefix n = 514 (hydrogen-free RXN files) with moiety graphs on.

**Acceptance Scenarios**:

1. **Given** the saved 318-node pair, **When** it is classified without labels, **Then** both subgraphs are put in one isomorphism class within 5 s.
2. **Given** a graph and a random relabelling of its nodes, **When** classified, **Then** they are one class; **given** the same graph with one edge moved, **Then** they are two classes.
3. **Given** the existing golden references (`classifySubgraphIsomorphismReference.mat`, `conservedReactingMoietiesReference.mat`), **When** the tests run, **Then** every output is identical to the reference.

---

### User Story 2 - RXN reactions with no bonds are read (Priority: P2)

A researcher builds the atom transition network from implicit-hydrogen RXN files that include water, ammonium or ion transports. Those reactions are read like any other: their atoms and atom transitions are present, their bond table is empty, and the build continues.

**Why this priority**: Required by reconXmoieties spec 033 (implicit-hydrogen corpus); without it, every hydrogen-free corpus loses its water and ion transports or fails to build.

**Independent Test**: Read a minimal RXN fixture (a water transport with one O atom per side and no bonds) with `readABRXNFile`, and build the atom and bond transition multigraph for a two-reaction model containing it.

**Acceptance Scenarios**:

1. **Given** an RXN file in which no molecule has a bond, **When** `readABRXNFile` reads it, **Then** it returns the atom table (with mappings) and an empty bond table with the documented variables, without error.
2. **Given** a model containing such a reaction, **When** `buildAtomAndBondTransitionMultigraph` runs, **Then** the reaction's atom transitions appear in the atom graph, it contributes no bond transitions, and the build completes.
3. **Given** existing explicit-hydrogen RXN files, **When** read, **Then** the outputs are identical to the current behaviour.

### Edge Cases

- Subgraphs with parallel edges, self-loops or directed edges: the exact test must respect them exactly as `isisomorphic` does on the label-only copies (multiplicity, loops, direction).
- Labelled calls (`'NodeVariables'` / `'EdgeVariables'` in `varargin`): behaviour and results must not change; the new exact test may be used for them only if it reproduces `isisomorphic` exactly, including label semantics.
- Highly regular graphs on which individualisation–refinement branches widely: the test must stay exact; a time or node budget, if any, must never turn an undecided pair into a wrong answer (falls back to the current call, and records that it did).
- Empty subgraphs and single-node subgraphs.
- An RXN file with some molecules bonded and others not (already handled today) must be unaffected.
- A reaction whose molecules are all hydrogen-free single atoms on one side and bonded on the other cannot occur (atoms are conserved), but must not crash the reader if met.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `classifySubgraphIsomorphism` MUST decide unlabelled candidate pairs with an exact isomorphism test that does not stall on large near-symmetric sparse graphs (individualisation–refinement with joint colour refinement, or an equivalent exact method). The resulting isomorphism classes MUST be identical to those an always-terminating `isisomorphic` would give.
- **FR-002**: The exact test MUST respect edge multiplicity, self-loops and direction as in the label-only copies the function already compares.
- **FR-003**: Labelled comparisons (any `'NodeVariables'`/`'EdgeVariables'` in `varargin`) MUST keep their current results; whether they also use the new test is a plan decision, allowed only if results are provably unchanged.
- **FR-004**: `readABRXNFile` MUST accept a reaction in which no molecule has a bond and return an empty bond table with the same variables and types as a non-empty one.
- **FR-005**: `buildAtomAndBondTransitionMultigraph` MUST build when one or more reactions contribute no bonds.
- **FR-006**: System MUST preserve documented public interfaces, diagnostic semantics, and file-location conventions affected by this feature: the signatures and outputs of `classifySubgraphIsomorphism`, `readABRXNFile` and their callers are unchanged.
- **FR-007**: System MUST define the narrowest reproducibility check or test that proves the feature behavior: unit tests on the saved stuck pair (stored as a small test data file), on permuted and perturbed graphs, on multigraph/loop/direction cases, and on a zero-bond RXN fixture; the existing golden tests must pass unchanged.
- **FR-008**: System MUST state measurable performance or numerical-integrity constraints when the feature affects solver behavior, scaling, residuals, diagnostics, or generated output volume: the classification time on the 1,960-reaction model used by feature 20260930-102230 must not increase by more than 10%, and the saved stuck pair must be decided within 5 s.
- **FR-009**: `KNOWN_ISSUES.md` KI-001 MUST be updated with the hydrogen-removal evidence and this second, hydrogen-independent mechanism, and with what this feature resolves.

### Key Entities

- **Bond component pair**: two subgraphs compared during classification; the saved stuck pair (318 nodes, 337 edges each) is the regression fixture.
- **Zero-bond RXN fixture**: a minimal implicit-hydrogen transport reaction with single-atom molecules.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The saved stuck pair is classified as one isomorphism class in at most 5 s (MATLAB R2024b, N = 3 repeats, maximum reported).
- **SC-002**: All existing tests in `test/verifiedTests/analysis/testReactingMoieties/` pass with outputs identical to their golden references.
- **SC-003**: Conserved-moiety identification with `computeMoietyGraphs = true` on reconXmoieties' hydrogen-free pufa prefix n = 514 finishes (it does not finish today in 30 min); the full pufa subsystem result is reported (finishes, or the next blocking pair is identified).
- **SC-004**: A reaction with no bonds is read and built without error, and its atom transitions appear in the atom graph (unit test).
- **SC-005**: Classification time on the 1,960-reaction model changes by no more than +10% against the current code (N = 3 each, median reported).

## Assumptions

- The saved pair (`lastUnlabelledPair_noH.mat`, label-only copies plus full subgraphs) is small enough to store as test data.
- Individualisation–refinement is exact; its cost is small on graphs from metabolic networks; a bounded fallback to the current call keeps correctness if it ever branches widely.
- The hydrogen-free RXN files used for SC-003 come from reconXmoieties (`results/ki001_strip_h/atomMapped_std_noH`, test device) until the implicit-hydrogen corpus of reconXmoieties spec 033 exists.
- Changing hydrogen handling in the RXN data is out of scope here (reconXmoieties spec 033).

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1, FR-001, SC-001 | testClassifySubgraphIsomorphism (stuck-pair case) | src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism |
| US1-2, FR-001 | testClassifySubgraphIsomorphism (permuted / one-edge-moved cases) | src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism |
| FR-002 | testClassifySubgraphIsomorphism (multigraph, self-loop, directed cases) | src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism |
| US1-3, FR-003, FR-006, SC-002 | testClassifySubgraphIsomorphism, testConservedReactingMoieties (golden references) | src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism |
| US2-1, FR-004, SC-004 | testReadABRXNFile (zero-bond fixture) | src/analysis/topology/reactingMoieties/readABRXNFile |
| US2-2, FR-005 | testBuildAtomAndBondTransitionMultigraph (two-reaction zero-bond model) | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph |
| US2-3, FR-006 | testReadABRXNFile (existing explicit-H fixture unchanged) | src/analysis/topology/reactingMoieties/readABRXNFile |
| FR-008, SC-005 | timing check on the 1,960-reaction model (reproducibility script) | — (no source function) |
| SC-003 | reconXmoieties pufa n = 514 run (external reproducibility check) | — (no source function) |
| FR-009 | KNOWN_ISSUES.md KI-001 update | — (no source function) |
