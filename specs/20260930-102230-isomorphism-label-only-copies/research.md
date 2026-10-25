# Phase 0 Research: classify isomorphism on label-only copies

**Feature**: `20260930-102230-isomorphism-label-only-copies` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

All experiments ran on MATLAB R2024b Update 8 at commit `f4a62639e`. The probes are in `research-prototype/`:
- `probeIsomorphismLabels.m`: R1.
- `probeLabelOnly2.m`: R2–R4.
- `classifySubgraphIsomorphismLabelOnly.m`: the prototype variant of the helper, which differs from the source only as described in R2.

## R1. The cost is label extraction on full tables (profile and first probe)

The 2026-09-30 profile shows the following:
- **`classifySubgraphIsomorphism`**: 350 s of 603 s.
- **`isisomorphic`**: 328 s of that, over 122,451 calls.
- **`graph.isomorphism>extractVarProp`**: 273 s, together with the `tabular.parenReference` and `braceReference` it drives.

In other words, most of the time goes on reading the requested label variable out of full node and edge tables: 8 node variables and 19 edge variables for the component subgraphs.

**First probe**: on the real 1,960-reaction component subgraphs, classification took 248.8 s on the full graphs. On copies carrying only the `mets` node variable it took 7.7 s to build the copies plus 17.8 s to classify. The results were identical.

## R2. Construction of the label-only copy (FR-003)

**Decision**: inside `classifySubgraphIsomorphism`, in the existing loop that computes the invariants, and after the invariant labels are read, build for each subgraph `i`:

```matlab
[s, t] = findedge(G);
H = digraph(s, t, [], numnodes(G));        % or graph(...) for a graph
if ~isempty(nodeVarName), H.Nodes.(nodeVarName) = G.Nodes.(nodeVarName); end
if ~isempty(edgeVarName), H.Edges.(edgeVarName) = G.Edges.(edgeVarName); end
```

The `isisomorphic` call then uses the copies.

**Why this is exact**:
- `findedge` returns the end nodes of every edge in the order of `G.Edges`, which is already sorted by end node.
- The constructor, given that same sorted list, keeps it, so row `k` of `H.Edges` is row `k` of `G.Edges`. The edge label column is therefore aligned with the right edges.
- Parallel edges and self-loops are kept. The constructor keeps self-loops unless `'omitselfloops'` is given.
- `numnodes(G)` keeps isolated nodes.
- The class (`graph`/`digraph`) and edge directions are preserved.

**Evidence**:
- 240 random classifications (60 cases × 4 modes: plain, `NodeVariables`, `EdgeVariables`, and both) on `graph` and `digraph` multigraphs with self-loops and extra variables: 0 mismatches against the current helper.
- The real 1,960-reaction component subgraphs: identical (R4).

**Alternatives considered**:
- Building the copy from a one-variable table, as in the first probe: equivalent, but it needs separate code for the case with no node variable.
- Removing the variables from a copy of `G` with `rmvars` on `Nodes`/`Edges`: this writes through `graph.subsasgn` once per variable, which is slower for 19 edge variables.
- Caching label vectors and calling `isomorphism` with custom functions: this changes how the comparison is made; rejected.

## R3. Option values and errors (FR-005, spec edge case)

**Finding**: the current helper reads the invariant label with `subgraphs{i}.Nodes.(nodeVarName)`. A cell value such as `{'mets'}` therefore raises `MATLAB:table:IllegalVarSubscript` ("Table variable names must be strings or character vectors.") in the invariant loop, before any comparison. A string scalar `"mets"` works, and a missing variable raises `MATLAB:table:UnrecognizedVarName`.

The prototype raises identical errors at the same point, because the copy is built after the invariant read in the same loop. This corrects the spec's earlier edge case, which said multi-variable values were kept. The spec now says the existing behaviour is kept exactly.

**Decision**: build the copy after the invariant reads in the same loop iteration, reusing `nodeVarName`/`edgeVarName` exactly as parsed today. No new validation is added, and no new message.

## R4. Real data: identity, cost and call count (FR-002, FR-004, SC-002, SC-004)

On the real 1,960-reaction component subgraphs, with `'NodeVariables', 'mets'`:

| | Time | Result |
|---|---|---|
| Current helper | 212.2 s | 736 classes; 39,204 `isisomorphic` calls |
| Label-only variant (copies built inside) | 23.6 s (ratio **0.111**) | identical |

The candidate pairs are unchanged because the invariants are unchanged (FR-004). The diagnostic count is therefore unchanged by construction, and the new CI test asserts it.

**Projection (SC-003)**:
- This call site saves about 190–220 s unprofiled.
- `identifyIsomorphicClasses` (`EdgeVariables`) and `findAndExtractMolecularGraphs` (plain) together are about 41 s profiled, and gain proportionally.
- The step should go from about 364 s to about 140–170 s, a ratio of about 0.40–0.47, against the 0.60 gate.

## R5. Verification approach (FR-007, FR-008)

- **CI**: extend `testClassifySubgraphIsomorphism.m` with expected classifications captured from `f4a62639e`, for deterministic random `graph`/`digraph` multigraphs with self-loops and extra variables in the three caller modes. Add the error cases (cell option, missing variable) and a call-count equality case. `testConservedReactingMoieties` already compares 6 golden cases end to end, and covers all three call sites.
- **Non-CI**, in a check script for this feature:
  - classification equality and call count on the real 1,960-reaction component subgraphs, against the pre-change helper (a verbatim copy);
  - end-to-end equality on the 1,960-reaction model against `n1960-endToEnd-golden.mat`;
  - the SC-003 gate as a median of 5 alternating runs of `identifyConservedReactingMoieties`. The baseline is the `f4a62639e` source, run through a baseline copy of the helper, which needs a path-shadowing arrangement: see the plan.
- **`reactingOptimisationReproducibilityCheck.m`**: 8 subsystems, default and conserved-only modes.

## R6. Library configuration audit (Principle IV)

No solver changes are involved. The relevant library behaviours:
- `isisomorphic(G1, G2, 'NodeVariables', v)` compares only `v`, and without options it compares structure only.
- `graph`/`digraph(s, t, [], n)` keeps self-loops and parallel edges by default, and keeps the given order of sorted end nodes.
- `findedge` returns end nodes in `G.Edges` row order.

No default is mismatched to the data.
