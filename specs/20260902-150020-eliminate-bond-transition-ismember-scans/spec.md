# Feature Specification: Eliminate remaining cell.ismember scans in buildAtomAndBondTransitionMultigraph's bond-transition loop

**Feature Branch**: `20260902-150020-eliminate-bond-transition-ismember-scans`

**Created**: 2026-09-02

**Status**: Draft

**Input**: User description: "Feature 022 (eliminate-table-object-hotspots) shipped but missed its own SC-002/SC-003 targets: cell.ismember fell 66.8% against a >=90% target, tabular.dotAssign fell 48.6% against a >=70% target, tabular.dotReference fell 27.4% against a >=70% target, on the Tyrosine benchmark (139 reactions). Root cause, confirmed by inspection of the current source (src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m, lines 677-684, unchanged by feature 022): the bond-transition loop resolves each bond-transition's four atom identities (substrate head/tail, product head/tail) by scanning dATME.Nodes with two ismember calls (on mets and Element) plus an AtomNumber equality, combined into a boolean mask, once for the Atom column and again for the AtomIndex column -- 8 lookup expressions per bond-transition, 16 ismember calls total, scaled by nTotalBondTransitions, the dominant term in the whole profile. This is the same 'no lookup index' anti-pattern feature 022's User Story 1 already fixed in readABRXNFile.m, at a call site feature 022's spec never scoped in (022's FR-003/FR-004 covered only how computed values get written into EdgeTable via dot-indexing, not how they get computed via these ismember scans). dATM.Nodes (the base multigraph node table these scans actually search, via its per-reaction extension dATME) is built once before the per-reaction loop starts (line 372/396), so a node-identity index built once per function call -- the same fix shape that already worked in readABRXNFile.m -- is the natural closing move."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Bond-transition loop resolves atom identity via an index, not 16 linear scans (Priority: P1)

A researcher runs the conserved/reacting-moieties pipeline and
buildAtomAndBondTransitionMultigraph's bond-transition loop resolves each
bond-transition's four substrate/product atom identities (head/tail x
substrate/product) against a lookup index built once per function call,
instead of re-scanning the entire node table twice per identity (once via
`ismember` on `mets`, once via `ismember` on `Element`, combined with an
`AtomNumber` equality) -- 16 `ismember` calls per bond-transition today.

**Why this priority**: this is the specific, already-diagnosed root cause of
feature 022 missing its own SC-002 (>=90% cell.ismember reduction; 66.8%
achieved) and SC-003 (>=70% tabular.dotReference reduction; 27.4% achieved)
targets -- the single largest remaining hotspot in the pipeline's profiler
results, and the reason those targets are still open two features later.
Fixing it completes work feature 022 already committed to but didn't finish.

**Independent Test**: Run
test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m
and confirm it still passes with every existing assertion unchanged.
Separately, run the Tyrosine benchmark reproducibility check
(`tyrosineReproducibilityCheck.m`, introduced in feature 021, reused in
feature 022) before and after this change and confirm `arm.L`,
`moietyFormulae`, and `reacting.selectedReactionNames` are byte-identical,
while the MATLAB Profiler's `cell.ismember` and `tabular.dotReference` call
counts attributable to `buildAtomAndBondTransitionMultigraph.m` are
measurably and substantially lower.

**Acceptance Scenarios**:

1. **Given** an existing atom-mapped RXN file feeding a reaction with at
   least one bond-transition, **When** buildAtomAndBondTransitionMultigraph
   resolves that bond-transition's four atom identities before and after
   this change, **Then** the `bondEdgeHeadBondHeadAtom` /
   `bondEdgeHeadBondTailAtom` / `bondEdgeTailBondHeadAtom` /
   `bondEdgeTailBondTailAtom` values and their `...Index` counterparts are
   identical, value for value, in the same iteration order.
2. **Given** the Tyrosine metabolism subsystem benchmark, **When** the full
   pipeline runs after this change, **Then** the total `cell.ismember` call
   count attributable to `buildAtomAndBondTransitionMultigraph.m` is
   strictly lower than the pre-change baseline, and both the new count and
   the resulting percentage reduction from the pre-feature-022 baseline
   (508,534) are reported, not just asserted pass/fail.
3. **Given** a reaction with more than one bond-transition, **When** the
   loop runs, **Then** the node-identity index built at the start of the
   function call is reused across all bond-transitions and all reactions in
   that call, not rebuilt per bond-transition or per reaction.
4. **Given** a reaction whose bond-transition atom identities reference an
   atom that genuinely is not present in `dATM.Nodes` (a malformed or
   edge-case input), **When** the loop runs after this change, **Then** it
   fails in an equally explicit way to the current implementation's
   element-count-mismatch error -- the fix must not silently proceed with a
   missing or wrong atom identity.

---

### User Story 2 - Ambiguous or missing atom-identity lookups fail loudly, not silently (Priority: P2)

