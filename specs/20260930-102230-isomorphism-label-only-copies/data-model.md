# Data Model: label-only copies

All structures are local to one call of `classifySubgraphIsomorphism`. Nothing new is returned.

| Entity | Built from | Lifetime | Used by |
|---|---|---|---|
| `nodeLabels{i}`, `edgeLabels{i}` (existing) | sorted label column of subgraph `i` | the call | invariant prefilter (unchanged) |
| `labelOnlySubgraphs{i}` (new) | `findedge(subgraphs{i})`, `numnodes(subgraphs{i})` and the requested label columns | the call | `isisomorphic` comparisons only |

**Invariants**:
- `labelOnlySubgraphs{i}` has the same class, node count and `Edges.EndNodes` (row for row) as `subgraphs{i}`.
- Its only non-structural variables are the requested label variables.
- Its size is at most the size of `subgraphs{i}`, so memory is linear in the input (FR-009).
