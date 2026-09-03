# Contracts: buildAtomAndBondTransitionMultigraph.m (unchanged) and resolveAtomNodeIndex.m (new)

**Feature**: `20260902-150020-eliminate-bond-transition-ismember-scans` | **Date**: 2026-09-02

## `buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options)` — unchanged public contract

This feature touches only the internal algorithm inside one existing, public COBRA
Toolbox library function; it introduces no new public interface for it (FR-006). This
section records the contract it MUST continue to satisfy exactly, so that "unchanged" is
verifiable rather than assumed.

* **Signature**: unchanged — same inputs (`model`, `RXNFileDir`, optional `options`), same
  outputs (`dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, M2BiE,
  M2BiW, BTi2R, BTiE`), same documented meaning of every field.
* **Behavioral contract this feature MUST preserve**:
  * `bondEdgeHeadBondHeadAtom`/`bondEdgeHeadBondTailAtom`/`bondEdgeTailBondHeadAtom`/
    `bondEdgeTailBondTailAtom` and their `...Index` counterparts — and therefore
    `EdgeTable`, `dBTM.Nodes`, `dBTM.Edges` — identical in content and row order before and
    after this change (Acceptance Scenario 1, FR-003).
  * The node-identity index (`dATMNodeIndexMap`, data-model.md E2) is built exactly once
    per call, before the bond-transition per-reaction loop begins — never once per
    reaction, never once per bond-transition (FR-002, Acceptance Scenario 3).
  * A bond-transition whose composite atom-identity key does not resolve to exactly one
    `dATM.Nodes` row fails explicitly — via `resolveAtomNodeIndex`'s named error — rather
    than silently picking an arbitrary match or silently dropping the bond-transition
    (FR-005, Acceptance Scenario 4).
  * A reaction with zero bond-transitions does not error and does not require the index to
    have been queried that iteration (Edge Cases).
  * The two existing try/catch log-and-skip blocks (per-reaction parse failure, one for the
    atom-transition loop and one for the bond-transition loop) continue to function
    correctly and are untouched by this feature.
* **What changes**: only how the bond-transition loop resolves each bond-transition's four
  atom identities before writing them into the accumulator arrays (FR-001; data-model.md
  E2, E3) — a node-identity index lookup via the new `resolveAtomNodeIndex` helper,
  instead of eight `ismember`-based boolean-mask expressions (16 `ismember` calls) against
  `dATME.Nodes`. No caller-visible change.

## `resolveAtomNodeIndex(nodeTable, nodeIndexMap, met, atomNumber, element)` — new function contract

* **Signature**: `[atom, atomIndex] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, met, atomNumber, element)`.
* **Inputs**: `nodeTable` — a `table` with `Atom` (cell array of char) and `AtomIndex`
  (double) columns, row-aligned with the row indices stored in `nodeIndexMap`;
  `nodeIndexMap` — a `containers.Map('KeyType','char','ValueType','any')` keyed by
  `sprintf('%s\x1f%d\x1f%s', met, atomNumber, element)`, values being the 1-based row
  index (or indices) into `nodeTable` matching that key; `met` — `char`; `atomNumber` —
  `double` scalar; `element` — `char`.
* **Outputs**: `atom` — `nodeTable.Atom` sliced at the uniquely-resolved row (`1x1 cell`);
  `atomIndex` — `nodeTable.AtomIndex` sliced at the same row (`double` scalar).
* **Error contract**:
  * `resolveAtomNodeIndex:missingNodeIdentity` — raised when `(met, atomNumber, element)`
    is not a key in `nodeIndexMap` (zero matching rows). Raised before any read of
    `nodeTable.Atom`/`nodeTable.AtomIndex`.
  * `resolveAtomNodeIndex:ambiguousNodeIdentity` — raised when `(met, atomNumber, element)`
    resolves to more than one row index. Raised before any read of
    `nodeTable.Atom`/`nodeTable.AtomIndex`.
  * Both errors carry a human-readable message naming the offending
    `met`/`atomNumber`/`element` triple.
* **Determinism**: pure function — same inputs always produce the same outputs or the same
  raised error identifier; no side effects, no persistent state.
* **New CI test**: `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m`
  (constitution III-Naming) exercises all three paths (unique match, missing key,
  ambiguous key) directly against synthetic `nodeTable`/`nodeIndexMap` inputs, with no
  dependency on RXN-file parsing (US2 Independent Test, SC-006).
