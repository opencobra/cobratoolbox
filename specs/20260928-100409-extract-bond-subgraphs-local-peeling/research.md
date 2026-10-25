# Phase 0 Research: Size-proportional peeling in `extractBondSubgraphs`

**Feature**: `20260928-100409-extract-bond-subgraphs-local-peeling` | **Date**: 2026-09-28 | **Spec**: [spec.md](spec.md)

All experiments were run headless on MATLAB R2024b Update 8 (`/usr/local/MATLAB/R2024b`, 24.2.0.3157250). The probe scripts and the research prototype are kept for reproducibility in `research-prototype/`: `probeSubgraphOrder.m` (R1), `runPrototypeEquivalence.m` (R2, R6), `runPrototypeScaling.m` (R7) and `extractBondSubgraphsLocal.m` (the prototype). They also need the scratch copies `extractBondSubgraphsBaseline.m` and `extractBondSubgraphsBaselineAssertK.m`, which tasks T002 and T003 recreate. These files are research evidence, not deliverables, and are never put on the toolbox path.

## R1. How `subgraph` and `rmedge` order nodes and edges (spec Assumptions; FR-004, FR-006)

**Decision**: Reproduce `subgraph(G, ids)` by the following rules, all confirmed empirically:

1. **Node order** follows `ids` exactly, including an unsorted `ids` (comp1's nodes followed by comp2's).
2. **Edges kept** are exactly the rows of `G.Edges` whose two end nodes are both in `ids`.
3. **End-node numbering**: each end node is renumbered to its position in `ids`. For an undirected `graph`, each row is then normalised to `[min, max]`.
4. **Row order** is a stable sort by the renumbered `(s, t)`, with ties kept in the original row order of `G.Edges`. This is `sortrows([s t originalRow])`.
5. `digraph(EdgeTable, NodeTable)` and `graph(EdgeTable, NodeTable)`, built from these rows, return `Nodes` and `Edges` tables that are `isequal` to `subgraph`'s.
6. `rmedge` keeps the relative row order of the rows it does not remove. So `BIGCopy.Edges` is always the not-yet-removed rows of `BIG.Edges`, in their original order, and "original row order" in rule 4 can be taken from `BIG.Edges`.

**Evidence**: a probe on a random multigraph (60 edges, parallel edges, unsorted `ids = [7 3 11 1 9]`) printed `1` for all eight properties: `digraph` and `graph`, node order, edge order, constructor reproduction, and `rmedge` order.

**Rationale**: these rules are the whole ordering contract that FR-004 and FR-006 need. They are encoded as an assertion in `testExtractBondSubgraphs` (see [contracts/extractBondSubgraphs.md](contracts/extractBondSubgraphs.md), "Ordering contract"), so a future MATLAB release that changes `subgraph` ordering fails a CI test rather than silently changing outputs.

**Alternatives considered**: documentation only. Rejected: the MathWorks page does not state the edge-order rule for unsorted `ids`.

## R2. Observed control flow: is `k` always reset to 1? (FR-009)

**Decision**: Yes. The main-path loop is replaced by "process the first remaining edge, repeat", and the outer `while` and the `k` / `numBonds` bookkeeping are removed.

**Argument**: for row `k`, both end atoms map through `compOfAtom` to `component1` and `component2`. Their atoms, `atomIndexATG(nodesByComp{c})`, are in `combinedSubgraph.Nodes.AtomIndex`, so edge `k` is in `GBB`. The inner `while size(GEdges,1) > 0` loop removes at least one row per layer and ends only when `GEdges` is empty, so every `GBB` edge, including `k`, is in `bondIdProcessed` and therefore in `idsToRemove`. So `ismember(k, idsToRemove)` is true and `k` resets to 1 on every pass. The `k + 1` branch is unreachable, and because `k` never exceeds `numBonds`, the outer loop body runs exactly once.

One assumption: `compOfAtom(a)` (from `ATG.Nodes.Component`) and `conncomp(ATG)` (used for `nodesByComp`) may be different labellings. The argument still holds, because it needs only that `a` is in `nodesByComp{compOfAtom(a)}`. That holds when `Component` equals `conncomp(ATG)`, which it does in `identifyConservedReactingMoieties`, where `Component` is set from `atoms2component = conncomp(ATG)`. When the two labellings differ, edge `k` may not be in `GBB`, and the baseline would then advance `k`. See R2a.