If a bond-transition's composite atom-identity key (metabolite, canonical
atom number, element) ever resolves to more than one row, the pipeline
reports a specific, diagnosable failure rather than silently selecting one
of the matches or silently corrupting a downstream field.

**Why this priority**: this is a safety net for the User Story 1 refactor,
not new functionality -- independently valuable because it is the one
behavior that is easy to get subtly wrong when replacing boolean-mask
indexing with a map/index lookup (a `containers.Map`-style lookup naturally
returns exactly one value per key, which can silently mask what today is a
loud crash on a non-unique or missing match, since MATLAB's
`A(k) = B(mask)` errors on an element-count mismatch when `mask` matches
zero or more than one row). Lower priority than User Story 1 because it only
matters if User Story 1's uniqueness assumption is ever violated, which is
not known to happen in the current model corpus but also is not proven.

**Independent Test**: Add one targeted regression case (a synthetic node
table with a duplicated or missing key, or a direct unit test of the
extracted lookup helper) confirming a duplicate-key or missing-key input
surfaces an explicit error rather than proceeding.

**Acceptance Scenarios**:

1. **Given** a synthetic node table with two rows sharing the same
   `(mets, AtomNumber, Element)` key, **When** the lookup is invoked for
   that key, **Then** it raises an explicit, identifiable error rather than
   returning one of the two matches silently.
2. **Given** a synthetic node table with no row matching a requested key,
   **When** the lookup is invoked for that key, **Then** it raises an
   explicit, identifiable error rather than returning an empty or default
   value that a caller could mistake for a valid atom identity.

### Edge Cases

- What happens when a bond-transition's composite key legitimately cannot
  be found in `dATM.Nodes` (malformed RXN file, an upstream parsing bug)?
  Must fail the same way as today, not silently continue.
- What happens when a reaction has zero bond-transitions (e.g., only
  atom-level changes)? The node-identity index must still build without
  error even if never queried that iteration.
- Does the index correctly stay valid across all reactions in the same run,
  given `dATM.Nodes` itself does not change once built (only `dATME`, its
  per-reaction extension with the energy pseudo-node, changes per reaction)?
- How does the fix interact with feature 020's symmetry/resonance
  canonicalization (`metAtomCanonicalRankMap`)? `subAtomNum1`/`subAtomNum2`
  and `prodAtomNum1`/`prodAtomNum2` are already canonicalized upstream of
  this loop via `safeCanonicalizeBondAtoms`, so the index is expected to be
  a pure lookup over already-canonical keys, not a second canonicalization
  step.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST replace the 16 `ismember`-based composite-key
  scans per bond-transition iteration (lines 677-684 of
  `buildAtomAndBondTransitionMultigraph.m`: 8 lookup expressions, each
  combining two `ismember` calls over `dATME.Nodes.mets` and
  `dATME.Nodes.Element` plus one `AtomNumber` equality) with lookups against
  a node-identity index.
- **FR-002**: System MUST build the node-identity index from `dATM.Nodes`
  (the run-once base multigraph node table) exactly once per call to
  `buildAtomAndBondTransitionMultigraph`, before the per-reaction loop
  begins -- not once per reaction and not once per bond-transition.
- **FR-003**: System MUST key the index on the same composite identity the
  current `ismember` scans use -- metabolite id (`mets`), canonical atom
  number (`AtomNumber`), and element (`Element`) -- and MUST return, for a
  given key, the same `Atom` and `AtomIndex` values the current
  implementation returns for that key.
- **FR-004**: System MUST leave resolution of the reaction-specific energy
  pseudo-node (`dATME`'s appended `'E'` row, handled separately via the
  `bondMappings.headAtoms`/`tailAtoms` energy-node assignment above this
  loop) untouched, since lines 677-684 never look up the energy node -- the
  index is scoped to the same real substrate/product atoms the current
  scans resolve.
- **FR-005**: System MUST fail in a way that is at least as clear as
  today's behavior when a composite key resolves to zero rows or to more
  than one row in `dATM.Nodes` -- today's boolean-mask indexing errors on
  an element-count mismatch when assigning into a single cell/array slot
  for a non-unique or empty match; the index-based lookup MUST NOT silently
  pick an arbitrary match or silently drop the bond-transition in either
  case.
- **FR-006**: System MUST preserve documented public interfaces, diagnostic
  semantics, and file-location conventions affected by this feature --
  `buildAtomAndBondTransitionMultigraph`'s function signature, return
  values, and the `EdgeTable` schema it produces must be unchanged.
- **FR-007**: System MUST define the narrowest reproducibility check that
  proves the feature's behavior is unchanged: re-running
  `tyrosineReproducibilityCheck.m` (introduced in feature 021, reused in
  feature 022) against the existing `tyrosine-golden-snapshot.mat` and
  confirming byte-identical `arm.L`, `moietyFormulae`, and
  `reacting.selectedReactionNames`.
- **FR-008**: System MUST report measurable call-count and wall-clock
  deltas for this change using the same MATLAB Profiler methodology used in
  features 021 and 022 (Tyrosine benchmark, 139 reactions), so the result
  is directly comparable to the pre-022 baseline and the feature-022
  shortfall it is meant to close.

