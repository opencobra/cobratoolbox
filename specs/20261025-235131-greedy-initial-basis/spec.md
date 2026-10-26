# Feature Specification: Complete a supplied partial non-negative nullspace basis in greedyExtremeRayBasis

**Feature Branch**: `20261025-235131-greedy-initial-basis`

**Created**: 2026-10-25

**Status**: Draft

**Input**: User description: "greedyExtremeRayBasis: complete a supplied partial non-negative basis of the left (or right) nullspace via param.initialBasis, and recover when the targeted objective has the wrong sign by retrying with -g. Full requirements, acceptance fixtures 1-6, constraints and non-goals are in specs/greedyExtremeRayBasis-initial-basis-prompt.md (read it in full; it is the authoritative feature description). Mathematical basis: moietyRank manuscript Appendix D, Proposition prop:mr:left-basis (a)-(c)."

Authoritative feature description: `specs/greedyExtremeRayBasis-initial-basis-prompt.md`
(copied verbatim into this directory as `feature-prompt.md` so the record is self-contained).

## Clarifications

### Session 2026-10-26

- Q: Should the `-g` sign retry also apply when no `initialBasis` is supplied? → A: Yes,
  always on; it is a correctness fix under Proposition (c), uses no random draws, leaves
  outputs identical on every run whose targeted step never obtains a dependent or
  zero-valued `+g` vertex (including the existing regression tests), and is recorded as a
  NOTE. (FR-008, FR-013)
- Q: In right-nullspace mode, what shape is `initialBasis`? → A: `n x k`, one candidate per
  column, matching the returned right-mode `Zpos`. (FR-012)
- Q: If the valid, independent supplied vectors outnumber the floating-point nullity
  estimate, what happens? → A: Keep all of them unchanged, outcome `'complete'`,
  `raysAdded = 0`, and warn that `raysFound` exceeds the rank-estimated `raysExpected`.
  (FR-006a, edge cases)
- Q: How is "no LP is solved" observed? → A: A new `status.nLPSolves` counts every LP the
  search solves, sign retries included, the shortfall-classification LP excluded.
  (FR-011, SC-001)

## Background

Let `N` (`m x n`) be the operative matrix: `model.S`, restricted to
`model.SConsistentRxnBool` when `param.internalStoichiometriMatrixLeftNullspace` is true,
and transposed when `param.leftRight = 'right'`. Let `K = {w in R^m : N' * w = 0, w >= 0}`
be the non-negative cone of the requested nullspace, and `nullity = m - rank(N)`.

