# Research: Exact isomorphism for near-symmetric bond components, and reading RXN reactions with no bonds

Phase 0 for [plan.md](plan.md). Code references are to `develop` at f1581781c.

## R1. Why the unlabelled `isisomorphic` call stalls, and what decides the pair

**Decision**: Decide unlabelled candidate pairs with an exact individualisation–refinement (IR) test, implemented as local functions of `classifySubgraphIsomorphism.m`:
1. joint colour refinement of the two graphs (each vertex's colour plus the multiset of its neighbours' colours, iterated to a stable partition; for digraphs, in- and out-neighbour multisets separately; edge multiplicities and self-loops counted), with a colour-histogram check that rejects non-isomorphic pairs;
2. when the partition is not discrete, individualise one vertex of the smallest non-singleton colour class of graph 1 against each vertex of the same class in graph 2, refine, recurse;
3. when discrete, build the induced bijection and verify that it maps the multiplicity adjacency matrix of graph 1 onto that of graph 2 exactly; a verified bijection proves isomorphism, an exhausted search proves non-isomorphism.

**Rationale**: Colour refinement is isomorphism-invariant, so any isomorphism preserves the joint colours; the IR search is complete, so the answer is exact. On the reconXmoieties stuck pair (318 nodes, 337 edges, 309 O and 9 C, two near-identical bond components over 227 eicosanoid metabolites; MATLAB R2024b, N = 1 each):
- `isisomorphic` (VF2), as called today: does not return within 60 min;
- joint 1-WL colours: 6 iterations, 114 colours, 0.06 s, equal histograms; `isisomorphic` with those colours as `NodeVariables`: does not return within 15 min;
- IR prototype: isomorphic, 0.33 s, 163 search nodes, bijection verified; random self-permutation 0.26 s; one edge moved: rejected by the histogram check in 0.003 s.
VF2 explores vertex orders without exploiting the colour partition and stalls on the many near-automorphisms of these sparse, almost-symmetric graphs; IR exploits the partition after every choice.

**Alternatives considered**:
- reusing `identifyAtomEquivalenceClasses.m` (feature 020): it already does 1-WL colour refinement, but on one metabolite's atoms and bonds (atom numbers, elements, bond endpoints) to find automorphism classes within a molecule, not on a pair of graph objects with multiplicities and direction; adapting its interface would change a public function, so the refinement is written locally;
- colour refinement + `isisomorphic` with colour labels: measured, still stalls;
- `isisomorphic` with element labels: changes the semantics of the unlabelled classification (FR-003/FR-006);
- calling nauty/bliss through an external binary or Python: new external dependency (Principle IV/V), not justified when a MATLAB IR decides the case in 0.33 s.

## R2. Exactness against `isisomorphic` semantics (FR-001, FR-002)

**Decision**: Build, per subgraph, the multiplicity adjacency matrix from `findedge` with `sparse` accumulation (parallel edges summed, self-loops on the diagonal; undirected graphs symmetric), on the same label-only copies the function already builds. Graph 1 and graph 2 are isomorphic exactly when some permutation P gives A2(P,P) = A1, which is what `isisomorphic` decides for unlabelled graph/digraph objects including multigraphs and self-loops.

**Validation**: a randomized equivalence test against `isisomorphic` on small graphs (≤ 12 nodes: simple, multigraph, self-loops, directed), where VF2 is fast, seeds fixed; plus the existing golden references.

## R3. Bounded fallback

**Decision**: Cap the IR search at a node budget (default 1e5 search nodes, a named constant). If the budget is reached, call `isisomorphic` exactly as today and count the fallback. Never return an undecided pair as non-isomorphic.

**Rationale**: IR is exponential on some highly regular graphs; metabolic bond components are not expected to be such, but correctness must not depend on that (spec edge case).

## R4. Scope: unlabelled calls only

**Decision**: Use IR only when `varargin` is empty (unlabelled). Labelled calls (`NodeVariables`, `EdgeVariables`) keep `isisomorphic` unchanged (FR-003).

**Rationale**: The stall was observed in the unlabelled bond-level classification; labels already prune VF2 strongly; extending IR to labelled edges needs edge-coloured refinement and its own equivalence testing, which is not needed now.

## R5. Call counting

**Decision**: The persistent `isisomorphicCallCount` keeps counting one exact comparison per candidate pair, whichever method decides it, so `getCallCount` semantics and existing tests that assert call counts are unchanged. A second persistent counter for fallbacks is exposed through a new action string `'getFallbackCount'` (additive, backward compatible).

## R6. The zero-bond failure in `readABRXNFile` (FR-004)

**Decision**: Create the `headAtomElements` and `tailAtomElements` columns (empty cell, n-by-1) before the per-bond loop, so the final reorder (`ismember(newvariables, oldvariables)`) always finds every column; build the empty bond table with typed empty columns (cell for `mets`, double for indices).

**Rationale**: With no bonds, the loop that creates these two columns never runs; `ismember` then returns 0 for them and `bonds(:, idx)` fails with "Array indices must be positive integers or logical values" (observed on 31 reconXmoieties hydrogen-free reactions). Non-empty files reach the same columns with the same values, so their output is unchanged.

## R7. The builder with zero-bond reactions (FR-005)

**Decision**: Verify with a two-reaction fixture model (a bonded reaction and a water transport) that `buildAtomAndBondTransitionMultigraph` concatenates an empty bond table and produces the bond graph from the other reaction; fix only what that test shows.

## R8. Performance baseline (FR-008, SC-005)

**Decision**: Time classification on the 1,960-reaction captures used by feature 20260930-102230 (its `quickstart.md`): `n1960-identifyInputs.mat` at `/home/jackmcgoldrick/repos/reconXmoieties/results/moietySizing/outputs/conservedMoietyHotspots/` (local capture, not in the repository), with that feature's timing script `specs/20260930-102230-isomorphism-label-only-copies/isomorphismLabelOnlyCheck.m` adapted to time unlabelled classification; before (develop f1581781c) and after, N = 3 each, median reported; and the stuck pair, N = 3, maximum reported. If the capture is missing, T003 stops and reports it.
