# Phase 0 Research: per-edge and per-component table hotspots in `identifyConservedReactingMoieties`

**Feature**: `20260929-111453-conserved-moiety-table-hotspots` | **Date**: 2026-09-29 | **Spec**: [spec.md](spec.md)

**Environment and inputs**:
- MATLAB R2024b Update 8.
- Base commit `858feabc1`.
- The probe used the real 1,960-reaction ATG and BIG, captured at the `extractBondSubgraphs` call by feature 20260928-100409 (`…/extractBondSubgraphsPeeling/n1960-inputs.mat`): 132,884 atoms, 101,792 transitions (19 edge variables), and 39,916 components.

The probe scripts are in `research-prototype/`.

## R1. Measured identity and unprofiled cost of each block (probe `probeHotspots.m`)

| Block | Old (unprofiled) | New (unprofiled) | Identical |
|---|---|---|---|
| T1: reorientation, 19,952 of 101,792 edges | 181.2 s | 0.44 s | yes (`isequaln` Nodes and Edges) |
| T2: per-component subgraphs, one set (39,916 components; extrapolated from 2,000) | 74.2 s | 17.2 s | yes (2,000/2,000) |
| T3: per-moiety graphs, stand-in partition of 39,916 moieties (the real run has 30,999) | 125.0 s | 13.3 s | yes (2,000/2,000) |

For T3 the stand-in labelling is `MoietyIndex` = component, with the bonds inside it; the real propagated moiety indices only exist later in the run.

T2 runs twice, so the expected saving is about 181 + 2 × 57 + ~90 (T3 scaled to 30,999 moieties) ≈ **385 s**, plus the propagation block (R5, ~40 s). That brings the 817 s step to roughly **390–430 s (48–53%)**, well inside the SC-003 gate of 0.65.

**Floor**: `graph(table, table)` for component-sized tables costs about 0.48 ms each. That is the unavoidable cost per part, as long as the subgraphs remain `graph` objects with their full tables, which FR-004/FR-005 require.

## R2. Reorientation (Story 1, FR-003)

**Decision**:
1. Read `ATG.Edges` once.
2. With `mask = orientationATG2dATM == -1`, build the five new columns:
   - `HeadAtomIndex(mask) = EndNodes(mask, 2)`;
   - `TailAtomIndex(mask) = EndNodes(mask, 1)`;
   - `HeadAtom(mask)` = old `TailAtom(mask)`;
   - `TailAtom(mask)` = old `HeadAtom(mask)`;
   - `Trans(mask) = cellfun(@(h, t) [h '#' t], newHead, newTail, 'UniformOutput', false)`.
3. Write each column back once with `ATG.Edges.<var> = column`, which is 5 whole-column assignments.

**Rationale**:
- `[h '#' t]` inside `cellfun` is the same expression as the loop, so the result is identical character for character.
- `strcat` is rejected: it trims trailing whitespace of char inputs.
- A whole-column write keeps the variable's class (`double` / `cell`) and position.
- The probe gave identical `Nodes` and `Edges`.

**Alternatives considered**:
- Replacing `ATG.Edges` wholesale: rejected, because the graph object validates `EndNodes` on whole-table writes and the change isn't needed.
- `graph(E, N)` reconstruction: rejected, because it re-sorts and is costlier.

## R3. The ordering contract gives each part's rows directly, with no sort (Stories 2 and 3)

**Finding**: for `subgraph(G, idx)` with `idx` **ascending**, which is what `atoms2component == i` (a logical mask) and `find(MoietyIndex == m)` both give, the renumbering from global to local node positions is monotone. `graph` stores edges sorted by global `[min max]` end nodes with ties in insertion order, so the part's rows, taken in their `G.Edges` order, are already in the stable local `[min max]` order that the contract of feature 20260928-100409 requires (rules 1–4, CI-tested in `testExtractBondSubgraphs`).

Each part is therefore `graph(G.Edges(rows, :) with local EndNodes, G.Nodes(nodes, :))`, where `rows` is ascending. The probe confirmed identity without any `sortrows`.

