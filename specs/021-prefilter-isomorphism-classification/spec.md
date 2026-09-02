# Feature Specification: Prefilter subgraph isomorphism classification

**Feature Branch**: `021-prefilter-isomorphism-classification`

**Created**: 2026-09-02

**Status**: Draft

**Input**: User description: "MATLAB profiler run on runTyrosineMoietyProfile_fixed.m
(Tyrosine metabolism subsystem, 339s total) shows 46% of total runtime spent in
three independent all-pairs `isisomorphic` loops that compare every candidate bond
subgraph against every other one with no cheap pre-filter:
findAndExtractMolecularGraphs.m:33 (2,678,455 calls, 114.5s, no pruning at all),
identifyConservedReactingMoieties.m:618 (96,562 calls, 41.6s, partial pruning via
excludedSubgraphs), and identifyIsomorphicClasses.m:37 (called from
identifyConservedReactingMoieties.m:846, same partial pruning pattern). This is
quadratic in the number of bond subgraphs and is believed to be the scalability
wall the user has previously hit on larger models. Fix: introduce a shared
isomorphism-classification helper used by all three call sites that computes a
cheap, provably-necessary structural invariant per subgraph (node count, edge
count, sorted node/edge label multiset matching whichever of NodeVariables/
EdgeVariables the call site already uses) and skips the isisomorphic call for any
pair whose invariants differ, before falling back to the existing exhaustive
isisomorphic check for same-invariant pairs. checkABRXNFiles.m's separate
duplicate-work bug (a flag that never resets, causing it to redundantly re-parse
every RXN file) and the readABRXNFile.m/addBondMappingsRXNFile.m MATLAB
table-object anti-patterns are explicitly OUT of scope for this feature (tracked
separately)."

## Clarifications

### Session 2026-09-02

- Q: SC-002 has an explicit [NEEDS CLARIFICATION] placeholder for the isisomorphic-call-count reduction target on the Tyrosine benchmark. What should gate pass/fail for this success criterion? → A: Any reduction (>0) — pass if the post-change total isisomorphic call count is strictly lower than the pre-change baseline, by any amount; the actual percentage is measured and reported (FR-009) but is not itself a gate.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Isomorphism classification scales sub-quadratically in practice (Priority: P1)

A researcher runs the conserved/reacting-moieties pipeline
(`buildAtomAndBondTransitionMultigraph` + `identifyConservedReactingMoieties`) on
a model and gets back the exact same conserved/reacting moiety classification as
today, but the pipeline no longer spends the majority of its wall-clock time
comparing bond subgraphs that could never be isomorphic in the first place.

**Why this priority**: This is the entire value of the feature. The three
all-pairs `isisomorphic` loops account for ~46% of total runtime on even a small
(139-reaction) subsystem model and are the most direct, root-cause explanation
found so far for why this pipeline does not scale to larger models — everything
else in this feature exists to make this safe.

