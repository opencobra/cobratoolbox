# Contract: `classifySubgraphIsomorphism` (new shared MATLAB function)

This is a library/CLI-less MATLAB toolbox, so the "contract" is the new
function's public signature and behavioral guarantees — the surface the three
call sites (and any future caller) rely on.

## Signature

```matlab
function [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = ...
    classifySubgraphIsomorphism(subgraphs, varargin)
```

* **File**: `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m` (new)

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `subgraphs` | `N×1` (or `1×N`) cell array of MATLAB `graph`/`digraph` objects | yes | The subgraphs to classify. `N == 0` and `N == 1` are valid (trivial cases). |
| `varargin` | name-value pairs | no | Forwarded verbatim to every `isisomorphic(subgraphs{i}, subgraphs{j}, varargin{:})` call. Supported by this feature: none (plain structural isomorphism), `'NodeVariables', 'mets'`, or `'EdgeVariables', 'mets'` — matching what the three current call sites already pass. Any other `isisomorphic`-supported name-value pair is forwarded unchanged (no validation added beyond what `isisomorphic` itself performs). |

## Outputs

| Name | Type | Description |
|---|---|---|
| `isomorphismClasses` | `1×numClasses` cell array of ascending-order double row vectors | `isomorphismClasses{k}(1)` is the leader (minimum) index of class `k`; classes are ordered by ascending leader index. |
| `firstSubgraphIndices` | `numClasses×1` double column vector | Leader index of each class, same order as `isomorphismClasses`. |
| `subsequentSubgraphIndices` | `N×1` double column vector | 1-based class number for every input index (including leaders). |

For `N == 0`: all three outputs are empty (`{}`, `[]`, `[]`).
For `N == 1`: `isomorphismClasses = {1}`, `firstSubgraphIndices = 1`,
`subsequentSubgraphIndices = 1`, and **no** `isisomorphic` call is made (Edge
Cases: a singleton bucket must not invoke `isisomorphic` at all).

## Behavioral guarantees

1. **No false negatives** (FR-003): for any pair `(i, j)` that the exhaustive
   per-site loops (pre-this-feature) would classify as isomorphic under the
   given `varargin` mode, this function classifies them into the same class.
2. **Necessary-only pre-filter** (FR-002): before calling
   `isisomorphic(subgraphs{i}, subgraphs{j}, varargin{:})` for a candidate
   pair, the function computes each subgraph's structural invariant (E2 in
   `data-model.md`: node count, edge count, and — when `varargin` names a
   `NodeVariables`/`EdgeVariables` column — the sorted label multiset for that
   column) and skips the `isisomorphic` call whenever the two invariants
   differ, treating the pair as not isomorphic.
3. **Deterministic, order-preserving output** (SC-004, `research.md` R1/R3):
   given the same `subgraphs` and `varargin`, the returned triple is the same
   regardless of internal loop implementation, and matches — index for index
   — what each of the three current call sites' own inline loops would have
   produced for the same input.
4. **No side effects on `subgraphs`**: the input cell array and its element
   graphs/digraphs are not mutated.
5. **No I/O, no `sanityChecks` parameter**: this function is a pure
   classification primitive. Any consistency/sanity checking that a call site
   currently interleaves with its classification loop (FR-007) remains the
   call site's responsibility, applied as a post-processing pass over the
   returned `isomorphismClasses`/`subsequentSubgraphIndices`.

## Callers (all three MUST route through this function per FR-004; no other
`isisomorphic(` pairwise-comparison loop may exist under
`src/analysis/topology/reactingMoieties/` per SC-006)

| Caller | Call | Notes |
|---|---|---|
| `identifyIsomorphicClasses.m` | `classifySubgraphIsomorphism(CBSubgraphs, 'EdgeVariables', 'mets')` | Public signature of `identifyIsomorphicClasses` itself is unchanged (FR-006); it wraps this call and re-attaches its `sanityChecks` side effects. |
| `identifyConservedReactingMoieties.m` (~line 603-676) | `classifySubgraphIsomorphism(subgraphs, 'NodeVariables', 'mets')` | Replaces the inline double loop; `I2C`, `atrans2component`, `atoms2isomorphismClass`, `atrans2isomorphismClass`, `nVertFirstSubgraph` are rebuilt from the returned triple. |
| `findAndExtractMolecularGraphs.m` (~line 24-61) | `classifySubgraphIsomorphism(bondSubgraphs)` | No `varargin` (matches today's mode-less `isisomorphic` call); gains invariant pre-filtering and `excludedSubgraphs`-equivalent pruning as a side effect (FR-005). |

## Non-goals

* Not a new public/exported COBRA Toolbox API — it is an internal helper
  under `src/analysis/topology/reactingMoieties/`, not intended for direct
  end-user use, and not documented in the toolbox's public function index
  beyond its own openCOBRA help header (Principle VII-E).
* Does not change `isisomorphic`'s own behavior or MATLAB path (no shadowing
  — `research.md` R6 alternatives-considered).