**Decision**: one shared helper, `extractPartitionSubgraphs(G, nodeLabel, keepEdge)`, in `src/analysis/topology/reactingMoieties/`. For each distinct label, ascending, as `unique` gives:
- **nodes**: the ascending node positions with that label;
- **edges**: the ascending `G.Edges` rows with both end nodes in the part, restricted to `keepEdge` when it is given;
- **result**: a `graph` or `digraph` with the same class as `G`, built from `G.Edges(rows, :)` with local end nodes (normalised to `[min max]` for `graph`) and `G.Nodes(nodes, :)`.

`G.Edges` and `G.Nodes` are read once, and nodes and edges are grouped once (`accumarray`), so the cost is linear in nodes plus edges, plus one constructor per part.

**Rationale**: Story 2 (components, both sets) and Story 3 (moieties) are the same operation. Having one source function gives a unit-testable surface for the edge cases the real fixtures don't contain (single-node parts, parts without edges, parallel edges, `digraph`), which inline code can't have (FR-008).

**Story 3 specifics**:
- The pre-change code computes `subgraph(ABG, nodes)` and then keeps the rows with `MoietyBondIndex == m`, preserving their order.
- Equivalently, `keepEdge = MoietyBondIndex == MoietyIndex(end1) & MoietyBondIndex == MoietyIndex(end2)`, so that an edge belongs to part `m` exactly when both of its end nodes are in part `m` and its bond index is `m`.
- This covers moiety index 0 generally (index 0 is never assigned today; 0 on all 8 fixtures probed).
- The part list is `unique(ABG.Nodes.MoietyIndex)`, exactly as the loop iterates.

**Alternatives considered**:
- Separate inline code for T2 and T3: rejected, because it duplicates logic and can't be unit-tested.
- Keeping `sortrows`: unnecessary, because R3 proves the order.
- Storing subgraphs with fewer variables: rejected, because FR-004 requires identity with `subgraph`.

## R4. Reusing the component grouping for the second set (Story 2)

Between the two per-component loops, `ATG` is never rebuilt (line 707 is an `if 0` branch). Only columns are added (`MoietyIndex`, `Component`, `IsomorphismClass`, `IsCanonical`, and edge `Component`/`IsomorphismClass`/`IsCanonical`), and `atoms2component` is unchanged.

**Decision**: call `extractPartitionSubgraphs(ATG, atoms2component)` at both sites. Grouping costs about 0.15 s, so caching it across the sites is not worth the extra state.

## R5. Moiety-index propagation (Story 2, FR-004a; lines 1046–1066 at `858feabc1`)

**Decision**:
1. **Class loop**: replace the class × component double loop with `for i = 1:nIsomorphismClasses`, `members = find(I2C(i, :) == 1)`, and for each `j` in `members` with `j ~= firstSubgraphIndices(i)`, `subgraphs{j}.Nodes.MoietyIndex = MoietyIndices`. `find` returns ascending `j`, the same assignment order as the double loop, so the result is identical even if a component belonged to two classes.
2. **Compile loop**: the loop sets `ATG.Nodes.MoietyIndex(bool) = subgraphs{i}.Nodes.MoietyIndex(j)` with `bool = ismember(ATG.Nodes.AtomIndex, subgraphs{i}.Nodes.AtomIndex(j))`. Because the subgraph's nodes are the ATG rows `nodesOfComponent{i}` in order, when `AtomIndex` is unique this equals `ATG.Nodes.MoietyIndex(nodesOfComponent{i}) = subgraphs{i}.Nodes.MoietyIndex`. That is one write per component, or a single vectorised write after collecting all non-first components.
3. **Guard**: if `numel(unique(AtomIndex)) ~= numel(AtomIndex)`, the original loop is kept for that input, so FR-002 holds for every input. The pipeline's `AtomIndex` is `1:nAtoms`.

**Cost**: linear in atoms plus components. It replaces 29,378,176 `I2C` checks and 101,885 `ismember` calls over 132,884 atoms.

**Out of this block**: the per-canonical-atom `MoietyIndex` loop just above it (lines 1033–1037, about 7 s profiled) stays unchanged. It isn't in the spec's line range, and its share is small.

