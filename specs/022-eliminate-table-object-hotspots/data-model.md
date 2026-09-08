# Data Model: Eliminate table-object dot-indexing and cell.ismember hotspots

**Feature**: `022-eliminate-table-object-hotspots` | **Date**: 2026-09-02

This feature introduces no new persistent data structures or COBRA model fields
(Constitution Principle I unaffected). The entities below are transient, in-memory MATLAB
values local to the two functions this feature touches; none is returned to callers or
survives past a single function call (research.md R4).

## E1: `atoms` / `bonds` tables (existing, unchanged in shape)

* **Representation**: MATLAB `table` objects returned by `readABRXNFile.m`, as documented
  in that function's existing help header. Column names, types, and meaning are unchanged
  by this feature (FR-006, Key Entities).
* **Relevant columns consumed by the new lookup (E2)**: `atoms.mets` (cell array),
  `atoms.metNrs` (double), `atoms.instances` (double), `atoms.atomTransitionNrs` (double),
  `atoms.elements` (cell array); `bonds.mets`, `bonds.headAtoms`, `bonds.tailAtoms`,
  `bonds.instances` (read); `bonds.headAtomTransitionNrs`, `bonds.tailAtomTransitionNrs`,
  `bonds.headAtomElements`, `bonds.tailAtomElements` (written, same values as today per
  FR-002).
* **Invariant**: value-for-value, row-for-row identical to today's output for every
  existing atom-mapped RXN file (Acceptance Scenario 1, FR-002).

## E2: Atom lookup index (new, transient)

Built once per `readABRXNFile` call, immediately after `atoms` is constructed, consumed
only within the same function's per-bond loop, and discarded when the function returns.

| Field | Type | Definition |
|---|---|---|
| key | `char` | `sprintf('%s\x1f%d\x1f%d', met, metNr, instance)` — a composite of `atoms.mets{r}`, `atoms.metNrs(r)`, `atoms.instances(r)` for row `r`, folded into one string via a non-printable unit-separator delimiter (research.md R1) |
| value | `double` row vector | the 1-based row index (or indices, if the existing "duplicate key" data-invariant violation occurs — research.md R1) of every `atoms` row matching that key |

**Construction**: one linear pass over `atoms`'s `p` rows (`for r = 1:height(atoms)`),
appending `r` to any existing key's value rather than overwriting, so a duplicate key (an
existing-invariant violation the spec's Edge Cases section anticipates) yields a
multi-element value rather than silently keeping only the last match.

**Consumption**: for each bond `i`, two lookups (`headKey`, `tailKey`) replace the current
four `find(...&ismember(...))` scans. A missing key resolves to `headIdx = []`/`tailIdx =
[]` (guarded via `isKey`, never a direct `containers.Map` indexing error) so that the
existing downstream `atoms.atomTransitionNrs(headIdx)`-style expression — and therefore the
exact existing error behavior on a no-match or duplicate-match input — is reproduced exactly
(research.md R1, Edge Cases, Acceptance Scenario 3).

**Lifecycle**: exists only for the duration of one `readABRXNFile` call; not returned, not
cached across calls, not visible to any caller (`checkABRXNFiles`,
`buildAtomAndBondTransitionMultigraph`'s two loops, `addBondMappingsRXNFile`).

## E3: EdgeTable accumulator (new, transient)

One instance per loop (atom-transition loop and bond-transition loop each get their own,
built and discarded independently within `buildAtomAndBondTransitionMultigraph.m`).

| Field | Type | Definition |
|---|---|---|
| per-column plain array/cell | `N×1` double, or `N×1`/`N×2` cell (matching each existing `EdgeTable` column's current type exactly) | preallocated at the same `nTotalAtomTransitions`/`nTotalBondTransitions` size (`N`) the current pre-loop `table(cell(N,...), zeros(N,...), ...)` call already uses; written via plain array/cell indexing (`col(k) = ...`, `col{k} = ...`) at the same loop iterations, with the same values, as today's `EdgeTable.col(k) = ...` dot-assignments |

**Construction**: preallocated immediately before the loop (replacing the current pre-loop
`EdgeTable = table(...)` call) as one local plain array/cell per column; written into, one
column-set per successful transition, exactly where today's code dot-assigns into
`EdgeTable`.

**Consumption**: after the loop completes, `EdgeTable = table(col1, col2, ...,
'VariableNames', {...})` is constructed exactly once, using the identical column order and
`'VariableNames'` list the current pre-loop `table(...)` call already passes. From this
point on, `EdgeTable`/`dATM`/`dBTM` are the same existing table/digraph objects with the
same existing shape, content, and row order (FR-005) — nothing downstream of the loop
changes.

**Lifecycle**: the per-column plain arrays exist only between preallocation and the
post-loop `table(...)` call; discarded (out of scope) once `EdgeTable` is built. No state
survives across separate calls to `buildAtomAndBondTransitionMultigraph`.

## E4: `dATM` / `dBTM` (existing, unchanged in shape)

* **Representation**: MATLAB `digraph` objects returned by
  `buildAtomAndBondTransitionMultigraph.m`, built from `EdgeTable` (E3) via
  `digraph(EdgeTable)`, exactly as today.
* **Invariant**: `dATM.Nodes`, `dATM.Edges`, `dBTM.Nodes`, `dBTM.Edges` identical in content
  and row order before and after this change (Acceptance Scenario 1, SC-005) — this feature
  changes only how `EdgeTable` is populated before `digraph(EdgeTable)` is called, not the
  table passed to `digraph` itself.
