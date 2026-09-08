# Contracts: readABRXNFile.m and buildAtomAndBondTransitionMultigraph.m (unchanged)

**Feature**: `022-eliminate-table-object-hotspots` | **Date**: 2026-09-02

This feature introduces no new function and no new public interface (research.md R4). Both
touched functions are existing, public COBRA Toolbox library functions; this document
records the contract each MUST continue to satisfy exactly (FR-006), so that "unchanged" is
verifiable rather than assumed.

## `readABRXNFile(rxnfileName, rxnfileDirectory, options)`

* **Signature**: unchanged — same inputs (`rxnfileName`, optional `rxnfileDirectory`,
  optional `options.readBonds`), same outputs (`atoms`, `bonds`), same documented meaning
  of every field (per the function's existing help header).
* **Behavioral contract this feature MUST preserve**:
  * `atoms` table: identical column set, types, and values to today, for every input
    (FR-002).
  * `bonds` table: identical column set, types, values, and column order to today
    (`mets`, `headAtoms`, `tailAtoms`, `bTypes`, `headAtomElements`, `tailAtomElements`,
    `headAtomTransitionNrs`, `tailAtomTransitionNrs`, `isSubstrate`, `instances`) — in
    particular `headAtomTransitionNrs`, `tailAtomTransitionNrs`, `headAtomElements`,
    `tailAtomElements` (Acceptance Scenario 1).
  * A bond referencing an atom that does not exist in `atoms` (malformed/edge-case input)
    fails in the same way as today — same error class, or same empty-match propagation
    (Acceptance Scenario 3, research.md R1).
  * Two atoms sharing the same `(met, metNr, instance)` key (an existing-invariant
    violation) resolve the same way as today (errors on the same size-mismatch assignment,
    not a silently different match — Edge Cases, research.md R1).
  * A zero-bond RXN file returns the same trivial `bonds` table as today, with no indexing
    error (Acceptance Scenario 4).
* **What changes**: only the internal algorithm computing `headAtomTransitionNrs`,
  `tailAtomTransitionNrs`, `headAtomElements`, `tailAtomElements` (FR-001) — replacing four
  `find(...&ismember(...))` linear scans per bond with two lookups against a
  once-built index (data-model.md E2). No caller-visible change.

## `buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options)`

* **Signature**: unchanged — same inputs (`model`, `RXNFileDir`, optional `options`), same
  outputs (`dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, M2BiE,
  M2BiW, BTi2R, BTiE`), same documented meaning of every field (per the function's existing
  help header).
* **Behavioral contract this feature MUST preserve**:
  * `dATM.Nodes`, `dATM.Edges`, `dBTM.Nodes`, `dBTM.Edges` identical in content and row
    order before and after this change (Acceptance Scenario 1, SC-005).
  * The `nTotalAtomTransitions ~= k-1` preallocation-mismatch warning continues to fire
    under the same conditions (FR-007).
  * The two existing try/catch blocks (log-and-skip on a per-reaction parse failure)
    continue to function correctly; a caught failure for one reaction does not corrupt
    already-accumulated rows for earlier reactions (FR-008).
* **What changes**: only how each loop accumulates a transition's field values before
  `EdgeTable`/`dATM`/`dBTM` are built — plain preallocated arrays/cells written per
  iteration, with the `table`/`digraph` objects constructed once after each loop
  (FR-003, FR-004; data-model.md E3) — instead of writing into a live `table` object on
  every iteration. No caller-visible change.