**Independent Test**: Run `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
and confirm it still passes with every existing assertion unchanged. Separately,
run the Tyrosine-metabolism-subsystem reproducibility check before and after the
change and confirm the moiety-classification output (`moietyFormulas`,
`moietyGraphs`, `moietyVectors`) is identical, while the number of `isisomorphic`
calls and/or wall-clock time for the classification step is measurably reduced.

**Acceptance Scenarios**:

1. **Given** the existing small Recon3D subnetwork fixture (`r0317`, `ACONTm`,
   `r0426`), **When** `testConservedReactingMoieties.m` runs, **Then** it passes
   with the same `L*N=0` invariant and the same structural assertions as before
   this feature, with no assertion loosened, removed, or replaced.
2. **Given** the Tyrosine metabolism subsystem model and its atom-mapped RXN
   files, **When** the pipeline runs before and after this change, **Then** the
   returned `moietyFormulas`, `moietyGraphs`, and `moietyVectors` are identical
   between the two runs.
3. **Given** the same Tyrosine benchmark, **When** the classification step runs
   after this change, **Then** the total count of `isisomorphic` calls across
   `findAndExtractMolecularGraphs`, `identifyConservedReactingMoieties`, and
   `identifyIsomorphicClasses` is strictly lower than the pre-change baseline
   (2,678,455 + 96,562 + the `identifyIsomorphicClasses` call count captured
   during planning), and this reduction is reported, not just asserted pass/fail.
4. **Given** two bond subgraphs that genuinely are isomorphic under the existing
   exhaustive check, **When** classification runs after this change, **Then**
   they are still classified into the same isomorphism class (the invariant
   pre-filter never produces a false negative).
5. **Given** `options.sanityChecks = 1`, **When** the pipeline runs after this
   change, **Then** the existing sanity-check assertions inside
   `identifyConservedReactingMoieties.m` and `identifyIsomorphicClasses.m`
   continue to fire on the same conditions as before.

---

### User Story 2 - One classification implementation instead of three (Priority: P2)

A maintainer investigating or fixing a bug in how bond subgraphs get classified
into isomorphism classes only has to look in one place, instead of three
independently-written, subtly-different all-pairs loops.

**Why this priority**: Secondary to the performance win itself, but the current
triplication is exactly how one of the three sites (`findAndExtractMolecularGraphs.m`)
ended up with no pruning at all while the other two do — duplicated logic drifts.
Consolidating removes that drift risk going forward, but delivers no user-visible
value on its own.

**Independent Test**: Grep the three source files for a pairwise `isisomorphic`
loop; confirm exactly one implementation exists (in the new/refactored shared
helper) and that `findAndExtractMolecularGraphs.m`,
`identifyConservedReactingMoieties.m`, and `identifyIsomorphicClasses.m` (if it
still exists as a separate file after refactoring) all call it rather than
containing their own loop.

**Acceptance Scenarios**:

1. **Given** the refactored code, **When** a maintainer greps for `isisomorphic(`
   inside `src/analysis/topology/reactingMoieties/`, **Then** exactly one call
   site owns the all-pairs comparison logic (candidate `isisomorphic` calls made
   by the shared helper itself), not three independent loops.

### Edge Cases

- What happens when a subgraph's invariant bucket contains exactly one member
  (itself)? No `isisomorphic` call should be made for it at all.
- What happens with zero or one total subgraphs (`numSubgraphs <= 1`)? Classification
  must return the same (trivial) result as today without dividing by zero or
  indexing out of range.
- `findAndExtractMolecularGraphs.m` currently has no `excludedSubgraphs`-style
  pruning at all; after refactoring onto the shared helper it must gain the same
  early-exit pruning the other two sites already have, without changing which
  subgraphs end up in `conservedGroup` vs `reactingGroups`.
- `identifyConservedReactingMoieties.m:618` compares using `'NodeVariables','mets'`;
  `identifyIsomorphicClasses.m:37` compares using `'EdgeVariables','mets'`. The
  shared helper must support both modes and the invariant computed for each mode
  must be consistent with what that mode actually compares (a node-label invariant
  for the `NodeVariables` call sites, an edge-label invariant for the
  `EdgeVariables` call site) so it can never prune a pair that mode would have
  matched.
- The existing small CI fixture (3 reactions) produces very few subgraphs — the
  fix must not regress correctness or add measurable overhead at that trivial
  scale even though its benefit is invisible there.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a single shared subgraph-classification
  helper that groups a cell array of MATLAB graph/digraph objects into
  isomorphism equivalence classes, parameterized by comparison mode
  (`NodeVariables` vs `EdgeVariables`) and variable name (e.g. `mets`), matching
  what each of the three current call sites already passes to `isisomorphic`.
- **FR-002**: Before invoking `isisomorphic` for any candidate pair of subgraphs,
  the helper MUST compute a structural invariant for each subgraph (at minimum:
  node count, edge count, and the sorted multiset of the relevant node or edge
  label values for the comparison mode in use) and MUST skip the `isisomorphic`
  call for any pair whose invariants differ.
- **FR-003**: The invariant pre-filter MUST be a strictly necessary (not merely
  sufficient) condition for isomorphism under each comparison mode: any two
  subgraphs the current exhaustive per-site loops would classify as isomorphic
  MUST still be classified as isomorphic after this change. The full
  `isisomorphic` check MUST still run for every pair whose invariants match.
- **FR-004**: `findAndExtractMolecularGraphs.m` (currently lines ~25-38),
  `identifyConservedReactingMoieties.m` (currently lines ~605-625), and
  `identifyIsomorphicClasses.m` (currently the whole file body) MUST all route
  their subgraph classification through the shared helper from FR-001 instead of
  each containing its own all-pairs loop.
- **FR-005**: `findAndExtractMolecularGraphs.m`'s classification MUST gain the
  same already-classified-pair pruning (`excludedSubgraphs`-equivalent early
  exit) that `identifyConservedReactingMoieties.m` and
  `identifyIsomorphicClasses.m` already have, as a side effect of routing through
  the shared helper.
- **FR-006**: The public function signatures of `findAndExtractMolecularGraphs`,
  `identifyConservedReactingMoieties`, and `identifyIsomorphicClasses` (inputs,
  outputs, and their documented meaning) MUST NOT change — this is an internal
  implementation change only (Constitution Principle II).
- **FR-007**: The existing `sanityChecks` option's behavior, as gated inside
  `identifyConservedReactingMoieties.m` and `identifyIsomorphicClasses.m`, MUST
  continue to fire under the same conditions as before this change.
- **FR-008**: `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  MUST continue to pass after this change with every existing assertion intact —
  none loosened, removed, or replaced.
- **FR-009**: The feature MUST include a documented, non-CI reproducibility check
  (Constitution Principle III's substitute for a full automated test, given the
  Tyrosine benchmark's external model/RXN-file dependencies and multi-minute
  runtime) that: (a) captures the pipeline's `moietyFormulas`, `moietyGraphs`,
  and `moietyVectors` output on the Tyrosine metabolism subsystem as a golden
  snapshot BEFORE this change is implemented, (b) re-runs the same benchmark
  AFTER the change and asserts structural equality against that snapshot, and
  (c) reports the before/after `isisomorphic` call count and/or wall-clock time
  for the classification step.
- **FR-010**: This feature MUST NOT modify `checkABRXNFiles.m`'s
  `checkDecompartmentaliseRXN` duplicate-work bug or the `readABRXNFile.m`/
  `addBondMappingsRXNFile.m` table-object patterns — those are tracked as
  separate work.

### Key Entities

- **Bond/molecular subgraph**: a MATLAB `graph`/`digraph` object held in the
  `bondSubgraphs`, `subgraphs`, or `CBSubgraphs` cell arrays at the three call
  sites — the thing being classified. Unchanged in meaning by this feature.
- **Structural invariant**: new concept introduced by this feature — a cheap,
  per-subgraph signature (node count, edge count, sorted relevant-label
  multiset) computed once per subgraph and used to decide whether a candidate
  pair is even eligible for a full `isisomorphic` comparison.
- **Isomorphism class**: existing output concept (a group of mutually-isomorphic
  subgraphs) — semantics and downstream consumption unchanged by this feature.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `testConservedReactingMoieties.m` passes after this change with
  every assertion identical to before (verifiable by diffing the test file: only
  non-assertion lines, if any, may change).
- **SC-002**: On the Tyrosine metabolism subsystem benchmark, the total
  `isisomorphic` call count across the three classification sites after this
  change is strictly lower than the pre-change baseline (2,678,455 + 96,562 +
  the `identifyIsomorphicClasses` call count captured during planning). There is
  no fixed percentage target — any nonzero reduction satisfies this criterion —
  but the actual before/after counts and percentage reduction MUST be measured
  and recorded (per FR-009), not just asserted pass/fail.
- **SC-003**: On the same benchmark, wall-clock time for the classification
  portion of the pipeline (`findAndExtractMolecularGraphs` +
  `identifyConservedReactingMoieties`'s own classification loop +
  `identifyIsomorphicClasses`) is measurably reduced and the before/after numbers
  are recorded in the reproducibility check's output.
- **SC-004**: The Tyrosine benchmark's `moietyFormulas`, `moietyGraphs`, and
  `moietyVectors` output is identical between the pre-change golden snapshot and
  the post-change run.
- **SC-005**: No `src/` function outside
  `src/analysis/topology/reactingMoieties/{findAndExtractMolecularGraphs.m,
  identifyConservedReactingMoieties.m, identifyIsomorphicClasses.m}` (plus the
  new shared helper, if implemented as its own file) is modified by this
  feature.
- **SC-006**: A grep for a pairwise `isisomorphic(` comparison loop inside
  `src/analysis/topology/reactingMoieties/` finds exactly one implementation
  after this change.

## Assumptions

- The Tyrosine metabolism subsystem model and its atom-mapped RXN files remain
  available at the paths used during profiling
  (`~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`,
  `/media/JACK/repos/ctf/rxns/atomMapped_standardised`) for the FR-009
  reproducibility check; if unavailable at implementation time, the check's
  fixture paths are adjusted without changing its intent.
- MATLAB's own `isisomorphic` implementation is not assumed to already perform
  an equivalent cheap pre-check internally — the observed call counts (2.68M,
  96,562) demonstrate that whatever internal shortcuts it may have are not
  sufficient to avoid the cost at this call volume, so the pre-filter is
  implemented at the call-site/helper level, outside `isisomorphic` itself.
- `identifyIsomorphicClasses.m` is the most likely candidate to become (or host)
  the shared helper from FR-001, since it is already the most generic and
  already has partial pruning, but the final structure (new file vs. extending
  this one) is a plan-phase decision, not fixed by this spec.
- The `checkABRXNFiles.m` duplicate-work bug and the table-object anti-patterns
  in `readABRXNFile.m`/`addBondMappingsRXNFile.m` (both identified in the same
  profiling session) are out of scope here and tracked separately — see project
  memory (`moiety_pipeline_performance_profile.md`, reconXmoieties repo).

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-006, FR-007, FR-008 | testConservedReactingMoieties.m | buildAtomAndBondTransitionMultigraph, identifyConservedReactingMoieties |
| US1 / FR-002, FR-003, FR-009, SC-002, SC-003, SC-004 | Tyrosine-benchmark reproducibility check (non-CI, new) | findAndExtractMolecularGraphs, identifyConservedReactingMoieties, identifyIsomorphicClasses |
| US1 / FR-004, FR-005 | Tyrosine-benchmark reproducibility check (isisomorphic call-count assertion) | findAndExtractMolecularGraphs |
| US2 / FR-001, FR-004, SC-006 | — (static grep check, no source function of its own) | shared classification helper |