### Key Entities

- **dATM.Nodes / dATME.Nodes**: the atom/bond-transition multigraph's node
  table (columns `Atom`, `AtomIndex`, `mets`, `AtomNumber`, `Element`).
  `dATM.Nodes` is built once per function call and is what lines 677-684
  actually search; `dATME.Nodes` is `dATM.Nodes` plus one reaction-scoped
  energy pseudo-node appended per reaction.
- **Node-identity index**: the new lookup structure this feature introduces
  over `dATM.Nodes`, keyed on `(mets, AtomNumber, Element)`, replacing the
  current `ismember`-based scans; built once per function invocation.
- **Bond-transition atom-identity lookup**: the 4 distinct
  (substrate-head, substrate-tail, product-head, product-tail) atom
  identities resolved twice each (once for `Atom`, once for `AtomIndex`)
  per bond-transition iteration -- 8 lookup expressions, 16 `ismember`
  calls today.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the Tyrosine benchmark (139 reactions), total pipeline
  `cell.ismember` calls fall to at most 10% of the pre-feature-022 baseline
  (508,534), i.e. <=50,853 -- completing the >=90% reduction target
  feature 022 fell short of (66.8% achieved).
- **SC-002**: On the same benchmark, `tabular.dotReference` calls fall to
  at most 30% of the pre-feature-022 baseline (1,863,426), i.e. <=559,028
  -- completing the >=70% reduction target feature 022 fell short of
  (27.4% achieved). `tabular.dotAssign` is out of scope for this feature
  (see Assumptions) and is not gated by a success criterion here.
- **SC-003**: The reproducibility check (`tyrosineReproducibilityCheck.m`)
  reports byte-identical `arm.L`, `moietyFormulae`, and
  `reacting.selectedReactionNames` before and after the change.
- **SC-004**: `testConservedReactingMoieties.m` passes with every existing
  assertion unchanged.
- **SC-005**: Total pipeline wall-clock time on the Tyrosine benchmark does
  not regress relative to the post-feature-022 baseline (55.0s); a further
  reduction is expected but not gated.
- **SC-006**: A targeted regression case demonstrates that a lookup key
  resolving to zero or multiple `dATM.Nodes` rows still surfaces as an
  explicit failure, not a silently wrong or silently dropped
  bond-transition.

## Assumptions

- `dATM.Nodes` contains at most one row per `(mets, AtomNumber, Element)`
  combination for the canonicalized atom numbers `safeCanonicalizeBondAtoms`
  already produces upstream of this loop -- the same uniqueness the current
  `ismember`-based scans already implicitly rely on; this feature does not
  change that invariant, only how it is looked up.
- The energy pseudo-node `dATME` appends per reaction is never a target of
  the lines 677-684 lookups (confirmed by inspection: those lookups only
  ever resolve `subMet1`/`subMet2`/`prodMet1`/`prodMet2`, which come from
  `canonicalBondKey` on real substrate/product bond mappings, never from
  the energy-node assignment a few lines above), so indexing `dATM.Nodes`
  once -- rather than `dATME.Nodes` once per reaction -- is sufficient and
  does not need to include the energy node.
- Feature 022's User Story 2 (EdgeTable write-side, dot-indexed assignment
  replaced with plain arrays) is complete and unaffected by this feature;
  this feature only replaces read-side lookups, so no further
  `tabular.dotAssign` reduction is targeted or expected here.
- The Tyrosine metabolism subsystem model (139 reactions) remains the
  benchmark and profiling target, consistent with features 021 and 022, so
  results are directly comparable across all three.
- MATLAB itself is not reachable from the assistant's device-bridge
  sandbox; implementation, test execution, and profiler reruns for this
  feature are expected to happen in the user's own MATLAB session, with
  correctness argued by code trace/diff review where direct MATLAB
  verification is not available to the assistant.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-003, FR-004 | testConservedReactingMoieties.m (existing regression suite, unmodified assertions) | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US1 / SC-001, SC-002 | Tyrosine benchmark MATLAB Profiler rerun (cell.ismember / tabular.dotReference call-count comparison, same methodology as features 021/022) | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US1 / SC-003 | tyrosineReproducibilityCheck.m (byte-identical arm.L / moietyFormulae / reacting.selectedReactionNames) | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US1 / SC-005 | Tyrosine benchmark wall-clock timing (same reproducibility run) | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US2 / FR-005, SC-006 | New targeted unit test: zero-match and multi-match lookup-key regression case (to be added under test/verifiedTests/analysis/testReactingMoieties/) | src/analysis/topology/reactingMoieties/resolveAtomNodeIndex.m (new lookup helper extracted from buildAtomAndBondTransitionMultigraph.m; see plan.md) |
| US2 / SC-004 | testConservedReactingMoieties.m (existing regression suite, unmodified assertions) — shared regression gate, also discharging the US1 row above | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
