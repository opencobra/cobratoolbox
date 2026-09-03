# Research: Eliminate remaining cell.ismember scans in buildAtomAndBondTransitionMultigraph's bond-transition loop

**Feature**: `20260902-150020-eliminate-bond-transition-ismember-scans` | **Date**: 2026-09-02

## R1: Lookup data structure, key design, and error semantics for the bond-transition loop's atom-identity resolution (FR-001, FR-002, FR-003, FR-005; US2)

**Decision**: A single `containers.Map('KeyType','char','ValueType','any')`, built once
over `dATM.Nodes` (not `dATME.Nodes`) immediately before the bond-transition per-reaction
loop begins (current line 606's `for i = 1:nRxns`, i.e. inside the
`if options.bondTransitionMultigraph` block alongside the existing
`metBondCountGroundTruth`/`metAtomCanonicalRankMap`/`metUnsafeNeighborsMap` map
declarations at current lines 593-604, so it is never built at all when bond-transition
multigraph construction is skipped):

```matlab
dATMNodeIndexMap = containers.Map('KeyType','char','ValueType','any');
for r = 1:height(dATM.Nodes)
    key = sprintf('%s\x1f%d\x1f%s', dATM.Nodes.mets{r}, dATM.Nodes.AtomNumber(r), dATM.Nodes.Element{r});
    if isKey(dATMNodeIndexMap, key)
        dATMNodeIndexMap(key) = [dATMNodeIndexMap(key), r]; % preserve duplicate-key matches, do not overwrite
    else
        dATMNodeIndexMap(key) = r;
    end
end
```

A new helper function, `resolveAtomNodeIndex.m`, wraps the guarded lookup plus the
`Atom`/`AtomIndex` column read:

```matlab
function [atom, atomIndex] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, met, atomNumber, element)
key = sprintf('%s\x1f%d\x1f%s', met, atomNumber, element);
if isKey(nodeIndexMap, key)
    idx = nodeIndexMap(key);
else
    idx = [];
end
if isempty(idx)
    error('resolveAtomNodeIndex:missingNodeIdentity', ...
        'No node in dATM.Nodes matches (mets=%s, AtomNumber=%d, Element=%s).', met, atomNumber, element);
elseif numel(idx) > 1
    error('resolveAtomNodeIndex:ambiguousNodeIdentity', ...
        '%d nodes in dATM.Nodes match (mets=%s, AtomNumber=%d, Element=%s); expected exactly 1.', ...
        numel(idx), met, atomNumber, element);
end
atom = nodeTable.Atom(idx);
atomIndex = nodeTable.AtomIndex(idx);
end
```

The bond-transition loop body (current lines 677-684) becomes four calls instead of eight
mask expressions:

```matlab
[bondEdgeHeadBondHeadAtom(k), bondEdgeHeadBondHeadAtomIndex(k)] = resolveAtomNodeIndex(dATM.Nodes, dATMNodeIndexMap, subMet1, subAtomNum1, subElem1);
[bondEdgeHeadBondTailAtom(k), bondEdgeHeadBondTailAtomIndex(k)] = resolveAtomNodeIndex(dATM.Nodes, dATMNodeIndexMap, subMet2, subAtomNum2, subElem2);
[bondEdgeTailBondHeadAtom(k), bondEdgeTailBondHeadAtomIndex(k)] = resolveAtomNodeIndex(dATM.Nodes, dATMNodeIndexMap, prodMet1, prodAtomNum1, prodElem1);
[bondEdgeTailBondTailAtom(k), bondEdgeTailBondTailAtomIndex(k)] = resolveAtomNodeIndex(dATM.Nodes, dATMNodeIndexMap, prodMet2, prodAtomNum2, prodElem2);
```

