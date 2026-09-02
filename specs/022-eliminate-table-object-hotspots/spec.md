# Feature Specification: Eliminate table-object dot-indexing and cell.ismember hotspots in RXN parsing

**Feature Branch**: `022-eliminate-table-object-hotspots`

**Created**: 2026-09-02

**Status**: Draft

**Input**: User description: "MATLAB profiler run on runTyrosineMoietyProfile_fixed.m (139-reaction Tyrosine metabolism subsystem, 149s total, post feature-021 isomorphism-prefilter and post checkABRXNFiles duplicate-read fix) shows cell.ismember as the single largest self-time consumer in the entire profile (11.6s, 525,632 calls), with a cluster of MATLAB table-object internals (tabular.dotAssign 10.1s/797,966 calls, tabular.dotReference 7.9s/2,158,231 calls, dotAssign>localTranslatedAssign 7.4s, tabular.vertcat 6.9s, tabular.dotParenReference 4.5s, tabular.horzcat 2.9s, plus a dozen smaller tabular.* functions) accounting for roughly 70 seconds of self-time out of the ~149 second run -- nearly half the pipeline, and larger than either of the two fixes already applied. The Parents breakdown for cell.ismember and tabular.dotAssign/dotReference attributes almost all of this to two call sites: (1) readABRXNFile.m lines 253-258, whose per-bond loop does two redundant find(...&ismember(...)) linear scans over the whole atoms table per bond (once each for the head and tail atom-transition-number lookup, then repeats the identical head/tail search a second time just to fetch a different column), and (2) buildAtomAndBondTransitionMultigraph.m's two EdgeTable-building loops (atom-transition, currently lines ~241-353, and bond-transition, currently lines ~590-693), which build a MATLAB table object row-by-row via dot-indexed assignment (EdgeTable.EndNodes{k,1}=..., roughly 15-20 fields per iteration) across potentially thousands of atom/bond transitions. Because addBondMappingsRXNFile.m internally calls readABRXNFile.m once per invocation, fixing readABRXNFile.m's algorithm benefits every one of its callers (checkABRXNFiles, both buildAtomAndBondTransitionMultigraph loops, and addBondMappingsRXNFile itself) without touching those call sites. addBondMappingsRXNFile.m's own separate redundant internal readABRXNFile call (a duplicate-read anti-pattern distinct from this feature's table-indexing focus) is explicitly OUT of scope and remains tracked separately, as does anything already covered by feature 021."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - readABRXNFile's per-bond atom lookup stops re-scanning the whole molecule (Priority: P1)

A researcher runs the conserved/reacting-moieties pipeline and readABRXNFile.m
parses each RXN file's bond list against its atom list without doing a full
linear scan of the atom table for every single bond, and without repeating
the identical head-atom or tail-atom search twice just to read a second
column off the same matched row.

**Why this priority**: readABRXNFile is the dominant single contributor to
both cell.ismember (340,278 of 525,632 calls, 65%) and tabular.dotReference
(1,019,438 of 2,158,231 calls, 47%) in the whole profile, and it is called
from four places (checkABRXNFiles, both buildAtomAndBondTransitionMultigraph
loops, and internally from addBondMappingsRXNFile), so a fix here compounds
across the entire pipeline without touching any of its callers. It is also
the smaller, more contained of the two fixes in this feature: one function,
a ten-line loop, no restructuring of any data type callers depend on.

**Independent Test**: Run
test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m
and confirm it still passes with every existing assertion unchanged. Separately,
call readABRXNFile directly on a sample of existing atom-mapped RXN files
before and after the change and confirm the returned atoms and bonds tables
are field-for-field identical, while the cell.ismember and tabular.dotReference
call counts attributable to readABRXNFile are measurably lower.

**Acceptance Scenarios**:

1. **Given** an existing atom-mapped RXN file with more than one bond, **When**
   readABRXNFile parses it before and after this change, **Then** the returned
   bonds table's headAtomTransitionNrs, tailAtomTransitionNrs, headAtomElements,
   and tailAtomElements columns are identical, value for value, in the same
   row order.
2. **Given** the Tyrosine metabolism subsystem benchmark, **When** the full
   pipeline runs after this change, **Then** the total cell.ismember call
   count attributable to readABRXNFile is strictly lower than the pre-change
   baseline (340,278), and this reduction is reported, not just asserted
   pass/fail.