Appendix D of the moietyRank manuscript ("Constructive identification of complete moiety
bases", Proposition prop:mr:left-basis) completes a supplied set `L0` (`k x m`) of
independent non-negative conservation vectors to a basis of `ker(N')` by adding exactly
`delta = nullity - rank(L0)` extreme rays of `K`:

- (a) If `delta = 0`, `L0` is already a basis.
- (b) If `delta > 0`, no set of conserved moiety vectors spans `ker(N')`; the added rays are
  conservation relations that are not moieties. So `L0` MUST be kept and only the missing
  rays added. Computing an unrelated basis from scratch does not meet the requirement.
- (c) With `G` the rows already held and `g` a nonzero vector of `ker(N')` orthogonal to
  `G`, at least one of `max {+g' * w : w in K, 1' * w = 1}` and
  `max {-g' * w : w in K, 1' * w = 1}` has a positive optimal value, and every optimal
  vertex of such a programme generates an extreme ray of `K` outside `span(G)`.

`greedyExtremeRayBasis` (`src/analysis/topology/extremeRays/optimalRays/`) already solves
this linear programme. When random objectives stall, its targeted objective uses as `g` the
leading direction of `ker(N')` orthogonal to the accepted rays: that is (c) with `G` the
accepted rays. Two gaps remain:

1. **It always starts from an empty basis**, and every restart after
   `param.maxNewBasisTime` discards everything back to empty. A caller cannot supply `L0`.
2. **It maximises `+g` only.** The sign of the leading singular vector is arbitrary. The
   current shift by `min(direction)` adds a constant on the feasible set (`1' * w = 1`), so
   it does not fix the sign. When `max g' * w = 0`, the optimal vertex can lie in
   `span(G)` and the search counts a failure, although `-g` has a positive optimum and
   would return a new ray.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete a supplied set of conserved moiety vectors (Priority: P1)

A modeller has `L0`, a set of independent non-negative conserved moiety vectors (for
example rows of `arm.L` from `identifyConservedMoieties`). They want a basis of the left
nullspace that contains `L0` unchanged and adds only the missing extreme rays, so that each
added ray can be interpreted as a conservation relation that is not a moiety.

**Why this priority**: This is the capability the manuscript's constructive procedure
(step 5) needs, and it is the feature's reason to exist.

**Independent Test**: Call the function with `param.initialBasis` on the fixture models
below and check that the leading rows of `Zpos` equal the supplied rows exactly, that the
number of added rays is `nullity - rank(kept rows)`, and that the result is complete.

**Acceptance Scenarios**:

1. **Given** fixture 1 (dimer: `N = [-1 0 2; 1 -2 0; 0 1 -1]`, rank 2, nullity 1) and
   `initialBasis = [1 1 2]`, **When** the function is called, **Then** `Zpos = [1 1 2]`,
   the outcome is `'complete'`, 0 rays are added, and no LP is solved.
2. **Given** fixture 2 (coupled antiport, species `Xe, Xp, Xc, Yc, Ye, Yp`,
   `N = [-1 1 0 0; 0 -1 1 0; 1 0 -1 0; -1 0 1 0; 1 0 0 -1; 0 0 -1 1]`, rank 3, nullity 3)
   and `initialBasis = [1 1 1 0 0 0; 0 0 0 1 1 1]`, **When** the function is called,
   **Then** exactly 1 ray is added, it equals `(0,0,1,1,0,0)` or `(1,1,0,0,1,1)` up to
   positive scaling, the first two rows of `Zpos` equal `initialBasis` exactly, and the
   outcome is `'complete'`.
3. **Given** fixture 3 (exchange with transport, `N` 8 x 6, rank 5, nullity 3) and the
   four-row `initialBasis` of the feature prompt, **When** the function is called, **Then**
   rows 1-3 are kept, row 4 is reported as dependent, the outcome is `'complete'` with 0
   rays added, and no LP is solved.

---

### User Story 2 - Recover when the targeted objective has the wrong sign (Priority: P1)

When the targeted objective's vertex lies in the span of the rows already held, the search
retries with the opposite sign before it counts a failure, as Proposition (c) guarantees a
positive optimum for one of the two signs.

**Why this priority**: Without it, completing a supplied `L0` can stall on exactly the
directions the user needs (the added rays are, by construction, orthogonal-complement
directions), and an existing run can spend failures that (c) says are avoidable.

**Independent Test**: Fixture 4, forcing the wrong sign first through a test-only hook or
by unit-testing the helper, shows the search recovers the missing ray.

**Acceptance Scenarios**:

1. **Given** fixture 4 (`S = [1; -1; 0]`, extreme rays `(1,1,0)` and `(0,0,1)`) and
   `initialBasis = [1 1 0]`, with the targeted step forced to try `-g` first where
   `g` is proportional to `(0,0,1)`, **When** the search runs, **Then** the `-g` vertex
   `(1/2,1/2,0)` is recognised as dependent, the search re-solves with `+g`, returns
   `(0,0,1)` up to positive scaling, the outcome is `'complete'`, and the sign-retry count
   is at least 1.

---

### User Story 3 - Unchanged behaviour for existing callers (Priority: P1)

Callers that do not supply `initialBasis` get the same results as before.

**Why this priority**: Constitution Principle II; downstream code
(`optimalExtremePoolDriver` and users' scripts) depends on the current behaviour.

**Independent Test**: The existing tests `testGreedyExtremeRayBasis`,
`testCheckNullspaceBasis` and `testNullspaceAccuracyTarget` pass unchanged, and a fixed-seed
call without `initialBasis` returns bit-for-bit the same `Zpos`, `Z` and existing `status`
fields as before the change.

**Acceptance Scenarios**:

1. **Given** `param.initialBasis` absent or empty, **When** the function is called with a
   fixed seed, **Then** it consumes the random stream identically and returns the same
   outputs as before, within the scope set by FR-013 (identical unless the targeted step obtains a dependent
   or zero-valued `+g` vertex).

---

### User Story 4 - Right-nullspace mode (Priority: P2)

The same capability is available for the right nullspace (`param.leftRight = 'right'`) on
the transposed problem.

**Why this priority**: Every guarantee of this function already holds identically in both
modes (header and parent features); this feature must not break that symmetry.

**Independent Test**: Run fixtures 1-3 with the transposed matrix in right mode and the
supplied basis in the right-mode orientation (FR-012); the results equal the left-mode
results transposed.

**Acceptance Scenarios**:

1. **Given** fixture 2 posed as a right-nullspace problem on `N'`, **When** called with
   `leftRight = 'right'`, **Then** the kept rows/columns survive unchanged, 1 ray is added,
   and the outcome is `'complete'`.

---

### User Story 5 - Real-model demonstration (Priority: P2)

On a genome-scale model used by earlier features (iDopaNeuroC or Recon3D), a supplied
partial basis survives unchanged and the result is complete.

**Why this priority**: Evidence the feature works at the scale the manuscript targets; it
is a reproducibility check, not a CI test.

**Independent Test**: Pass as `initialBasis` either the conserved-moiety matrix `L` from
`identifyConservedMoieties`, if an atom-mapped model is available in this repository, or
else a random subset of rows of a previously computed `Zpos`; report the counts with their
scope.

**Acceptance Scenarios**:

1. **Given** the chosen model and supplied rows, **When** the function is called, **Then**
   the kept rows are the leading rows of `Zpos` unchanged, the outcome is `'complete'`, and
   the report states rows supplied, kept, dropped, rejected, rays added, sign retries,
   nullity, elapsed time, solver, and which model and which supply route were used.

### Edge Cases

- `initialBasis` with the wrong number of columns (left mode: not `m`), or not numeric /
  not real: error with an identifier naming the expected size; nothing is computed.
- A supplied row with a negative entry: rejected (reported), not returned.
- A supplied row whose residual against the operative matrix exceeds the acceptance target
  (`status.acceptanceTarget`): rejected (reported), not returned.
- An all-zero supplied row: reported as dependent (it adds no rank).
- A supplied row that duplicates or is a combination of earlier kept rows: reported as
  dependent; the earliest independent rows in supplied order are kept.
- Every supplied row rejected or dependent: the search proceeds as if `initialBasis` were
  empty for the remaining count, but status still reports what was supplied.
- Kept rows already span the nullspace (`kept = nullity`): return immediately, no LP solved,
  outcome `'complete'`.
- Kept rows exceed the rank-estimated nullity (possible only if the floating-point rank
  estimates disagree): see FR-006a.
- Restart after `maxNewBasisTime`: the kept rows are restored as the first rows; only the
  added rays are discarded.
- Final verification that drops rows failing the accuracy target never drops a kept row
  (kept rows already passed the same check).
- Early-return outcomes (`'missingField'`, `'emptyNullspace'`, `'badlyScaled'`): the new
  status fields are present with values consistent with "nothing kept, nothing added",
  and the supplied count recorded.
- Both `+g` and `-g` vertices are dependent (which (c) rules out in exact arithmetic but
  floating point may produce): count one failure, as today, and continue.
- The paired-comparison instrumentation (`param.compareSolvers`) is on: the sign retry
  and the supplied basis behave the same way as on the ordinary path.

## Requirements *(mandatory)*

### Functional Requirements

**Supplied partial basis**

- **FR-001**: The function MUST accept an optional `param.initialBasis`, a matrix of
  candidate basis vectors in the same orientation as the returned `Zpos` for the requested
  mode (FR-012). Absent or empty means no supplied basis. Its vector length is the
  dimension of the OPERATIVE matrix's requested nullspace, i.e. after any restriction by
  `param.internalStoichiometriMatrixLeftNullspace` (left mode: number of metabolites `m`;
  right mode: number of operative reactions). Full or sparse input is accepted.
- **FR-002**: Each supplied vector MUST be validated before use: it MUST be non-negative
  exactly (any entry `< 0`, however small, rejects it, because the returned `Zpos` is
  required to be exactly non-negative and kept vectors are never clipped) and MUST meet the same accuracy target applied to accepted rays
  (`status.acceptanceTarget`, the per-row max-entry residual against the operative matrix).
  A vector failing either check MUST be reported (by index, with the reason `'negative'`
  or `'accuracy'`; a vector failing both is reported as `'negative'`) and MUST NOT be
  returned. Indices refer to supplied order (rows in left mode, columns in right mode).
- **FR-003**: Of the vectors that pass FR-002, the function MUST keep a maximal
  linearly independent subset chosen greedily in the supplied order (a vector is kept when
  it raises the rank of those already kept), and MUST report the indices of those dropped
  as dependent.
- **FR-004**: The kept vectors MUST occupy the first rows of `Zpos` (first columns in right
  mode), in supplied order, and MUST be returned value-identical (every entry bitwise
  equal as a double; the storage class of `Zpos` stays sparse as today): never rescaled,
  clipped, truncated, reordered or replaced.
- **FR-005**: The kept vectors MUST be treated as accepted rays in every respect of the
  search (independence tests, the support mask used to zero covered metabolites, and the
  targeted objective's `G`), and MUST be restored as the first rows after every restart.
  Only rays added by the search are discarded on a restart. The best-basis-across-restarts
  bookkeeping MUST likewise always contain the kept vectors.
- **FR-006**: The search MUST seek only the remaining `nullity - kept` rays. If none
  remain, the function MUST return without solving any LP.
- **FR-006a**: If the kept vectors outnumber the rank-estimated nullity, the function MUST
  return all of them unchanged, with outcome `'complete'` and `raysAdded = 0`, and MUST
  raise a warning (identifier `greedyExtremeRayBasis:keptExceedsNullity`) stating that
  `raysFound` exceeds the estimated `raysExpected`. No supplied vector is truncated, and
  the set of outcomes is unchanged.
- **FR-007**: The final accuracy verification on the returned basis MUST NOT drop a kept
  vector; if a kept vector failed it, that would be a defect and MUST raise an error, not
  be silently removed.

**Sign recovery in the targeted step**

- **FR-008**: In the targeted step, if the vertex returned for objective `+g` is linearly
  dependent on the rows currently held, or `|g' * w|` is below a stated tolerance, the
  function MUST re-solve with `-g` (shifted to the same non-negative form) before counting
  a failure. Only if the second vertex also fails is one failure counted, as today. This
  applies on every call (FR-013). A first vertex rejected for ACCURACY, or an empty solve,
  does not trigger the retry: it is counted exactly as today.
- **FR-008a**: Counting under the retry keeps existing meanings: `nTargetedObjectives`
  still counts targeted steps (one per step, whether or not it retried); `nSignRetries`
  counts the second solves; a first vertex dropped as dependent is counted in
  `raysRejectedForDependence`, as any dropped dependent candidate is; and the retried
  vertex is judged (accuracy, then independence) exactly like any other candidate.
- **FR-009**: The sign retry MUST consume no draws from the random stream.
- **FR-010**: There MUST be a test-only way to force the first sign tried (for example a
  hidden parameter or a unit-testable helper), so that recovery from the wrong sign is
  demonstrable deterministically on fixture 4. This hook MUST be documented as test-only
  and MUST default to the current behaviour.

**Status**

- **FR-011**: `status`, populated on every call and every return path, MUST gain fields
  for: vectors supplied; vectors kept (count and indices); vectors dropped as dependent
  (count and indices); vectors rejected for accuracy or sign (count, indices and reason);
  rays added by the search; the number of sign retries; and the number of LPs the search
  solved (`nLPSolves`: every extreme-pool LP including sign retries, excluding the
  shortfall-classification LP). Suggested names:
  `initialBasisSupplied`, `initialBasisKept`, `initialBasisKeptIndex`,
  `initialBasisDependent`, `initialBasisDependentIndex`, `initialBasisRejected`,
  `initialBasisRejectedIndex`, `initialBasisRejectedReason`, `raysAdded`,
  `nSignRetries`, `nLPSolves`. The meaning of every existing field MUST NOT change; in particular
  `raysFound` still equals `size(Zpos, 1)` (kept plus added), `raysExpected` is still the
  nullity, and `raysRejectedForAccuracy` / `raysRejectedForDependence` still count only
  candidates produced by the search, not supplied vectors.

**Modes and compatibility**

- **FR-012**: In right-nullspace mode the supplied basis MUST behave identically on the
  transposed problem. In right mode `initialBasis` is `n x k`, one candidate per COLUMN, the same orientation as the returned right-mode `Zpos`, so a subset of an earlier result can be passed back directly (clarified 2026-10-26).
- **FR-013**: With `initialBasis` absent or empty, the function MUST consume the random
  stream identically and return the same outputs as before this feature.
  The sign retry (FR-008) applies on every call, with or without a supplied basis
  (clarified 2026-10-26): it is a correctness fix under Proposition (c). It consumes no
  random draws (FR-009), so outputs are identical to the pre-feature function on every run
  in which the targeted step never obtains a dependent or zero-valued `+g` vertex, which
  includes every existing regression test. Runs where that does happen may now add a ray
  where they formerly counted a failure; this change of default behaviour is recorded in
  the header NOTE (FR-016), as earlier features recorded theirs.
- **FR-014**: The function MUST NOT change `findExtremePool`'s behaviour for its other
  callers.
- **FR-015**: The LP solver default remains gurobi, as the function nominates; mosek
  remains rejected because it does not return vertices.

**Documentation and record**

- **FR-016**: The function header MUST document `param.initialBasis`, the new status
  fields, and a NOTE entry in the style of the existing ones describing this change and
  citing this feature directory. The change MUST be recorded in the repository's usual
  places (the feature's spec artifacts and receipt; any changelog the plan identifies).
- **FR-017**: The narrowest test proving the behaviour MUST be added to the existing
  `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` (constitution
  III-Naming), declare its requirements with `prepareTest` (gurobi), fix the random seed,
  and compare rays up to positive scaling in exact rational form.
- **FR-018**: Numerical integrity: kept vectors and added rays MUST each meet
  `status.acceptanceTarget`; `Zpos` MUST be non-negative; the implied rank of the returned
  basis MUST equal `kept + added`. No warning raised by this path may be suppressed.

### Key Entities

- **Supplied basis (`initialBasis`)**: `k` candidate non-negative vectors of the requested
  nullspace, in the returned `Zpos` orientation. Partitioned by this feature into kept,
  dependent and rejected, each reported by index.
- **Kept rows**: the maximal independent subset of valid supplied vectors, in supplied
  order; immutable leading rows of `Zpos`.
- **Added rays**: extreme rays of `K` found by the search, `nullity - kept` of them when
  complete; the conservation relations that are not in the span of the supplied vectors.
- **Targeted direction `g`**: unit vector of `ker(N')` orthogonal to the rows held, with
  an explicit sign tried first and the opposite sign tried on failure.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Fixtures 1 and 3 return `'complete'` with 0 rays added and
  `status.nLPSolves = 0`;
  fixture 3 reports row 4 as dependent and rows 1-3 as kept.
- **SC-002**: Fixture 2 returns `'complete'` with exactly 1 added ray equal, in exact
  rational form up to positive scaling, to `(0,0,1,1,0,0)` or `(1,1,0,0,1,1)`, and with the
  first two rows of `Zpos` identical to `L0`.
- **SC-003**: Fixture 4, with the wrong sign forced first, recovers `(0,0,1)` and reports
  at least one sign retry.
- **SC-004**: `testGreedyExtremeRayBasis`, `testCheckNullspaceBasis` and
  `testNullspaceAccuracyTarget` pass unchanged; and for a fixed seed on a named model
  (at least ecoli_core, as the existing test uses), outputs of the pre-feature function
  are recorded BEFORE the change and the post-feature call without `initialBasis` returns
  `Zpos` and `Z` value-identical, and every pre-existing `status` field equal except
  `elapsedTime` and `spectrumTime`, within the scope fixed by FR-013. The record and the
  comparison are kept in the feature directory.
- **SC-005**: Fixtures 1-3 pass in right mode with results equal to the left-mode results
  transposed.
- **SC-006**: On the chosen real model, every kept supplied row is returned unchanged
  (bitwise equal), the outcome is `'complete'`, and the counts (supplied, kept, dependent,
  rejected, added, sign retries, nullity) and their scope (model, supply route, solver,
  elapsed time) are recorded in the feature directory.
- **SC-007**: For every fixture, every row of `Zpos` meets `status.acceptanceTarget`,
  `Zpos >= 0`, and the rank of `Zpos` equals `status.raysFound`.

## Assumptions

- "Accuracy target" for supplied vectors is `status.acceptanceTarget` (the derived target,
  tightened by `param.feasTol` when that is smaller), so supplied and searched rows are held
  to one contract, the same one `checkNullspaceBasis` applies.
- Linear independence of supplied vectors is decided by the same rank routine the search
  uses for accepted rays, so the two decisions cannot disagree.
- `nullity` remains the floating-point rank estimate the function already uses
  (`status.raysExpectedIsEstimate` stays true). Exact-arithmetic certification belongs to
  the manuscript's procedure, not to this function.
- Fixtures 1-4 are small models built in the test with `S` equal to the given internal
  matrix, no exchange reactions, species as rows, and `SConsistentRxnBool` all true. Their
  stated ranks and nullities were checked in exact arithmetic during specification.
- The real-model demonstration (US5) is a documented reproducibility check run locally,
  not a CI test, because the models are large and their availability in CI is not assumed.
- The tolerance for "`|g' * w|` below tolerance" in FR-008 is fixed by the plan, with
  justification relative to the acceptance target.

## Out of Scope (recorded follow-ups)

Each is a separate future feature, not part of this one:

- **Follow-up 1**: recovering exact integer rays from the support of a floating-point
  vertex (the manuscript's remark that an extreme ray is determined by its support).
- **Follow-up 2**: adding the entrywise faithful-accounting check `M * M2R == M2M' * N` to
  `identifyConservedMoieties`, which currently checks only
  `M2M * M2M' * N == M2M * M * M2R`.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1, FR-006, SC-001 (fixture 1) | testGreedyExtremeRayBasis (test/verifiedTests/analysis/testTopology/) | src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m |
| US1-2, FR-004, FR-005, SC-002 (fixture 2) | testGreedyExtremeRayBasis | greedyExtremeRayBasis.m |
| US1-3, FR-003, SC-001 (fixture 3) | testGreedyExtremeRayBasis | greedyExtremeRayBasis.m |
| FR-002 (rejection for sign/accuracy), edge cases | testGreedyExtremeRayBasis | greedyExtremeRayBasis.m |
| US2-1, FR-008, FR-009, FR-010, SC-003 (fixture 4) | testGreedyExtremeRayBasis | greedyExtremeRayBasis.m (targeted-objective helper) |
| US3-1, FR-013, FR-014, SC-004 | testGreedyExtremeRayBasis, testCheckNullspaceBasis, testNullspaceAccuracyTarget | greedyExtremeRayBasis.m |
| US4-1, FR-012, SC-005 | testGreedyExtremeRayBasis | greedyExtremeRayBasis.m |
| US5-1, SC-006 | reproducibility script + recorded output in this feature directory | greedyExtremeRayBasis.m |
| FR-011 (status fields on every path) | testGreedyExtremeRayBasis | greedyExtremeRayBasis.m |
| FR-016 (header NOTE) | — (no source test; checked in review against the header) | greedyExtremeRayBasis.m |
| FR-007, FR-018, SC-007 | testGreedyExtremeRayBasis | greedyExtremeRayBasis.m |
