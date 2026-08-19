# Contract: `buildAtomAndBondTransitionMultigraph` Bond-Node Identity

**Feature**: 019-canonicalize-bond-node-keys
**Public function**: `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`

## Public call surface

No signature change. Existing calls remain valid, including:

```matlab
options.directed = 0;
options.sanityChecks = 1;
[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, ...
    M2BiE, M2BiW, BTi2R, BTiE] = ...
    buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options);
```

No new user-facing parameter is introduced. `options.sanityChecks` (already existing, default
`1`) also gates the new per-metabolite bond-count check (FR-008).

## Behavioural contract

1. For a physical bond of a metabolite, `dBTM.Nodes.Bond` (the node identity string) MUST be
   identical regardless of which reaction's RXN file supplied that bond's row, and MUST NOT
   depend on which of the bond's two atoms that RXN file listed first.
2. Two distinct bonds (different atom pairs, whether within one metabolite or crossing into a
   reaction's energy node) MUST continue to resolve to distinct `dBTM.Nodes.Bond` values.
3. `dBTM.Nodes.BondHeadAtom`, `.BondTailAtom`, `.BondHeadAtomIndex`, `.BondTailAtomIndex`, and
   `.BondElmts` MUST all reflect the same canonicalized (head, tail) assignment as `.Bond` for
   that row — no attribute may reflect the pre-canonicalization raw order while another
   reflects the canonicalized order.
4. `dBTM.Edges.HeadMet`/`.TailMet` (which molecule instance is the reaction's substrate vs.
   product side) MUST NOT change as a result of this fix — only the within-bond atom head/tail
   labeling changes, never the edge's reaction-direction assignment.
5. For a bond with `BondType > 1` (double/triple), the existing multi-edge-per-node behavior
   (one edge per bond-order unit, all collapsing onto the same `dBTM.Nodes` row) MUST be
   preserved exactly.
6. For any metabolite whose bond-node keys were already consistent across every reaction that
   references it, `dBTM.Nodes`/`dBTM.Edges` row count, values, and derived matrices
   (`M2BiE`, `M2BiW`, `BTi2R`, `BTiE`) MUST be unchanged by this fix.
7. When `options.sanityChecks` is enabled, after `dBTM` construction the function MUST compare
   each atom/bond-mapped metabolite's distinct bond-node count against that metabolite's own
   true bond count (read once from its canonical RXN-file molblock) and emit a non-fatal
   warning identifying the metabolite on mismatch, without halting execution or altering the
   function's return values.
8. The existing `N`-vs-`N2` consistency check (lines 798–824) MUST NOT report a mismatch for
   any reaction/metabolite pair whose disagreement was solely caused by the cross-file
   bond-key inconsistency this feature corrects.

## Numerical contract

- For a model containing exactly `ELAIDCPT1`, `HMR_2634`, `HMR_2919`, `crn[c]` resolves to
  exactly 25 `dBTM.Nodes` rows (its true bond count), not 31.
- `dBTM.Edges` for these three reactions, filtered to `crn[c]`-touching bonds, reference the
  same `BondIndex` values across all three reactions for the same physical bond.
- `M2BiE`/`M2BiW` row sums for `crn[c]` (and any other previously-affected metabolite) equal
  its true bond count post-fix; the `res` residual at line 801 is zero for these
  metabolite/reaction pairs where it was previously non-zero solely due to this bug.

## Downstream consumer contract (established by research R3, not changed by this feature)

- `identifyConservedReactingSubgraphs.m` reads `dBTM.Edges.HeadMet`/`.TailMet` (reaction
  direction, unaffected) and treats `BondIndex`/`BondHeadAtomIndex`/`BondTailAtomIndex` as
  opaque identifiers / an unordered set — continues to function correctly with corrected,
  smaller node counts for previously-affected metabolites.
- `identifyConservedReactingMoieties.m` does not read `dBTM` directly; it consumes `BG` (built
  from `dBTM.Nodes.BondHeadAtomIndex`/`.BondTailAtomIndex`) and treats both atoms of a bond
  symmetrically throughout (including the CRB2R construction). Continues to function correctly.
- `extractBondSubgraphs.m` has no direct `dBTM` field access. Continues to function correctly.

## Test contract

Primary validation (existing test, extended — no new test file, per Constitution III-Naming and
research R7):

```matlab
testConservedReactingMoieties
```

Required outcomes:

- Existing assertions (`L*N = 0` invariant, `brokenBondsTable`/`formedBondsTable` heights,
  moiety counts) continue to pass unchanged for the existing `r0317`/`ACONTm`/`r0426` fixture,
  demonstrating no regression for unaffected metabolites (spec FR-006, US2).
- New assertions (added by this feature, using new fixtures per research R6) confirm:
  - `crn[c]` resolves to exactly 25 `dBTM.Nodes` rows for a model containing `ELAIDCPT1`,
    `HMR_2634`, `HMR_2919`.
  - No `Inconsistent directed bond transition multigraph` warning is emitted for these three
    reactions.
  - The new per-metabolite sanity check does not flag `crn[c]` post-fix, and does flag a
    deliberately-mismatched fixture (if one is constructed for this purpose).

Implementation may add focused assertions to `testConservedReactingMoieties.m` if needed, but
must not weaken or remove existing assertions.