3. **Given** an RXN file whose bond list references an atom that genuinely
   does not exist in the atom list (a malformed or edge-case file), **When**
   readABRXNFile parses it after this change, **Then** it fails in the same
   way (same error, or same empty-match behavior) as the current
   find(...&ismember(...)) implementation -- the fix must not silently paper
   over a lookup miss that today surfaces as an error.
4. **Given** an RXN file with zero bonds, **When** readABRXNFile parses it,
   **Then** it returns the same (trivial) bonds table as today without
   indexing errors.

---

### User Story 2 - buildAtomAndBondTransitionMultigraph stops building its EdgeTable one dot-indexed row at a time (Priority: P2)

A researcher runs buildAtomAndBondTransitionMultigraph and its two per-reaction
loops (atom-transition and bond-transition) accumulate each transition's
fields in plain preallocated arrays during the loop, constructing the actual
table/digraph object only once after the loop completes, instead of writing
into a live table object on every iteration.

**Why this priority**: this is the second-largest contributor to the same
hotspot cluster (168,196 of 525,632 cell.ismember calls, 32%; 376,105 of
797,966 tabular.dotAssign calls, 47%) but is a larger, more invasive change
than User Story 1 -- it touches the internal data-flow of two loops across
roughly 150 lines in one function, rather than one contained ten-line block,
so it is prioritized second and is independently valuable even if User
Story 1 were the only one shipped.

**Independent Test**: Run testConservedReactingMoieties.m and confirm it
still passes unmodified. Separately, run the Tyrosine benchmark reproducibility
check (the same mechanism feature 021 introduced) before and after this
change and confirm buildAtomAndBondTransitionMultigraph's own dATM and dBTM
outputs (Nodes and Edges tables) are identical, while the tabular.dotAssign,
tabular.dotReference, and cell.ismember call counts attributable to
buildAtomAndBondTransitionMultigraph are measurably lower.

**Acceptance Scenarios**:

1. **Given** the Tyrosine metabolism subsystem benchmark, **When**
   buildAtomAndBondTransitionMultigraph runs before and after this change,
   **Then** the returned dATM.Nodes, dATM.Edges, dBTM.Nodes, and dBTM.Edges
   are identical in content and row order between the two runs.
2. **Given** the same benchmark, **When** the classification step runs after
   this change, **Then** the tabular.dotAssign and tabular.dotReference call
   counts attributable to buildAtomAndBondTransitionMultigraph are strictly
   lower than the pre-change baseline (376,105 and 170,000 respectively), and
   this reduction is reported.
3. **Given** the existing not-yet-fixed edge case where a single reaction's
   RXN file fails mid-loop (the two crash-fix bugs addressed separately from
   this feature), **When** that failure occurs after this change, **Then**
   the partially-built plain-array accumulator for that loop is left in a
   safe, well-defined state (the failed reaction's row simply never gets
   written) and does not corrupt rows already accumulated for earlier
   reactions.
4. **Given** the existing nTotalAtomTransitions/nTotalBondTransitions
   preallocation-size mismatch check (`if nTotalAtomTransitions ~= k-1,
   warning(...)`), **When** the loop is refactored to plain arrays, **Then**
   this same check and warning still fire under the same conditions as today.

### Edge Cases

- What happens when readABRXNFile's new lookup structure is built for a file
  where two atoms share the same (met, metNr, instance) key (should not
  happen per the existing data invariant, but the current find(...) would
  return whichever index(es) match)? The replacement MUST reproduce the
  current implementation's exact resolution (including erroring or picking
  the same match) rather than silently choosing a different one.
- What happens with a bond whose bondTransitionNrs contains a gap or
  non-contiguous numbering? Neither loop's iteration order or trip count may
  change as part of this feature -- only how each iteration's result is
  stored.
- What happens when nRxns or the number of atoms/bonds in a single file is
  very large? The new lookup/array-accumulation approach must not regress
  memory behavior (e.g. must still preallocate by the existing
  nTotalAtomTransitions/nTotalBondTransitions counts, not grow arrays one
  element at a time).
