# Contract: `extractPartitionSubgraphs` (new, internal helper)

```matlab
parts = extractPartitionSubgraphs(G, nodeLabel)
parts = extractPartitionSubgraphs(G, nodeLabel, keepEdge)
```

## Inputs

| Input | Type | Meaning |
|---|---|---|
| `G` | `graph` or `digraph` | Any graph, with or without extra node and edge variables. |
| `nodeLabel` | numeric vector, `numnodes(G)` × 1 | The part of each node. Parts are the distinct values, in ascending order (as `unique(nodeLabel)` gives them). |
| `keepEdge` *(optional)* | logical vector, `numedges(G)` × 1 | Edges eligible to appear. Absent or empty means all edges. |

## Output

`parts` is a column cell array with one entry per distinct label, in ascending label order. Each `parts{k}`, for label `v = u(k)` where `u = unique(nodeLabel)`, satisfies:

- **Same as `subgraph`**: `parts{k}` is `isequal` in class, `Nodes` and `Edges` to

  ```matlab
  H = subgraph(G, find(nodeLabel == v));
  keep = keepEdge(<rows of G.Edges kept by subgraph, in H's row order>);
  class(G)(H.Edges(keep, :), H.Nodes)
  ```

  Without `keepEdge`, it is `subgraph(G, find(nodeLabel == v))` itself.
- **Node order**: the ascending positions of the part's nodes in `G`.
- **Edge rows**: the rows of `G.Edges` with both end nodes in the part and `keepEdge` true. They appear in their `G.Edges` order, with end nodes renumbered locally (and `[min max]` for `graph`). That is the order `subgraph` gives for an ascending index list (research R3).
- **Empty parts**: a single-node part, and a part with no eligible edges, both give the same graph that `subgraph` gives.
- **Empty graph**: `numnodes(G) == 0` gives `parts = {}` (0 × 1 behaviour matches the loop it replaces: `MG = {}`).

## Cost

- `G.Edges` and `G.Nodes` are each read once.
- Grouping is done once (linear in nodes plus edges), followed by one table-row selection and one `graph`/`digraph` constructor per part.
- There are no per-part scans of the whole graph.

## Errors

The helper adds no new error text. A `nodeLabel` that is the wrong length, or `keepEdge` that is the wrong length, raises MATLAB's own indexing error. The callers always pass correct sizes.
