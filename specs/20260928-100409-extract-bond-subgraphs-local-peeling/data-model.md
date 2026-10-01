# Data Model: Size-proportional peeling in `extractBondSubgraphs`

All structures are local to one call of `extractBondSubgraphs`. Nothing is persisted, and nothing is added to the outputs.

## E1. Inputs (read-only, unchanged)

- **`BIG`** (`digraph`): a bond instance graph whose node `i` is the atom with `AtomIndex == i`.
  - `Edges` has `EndNodes` (numeric n×2), `EdgeIndex` (unique), `BondIndex`, and other variables, which in the pipeline are `Weight`, `Bond`, `BondHeadAtom`, `BondTailAtom` and `mets`.
  - `Nodes` has `Atom`, `AtomIndex`, `mets`, `AtomNumber` and `Element`.
- **`ATG`** (`graph` in the pipeline; `digraph` is also supported):
  - `Nodes` has `AtomIndex` (unique positive integers) and `Component`, plus the others.
  - `Edges` has `EndNodes` plus 18 other variables in the pipeline.
  - `atoms2component = conncomp(ATG)'` gives the component of each ATG position.

## E2. `compOfAtom` (existing)

A dense vector indexed by atom index, with `compOfAtom(atomIndexATG) = componentATG`. It is built at lines 65–66, unchanged.

**Validation**: the existing preconditions require `compOfAtom(endNodes(:)) > 0`.

## E3. Pair edge index for `BIG` (new, built once)

| Field | Type / size | Meaning |
|---|---|---|
| `edgeLo`, `edgeHi` | double, nEdges×1 | `min`/`max` of `compOfAtom` over each edge's two end atoms |
| `edgesByBucket` | cell, nBuckets×1 | ascending `BIG.Edges` row numbers per distinct `(edgeLo, edgeHi)` |
| `bucketId` | sparse double, nComps×nComps | `bucketId(lo, hi)` = bucket number, or 0 if there is no edge |

**Invariant**: for a pair `{A, B}`, `A ≤ B`, the union of buckets `(A,A)`, `(B,B)` and `(A,B)` is exactly the set of `BIG` rows whose two end atoms both lie in components `A ∪ B`, under the `compOfAtom` labelling.

## E4. Pair edge index for `ATG` (new, built once; Story 2)

This has the same shape as E3 (`atgEdgesByBucket`, `atgBucketId`), keyed by `atoms2component` of the two ATG end-node positions.

**Invariant**: for an undirected ATG, only diagonal buckets `(c,c)` exist. For a `digraph` ATG with strong components, off-diagonal buckets hold the edges that join two components (R5).

## E5. `remaining` (new; replaces `BIGCopy`, `bondIdProcessed`, `idsToRemove`, and the `endNodes`/`edgeIdx` mirrors)

A logical nEdges×1 vector, initially all `true`.

**State transition**: at the end of each pass, `remaining(rows) = false` for exactly the rows of that pass's `GEdges` before peeling. Rows never become `true` again.

**Invariant**: the rows where `remaining` is true, in ascending order, are exactly `BIGCopy.Edges` of the baseline at the same pass (R1, rule 6).

## E6. `first` (new; replaces `k`, `numBonds` and the outer `while`)

The smallest row with `remaining(first)` true, or `nEdges + 1` when none is left. It only moves forward, so it advances O(nEdges) times in total.

**Invariant** (R2): the baseline processes row `first` of the original table on every pass.

## E7. Per-pass pair tables (new construction; same values as before)

| Name | Construction | Equals (baseline) |
|---|---|---|
| `nodesInBothComponents` | unchanged (lines 114–118) | same |
| `pairAtoms` | `atomIndexATG(nodesInBothComponents)` | `combinedSubgraph.Nodes.AtomIndex` |
| `rows` | remaining rows of the pair's buckets, then `sortrows([localEnds rows])` | the `BIGCopy` rows that `subgraph` keeps, in its output order |
| `GEdges` | `BIGEdges(rows, :)` with `EndNodes = localEnds` | `GBB.Edges` |
| `GNodes` | `BIGNodes(pairAtoms, :)` | `GBB.Nodes` |
| `combinedSubgraph` (Story 2) | `graph`/`digraph(cEdges, ATGNodes(nodesInBothComponents, :))` from the E4 buckets, renumbered, normalised to `[min,max]` if undirected, and `sortrows` | `subgraph(ATG, nodesInBothComponents)` |

The scratch vectors `localPos` (atom index → local position) and `localPosATG` (ATG position → local position) are set for the pair's nodes and reset to 0 after each lookup.

## Outputs (unchanged)

`bondSubgraphs`, `BMG` and `bmgEdgeIndex`: cell arrays, one entry per layer of each pass, in the same order as the baseline. See [contracts/extractBondSubgraphs.md](contracts/extractBondSubgraphs.md).