- The existing small CI fixture (3 reactions) produces very few atoms/bonds
  per file -- the fix must not regress correctness or add measurable
  overhead at that trivial scale even though its benefit is invisible there.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: readABRXNFile.m's per-bond loop MUST replace the current
  per-bond, per-column find(atoms.metNrs==... & atoms.instances==... &
  ismember(atoms.mets,...)) linear scans with a lookup built once before the
  loop (keyed by metabolite identifier, metNr, and instance), used for both
  the head-atom and tail-atom lookups, computed once per bond rather than
  once per output column.
- **FR-002**: The replacement lookup MUST return results identical to the
  current implementation for every existing atom-mapped RXN file: same
  headAtomTransitionNrs, tailAtomTransitionNrs, headAtomElements, and
  tailAtomElements values, in the same row order, including on any input
  that currently produces an error or an empty match.
- **FR-003**: buildAtomAndBondTransitionMultigraph.m's atom-transition loop
  (the one populating EdgeTable via readABRXNFile, currently lines ~241-353)
  MUST accumulate its per-transition fields in preallocated plain arrays or
  cell arrays during the loop and construct the EdgeTable (and therefore
  dATM) only once, after the loop completes, rather than writing into a live
  table object on every iteration.
- **FR-004**: buildAtomAndBondTransitionMultigraph.m's bond-transition loop
  (currently lines ~590-693, itself the subject of the recent try/catch
  robustness fix) MUST receive the same treatment as FR-003 for its own
  EdgeTable (and therefore dBTM).
- **FR-005**: Neither FR-003 nor FR-004 MAY change the number, order, or
  content of rows that end up in EdgeTable/dATM/dBTM -- only how each row's
  data is accumulated before the table is built.
- **FR-006**: Public signatures of readABRXNFile, addBondMappingsRXNFile,
  and buildAtomAndBondTransitionMultigraph (inputs, outputs, and their
  documented meaning) MUST NOT change -- this is an internal implementation
  change only (Constitution Principle II).
- **FR-007**: The existing nTotalAtomTransitions/nTotalBondTransitions
  preallocation-mismatch warning in buildAtomAndBondTransitionMultigraph
  MUST continue to fire under the same conditions as before this change.
- **FR-008**: The two try/catch blocks recently added around
  buildAtomAndBondTransitionMultigraph's atom-transition and bond-transition
  loops (log-and-skip on a parse failure) MUST continue to function
  correctly against the refactored plain-array accumulation -- a caught
  failure for one reaction must not leave the accumulator for already-
  processed reactions in an inconsistent state.
- **FR-009**: test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m
  MUST continue to pass after this change with every existing assertion
  intact -- none loosened, removed, or replaced.
- **FR-010**: The feature MUST include a documented, non-CI reproducibility
  check (Constitution Principle III's substitute for a full automated test,
  given the Tyrosine benchmark's external model/RXN-file dependencies and
  multi-minute runtime), reusing or extending feature 021's
  tyrosineReproducibilityCheck.m, that: (a) captures dATM.Nodes, dATM.Edges,
  dBTM.Nodes, dBTM.Edges, and the readABRXNFile-returned atoms/bonds tables
  for a sample of RXN files as a golden snapshot BEFORE this change, (b)
  re-runs the same benchmark AFTER the change and asserts structural
  equality against that snapshot, and (c) reports the before/after
  cell.ismember, tabular.dotAssign, and tabular.dotReference call counts
  attributable to readABRXNFile and buildAtomAndBondTransitionMultigraph.
- **FR-011**: This feature MUST NOT modify addBondMappingsRXNFile.m's own
  internal redundant call to readABRXNFile, or anything already addressed by
  feature 021 (021-prefilter-isomorphism-classification) -- those are
  tracked separately.

### Key Entities

- **Atom lookup structure**: new concept introduced by this feature -- a
  per-file structure (e.g. a containers.Map or equivalent index) built once
  from the atoms table's met/metNr/instance columns, replacing the current
  per-bond linear scan. Exists only for the lifetime of one readABRXNFile
  call.
- **EdgeTable accumulator**: new concept introduced by this feature -- the
  preallocated plain-array/cell-array staging area each of
  buildAtomAndBondTransitionMultigraph's two loops writes into per iteration,
  replacing direct dot-indexed writes into a live table object. Converted to
  the existing EdgeTable/dATM/dBTM table and digraph objects once, after the
  loop.