**Evidence**: an instrumented copy of the baseline, in which the `k = k + 1` branch raises an error, never raised it on the CI fixture (22 passes) or on 300 randomised synthetic inputs.

### R2a. Guard for mismatched component labellings

For main-path inputs whose `ATG.Nodes.Component` is **not** the `conncomp(ATG)` labelling (allowed by the precondition checks, which only require labels in range), the argument in R2 can fail. **Decision**: the new main path first checks, once and in time linear in the number of ATG nodes, that `isequal(componentATG(:), atoms2component(:))`. The atom at ATG position `p` is in `nodesByComp{compOfAtom(atomIndexATG(p))}` exactly when `atoms2component(p) == componentATG(p)`, so this check is sufficient. If the check fails (spec FR-014), the existing `k`-loop is kept for that input by running the pre-change main-path loop body, which stays in the file as a local function (see plan, "Structure decision"). FR-008 (precondition checks and fallback byte-identical) is unaffected. The `identifyConservedReactingMoieties` pipeline always takes the fast branch.

**Found during implementation (T008)**: on such inputs the pre-change loop can fail to terminate. If a bond has an end atom whose `Component` label points to a different conncomp component, that bond is never in its own pair's `GBB`, so it is never removed, and the outer `while size(endNodes,1) > 0` restarts forever. Because `extractBondSubgraphsByEdgeScan` is the pre-change loop verbatim, it has the same behaviour, including not terminating, which is what FR-002/FR-014 require. The CI `labelMismatch` case therefore keeps only bonds that join the two relabelled components or avoid both, so the pre-change function terminates on it.

**Alternatives considered**: (a) assume the labellings always agree. Rejected: FR-002 covers every input that satisfies the preconditions. (b) Emulate the `k`-advance inside the new loop. Rejected: this adds complexity to a path the pipeline never takes.

## R3. Indexing the bond-instance edges of a component pair (FR-003, FR-004, FR-005)

**Decision**: build, once, an **edge-by-component-pair index**. For every `BIG` edge row `e`, compute `cLo(e) = min(comp(s), comp(t))` and `cHi(e) = max(…)`. Group the rows into buckets by the key `(cLo, cHi)`, with the rows in each bucket ascending. Store `bucketId = sparse(cLo, cHi, bucket, nComps, nComps)`.

The `GBB` edges for pair `{A, B}` are then exactly the remaining rows of the buckets `(A,A)`, `(B,B)` and `(min, max)` (only `(A,A)` when `A == B`). No other edge has both end atoms in `A ∪ B`, and every edge in those buckets does.

A logical `remaining` flag over the rows of `BIG.Edges` replaces `rmedge`, `ismember(edgeIdx, bondIdProcessed)` and the `endNodes`/`edgeIdx` mirrors. After each pass, `remaining(rows) = false` costs time proportional to the rows peeled. The next edge to process is found by advancing a `first` pointer past rows already removed, which costs O(number of edges) in total over the run.

**Rationale**: every per-pass operation touches only the rows of three buckets and the atoms of two components. The spec's Key Entity "edge-by-component-pair index" is this index. A per-component list, which holds every edge touching component `c`, would also satisfy FR-004, but a hub component that pairs with many others would have its whole list rescanned on every pass it takes part in. That is the same whole-model cost pattern this feature removes. The pair-keyed index has no such rescans.

**Local end-node numbering**: a preallocated scratch vector `localPos` (length ≥ max atom index) is set to `1:numel(pairAtoms)` at `pairAtoms` before the lookup and reset to 0 afterwards, so the lookup is pair-sized and needs no `ismember`.

**Alternatives considered**: `containers.Map` keyed by pair. Rejected: per-call overhead is higher than a sparse lookup, and it needs string or `uint64` keys. A per-component list: see above. Keeping `BIGCopy` and calling `subgraph` on a view: not possible; MATLAB graphs have no views.

## R4. Building `GBB` without a graph object (FR-004)