## R6. Test coverage (FR-008, Constitution III and III-Naming)

The existing fixtures of `testConservedReactingMoieties` were probed after `identifyConservedReactingMoieties` in conservedOnly mode:

| Fixture | Atoms | Transitions | Reoriented | Components | Single-atom | MG | MG without edges |
|---|---|---|---|---|---|---|---|
| main (r0317/ACONTm/r0426) | 54 | 54 | 0 | 18 | 0 | 6 | 0 |
| crnBondKeySubmodel | 710 | 381 | 0 | 329 | 0 | 12 | 4 |
| coaMBondKeySubmodel | 766 | 463 | 80 | 303 | 0 | 22 | 12 |
| coaXBondKeySubmodel | 1,184 | 713 | 159 | 471 | 0 | 38 | 20 |
| coaRBondKeySubmodel | 604 | 342 | 0 | 262 | 0 | 20 | 10 |
| crnMBondKeySubmodel | 396 | 211 | 26 | 185 | 0 | 12 | 6 |

**Decision**:
- **`testConservedReactingMoieties.m` (extended)**: compare `arm`, `moietyFormulae` and `reacting` with golden outputs captured from `858feabc1` for the main fixture (default and conservedOnly, with `sanityChecks` 0 and 1) and for coaX and crnM (conservedOnly). These cover reoriented edges, moiety graphs without edges, and multi-member isomorphism classes. The golden file goes in `data/conservedReactingMoietiesReference.mat` (target ≤ 1 MB; size recorded).
- **`testExtractPartitionSubgraphs.m` (new, for the new helper)**: for random `graph` and `digraph` inputs with parallel edges, single-node parts, parts without edges and `keepEdge` masks, assert that every part equals `subgraph(G, find(label == v))` restricted to `keepEdge`. The assertions include class, `Nodes`, `Edges` and row order.

Single-atom components don't occur in the pipeline, because every atom of a mapped metabolite takes part in at least one transition. They are covered by the helper's unit test.

## R7. Non-CI verification and the SC-003 gate (FR-009)

Reuse feature 20260928-100409's approach and helpers (`buildLowSymmetrySubsetModels.m`, `fingerprintBondSubgraphOutputs.m`-style fingerprints):

- **Golden, n1960 conservedOnly**: `…/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat` was captured at `b57404773`, and feature 20260928-100409 proved that the outputs of `858feabc1` are `isequaln` to it (SC-002). It is reused, so there is no new 1-hour capture.
- **Inputs, n1960**: `(model, BG, dATM)` are saved once to a new local directory `…/outputs/conservedMoietyHotspots/n1960-identifyInputs.mat`, so each check skips the 400 s build.
- **Baseline copy**: `FEATURE/identifyConservedReactingMoietiesBaseline.m`, from `git show 858feabc1:…`, with only line 1 renamed. It calls the committed helpers (`extractBondSubgraphs` etc.), which this feature doesn't change.
- **SC-003 gate**: alternating baseline/new median-of-3 runs of `identifyConservedReactingMoieties` (conservedOnly, `sanityChecks` 0) on n1960; gate ratio ≤ 0.65.
- **SC-004 (reported)**: a block micro-benchmark on the real ATG, as in `probeHotspots.m`.
- **SC-002**: profiler counts of `graph.subgraph` and `graph.subsasgn` called from `identifyConservedReactingMoieties`. Pre-change: 110,832 and 271,845.
- **SC-001, 8 subsystems**: `reactingOptimisationReproducibilityCheck.m`, default and conservedOnly (16 comparisons), plus its `CBT_RMO_SANITY=1` mode for `sanityChecks = 1` (tyr and ci sanity snapshots).

## R8. Library configuration audit (Principle IV)

No solver changes are involved. Library surface used:
- `graph`/`digraph` table constructors: sort by `[min max]`/`[s t]`, stable (R3);
- `unique`: sorted, as the loop uses;
- `accumarray` with `@(v) {sort(v)}`: order made explicit by the sort;
- `find` on a sparse row: ascending;
- `cellfun` with `UniformOutput` false.

No default is mismatched to the data.