- **atoms / bonds tables**: existing output of readABRXNFile, unchanged in
  shape, column names, or meaning by this feature.
- **dATM / dBTM**: existing outputs of buildAtomAndBondTransitionMultigraph
  (directed atom/bond transition multigraphs), unchanged in shape or meaning
  by this feature.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: testConservedReactingMoieties.m passes after this change with
  every assertion identical to before (verifiable by diffing the test file:
  only non-assertion lines, if any, may change).
- **SC-002**: On the Tyrosine metabolism subsystem benchmark, the total
  cell.ismember call count attributable to readABRXNFile and
  buildAtomAndBondTransitionMultigraph combined is reduced by at least 90%
  from the pre-change baseline (508,474 of the profiled run's 525,632
  total). Call count, not wall-clock, is the gating metric -- this session's
  own profiling showed +/-10% wall-clock swings between two runs of
  byte-identical code purely from machine load, so wall-clock alone cannot
  reliably gate pass/fail.
- **SC-003**: On the same benchmark, the total tabular.dotAssign and
  tabular.dotReference call counts attributable to readABRXNFile and
  buildAtomAndBondTransitionMultigraph combined are each reduced by at least
  70% from their pre-change baselines (readABRXNFile+buildAtomAndBond...:
  717,081 of 797,966 dotAssign calls; 1,189,438 of 2,158,231 dotReference
  calls).
- **SC-004**: Wall-clock time for the classification-independent parsing and
  graph-building portion of the pipeline (readABRXNFile,
  addBondMappingsRXNFile, buildAtomAndBondTransitionMultigraph) is reported
  before and after in the reproducibility check's output, averaged over at
  least 2 runs given the observed run-to-run noise, but is not itself a
  pass/fail gate.
- **SC-005**: dATM.Nodes, dATM.Edges, dBTM.Nodes, dBTM.Edges, and a sample of
  readABRXNFile's atoms/bonds tables are identical between the pre-change
  golden snapshot and the post-change run.
- **SC-006**: No src/ function outside
  src/analysis/topology/reactingMoieties/{readABRXNFile.m,
  buildAtomAndBondTransitionMultigraph.m} is modified by this feature.

## Assumptions

- The Tyrosine metabolism subsystem model and its atom-mapped RXN files
  remain available at the paths used during profiling
  (~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat,
  /media/JACK/repos/ctf/rxns/atomMapped_standardised) for the FR-010
  reproducibility check; if unavailable at implementation time, the check's
  fixture paths are adjusted without changing its intent.
- The two try/catch robustness fixes already applied to
  buildAtomAndBondTransitionMultigraph.m's atom-transition and
  bond-transition loops (log-and-skip on a parse failure) remain in place
  and are treated as a precondition of this feature, not something it
  re-does.
- addBondMappingsRXNFile.m's own internal redundant call to readABRXNFile
  (a duplicate-read anti-pattern distinct from this feature's dot-indexing
  focus) is out of scope here and tracked separately, as is anything already
  covered by feature 021 (021-prefilter-isomorphism-classification).
- containers.Map (or an equivalent hash-based lookup already used elsewhere
  in this codebase, e.g. in classifySubgraphIsomorphism.m and
  buildAtomAndBondTransitionMultigraph.m's own bond-transition loop for
  metBondCountGroundTruth/metAtomCanonicalRankMap) is an acceptable and
  precedented lookup mechanism for FR-001; the final choice of lookup data
  structure is a plan-phase decision, not fixed by this spec.

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-006, FR-009 | testConservedReactingMoieties.m | readABRXNFile |
| US1 / FR-001, FR-002, SC-002, SC-003 | Tyrosine-benchmark reproducibility check (extended from feature 021) | readABRXNFile |
| US2 / FR-003, FR-004, FR-005, FR-007, FR-008, FR-009 | testConservedReactingMoieties.m | buildAtomAndBondTransitionMultigraph |
| US2 / FR-003, FR-004, SC-002, SC-003, SC-004, SC-005 | Tyrosine-benchmark reproducibility check (extended from feature 021) | buildAtomAndBondTransitionMultigraph |
| US1+US2 / SC-006 | -- (static grep/diff check, no source function of its own) | -- (no source function) |
