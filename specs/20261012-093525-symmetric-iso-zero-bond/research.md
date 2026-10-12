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

## R9. Implementation findings (added during /speckit-implement, 2026-10-12)

Recorded after T003, when the exact test as planned (R1–R3) was measured on the 1,960-reaction bond-mapping components (44,631 components; 49,009 unlabelled candidate pairs; baseline median 14.38 s at T003, 9.79 s at T011 under lower load).

- **IR alone was too slow for SC-005.**
  - The full-graph joint refinement of R1 was decided correctly (0 mismatches on all real pairs), but cost 2.61× the baseline (T011 first measurement: 25.85 s against 9.90 s).
  - Most of the cost was 3,388 non-isomorphic pairs of about 12,000-node components and 218 isomorphic large pairs, each needing about 1,000 single-node individualisations.
  - The maintainer chose "optimise, then measure" (2026-10-12) over an opt-in mode or accepting the slowdown.
- **Changes beyond R1–R3.** Each keeps the test exact: a positive answer is always a verified bijection, a negative one an invariant difference or the complete search.
  1. *Identity fast path*: two subgraphs with identical edge lists (end nodes from `findedge` on the label-only copies, same class) are isomorphic by the identity map. This applies to 38,467 of the 49,009 candidate pairs.
  2. *Per-subgraph certificate*: node hashes after four rounds of colour refinement, with fixed (node-order-independent) integer hashing that is exact below 2^53; the certificate is their sorted list. It is computed once per subgraph, and different certificates prove non-isomorphism (5,445 pairs, 0.77 s). The node hashes seed the joint refinement as its initial colouring.
  3. *Worklist refinement*: only the cells next to recoloured nodes are re-examined, with per-node weights updated incrementally.
  4. *Verified greedy pass* before the exact search: the t-th node of each non-singleton class in graph 1 is individualised against the t-th node of the same class in graph 2. The batch is halved while refinement is incompatible, and the result is used only when the final bijection verifies.
- **Result.**
  - SC-005: median ratio 0.658 (6.44 s against 9.79 s, N = 3, alternating); classification and candidate-pair count identical; 0 fallbacks.
  - SC-001: stored pair at most 0.039 s.
  - 0 mismatches against `isisomorphic` on 3,000 random small graphs and on all 43,947 first-leader real pairs (prototype benchmark).
- **R6/R7 found two more zero-bond defects**, fixed at the smallest place:
  - `checkABRXNFiles` computed `nBondTransitions = max(bondTransitionNrs)`, which is empty for a reaction with no bonds and turned `nTotalBondTransitions` empty. It now uses `max([0; ...])`. This is one source file outside the plan's list, so a zero-bond assertion was added to `testCheckABRXNFiles` (III-Naming);
  - `buildAtomAndBondTransitionMultigraph` sized `BTi2R` by the atom-mapped reaction count while indexing columns by bond-mapped reactions. It now uses `nBondMappedRxns`. The two counts are equal whenever every atom-mapped reaction has a bond, so existing outputs are unchanged (golden tests pass);
  - in a non-empty bond table, `bonds.isSubstrate` is double, not logical, so the empty table uses `zeros(0, 1)`.
