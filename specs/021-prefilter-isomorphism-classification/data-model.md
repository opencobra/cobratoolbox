# Data Model: Prefilter subgraph isomorphism classification

**Feature**: `021-prefilter-isomorphism-classification` | **Date**: 2026-09-02

This feature introduces no new persistent data structures or COBRA model fields
(Constitution Principle I unaffected). The entities below are in-memory MATLAB
values scoped to the classification helper and its call sites.

## E1: Bond/molecular subgraph (existing, unchanged)

* **Representation**: element of a MATLAB `graph`/`digraph` cell array
  (`bondSubgraphs`, `subgraphs`, or `CBSubgraphs` at the three call sites).
* **Relevant fields consumed by this feature** (read-only): `.Nodes` (node
  table; `mets`/`AtomIndex` columns used depending on call site), `.Edges`
  (edge table; `mets`/`TransIndex`/`EdgeIndex` columns used depending on call
  site), `numnodes(g)`, `numedges(g)`.
* **Invariants**: unchanged by this feature. No field is added, renamed, or
  removed on these objects.

## E2: Structural invariant (new)

Per-subgraph signature computed once by `classifySubgraphIsomorphism.m`,
never persisted, never surfaced to callers.

| Field | Type | Definition |
|---|---|---|
| `numNodes` | scalar double | `numnodes(subgraph)` |
| `numEdges` | scalar double | `numedges(subgraph)` |
| `labelMultiset` | sorted vector/cell (or `[]`) | `sort(subgraph.Nodes.(varName))` when called with `'NodeVariables', varName`; `sort(subgraph.Edges.(varName))` when called with `'EdgeVariables', varName`; `[]` when called with no comparison-mode arguments (`findAndExtractMolecularGraphs.m`'s plain-isomorphism call) |

**Equality rule** (necessary, not sufficient, condition for isomorphism —
FR-003): two subgraphs' invariants are equal iff `numNodes` matches, `numEdges`
matches, and `labelMultiset` matches element-wise after sorting (`isequal` on
the sorted vectors/cell arrays; empty `labelMultiset` on both sides trivially
matches, degrading to a pure node/edge-count check for the mode-less call
site).

**Lifecycle**: computed once per subgraph before the pairwise scan begins;
consumed only within `classifySubgraphIsomorphism.m`; discarded when the
function returns. No state survives across calls (other than the call-count
instrumentation in R6, which is a separate, orthogonal `persistent` counter).

## E3: Isomorphism class / classification result (existing concept, now centrally produced)

Returned by `classifySubgraphIsomorphism.m` (and, unchanged in shape, by the
`identifyIsomorphicClasses.m` wrapper that calls it):

| Output | Type | Definition |
|---|---|---|
| `isomorphismClasses` | `1×numClasses` cell array | `isomorphismClasses{k}` is an ascending-order row vector of subgraph indices belonging to class `k`; the first element is the class leader (minimum index in the class). Classes appear in ascending-leader order. |
| `firstSubgraphIndices` | `numClasses×1` double vector | `firstSubgraphIndices(k)` = the leader index of class `k` (== `isomorphismClasses{k}(1)`). |
| `subsequentSubgraphIndices` | `numSubgraphs×1` double vector | `subsequentSubgraphIndices(idx)` = the 1-based class number that subgraph `idx` belongs to, for every `idx` (leaders included). |

**Invariant carried over from today's three independent implementations**
(proved equivalent in `research.md` R1): for a fixed set of subgraphs and a
fixed pairwise `isisomorphic` truth table, this triple is uniquely determined
— it does not depend on which of the two historical loop skeletons produced
it. This is what allows one shared helper to replace three independent
implementations without changing any downstream consumer's observed values
(SC-004).

**Consumption by call site** (each site keeps its own post-processing,
unchanged from today except for reading through the shared triple instead of
building it inline):

* `identifyIsomorphicClasses.m` — re-attaches the `sanityChecks`-gated
  `Nodes.AtomIndex ~= idx` check and the `atrans2component` /
  `atoms2isomorphismClass` / `atrans2isomorphismClass` `NASGU` assignments, by
  iterating `isomorphismClasses` class-by-class, member-by-member.
* `identifyConservedReactingMoieties.m` — builds `I2C` (sparse
  class-by-subgraph indicator), `atrans2component`, `atoms2isomorphismClass`,
  `atrans2isomorphismClass`, and `nVertFirstSubgraph` from the same triple.
* `findAndExtractMolecularGraphs.m` — takes `conservedGroup =
  isomorphismClasses{argmax length}`, `reactingGroups = setdiff(1:numSubgraphs,
  conservedGroup)`, unchanged from its current post-processing.

No state transitions apply (this is a one-shot classification, not a
stateful entity with lifecycle beyond a single function call).