**Decision**: `GBB` is not built at all. The baseline uses only `GBB.Edges` and `GBB.Nodes`, so the new code builds these two tables directly:

- `GEdges = BIGEdges(rows, :)`, then `GEdges.EndNodes = localEnds`;
- `GNodes = BIGNodes(pairAtoms, :)`.

Here `BIGEdges = BIG.Edges` and `BIGNodes = BIG.Nodes` are read **once**. Reading `BIG.Edges` returns a copy of the whole table, so reading it on every pass would bring back the whole-model cost.

**Evidence**: the prototype built these tables this way and matched the baseline exactly (R6).

**Error parity**: the baseline's `subgraph(BIGCopy, pairAtoms)` raises an error when a pair atom index exceeds `numnodes(BIG)`. That case can satisfy the preconditions, which bound only end-node indices. The new code checks `any(pairAtoms > numnodes(BIG))` (pair-sized), and only in that case calls `subgraph(BIG, pairAtoms)`, so that it raises the identical error at the identical pass. This call is never reached on valid inputs, so SC-003 (zero calls) still holds.

## R5. Building `combinedSubgraph` without `subgraph(ATG, …)` (Story 2, FR-006)

**Decision**: index the rows of `ATG.Edges` by component pair in the same way as R3 (`atgBucketId`, `atgEdgesByBucket`), using the `conncomp` labelling. For each pass:

1. Collect the ATG rows of buckets `(A,A)`, `(B,B)` and `(min,max)`.
2. Renumber the end nodes through a scratch vector `localPosATG`, normalise to `[min, max]` if `ATG` is a `graph`, and sort with `sortrows([ends rows])`.
3. Build `graph(cEdges, ATGNodes(nodesInBothComponents, :))`, or `digraph(…)` when `ATG` is a `digraph`.

`ATGNodes = ATG.Nodes` and `ATGEdges = ATG.Edges` are read once.

**FR-006 rationale (the spec was updated to match)**: "no ATG edge joins two different components" is true for an undirected `ATG`, which is what the pipeline builds (`ATG` is a `graph`). For a `digraph` ATG, `conncomp` defaults to *strong* components, and edges can join two components. The pair-bucket index covers both cases, because bucket `(min,max)` holds exactly those joining edges. The randomised equivalence set includes `digraph` ATGs (every 7th seed) and passes.

**Cost**: `graph(table, table)` for a pair-sized input takes about 1.0 ms, and `digraph(table, table)` about 0.23 ms. In the same probe, `subgraph` on a 200k-node graph took 21 ms and `rmedge` on an 800k-edge graph took 44 ms. With about 41,700 passes, Story 2's constructor cost is about 40 s, against a whole-graph `subgraph(ATG, …)` per pass. The real share is measured by the Story 3 benchmark, run with Story 1 only and then with Stories 1 and 2 (T-benchmark switch; see plan).

**Droppable (clarification Q1)**: Story 2 is implemented after Story 1 as its own increment. If any fixture fails FR-002 with Story 2 enabled, Story 2 is removed from the source file, and the deferral and its reason are recorded in the implementation receipt.

**Alternatives considered**: calling `subgraph` once per component at start-up and combining the results. Rejected: this makes `nComps` calls to `subgraph` on the full `ATG` (whole-model cost × number of components), and combining two graph objects still needs a constructor call.

## R6. Equivalence evidence for the design (FR-002)

The research prototype (Stories 1 and 2, main path only) was compared with a verbatim copy of the current function:

| Input | Outputs | Passes | Story 1 identical | Stories 1+2 identical | `k` always first |
|---|---|---|---|---|---|
| CI fixture (Recon3D r0317/ACONTm/r0426; ATG 54 nodes/54 edges, BIG 60 edges) | 26 | 22 | yes | yes | yes |
| 300 randomised synthetic inputs (seeds 1–300) | 1–~40 each | — | 300/300 | 300/300 | 300/300 |

Equality was checked with `isequaln` on the `Nodes` and `Edges` tables, graph class, cell sizes and `bmgEdgeIndex`. The synthetic generator covers:

- shuffled ATG node order and `AtomIndex` permutations;
- single-atom components and ATG components with no edges;
- extra ATG cycles;
- `digraph` ATGs (strong components with joining edges);
- parallel BIG edges and repeated `BondIndex` values;
- extra isolated BIG nodes;
- a non-`EndNodes` numeric edge variable (`Weight`);
- `component1 == component2` pairs;
- components shared by pairs across passes.

## R7. Expected speed-up and scaling (SC-004, SC-005)

Synthetic scaling probe (≈3 atoms per component, ≈1.1 bonds per atom between nearby atoms, seed 1; time for one run each):

| Atoms | BIG edges | Passes | Baseline (s) | Story 1 (s) | Stories 1+2 (s) | Identical |
|---|---|---|---|---|---|---|
| 2,000 | 2,149 | 1,405 | 2.88 | 1.05 | 1.32 | yes |
| 4,000 | 4,283 | 2,861 | 4.75 | 1.62 | 1.99 | yes |
| 8,000 | 8,585 | 5,762 | 9.88 | 3.38 | 3.79 | yes |
| 16,000 | 17,217 | 11,453 | 28.79 | 7.50 | 7.23 | yes |
| **log-log exponent** | | | **1.10** | **0.96** | **0.83** | |

On these small synthetic graphs, the baseline's per-pass cost is still mostly fixed overhead (about 2.5 ms per pass at 16k atoms, and rising), and the new per-pass cost is flat at about 0.65 ms. The cost is now in the pair-sized table and graph operations that FR-007 keeps: `digraph(EdgeTable, GNodes)`, `addedge`, `unique`, and table row indexing. On the real 1,960-reaction model, the baseline averages about 30 ms per pass (1,274 s / 41,671 passes, profiled), so whole-model costs dominate there.

**Risk to SC-004 (hard gate)**: if the remaining fixed pair-sized cost on real components is around 3 ms per pass, the new time is about 125 s, or about 10% of baseline. That is inside the 15% gate but without much margin. **Contingency, in order**:
1. Remove per-pass table overhead that FR-007 allows to change, provided FR-002 still holds. For example, index `GEdges` columns as arrays rather than through table subscripting inside the layer loop, and build each layer's `EdgeTable` from a row index of the pair table rather than deleting rows repeatedly.
2. Record the result against the gate.

Output-changing shortcuts are never taken.

**Caveat**: the synthetic graphs are much smaller per pair than real metabolic components. SC-004 and SC-005 are decided only by the Story 3 benchmark on the captured nested-subset fixtures.

**SC-005 output-size normalisation**: the benchmark also records `outputSize = Σ_i (numnodes + numedges)` of `bondSubgraphs{i}` and `BMG{i}`, and fits its exponent. If the output-size exponent is above 1.1, SC-005 is evaluated as time / output size and marked "scope-explained" (spec SC-005 caveat).

## R8. Fixtures: sources, capture method and placement (SC-001, SC-002; clarification Q2)

**Decision**:

| Fixture | Source | Capture | Location |
|---|---|---|---|
| Synthetic CI | hand-built deterministic `(BIG, ATG)` covering the FR-011 edge cases | `captureLocalPeelingReference.m` (this feature) on unmodified `src/` | **committed**: `test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphPeelingReference.mat` |
| Tyrosine (`tyr`) | `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`, same as `reactingOptimisationReproducibilityCheck.m`; corpus `/media/JACK/repos/ctf/rxns/atomMapped_std` | conditional breakpoint at the `extractBondSubgraphs` call | local |
| Nested subsets 332 / 531 / 1,067 / 1,604 and full 1,960 | `lowSymmetryRisk_2000rxn.mat` selection over `vmh2_reconx_for_atom_mapping.mat`, blocked RXN files removed (notebook section 2b), then whole subsystems added in `rng(1)` shuffled order up to targets 250/500/1000/1500 (notebook section 7) | as above | local; the 332 capture is **committed** beside the synthetic fixture only if its compressed `-v7` MAT file is ≤ 1 MB (the size is recorded in the results file either way) |

Local captures are saved under `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling/`, as with the previous feature's `externalDir`. `.mat` files are marked `binary` in `.gitattributes`; Git LFS is not used in this repository.

