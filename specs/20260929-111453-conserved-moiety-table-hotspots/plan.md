# Implementation Plan: Remove the per-edge and per-component table hotspots in `identifyConservedReactingMoieties`

**Branch**: `20260929-111453-conserved-moiety-table-hotspots` | **Date**: 2026-09-29 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20260929-111453-conserved-moiety-table-hotspots/spec.md`

## Summary

Three blocks of `identifyConservedReactingMoieties` repeat whole-graph work per edge, per component or per moiety. Together they are about 63% of the profiled 1,960-reaction run. This plan replaces them with constructions that read each table once:

1. **Story 1 (reorientation)**: five whole-column writes built from a mask, instead of seven per-edge writes for each of 19,952 edges.
2. **Story 2 (components and propagation)**:
   - The component subgraphs, at both sites, are built by a new helper, `extractPartitionSubgraphs`. It groups nodes and edges once and builds each part from its own rows. Those rows are already in `subgraph`'s order, because the index lists are ascending (research R3).
   - The moiety-index propagation loops over class members and writes each component's atoms directly (R5).
3. **Story 3 (moiety graphs)**: the same helper, with an edge mask that keeps only each moiety's internal bonds.

A probe on the real 1,960-reaction ATG gave identical results for all three, and unprofiled savings of about 181 s, 2 × 57 s and ~90 s (R1). That projects the step at 48–53% of 817 s, against the 0.65 gate.

## Technical Context

**Language/Version**: MATLAB R2024b Update 8 (reference environment).

**Primary Dependencies**: base MATLAB `graph`/`digraph` and tables only. No solver change. The default mode's reacting-moiety MILP is unaffected.

**Storage**:
- **CI golden data**: `test/verifiedTests/analysis/testReactingMoieties/data/conservedReactingMoietiesReference.mat` (≤ 1 MB target).
- **Local data**: `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/conservedMoietyHotspots/`, holding the n1960 identify inputs and results. The n1960 golden is reused from `…/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat` (R7).

**Testing**:
- `testConservedReactingMoieties.m`, extended with golden comparisons.
- `testExtractPartitionSubgraphs.m`, new, for the new helper (Constitution III: a new module ships with its test).
- A non-CI check and benchmark script in this directory, plus `reactingOptimisationReproducibilityCheck.m`.

**Target Platform**: headless Linux. The code is platform-independent.

**Project Type**: scientific MATLAB library.

**Performance Goals**:
- **SC-003 (gate)**: new/baseline median ratio ≤ 0.65 on n1960 (conservedOnly, unprofiled, 3 alternating runs).
- **SC-004 (reported)**: each block ≤ 10% of its old cost.
- **SC-002**: profiler counts from `identifyConservedReactingMoieties`: `graph.subgraph` falls from 110,832 to ≤ 1, and `graph.subsasgn` from 271,845 to a count that doesn't grow with the number of edges.

**Constraints**:
- Outputs identical under `isequaln` in both modes and both `sanityChecks` settings.
- No message changes.
- Linear memory.
- Each story revertible on its own.

**Scale/Scope**: n1960 has 132,884 atoms, 101,792 transitions, 39,916 components and 30,999 moieties. One source file is edited (`identifyConservedReactingMoieties.m`, 1,776 lines), and one source file is new (`extractPartitionSubgraphs.m`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: no formulation change. The signature and outputs are unchanged (FR-001, Principle II). The new helper is internal, and has no caller other than `identifyConservedReactingMoieties`. **PASS**
- **Testing and reproducibility**:
  - **CI**:
    - `testConservedReactingMoieties` gains golden comparisons for six fixture/mode combinations (main in both modes with `sanityChecks` 0 and 1, coaX, crnM) that cover reoriented edges, moiety graphs without edges, and multi-member classes (R6).
    - `testExtractPartitionSubgraphs` checks the helper against `subgraph`, including single-node parts, `digraph` inputs and edge masks.
  - **Non-CI evidence**: n1960 end-to-end, the 8-subsystem check in both modes plus sanity mode, and timing, all documented in this directory.

  **PASS**
- **User experience and diagnostics**: no message text, condition or order changes. The `sanityChecks` blocks are untouched and read identical data (FR-006). **PASS**
- **Performance and numerical integrity**: the outputs are discrete, and equality is `isequaln`. Performance is subordinate: every story is reverted if FR-002 fails. **PASS**
- **External-solver configuration audit**: N/A. The graph-library defaults are audited in R8. **PASS**
- **Spec-driven scope control**:
  - **Edited**:
    - `identifyConservedReactingMoieties.m` at three sites: lines 425–435; 592–595 and 1041–1044; 1046–1066; and 1152–1177 (all at `858feabc1`);
    - its help header, with a `.. Author:` line only (FR-011; no described behaviour changes).
  - **New**: `src/analysis/topology/reactingMoieties/extractPartitionSubgraphs.m`, placed beside its only caller (Principle IX).
  - **Read-only**: every other `src/` file, including `extractBondSubgraphs.m` and `classifySubgraphIsomorphism.m`, and `external/`.

  **PASS** (see Complexity Tracking for the new file)
- **MATLAB coding standards**:
  - no `evalc`;
  - no warning suppression;
  - no new `try/catch`;
  - optional `keepEdge` handled with `exist`/`isempty` (VII-D);
  - openCOBRA header on the new function (VII-E);
  - naming and style per VII-G.

  VII-F: no MATLAB skill is registered. The practice notes of feature 20260928-100409 (`matlab-practice-notes.md`) apply and are cited. **PASS**
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**:
  - **Helper**: beside its caller in `src/analysis/topology/reactingMoieties/`.
  - **Tests and data**: in `test/verifiedTests/analysis/testReactingMoieties/`.
  - **Scripts and results**: in this feature directory.
  - **Large captures**: in the local reconXmoieties results tree.

  **PASS**

**Post-design re-check**: all PASS. The one addition beyond the spec's wording is the new helper file. It serves FR-004/FR-005 and FR-008, and is recorded below.

## Design

### Story 1: reorientation (lines 424–435)

```text
mask = orientationATG2dATM == -1
edges = ATG.Edges                         % one read
newHead = edges.TailAtom(mask); newTail = edges.HeadAtom(mask)
headAtomIndex(mask) = EndNodes(mask,2); tailAtomIndex(mask) = EndNodes(mask,1)
headAtom(mask) = newHead; tailAtom(mask) = newTail
trans(mask) = cellfun(@(h,t) [h '#' t], newHead, newTail, 'UniformOutput', false)
ATG.Edges.HeadAtomIndex = …; …TailAtomIndex; …HeadAtom; …TailAtom; …Trans    % 5 column writes
```

When `mask` has no true entries, skip the writes, so ATG is left byte-identical (edge case).

### Story 2: component subgraphs (591–595, 1040–1044) and propagation (1046–1066)

- `subgraphs = extractPartitionSubgraphs(ATG, atoms2component)` at both sites. Parts come in ascending label order, and the labels are `1..nComps` from `conncomp`, so `subgraphs{i}` is component `i`.
- **Class loop**: `for i`, `members = find(I2C(i,:) == 1)`, assigning to the members other than `firstSubgraphIndices(i)`.
- **Compile loop**: if `AtomIndex` is unique, `ATG.Nodes.MoietyIndex(nodesOfComponent{i}) = subgraphs{i}.Nodes.MoietyIndex` for each non-first component, gathered into one column write. Otherwise the original loop runs (R5).
  - `nodesOfComponent` comes from `accumarray(atoms2component, …)` with ascending positions, which matches the helper's node order.

### Story 3: moiety graphs (1152–1177)

```text
nodeMoiety = ABG.Nodes.MoietyIndex; ends = ABG.Edges.EndNodes; b = ABG.Edges.MoietyBondIndex
keepEdge = b == nodeMoiety(ends(:,1)) & b == nodeMoiety(ends(:,2))
MG = extractPartitionSubgraphs(ABG, nodeMoiety, keepEdge)
```

`MG` keeps its current shape (a column cell in `unique` order). `MG = {}` when ABG has no nodes, as the loop gives today.

### Helper: `extractPartitionSubgraphs(G, nodeLabel, keepEdge)`

See [contracts/extractPartitionSubgraphs.md](contracts/extractPartitionSubgraphs.md).

## Project Structure

### Documentation (this feature)

```text
specs/20260929-111453-conserved-moiety-table-hotspots/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/extractPartitionSubgraphs.md
├── checklists/requirements.md
├── research-prototype/{probeHotspots.m, probeCIFixtures.m}
├── identifyConservedReactingMoietiesBaseline.m   # NEW — git show 858feabc1, line 1 renamed (R7)
├── captureHotspotFixtures.m                      # NEW — CI golden (unchanged src) + n1960 identify inputs
├── conservedMoietyHotspotsCheck.m                # NEW — n1960 equality, profiler counts, median-of-3 gate, block micro-benchmark
├── conservedMoietyHotspotsResults.md             # NEW — generated, append-only
├── story{1,2}-*.patch                            # NEW — per-story revert points (FR-007)
└── tasks.md
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── identifyConservedReactingMoieties.m    # MODIFIED — three sites + .. Author:
└── extractPartitionSubgraphs.m            # NEW — subgraph of every part of a node labelling