**Rationale**:
* **Why `dATM.Nodes`, not `dATME.Nodes` (FR-004, Assumptions)**: `dATME = addnode(dATM,
  EnergyNode)` (current line 630) only *appends* one row per reaction; it never reorders
  or mutates `dATM.Nodes`'s existing rows. Every row index resolved against `dATM.Nodes`
  therefore addresses the identical `Atom`/`AtomIndex` value in `dATME.Nodes` for that same
  row. The current lines 677-684 never resolve the energy node (confirmed by inspection:
  `subMet1`/`subMet2`/`prodMet1`/`prodMet2` come from `canonicalBondKey` on real
  substrate/product bond mappings, never from the energy-node assignment at lines 632-636),
  so indexing `dATM.Nodes` once — built before the per-reaction loop and never touched
  again — is both sufficient and exactly what FR-002 requires ("once per call ... before
  the per-reaction loop begins").
* **`containers.Map` keyed by a composite `sprintf`-folded string** mirrors the precedent
  feature 022 already established one call site earlier in this same file family
  (`readABRXNFile.m`'s `atomIndexMap`, keyed by `(met, metNr, instance)`) and the precedent
  already present in this exact function (`metBondCountGroundTruth`,
  `metAtomCanonicalRankMap`, `metUnsafeNeighborsMap`, all `containers.Map('KeyType','char',
  ...)`). The unit-separator control character `\x1f` (not a printable character, cannot
  appear in a metabolite identifier, atom number, or element symbol) is used instead of a
  printable delimiter, for the identical collision-avoidance reason feature 022's R1
  documents (compartment tags like `[c]` or ChEBI-style identifiers already contain
  characters that could collide with a printable-delimiter scheme).
* **Duplicate-key and no-match handling, and why this feature raises explicitly instead of
  relying on a downstream size-mismatch error (deviation from feature 022's R1)**: feature
  022's `readABRXNFile.m` fix let a bad-cardinality `idx` propagate unguarded into the
  caller's own array-index assignment, reproducing MATLAB's generic
  "left side is 1-by-1, right side is N-by-1" error one line later — sufficient there
  because that feature had no independent-testability requirement on the lookup itself.
  This feature's spec (User Story 2, FR-005) explicitly requires that *the lookup* — not
  some assignment several lines downstream inside the caller's loop body — is what "raises
  an explicit, identifiable error rather than returning one of the two matches silently" or
  "returning an empty or default value that a caller could mistake for a valid atom
  identity," and explicitly calls for "a direct unit test of the extracted lookup helper."
  `resolveAtomNodeIndex` therefore checks `numel(idx)` itself and raises a named error
  (`resolveAtomNodeIndex:missingNodeIdentity` / `resolveAtomNodeIndex:ambiguousNodeIdentity`)
  before ever touching `nodeTable.Atom`/`nodeTable.AtomIndex` — both more explicit
  (a named, catchable identifier vs. a generic size-mismatch message) and independently
  observable by a test that calls only `resolveAtomNodeIndex` with a synthetic table and
  map, with no dependency on RXN-file parsing or the surrounding loop. This satisfies
  FR-005 ("at least as clear as today's") strictly, and US2's AC1/AC2 literally (the
  function call that performs the lookup is the one that raises).
  `error('functionName:condition', 'message', ...)` matches the convention already used
  throughout this exact directory (`identifyAtomEquivalenceClasses.m`,
  `readABRXNFile.m`'s own `blockOrderMismatch`, `classifySubgraphIsomorphism.m`,
  `minimumSetCoverPlain.m` — grep-confirmed against the current source tree), so no new
  MATLAB idiom is introduced (VII-G).
* **Zero-bond-transition reaction (Edge Cases)**: `dATMNodeIndexMap` is built once before
  the `for i = 1:nRxns` loop and is simply never consulted if `max(bondMappings.bondTransitionNrs)`
  yields no iterations for a given reaction — no special-casing required, matching feature
  022 R1's identical "zero-bond file" analysis.
* **Combining the `Atom` and `AtomIndex` lookup into one helper call, one map lookup per
  atom identity**: today's code performs the *same* mask expression twice per atom identity
  (once to index `.Atom`, once to index `.AtomIndex`) — 8 mask expressions (4 identities x
  2 columns), 16 `ismember` calls. `resolveAtomNodeIndex` performs the composite-key lookup
  once per identity and reads both columns from the same resolved `idx`, so the
  bond-transition loop makes exactly 4 lookup calls per bond-transition (one per
  substrate/product head/tail atom) instead of 8 mask expressions — a stronger reduction
  than a literal 8-lookups-replace-8-mask-expressions translation would give, with no
  additional complexity (`idx` is already resolved once; reusing it for both columns is
  free).

**Alternatives considered**:
* *Let the bad-cardinality `idx` propagate into the caller's array assignment unguarded,
  exactly as feature 022's R1 did for `readABRXNFile.m`.* Rejected — this feature's User
  Story 2 explicitly requires the lookup itself (not a downstream assignment) to raise, and
  explicitly asks for an independently unit-testable extracted helper; an unguarded
  propagate-and-let-it-fail-later design cannot be unit-tested without also reconstructing
  the caller's exact downstream assignment shape in the test, which is the extraction this
  feature is meant to avoid needing.
* *`struct`-array or sorted-table-plus-binary-search index.* Rejected for the same reasons
  feature 022's R1 rejected it: no simpler than `containers.Map`, and `containers.Map` is
  already precedented in this exact function and its neighbor file, satisfying the spec's
  Assumptions-section guidance to reuse "the same fix shape that already worked in
  readABRXNFile.m" without introducing a new pattern.
* *Overwrite-on-duplicate map (last-write-wins).* Rejected — silently changes behavior on
  the duplicate-key edge case from "errors" to "picks an arbitrary match," which FR-005
  explicitly forbids.
* *Building the index over `dATME.Nodes` once per reaction (inside the `for i = 1:nRxns`
  loop, after the energy node is appended).* Rejected — violates FR-002 ("once per call ...
  not once per reaction") for no benefit, since the energy node is never a lookup target at
  this call site (Assumptions) and `dATM.Nodes` is already stable across the whole
  function call.

## R2: Extracting `resolveAtomNodeIndex.m` as a new `src/` file vs. an inline (feature-022-style) fix (FR-001, FR-005; US2; Principle V, III-Naming)

**Decision**: Extract the guarded lookup into a new, single-purpose function file,
`src/analysis/topology/reactingMoieties/resolveAtomNodeIndex.m`, with its own dedicated CI
test, `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m`
(constitution III-Naming: `test<FunctionName>.m`, one test file per source function). The
`containers.Map`-building loop itself (R1) stays inline in
`buildAtomAndBondTransitionMultigraph.m`, exactly as feature 022's equivalent
`atomIndexMap`-building loop stayed inline in `readABRXNFile.m` — it has exactly one call
site (built once per function call) and no independent-testability requirement, so
extracting it would add a file with no corresponding feature need.

**Rationale**:
* Feature 022's `readABRXNFile.m` fix (R4 there) deliberately introduced **no** new file,
  because that feature's spec carried no requirement that the lookup be independently
  testable outside the full parsing pipeline — any duplicate/no-match behavior was
  verifiable only through the natural downstream error, and that was sufficient for that
  feature's User Story 2-equivalent Edge Case coverage.
  This feature's spec is different: User Story 2's Independent Test explicitly offers
  "a direct unit test of the extracted lookup helper" as the practical way to exercise the
  zero-/multi-match paths (the production model corpus has no known duplicate or missing
  node-identity keys per the spec's own Assumptions, so the only way to exercise those
  paths deterministically is a synthetic table, and the only way to do that without
  reconstructing `buildAtomAndBondTransitionMultigraph`'s full `model`/`RXNFileDir`
  call contract is to extract the lookup into its own directly-callable function).
* Principle V requires new files to be justified by a feature need; US2's explicit
  independent-test requirement is that need. The extraction is minimal — one pure function,
  no new dependency, no new abstraction beyond the single lookup-plus-read operation it
  replaces at its one call site (called four times per bond-transition iteration, all
  within `buildAtomAndBondTransitionMultigraph.m`).
* Constitution III-Naming requires exactly one `test<FunctionName>.m` per source function;
  `resolveAtomNodeIndex.m` therefore gets its own `testResolveAtomNodeIndex.m` rather than
  folding its assertions into `testConservedReactingMoieties.m` (which tests the pipeline's
  end-to-end behavior, not this one helper's error contract in isolation).

**Alternatives considered**:
* *Keep the lookup fully inline in `buildAtomAndBondTransitionMultigraph.m`, matching
  feature 022's precedent exactly.* Rejected — see Rationale; this feature's own User
  Story 2 explicitly calls for an extracted, independently unit-testable helper, which an
  inline implementation cannot satisfy without a test that duplicates the caller's internal
  loop structure just to reach the lookup.
* *A local (file-private) MATLAB function at the bottom of
  `buildAtomAndBondTransitionMultigraph.m` instead of a separate file.* Rejected — MATLAB
  local functions are not callable from outside their containing file, so a local function
  cannot be unit-tested directly by a separate test file, defeating the purpose of the
  extraction.
* *Also extract the `containers.Map`-building loop (R1) into its own
  `buildAtomNodeIndex.m` file.* Rejected — it has exactly one call site and no independent
  testability requirement in the spec; adding a second new file for it would be scope
  creep against Principle V with no corresponding feature need.

## R3: FR-007/FR-008 reproducibility check — placement and relationship to features 021/022's script

**Decision**: A new script,
`specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m`,
reusing feature 022's `tyrosineReproducibilityCheck.m` (itself built on feature 021's) as
its structural template (model-loading block, capture-vs-compare mode selection by
golden-snapshot presence, before/after results file), extended for this feature's own
concerns:

1. It captures `arm.L`, `moietyFormulae`, and `reacting.selectedReactionNames` (the same
   layer feature 021's script captured, and what this feature's own FR-007/SC-003
   specifically name) as the golden snapshot.
2. It wraps the relevant pipeline portion in MATLAB's built-in `profile on` / `profile
   off` / `profile('info')`, then reads the `FunctionTable` entries for `cell.ismember` and
   `tabular.dotReference` (matching the exact function names this feature's own SC-001/
   SC-002 and the spec's Input-section profiling session use) to report before/after call
   counts attributable to `buildAtomAndBondTransitionMultigraph.m` — not a hand-rolled
   counting wrapper, for the identical reason feature 022's R3 gives (these are
   MATLAB-builtin/class-internal functions with no single call site this feature controls).
3. It re-runs after the change and asserts byte-identical equality (`isequal`/`isequaln`)
   of `arm.L`, `moietyFormulae`, and `reacting.selectedReactionNames` against the golden
   snapshot (FR-007, SC-003), and appends the before/after `cell.ismember`/
   `tabular.dotReference` counts, their percentage reduction from the pre-feature-022
   baselines (508,534 and 1,863,426), and wall-clock time (SC-001, SC-002, SC-005) to
   `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosine-reproducibility-results.md`.

**Rationale**: FR-007 explicitly names `tyrosineReproducibilityCheck.m` "introduced in
feature 021, reused in feature 022" as the check to re-run; this feature continues that
same reuse-as-structural-template chain rather than editing either prior feature's own
artifact directory (Principle IX: each feature's reproducibility script lives with that
feature, per features 021/022's own established precedent — research.md R3 in feature 022
gives the identical reasoning for not editing feature 021's script in place).

**Alternatives considered**:
* *Edit feature 022's `specs/022-.../tyrosineReproducibilityCheck.m` in place.* Rejected —
  identical reasoning to feature 022's own R3: conflates two features' artifacts in one
  file with no clean ownership boundary; not required, since FR-007 asks only that the
  same script be "re-run," which this feature's own copy under its own `specs/` directory
  satisfies by construction (same captured values, same methodology).
* *A hand-rolled counting wrapper around `ismember`/`tabular.dotReference`.* Rejected —
  identical reasoning to feature 022's R3; `profile` is the only practical instrument for
  MATLAB-builtin/class-internal call counting.

## R4: Constitution/scope confirmation — the one justified new `src/` file

**Decision**: `resolveAtomNodeIndex.m` is the only new `src/` file this feature creates,
and it is placed in the same domain folder as its only caller
(`src/analysis/topology/reactingMoieties/`), per Principle IX ("new code SHOULD be added
as a new subfolder under the most appropriate domain" is a guideline for genuinely new
capabilities; a single-purpose helper for one existing function's internal refactor stays
beside that function, matching how `canonicalBondKey.m`, `identifyAtomEquivalenceClasses.m`,
and `safeCanonicalizeBondAtoms` already sit beside
`buildAtomAndBondTransitionMultigraph.m` as its helper functions, not in a new subfolder).

**Rationale**: R2 already establishes the feature need (US2's independent-testability
requirement) for this one file. No second new file is required: the `containers.Map`
build step (R1) stays inline (R2), and the reproducibility check (R3) is a Spec Kit
artifact under `specs/`, not a `src/` file.

**Alternatives considered**: None — this directly follows from R1/R2/R3, which leave no
design freedom on this point.
