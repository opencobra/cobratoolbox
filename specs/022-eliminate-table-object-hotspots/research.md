# Research: Eliminate table-object dot-indexing and cell.ismember hotspots in RXN parsing

**Feature**: `022-eliminate-table-object-hotspots` | **Date**: 2026-09-02

## R1: Lookup data structure and key design for readABRXNFile.m's per-bond atom lookup (FR-001)

**Decision**: A single `containers.Map('KeyType','char','ValueType','any')` built once,
immediately after `atoms` is constructed (current line 243) and before the per-bond loop
(current lines 254-259). One pass over `atoms`'s `p` rows populates it:

```matlab
atomIndexMap = containers.Map('KeyType','char','ValueType','any');
for r = 1:height(atoms)
    key = sprintf('%s\x1f%d\x1f%d', atoms.mets{r}, atoms.metNrs(r), atoms.instances(r));
    if isKey(atomIndexMap, key)
        atomIndexMap(key) = [atomIndexMap(key), r]; % preserve duplicate-key matches, do not overwrite
    else
        atomIndexMap(key) = r;
    end
end
```

The per-bond loop then does exactly two lookups per bond (head, tail) instead of four
`find(...&ismember(...))` scans (head-transition-number, tail-transition-number,
head-element, tail-element — the last two repeat the first two's condition):

```matlab
for i = 1:nAllBonds
    headKey = sprintf('%s\x1f%d\x1f%d', bonds.mets{i}, bonds.headAtoms(i), bonds.instances(i));
    tailKey = sprintf('%s\x1f%d\x1f%d', bonds.mets{i}, bonds.tailAtoms(i), bonds.instances(i));
    if isKey(atomIndexMap, headKey), headIdx = atomIndexMap(headKey); else, headIdx = []; end
    if isKey(atomIndexMap, tailKey), tailIdx = atomIndexMap(tailKey); else, tailIdx = []; end
    bonds.headAtomTransitionNrs(i) = atoms.atomTransitionNrs(headIdx);
    bonds.tailAtomTransitionNrs(i) = atoms.atomTransitionNrs(tailIdx);
    bonds.headAtomElements(i) = atoms.elements(headIdx);
    bonds.tailAtomElements(i) = atoms.elements(tailIdx);
end
```

**Rationale**:
* `containers.Map` keyed by `(met, metNr, instance)` is the precedented lookup mechanism
  the spec's Assumptions section names, and matches the pattern already used elsewhere in
  this same directory (`buildAtomAndBondTransitionMultigraph.m`'s
  `metBondCountGroundTruth`/`metAtomCanonicalRankMap`/`metUnsafeNeighborsMap`,
  `containers.Map('KeyType','char', ...)`).
* `containers.Map` requires a homogeneous key type; a composite `(char, double, double)`
  key is folded into one `char` key via `sprintf`. The unit-separator control character
  `\x1f` (not a printable character, cannot appear in a metabolite identifier or be typed
  in an RXN file) is used instead of a printable delimiter such as `'#'` or `'|'` to avoid
  any theoretical collision with characters that legitimately appear in `mets` values
  (compartment tags like `[c]`, or ChEBI-style identifiers already contain digits that
  could collide with a printable-delimiter scheme).
* **Duplicate-key edge case (spec Edge Cases, FR-002)**: the current
  `find(atoms.metNrs==... & atoms.instances==... & ismember(atoms.mets,...))` returns a
  vector of *every* matching row index. If more than one atom shares a
  `(met, metNr, instance)` key (an existing-invariant violation, "should not happen"),
  `find` returns a 2+-element vector, and today's code
  (`bonds.headAtomTransitionNrs(i) = atoms.atomTransitionNrs(find(...))`) throws MATLAB's
  standard "Unable to perform assignment because the size of the left side is 1-by-1 and
  the size of the right side is 1-by-N" error when assigning a multi-element vector into
  the scalar-indexed `bonds.headAtomTransitionNrs(i)` slot. The map above reproduces this
  exactly: it *appends* to an existing key's value instead of overwriting
  (`atomIndexMap(key) = [atomIndexMap(key), r]`), so a duplicate key yields a multi-element
  `headIdx`/`tailIdx`, and `atoms.atomTransitionNrs(headIdx)` assigned into
  `bonds.headAtomTransitionNrs(i)` throws the identical size-mismatch error via the
  identical downstream expression shape — not a different, map-specific error.
* **No-match edge case (Acceptance Scenario 3)**: today's `find(...)` returns `[]` when no
  atom matches, and `atoms.atomTransitionNrs([])` assigned into
  `bonds.headAtomTransitionNrs(i)` throws (table-column-height-mismatch class of error) when
  that column is later reconciled against the table's row count. The `isKey`-guarded
  lookup above sets `headIdx = []` on a missing key for the same reason — it routes through
  the identical `atoms.atomTransitionNrs(headIdx)` expression as the matched case, so the
  identical error fires at the identical place, rather than `containers.Map` raising its
  own "specified key is not present in this container" error one line earlier. This is the
  reason the guarded pattern (`if isKey(...) ... else headIdx = []; end`) is used instead of
  a bare `atomIndexMap(headKey)` lookup.
* **Zero-bond file (Edge Case)**: `nAllBonds = 0`, the loop body never executes, and
  `atomIndexMap` is simply never consulted — no special-casing required.

**Alternatives considered**:
* *`struct`-array or table-based index keyed by a computed hash.* Rejected — no simpler
  than `containers.Map`, and `containers.Map` is already precedented in this exact file
  family, satisfying the Assumptions section's "already used elsewhere in this codebase"
  guidance without introducing a new pattern.
* *Sorting `atoms` once and using `ismember`/binary search per bond.* Rejected — still pays
  a per-bond `O(log p)` search plus sort-order bookkeeping to map back to original row
  order (needed for `atoms.elements`/`atoms.atomTransitionNrs` lookups), more complex than
  a single hash-map pass for no measurable benefit at this data scale (atoms/bonds per file
  are in the hundreds, not a regime where O(log p) vs O(1) matters).
* *Overwrite-on-duplicate map (last-write-wins).* Rejected — silently changes behavior on
  the duplicate-key edge case from "errors" to "picks an arbitrary match," which the spec's
  Edge Cases section explicitly forbids ("MUST reproduce the current implementation's exact
  resolution ... rather than silently choosing a different one").

## R2: EdgeTable accumulator design for buildAtomAndBondTransitionMultigraph.m's two loops (FR-003, FR-004, FR-005)

**Decision**: For each of the two loops (atom-transition, current lines ~217-355; bond-
transition, current lines ~547-693), replace the pre-loop `EdgeTable = table(cell(N,2), ...)`
construction with one plain local variable per column (a `N×2` cell for `EndNodes`, a
`N×1` cell or `N×1` double per remaining column, matching each column's existing type
exactly), keep every in-loop write as plain array/cell indexing into those local variables
(`EndNodes{k,1} = ...`, `TransInstIndex(k) = ...`, no `EdgeTable.` prefix anywhere inside
the loop), and construct `EdgeTable = table(EndNodes, Trans, ..., 'VariableNames', {...})`
exactly once, immediately after the loop, using the same column order and
`'VariableNames'` list the current code already passes to its pre-loop `table(...)` call.

**Rationale**:
* This is a pure hoist: the two loops already fully determine every value written to every
  column on every iteration; only the *timing* of `table` object construction moves from
  "once per column, before the loop, then written into `N` times per column via
  `tabular.dotAssign`" to "written into plain pre-allocated arrays `N` times per column via
  ordinary MATLAB array/cell indexing, then the `table` object constructed exactly once."
  `tabular.dotAssign`/`tabular.dotReference` (the profiled hotspot) exist specifically
  because dot-indexing into a `table` object routes through the class's property-set
  machinery on every call; plain array indexing (`arr(k) = ...`, `c{k,1} = ...`) does not.
* **Preallocation size unchanged (Edge Cases, "very large" case)**: the plain arrays are
  preallocated at the exact same `nTotalAtomTransitions`/`nTotalBondTransitions` size the
  current `table(cell(N,...), zeros(N,...), ...)` call already uses (from
  `checkABRXNFiles`, current line 168) — no one-element-at-a-time growth is introduced.
* **Trailing-unfilled-row behavior preserved (FR-005, FR-007)**: if a reaction's RXN file
  fails to parse mid-loop (an existing, out-of-scope try/catch — see Assumptions), fewer
  than `N` rows get written (`k-1 < N` when the loop ends) and the atom-transition loop's
  existing `if nTotalAtomTransitions ~= k-1, warning(...)` check (current line 353) fires
  exactly as it does today, comparing against the same `k`. The table built after the loop
  is still constructed at the full preallocated size `N`, so any trailing never-written
  rows keep the exact same default fill values (`0` for numeric columns, `{}`/empty char
  for cell columns) they already have today from the pre-loop `table(cell(N,...),
  zeros(N,...), ...)` initializer — this feature does not truncate, compact, or otherwise
  change row count or trailing-row content (FR-005). The bond-transition loop has no
  analogous post-loop mismatch check today (only the atom-transition loop's is fired) —
  FR-007's "the existing ... warning MUST continue to fire under the same conditions" is
  satisfied because that is the *only* existing such warning; no new one is introduced for
  the bond loop, since doing so would be new behavior outside this feature's scope.
* **Partial-write-on-caught-failure state (FR-008)**: identical before and after this
  change. Today, if `readABRXNFile`/the inner per-transition loop throws partway through
  reaction `i`'s transitions, some of reaction `i`'s `k` slots may already have been
  dot-assigned into `EdgeTable` before the `catch` block is entered; slots belonging to
  already-completed earlier reactions (`k` values below reaction `i`'s starting `k`) are
  untouched and correct either way. Switching the write target from `EdgeTable.col(k)` to
  `col(k)` (a plain array) does not change *which* `k` slots get written before a given
  failure, nor does it retroactively touch other reactions' slots — the accumulator's
  per-iteration write pattern, not its underlying object type, determines this invariant,
  and that pattern is unchanged.

**Alternatives considered**:
* *Growing arrays with `[arr; newRow]` inside the loop instead of preallocating.* Rejected
  — this is exactly the "grow arrays one element at a time" anti-pattern the spec's Edge
  Cases section explicitly forbids, and would regress memory/time behavior at large scale
  instead of merely avoiding `tabular.dotAssign` overhead.
* *Building the table incrementally in chunks (e.g., every 1000 rows) to bound peak memory.*
  Rejected as unnecessary complexity — the existing code already preallocates the full
  table up front (memory footprint is already `O(N)` today), so a chunked approach would
  not reduce memory versus today's baseline and would reintroduce partial-table-object
  dot-indexing for each chunk, defeating the purpose.
* *Using a `struct` array (one struct per transition) instead of parallel plain arrays.*
  Rejected — a struct array's field access is also not the cheap path MATLAB profiles as
  fastest for this shape (plain preallocated arrays/cells with linear-index writes are), and
  converting a struct array to the required `table` shape at the end adds a translation step
  the parallel-arrays approach does not need (each parallel array already **is** one
  `table` column in the right order).

## R3: FR-010 reproducibility check — placement, relationship to feature 021's script, and call-count instrumentation

**Decision**: A new script,
`specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`, reusing feature
021's `tyrosineReproducibilityCheck.m` as its structural template (model-loading block,
capture-vs-compare mode selection by golden-snapshot presence, before/after results file)
but extended for this feature's own concerns:
1. It captures `dATM.Nodes`, `dATM.Edges`, `dBTM.Nodes`, `dBTM.Edges` (directly — feature
   021's script only captured `arm.L`/`moietyFormulae`/`reacting.*`, one layer downstream of
   `buildAtomAndBondTransitionMultigraph`'s own return values, which this feature's FR-010(a)
   and SC-005 need at their own layer) and a representative sample of
   `readABRXNFile`-returned `atoms`/`bonds` tables for a handful of RXN files in
   `rxnFilesDir` (FR-010(a)).
2. It wraps the parsing/graph-building portion (`buildAtomAndBondTransitionMultigraph`,
   which itself calls `readABRXNFile` and `addBondMappingsRXNFile`) in MATLAB's built-in
   `profile on` / `profile off` / `profile('info')`, then reads the `FunctionTable` entries
   for `cell.ismember`, `tabular.dotAssign`, and `tabular.dotReference` (matching the exact
   function names the spec's own Input section profiling session identified) to report
   before/after call counts (FR-010(c)) — not a hand-rolled counting wrapper. Unlike feature
   021's `isisomorphic` (a Graph-and-Network-Algorithms *toolbox* function callable only from
   the one new helper file that feature added), `cell.ismember`/`tabular.dotAssign`/
   `tabular.dotReference` are MATLAB-builtin/class-internal functions with no single call
   site this feature controls to instrument with a `persistent` counter — `profile` is the
   only mechanism (also consistent with how the spec's own baseline numbers were originally
   obtained). Wall-clock time (SC-004) is measured by running the parsing/graph-building
   portion at least twice per mode (capture/compare) and reporting the average — SC-004
   explicitly requires "averaged over at least 2 runs" given this session's own observed
   ±10% run-to-run wall-clock noise. The profiled call counts are not subject to this
   averaging: they are deterministic per input (the same code parsing the same RXN files
   always makes the same number of `cell.ismember`/`tabular.*` calls), so a single `profile`
   capture per mode is sufficient for FR-010(c)/SC-002/SC-003.
3. It re-runs after the change and asserts structural equality (`isequal`/`isequaln`) of
   `dATM.Nodes`/`dATM.Edges`/`dBTM.Nodes`/`dBTM.Edges` and the sampled `atoms`/`bonds` tables
   against the golden snapshot (FR-010(b), SC-005), and appends the before/after
   `cell.ismember`/`tabular.dotAssign`/`tabular.dotReference` counts and wall-clock time
   (SC-002, SC-003, SC-004) to
   `specs/022-eliminate-table-object-hotspots/tyrosine-reproducibility-results.md`.

**Rationale**: FR-010 says "reusing or extending feature 021's tyrosineReproducibilityCheck.m."
Feature 021's own artifact directory (`specs/021-prefilter-isomorphism-classification/`) is
that completed feature's placement under Principle IX ("Spec Kit artifact →
specs/<feature>/") and its script is scoped to 021's own captured values
(`arm.L`/`moietyFormulae`/`reacting.*`, `isisomorphic` call count) — none of which are what
FR-010 needs captured for *this* feature (`dATM`/`dBTM` tables directly, `atoms`/`bonds`
tables, and three different profiled function names). Directly editing feature 021's script
to bolt on unrelated capture/instrumentation logic would blur which feature owns which
artifact and risks a future feature needing to touch it a third time. Creating this
feature's own script under its own `specs/022-.../` directory, reusing 021's proven
model-loading and capture/compare skeleton verbatim (which is exactly what "reusing" a prior
script's structure means), satisfies FR-010's "reusing or extending" wording, keeps Principle
IX artifact placement clean (each feature's reproducibility script lives with that feature),
and does not require editing anything under `specs/021-.../` (which is not this feature's
scope per SC-006's `src/`-only restriction, and out of scope for `specs/` artifacts entirely).

**Alternatives considered**:
* *Edit `specs/021-.../tyrosineReproducibilityCheck.m` in place to add this feature's
  captures/instrumentation.* Rejected — see Rationale; conflates two features' artifacts in
  one file with no clean ownership boundary, and this feature's spec does not require
  editing that file specifically, only "reusing or extending" its approach.
* *A hand-rolled counting wrapper around `ismember`/table dot-access (analogous to feature
  021's R6 approach for `isisomorphic`).* Rejected — `cell.ismember`, `tabular.dotAssign`,
  and `tabular.dotReference` are not functions this feature calls directly by name from a
  single file it controls (unlike `isisomorphic`, called only from feature 021's own new
  helper); they are invoked implicitly by MATLAB's own dot-indexing/`ismember` syntax
  everywhere in the codebase, and are exactly what the spec's own baseline was measured with.
  `profile` is the correct, and only practical, instrument.

## R4: Constitution/scope confirmation — no new src/ file required

**Decision**: Both FR-001's lookup structure and FR-003/FR-004's accumulator arrays are
implemented as local variables inside the existing bodies of `readABRXNFile.m` and
`buildAtomAndBondTransitionMultigraph.m` respectively — no new function file is created.

**Rationale**: SC-006 restricts modification to exactly
`src/analysis/topology/reactingMoieties/{readABRXNFile.m,
buildAtomAndBondTransitionMultigraph.m}`; a new helper file (as feature 021 needed for its
shared, three-call-site helper) is neither required (both structures are single-call-site,
single-function-scoped, per the spec's own Key Entities section: "[the lookup] exists only
for the lifetime of one `readABRXNFile` call") nor permitted (it would violate SC-006).
FR-006 ("public signatures ... MUST NOT change") is trivially satisfied since neither
function's signature is touched at all — only internal loop bodies change.

**Alternatives considered**: None — this directly follows from SC-006 and FR-006, which
leave no design freedom on this point.