test/verifiedTests/analysis/testReactingMoieties/
├── testConservedReactingMoieties.m        # MODIFIED — golden comparisons (main ×2 modes, coaX, crnM)
├── testExtractPartitionSubgraphs.m        # NEW — helper vs subgraph
└── data/conservedReactingMoietiesReference.mat   # NEW — captured from 858feabc1
```

**Structure Decision**: the single toolbox layout. The helper sits beside its caller, and the tests and data sit beside the existing ones.

## Implementation order (for `/speckit-tasks`)

1. **Baseline, captures and tests, on unchanged `src/`**:
   1. Create the baseline copy.
   2. Capture the CI golden (6 combinations). Record its size.
   3. Save the n1960 identify inputs.
   4. Extend `testConservedReactingMoieties` and run it (PASS).
   5. Write the check script and run it on unchanged code. It must report identical, and it records the baseline counts and times.
2. **Helper**: write `extractPartitionSubgraphs` and `testExtractPartitionSubgraphs`, and run the test (PASS). This touches nothing else.
3. **Story 1**: edit, then run the CI tests and the n1960 equality check. Save a patch.
4. **Story 2**: edit, check, and save a patch.
5. **Story 3**: edit and check.
6. **Final**:
   - the SC-003 gate and SC-004/SC-002 reporting;
   - the 8-subsystem check in both modes, plus sanity mode;
   - all `testReactingMoieties` tests;
   - static review;
   - the `.. Author:` line;
   - the receipt.

   Any story that fails FR-002 is reverted to the previous patch and recorded (FR-007).

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
|------|------------|--------------------------------------|
| New source file `extractPartitionSubgraphs.m` (the spec asked for no new public surface but did not forbid one) | Stories 2 and 3 are the same operation, and FR-008 needs single-node parts, `digraph` input and parallel edges tested, which no real fixture contains (R6) | Inline code duplicates the logic in two places and can't be unit-tested. A local function is invisible to tests. |
| Guarded fallback to the original compile loop when `AtomIndex` isn't unique (R5) | FR-002 must hold for every input | Assuming uniqueness would silently change results for such inputs |