**Capture method**: reuse the conditional-breakpoint pattern of feature 20260921-154310 (`captureStageNineInputs.m`), so that `src/` is not edited. `dbstop in identifyConservedReactingMoieties at <line> if captureExtractBondSubgraphsInputs(BIG, ATG)`. The condition function saves the inputs and returns `false`. The line is found by its text, `[bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG);` (it is currently line 847). Golden outputs are produced by the pre-change function on the saved inputs, and the capture script refuses to run if `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m` differs from the feature's base commit `b57404773`.

**Golden storage for the local fixtures (changed during implementation, T009)**: saved as MAT files, the pre-change outputs take about 0.2 MB per output graph. `tyr` alone (2,048 outputs) was 377 MB in `-v7.3`, and `n1960` (≥ 41,671 outputs) would exceed 8 GB. The local `-golden.mat` files therefore keep, per output graph, a SHA-256 fingerprint of the serialised `{class, Nodes, Edges}`, plus one fingerprint of `bmgEdgeIndex`, the output count and the output size (`fingerprintBondSubgraphOutputs.m`). Equal fingerprints imply equal outputs. If any fingerprint differs, `extractBondSubgraphsPeelingCheck.m` decides FR-002 by running `extractBondSubgraphsBaseline` (the verbatim pre-change copy, R9) on the same inputs and comparing with `isequaln`. The committed CI fixtures still store full outputs. On the CI fixture, fingerprints proved deterministic across runs, and byte-identical between the pre-change function and both new drafts.

**SC-002 end-to-end reference**: the spec's end-to-end check is the `arm`/`moietyFormulae` equality check of `reactingOptimisationReproducibilityCheck.m` (feature 20260921-154310), in `conservedOnly` mode. The 1,960-reaction end-to-end baseline (`arm`, `moietyFormulae`, and the `conservedMoietiesOnly` outputs) is saved during the same run that captures the 1,960 inputs, so the slow pipeline runs only once before the change.

## R9. Baseline implementation for back-to-back timing (Story 3)

**Decision**: `specs/<feature>/extractBondSubgraphsBaseline.m` is generated by `git show b57404773:src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`, with only the function name on line 1 changed. It is a Spec Kit artifact (Principle IX), is never put on the toolbox path by `initCobraToolbox`, and is added to the path only by the benchmark and capture scripts.

## R10. Profiler call-count check (SC-003)

**Decision**: the benchmark runs the new function once under `profile on`, then inspects `profile('info').FunctionTable`. It finds the row whose `FunctionName` is `extractBondSubgraphs` and sums the `NumCalls` of its `Children` whose names match `rmedge` or `subgraph` (e.g. `digraph.rmedge`, `digraph.subgraph`, `graph.subgraph`). The expected total is 0. Profiled runs are excluded from the SC-004 timings.

## R11. Memory (FR-013)

The new one-time structures are:

- `remaining` (1 byte per BIG edge);
- `cLo`/`cHi`/bucket vectors and `edgesByBucket` (O(BIG edges));
- `bucketId` (sparse, one non-zero per bucket);
- `localPos` (one double per atom index);
- for Story 2, the same structures for ATG edges.

All are linear in the input size, and the cached `BIG.Edges`/`BIG.Nodes`/`ATG.Nodes`/`ATG.Edges` tables are copies the baseline also makes (`BIGCopy`, and the per-pass property reads). `BIGCopy`, `bondIdProcessed` (which grows to every edge) and the `endNodes`/`edgeIdx` mirrors are removed.

## R12. External solver / library configuration audit (Principle IV)

No optimisation solver is called. The only library surface is the MATLAB graph toolbox (`graph`, `digraph`, `conncomp`, `addedge`, and in the baseline `subgraph`/`rmedge`), plus `unique`, `sortrows`, `accumarray` and `sparse`. The defaults that matter:

- `conncomp` uses `'Type','strong'` for a `digraph` (handled in R5);
- `unique(..., 'first')` is kept verbatim (FR-007);
- `sortrows` on numeric matrices is stable, lexicographic and ascending;
- the `graph`/`digraph` table constructors sort edges as in R1.

No default is mismatched to the data profile.
