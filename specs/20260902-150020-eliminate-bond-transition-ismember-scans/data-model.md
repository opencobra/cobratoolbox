# Data Model: Eliminate remaining cell.ismember scans in buildAtomAndBondTransitionMultigraph's bond-transition loop

**Feature**: `20260902-150020-eliminate-bond-transition-ismember-scans` | **Date**: 2026-09-02

This feature introduces no new persistent data structures or COBRA model fields
(Constitution Principle I unaffected). E1/E2 are transient, in-memory MATLAB values local
to `buildAtomAndBondTransitionMultigraph.m`'s bond-transition loop; E3 is a new, narrowly-
scoped pure function with no persistent state of its own; E4 is the existing, unchanged
output shape.

## E1: `dATM.Nodes` (existing, unchanged in shape)

* **Representation**: MATLAB `table`, columns `Name`, `Atom`, `AtomIndex`, `Met`
  (unused by this feature), `mets`, `AtomNumber`, `Element` — built once at current line
  386 (`addvars(dATM.Nodes, Atom, AtomIndex, Met, AtomNumber, Element, ...)`), before the
  bond-transition section (`if options.bondTransitionMultigraph`, current line 555) even
  begins.
* **Relevant columns consumed by the new index (E2)**: `dATM.Nodes.mets` (cell array of
  char), `dATM.Nodes.AtomNumber` (double), `dATM.Nodes.Element` (cell array of char, read
  by the new lookup); `dATM.Nodes.Atom` (cell array of char), `dATM.Nodes.AtomIndex`
  (double) — both read by `resolveAtomNodeIndex` (E3) for a resolved row index.
* **Invariant**: `dATM.Nodes` is fully built and immutable before the bond-transition
  per-reaction loop starts, and stays immutable for the remainder of the function call —
  only `dATME` (its per-reaction extension with one appended energy-node row) changes per
  reaction (Edge Cases, FR-004, research.md R1). This feature reads `dATM.Nodes`, not
  `dATME.Nodes`, at the bond-transition loop's four atom-identity lookups.

## E2: Node-identity index (`dATMNodeIndexMap`) (new, transient)

Built once per `buildAtomAndBondTransitionMultigraph` call, immediately before the
bond-transition per-reaction loop begins (only when `options.bondTransitionMultigraph` is
true), consumed only within that loop's body, and discarded when the function returns.

| Field | Type | Definition |
|---|---|---|
| key | `char` | `sprintf('%s\x1f%d\x1f%s', met, atomNumber, element)` — a composite of `dATM.Nodes.mets{r}`, `dATM.Nodes.AtomNumber(r)`, `dATM.Nodes.Element{r}` for row `r`, folded into one string via a non-printable unit-separator delimiter (research.md R1) |
| value | `double` row vector | the 1-based row index (or indices, if the existing "at most one row per key" data-invariant is ever violated — research.md R1, Assumptions) of every `dATM.Nodes` row matching that key |

**Construction**: one linear pass over `dATM.Nodes`'s rows (`for r = 1:height(dATM.Nodes)`),
appending `r` to any existing key's value rather than overwriting, so a duplicate key
yields a multi-element value rather than silently keeping only the last match
(research.md R1).

**Consumption**: for each bond-transition, four calls to `resolveAtomNodeIndex` (E3) —
one per substrate-head, substrate-tail, product-head, product-tail atom identity — replace
the current eight `ismember`-based mask expressions (16 `ismember` calls total, FR-001).

**Lifecycle**: exists only for the duration of one `buildAtomAndBondTransitionMultigraph`
call, scoped to the `if options.bondTransitionMultigraph` block; not returned, not cached
across calls, not visible to any caller.

## E3: `resolveAtomNodeIndex` (new function, `src/analysis/topology/reactingMoieties/resolveAtomNodeIndex.m`)

* **Signature**: `[atom, atomIndex] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, met, atomNumber, element)`
* **Inputs**:
  | Name | Type | Definition |
  |---|---|---|
  | `nodeTable` | `table` | `dATM.Nodes` (or any table sharing its `Atom`/`AtomIndex` column shape) |
  | `nodeIndexMap` | `containers.Map` | the index built per E2, keyed identically to how `met`/`atomNumber`/`element` are folded here |
  | `met` | `char` | metabolite identifier component of the composite key |
  | `atomNumber` | `double` scalar | canonical atom-number component of the composite key |
  | `element` | `char` | element-symbol component of the composite key |
* **Outputs**:
  | Name | Type | Definition |
  |---|---|---|
  | `atom` | `1x1 cell` of `char` | `nodeTable.Atom(idx)` for the uniquely-resolved row `idx` |
  | `atomIndex` | `double` scalar | `nodeTable.AtomIndex(idx)` for the uniquely-resolved row `idx` |
* **Error contract** (FR-005, US2, research.md R1):
  | Condition | Error identifier | Behavior |
  |---|---|---|
  | key present in `nodeIndexMap`, resolves to exactly one row | — | returns `atom`/`atomIndex` for that row |
  | key absent from `nodeIndexMap` | `resolveAtomNodeIndex:missingNodeIdentity` | raises before reading `nodeTable.Atom`/`nodeTable.AtomIndex` |
  | key present, resolves to more than one row | `resolveAtomNodeIndex:ambiguousNodeIdentity` | raises before reading `nodeTable.Atom`/`nodeTable.AtomIndex` |
* **Lifecycle**: pure function, no persistent state; called four times per bond-transition
  iteration from `buildAtomAndBondTransitionMultigraph.m`, and directly from
  `testResolveAtomNodeIndex.m` with synthetic `nodeTable`/`nodeIndexMap` inputs (US2
  Independent Test, SC-006).

## E4: `dATM` / `dBTM` / `EdgeTable` (existing, unchanged in shape)

* **Representation**: MATLAB `digraph` objects and their backing `EdgeTable`, exactly as
  built today by `buildAtomAndBondTransitionMultigraph.m`'s bond-transition loop (current
  lines 672-696 and 711-725) — this feature changes only how
  `bondEdgeHeadBondHeadAtom`/`bondEdgeHeadBondTailAtom`/`bondEdgeTailBondHeadAtom`/
  `bondEdgeTailBondTailAtom` and their `...Index` counterparts are computed per iteration
  (via `resolveAtomNodeIndex`, E3), not the accumulator arrays, loop structure, or
  post-loop `table(...)`/`digraph(...)` construction feature 022 already fixed.
* **Invariant**: value-for-value, row-for-row identical to today's output for every
  existing atom-mapped RXN file (Acceptance Scenario 1, FR-003, FR-006).
