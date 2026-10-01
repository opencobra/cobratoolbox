# Contract: `extractBondSubgraphs`

## Public interface (unchanged — FR-001, Principle II)

```matlab
[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG)
[bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG)
```

| Output | Type | Contract |
|---|---|---|
| `bondSubgraphs` | n×1 cell of `graph`/`digraph` (same class as `ATG`) | For each pass (component pair) and each layer: `combinedSubgraph` plus that layer's bond edges, added with `addedge`. |
| `BMG` | n×1 cell of `digraph` | For each layer: `digraph(layerEdgeTable, GNodes)`. |
| `bmgEdgeIndex` | n×1 cell of column vectors | `EdgeIndex` values of each `BMG{m}`, in extraction order. |

An empty `BIG` returns `{}` for all three outputs.

**Routing**:

| Input | Path |
|---|---|
| Fails the lookup-array preconditions (lines 54–73) | `extractBondSubgraphsByComponentScan`, byte-identical (FR-008) |
| `ATG.Nodes.Component` ≠ `conncomp(ATG)` | `extractBondSubgraphsByEdgeScan`, the pre-change main loop, verbatim (research R2a) |
| Otherwise | The new size-proportional loop |

**Equality contract (FR-002)**: for every input, all three outputs are equal to those of `b57404773`:

- same cell sizes;
- same graph class per element;
- `isequaln` `Nodes` and `Edges` tables;
- `isequaln` `bmgEdgeIndex`.

Errors raised by the baseline on inputs that pass the preconditions are raised at the same pass, with the same identifier and message (research R4).

## Ordering contract (R1; asserted in `testExtractBondSubgraphs`)

For `H = subgraph(G, ids)`, with `G` a `graph` or `digraph`, `ids` unique and possibly unsorted:

1. `H.Nodes` is `G.Nodes(ids, :)`.
2. Let `keep` be the rows of `G.Edges` whose two end nodes are both in `ids`. Let `[~, ls] = ismember(s, ids)`, and `lt` likewise, and for `graph` replace them with `[min(ls,lt), max(ls,lt)]`.
3. `H.Edges` is `G.Edges(keep(order), :)` with `EndNodes = [ls lt](order, :)`, where `[~, order] = sortrows([ls lt keep])`.
4. `digraph(H.Edges, H.Nodes)` (or `graph(…)`) built from those tables is `isequal` to `H` in `Nodes` and `Edges`.
5. `rmedge(G, r)` keeps the other rows of `G.Edges` in their original relative order.

The CI test builds a small multigraph with parallel edges and an unsorted `ids`, and asserts rules 1–5 for both `graph` and `digraph`. If a MATLAB release changes any rule, the test fails with a message naming the rule.

## Cost contract (FR-003–FR-006, SC-003)

On the new loop, `extractBondSubgraphs` calls neither `rmedge` nor `subgraph`, except that `subgraph(BIG, pairAtoms)` is called only to re-raise the baseline error when a pair atom index exceeds `numnodes(BIG)`. Each pass touches only the pair's bucket rows and its component nodes. The one-time indices are linear in `numedges(BIG) + numnodes(ATG) + numedges(ATG)`.
