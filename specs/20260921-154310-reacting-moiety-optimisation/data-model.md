# Phase 1 Data Model: reacting-moiety optimisation

**Feature**: `20260921-154310-reacting-moiety-optimisation` | **Spec**: [spec.md](spec.md) | **Research**: [research.md](research.md)

This feature adds no model fields and no public data structures. The entities below are the internal
intermediates the optimised code reads or produces, plus the two verification artefacts. The "invariant"
column is what the implementation must keep true. Line numbers refer to `identifyConservedReactingMoieties.m`
on `develop` (`64efe1dc8`).

## Internal intermediates

| Entity | Shape / type | Produced by | Invariant the optimised code relies on or must keep |
|---|---|---|---|
| `BIG` | `digraph`; `Edges`: `EndNodes` (`nBonds x 2`, numeric atom indices), `BondIndex`, `EdgeIndex`, ...; `Nodes` = `dATM.Nodes` | `createBIGraph(BG)` (line 570) | Node `i` is atom `i` (`subgraph(BIGCopy, AtomIndex)` relies on this; unchanged). `EdgeIndex` indexes `BIG.Edges` rows (STEP B4 relies on this; unchanged). |
| `ATG` | `graph`; `Nodes`: `AtomIndex`, `Component`, ... | built from `dATM`, with `Component` added at line 699 | **Fast-path precondition (R1)**: `AtomIndex` is numeric, positive, whole and unique; each `Component` is a whole number in `1..max(conncomp(ATG))`. If not, the original algorithm runs (FR-007). |
| `compOfAtom` | `max(AtomIndex) x 1` double | new, local to `extractBondSubgraphs` | `compOfAtom(ATG.Nodes.AtomIndex) = ATG.Nodes.Component`; `0` means the atom is absent, and any `0` at a BIG end node sends the call to the fallback. |
| `nodesByComp` | `nComps x 1` cell of ascending column vectors | new, local | `nodesByComp{c}` equals `find(conncomp(ATG)' == c)`. |
| `endNodes`, `edgeIdx` (cache) | copies of `BIGCopy.Edges.EndNodes` / `.EdgeIndex` | new, local | After each `rmedge(BIGCopy, ids)`, the same `ids` rows are deleted, so the cache equals `BIGCopy.Edges` row for row. |
| `GEdges`, `GNodes` | `table` | `GBB.Edges` / `GBB.Nodes`, read once per component pair | Deleting rows keeps their order, the same as `rmedge(GBB, rows)`. |
| `bondSubgraphs` | `nSub x 1` cell of `graph` | `extractBondSubgraphs` | Must be **identical** to the pre-change output: class, `Nodes` table, `Edges` table, same cell order (FR-003). |
| `BMG` | `nSub x 1` cell of `digraph` | `extractBondSubgraphs` | Identical, as above (FR-003). |
| `bmgEdgeIndex` | `nSub x 1` cell of column vectors (**new optional 3rd output**) | `extractBondSubgraphs` | `sort(bmgEdgeIndex{m}) == sort(BMG{m}.Edges.EdgeIndex)`. The order is construction order, and every consumer uses it as a set (R2). |
| `conservedGroups`, `reactingGroups` | row vectors of subgraph indices | `findAndExtractMolecularGraphs` | Identical (unchanged classification). |
| `CMTG`, `RMTG`, `CMG`, `RMG` | `digraph` | `findAndExtractMolecularGraphs` | Identical `Nodes`/`Edges` tables (FR-004). |
| `bonds2component`, `bonds2isomorphismClass` | `nBonds x 1` double | STEP B4 loops | Identical values (R7). |
| `RBG` | `graph` on the atoms of reacting bonds | stage 14a | `newEndNodes` identical to the per-edge `find` result. **Precondition**: `nodeTable.AtomIndex` is unique and every endpoint is found; if not, the original loop runs (R4). |
| `COndensed_RBG` / `Condensed_RBG` | `graph` on ATG components | stage 14b / STEP 1 | `endNodesModified` identical, **including when there is exactly one edge** (reshape to `size(EndNodes)`, R5). Precondition: `EndNodes` is numeric and no location is `0`. |
| `atomToRxn` | `nAtomsMax x nRxns` sparse logical-valued double | new, local to STEP 3 | `atomToRxn(a, r) = 1` exactly when some transition with `HeadAtomIndex == a` or `TailAtomIndex == a` belongs to reaction `r` (`rxnCols > 0`). |
| `CRB2R` | `nCRB x nRxns` **sparse double**, values in `{1}` | STEP 3 | Identical size, non-zeros, values and `issparse` (FR-008). Precondition: atom indices numeric, whole, positive; `bondIdx` whole and in `1..maxBondIndex`. If not, the original loop runs (R6). |

## Verification artefacts

### Golden snapshot (`specs/<feature>/snapshots/<fixture>-<mode>-golden-snapshot.mat`)

Captured once from **unmodified** `develop`, before any source change (FR-011).

| Field | Content |
|---|---|
| `fixtureName`, `mode` | fixture in {nglycan, phe, andest, chol, urea, tyr, bileacid, ci} (`ci` = the in-repo CI fixture, needed for FR-002 sanity mode); mode in {`default`, `conservedOnly`, `sanity`} |
| `options` | the exact `options` struct passed |
| `outcome` | `'ok'` or `'error'` |
| `arm`, `moietyFormulae`, `reacting` | outputs (when `outcome == 'ok'`) |
| `errorIdentifier`, `errorMessage`, `errorTopFrame` | when `outcome == 'error'` |
| `consoleText` | the `diary` text of one call (SC-006) |
| `wholeFunctionSeconds`, `wholeFunctionMedianSeconds` | 3 runs and their median (`default` mode only; FR-012) |
| `targetedStageSeconds` | profiler block sums for stage 09 and stage 14/17 (bileacid, `default` only) |
| `milpSolver` | value of `CBT_MILP_SOLVER` at capture |
| `corpusProvenance` | corpus path, `.rxn` file count, subsystem-model file path and date (029 pattern) |
| `gitCommit`, `capturedAt`, `nReactions`, `nMetabolites` | provenance |

State: absent, then CAPTURED (the check runs in capture mode), then COMPARED (every later run). A
snapshot is never overwritten by the check. To recapture it, delete it deliberately and record why in
the results file.

### Unit-test reference (`test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat`)

Captured once from unmodified `develop` by `captureBondSubgraphReferences.m` (R8).

| Field | Content |
|---|---|
| `ciInputs.BIG`, `ciInputs.ATG` | the stage-09 inputs from the CI fixture (Recon3D `r0317`, `ACONTm`, `r0426`; `options.directed = 0`, `sanityChecks = 0`), taken by conditional breakpoint |
| `ciExpected.bondSubgraphs`, `ciExpected.BMG` | unmodified `extractBondSubgraphs` output |
| `ciExpected.CMTG` ... `ciExpected.reactingGroups` | unmodified `findAndExtractMolecularGraphs` output (six outputs) |
| `fallbackCases(k)` | struct array: `name`, `BIG`, `ATG`, `outcome` (`'ok'`/`'error'`), `bondSubgraphs`, `BMG`, `errorIdentifier`, `errorMessage`, `errorTopFrame` (`file:line` of `ME.stack(1)`, Constitution VII-C) |
| `provenance` | git commit, MATLAB version, capture date |

The fallback cases are: `duplicateAtomIndex`, `nonIntegerAtomIndex`, `componentLabelOutOfRange`,
`namedBIGNodes`, `zeroBIGEdges` (research R8).
