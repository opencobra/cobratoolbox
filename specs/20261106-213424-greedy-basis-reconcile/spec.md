# Feature Specification: Reconcile the two greedyExtremeRayBasis initial-basis features and merge upstream

**Feature Branch**: `20261106-213424-greedy-basis-reconcile`

**Created**: 2026-11-06

**Status**: Draft

**Input**: User description: reconcile two independently developed `greedyExtremeRayBasis` features so that local
`develop` can merge `origin/develop` (fork `rmtfleming/cobratoolbox`, PR #9) and upstream `opencobra/cobratoolbox`
`develop`, and then be offered as a pull request from the fork's `develop` to upstream `develop`.

The two features:
- **A: feature 089 `large-model-solver-speed`**, on local `develop` only (commits `f2dff769c`, `1b4c2cb01`; test
  `testGreedyExtremeRayBasisResume.m`). `param.initialBasis` means resume from a saved checkpoint: each row is
  re-judged by the acceptance rule and seeds the search, and a restart resets to the seed. `param.checkpointFile`
  and `param.checkpointInterval` write the accepted rays during the search and on every exit path (normal return,
  time budget, error, interrupt, and a stop by signal, through a write at the top of the loop). The checkpoint
  keeps the largest basis seen across restarts. Outputs: `status.raysSeeded`, `status.checkpointFile`. It also
  computes Frobenius norms on sparse operands. Motivation: a 10-hour whole-body search reached 2206 of 2212 rays
  and lost them all.
- **B: feature `20261025-235131-greedy-initial-basis`**, merged into `origin/develop` by PR #9. `param.initialBasis`
  means a supplied partial basis to complete:
  - each candidate is judged and ends up kept, dependent, or rejected as negative or inaccurate;
  - the kept candidates are returned unchanged as the leading rows of `Zpos` (columns in right mode), in supplied
    order, and survive every restart;
  - only the missing rays are searched for, and no LP is solved when nothing is missing;
  - `greedyExtremeRayBasis:keptExceedsNullity` is warned when the kept candidates outnumber the estimated nullity;
  - the targeted step retries with the opposite sign;
  - `param.testHook` provides test-only controls;
  - new status fields: `initialBasisSupplied`, `initialBasisKept` and the rest of the partition, `raysAdded`,
    `nSignRetries` and `nLPSolves`.

## Clarifications

### Session 2026-11-06

- Q: Which meaning does `param.initialBasis` take? → A: B's. A supplied basis is completed, and resuming from a
  checkpoint is completing the checkpoint's rays. The checkpoint is written in the orientation B expects, and A's
  resume test is adapted to that.
- Q: Keep A's `status.raysSeeded`? → A: No. It was never published and only A's own test reads it; the test reads
  `status.initialBasisKept` instead.
- Q: How far does the feature go with the three tests that already fail on local `develop`
  (`testGreedyExtremeRayBasis`, `testGreedyExtremeRayBasisResume`, `testCheckNullspaceBasis`)? → A: Diagnose and
  fix. All three must pass. A cause outside `greedyExtremeRayBasis` is reported, and is fixed in this feature
  only if the fix is small.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One initial-basis option that completes a supplied basis and resumes a checkpoint (Priority: P1)

A modeller computing a non-negative nullspace basis supplies vectors they already have, whether from earlier
work or from a checkpoint left by an interrupted run. The function returns those vectors unchanged and finds only
the missing ones. Long runs write their progress to disk and can be resumed after any interruption.

**Why this priority**: the two features cannot be merged until the function has one meaning for the option.
Losing hours of search on a large model is the failure that feature A was written to prevent.

**Independent Test**: B's tests and A's resume test (adapted to B's meaning), run in MATLAB against the reconciled
function, all pass.

**Acceptance Scenarios**:

1. **Given** a supplied partial basis, **When** the function runs, **Then** the kept candidates are the leading
   rows of the result, bit-for-bit unchanged and in supplied order, and the dependent and rejected candidates are
   reported by index and reason, as in B.
2. **Given** a checkpoint file set, **When** the search stops on any exit path (normal, time budget, error,
   interrupt, signal), **Then** the file holds every ray accepted so far, keeping the largest basis seen across
   restarts.
3. **Given** a run that stopped part-way and wrote a checkpoint, **When** the function is called again with the
   checkpoint's rays as the initial basis, **Then** every checkpointed ray is kept, unchanged, and the search adds
   only the missing rays.
4. **Given** neither option is set, **When** the function runs with a fixed random seed, **Then** it returns the
   same basis and the same pre-existing status fields as on `develop` before both features.

---

### User Story 2 - develop merges the fork and upstream cleanly (Priority: P1)

The maintainer brings the fork's `develop` and upstream `develop` into local `develop` without losing either
side's work, then proposes the result upstream.

**Why this priority**: this is the purpose of the request.

**Independent Test**: `develop` contains both `origin/develop` and `upstream/develop` as ancestors, has no
conflict markers, and the MATLAB test suite shows no new failures against a baseline.

**Acceptance Scenarios**:

1. **Given** the merge of `origin/develop`, **When** it completes, **Then** `greedyExtremeRayBasis.m` is the
   reconciled function (US1) and `CLAUDE.md` keeps its hand-maintained section, with the Spec Kit plan pointer set
   to the active feature.
2. **Given** the merge of `upstream/develop`, **When** it completes, **Then** each file where upstream's change met
   a RunMat-compatibility rewrite (`waterGibbsEnergyOfFormation.m`, `compareBounds2Models.m`,
   `setSimulationConstraints.m`) has upstream's content and the rewrite's form (for example the explicit
   `end` terminators).
3. **Given** the merged `develop`, **When** it is pushed to the fork, **Then** a pull request into
   `opencobra/cobratoolbox` `develop` is opened, and its description names the features it brings.

---

### User Story 3 - The known failures are diagnosed and fixed (Priority: P2)

**Why this priority**: a PR upstream should not bring failing tests with it.

**Independent Test**: the three tests pass in MATLAB on the merged `develop`; each root cause is written down.

**Acceptance Scenarios**:

1. **Given** the reconciled function, **When** `testGreedyExtremeRayBasis`, `testGreedyExtremeRayBasisResume` and
   `testCheckNullspaceBasis` run, **Then** all three pass, and each failure on the old `develop` has a recorded root
   cause.

### Edge Cases

- A checkpoint written by A's version: orientation `nBases x nVar`, the operative orientation. In right mode that
  is the transpose of what B expects. Feature A's version was never published, so no compatibility shim is
  required; the documented resume recipe is updated.
- A checkpoint whose rays are fewer than the kept candidates supplied: the checkpoint always holds at least the
  kept candidates, because they survive restarts.
- A checkpoint row that fails re-judgement (for example on a different solver): it is rejected and reported, as
  any supplied candidate is.
- Kept candidates outnumber the nullity: B's warning and outcome apply; the checkpoint holds all of them.
- The sign retry and the checkpoint write happen in the same iteration: an accepted retried ray is checkpointed
  like any other.
- Upstream changed a file that the RunMat rewrite also changed: upstream's content wins, and the RunMat form is
  re-applied only where the rewrite was mechanical.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `param.initialBasis` MUST have B's meaning and contract (B's FR-001 to FR-007): validation,
  partition, unchanged leading rows, restart survival, search for the remainder only, no LP when complete, the
  `keptExceedsNullity` warning, and no kept vector dropped by final verification.
- **FR-002**: `param.checkpointFile` and `param.checkpointInterval` MUST keep A's behaviour: rays are written
  during the search and on every exit path (normal, time budget, error, interrupt, and stop by signal through the
  write at the top of the loop), and the largest basis seen across restarts is kept.
- **FR-003**: The checkpoint MUST be directly usable as `param.initialBasis` in the caller's orientation for the
  mode it was written in, so that resuming needs no transposition the caller has to remember. The help text MUST
  give the recipe.
- **FR-004**: The checkpoint MUST always contain the kept supplied candidates, so a resume of a resume loses nothing.
- **FR-005**: B's sign retry (B's FR-008, FR-008a, FR-009) and `param.testHook` MUST be kept unchanged.
- **FR-006**: The status MUST report B's partition fields, `raysAdded`, `nSignRetries` and `nLPSolves`, and A's
  `checkpointFile`. `raysSeeded` is not reported.
- **FR-007**: With `initialBasis`, `checkpointFile`, `checkpointInterval` and `testHook` all absent, results and
  the pre-existing status fields MUST equal those of the common ancestor of both features, on the same inputs,
  solver and seed (Principle II).
- **FR-008**: A's sparse Frobenius norm change MUST be kept, and MUST give the same values as before.
- **FR-009**: The RunMat-compatibility form from feature `20261102-153951-runmat-compat` (explicit `end`
  terminators and the other mechanical rewrites) MUST be kept in every merged file.
- **FR-010**: `testGreedyExtremeRayBasis`, `testGreedyExtremeRayBasisResume` (adapted to FR-001 and FR-006),
  `testCheckNullspaceBasis` and every test B added MUST pass. Each failure on the old `develop` MUST have a
  recorded root cause.
- **FR-011**: `develop` MUST end with both `origin/develop` and `upstream/develop` as ancestors and no conflict
  markers. Conflicts outside `greedyExtremeRayBasis.m` are resolved as in US2-2; `.specify/feature.json` and the
  `CLAUDE.md` plan pointer name the active feature.
- **FR-012**: The MATLAB `testAll` on the merged `develop` MUST show no test that passes on both
  `upstream/develop` and the old local `develop` but fails after the merge.
- **FR-013**: A pull request MUST be opened from `rmtfleming/cobratoolbox` `develop` to `opencobra/cobratoolbox`
  `develop`, only after FR-010 to FR-012 hold. Pushing and opening it are outward actions and follow the
  constitution's contribution conventions.
- **FR-014**: `external/`, `deprecated/` and submodule pointers MUST NOT change, except as the upstream merge
  brings them.

### Key Entities

- **Supplied candidate**: one vector of `param.initialBasis`; ends kept, dependent or rejected (with reason).
- **Checkpoint**: a MAT-file holding the largest accepted basis so far plus run metadata; usable as a supplied
  basis.
- **Merge baseline**: the per-test outcome of `testAll` on the old local `develop` and on `upstream/develop`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: B's tests and the adapted resume test pass: 100% of their test cases.
- **SC-002**: A run interrupted after it has accepted k rays, then resumed from its checkpoint, returns those k rays
  unchanged as its leading rows and reaches the same number of rays as an uninterrupted run.
- **SC-003**: With none of the new options, the reconciled function's output equals the ancestor's on every
  fixture of `testGreedyExtremeRayBasis` with a fixed seed.
- **SC-004**: The three previously failing tests pass, and 3 of 3 root causes are recorded.
- **SC-005**: 0 tests regress across the merge (FR-012).
- **SC-006**: 0 conflict markers in the tree; `git merge-base --is-ancestor` holds for both `origin/develop` and
  `upstream/develop`.
- **SC-007**: One pull request is open upstream, with a description naming the features and listing the test
  results.

## Assumptions

- Neither A nor B is in upstream `develop`, so B's semantics can be adopted without an upstream deprecation.
- A's checkpoint file format may change, because A was never published.
- MATLAB R2026a and the default solvers of the existing tests (gurobi for LP) are the reference.
- Full-suite `testAll` runs need full clones with submodules and take more than an hour each.
- The other session's uncommitted files in the main checkout are not part of this feature.

## Traceability

| Requirement | Verification | Function under test |
|---|---|---|
| FR-001, FR-005, FR-006, SC-001 | B's tests in `testGreedyExtremeRayBasis.m` | `greedyExtremeRayBasis` |
| FR-002–FR-004, SC-002 | `testGreedyExtremeRayBasisResume.m` (adapted) | `greedyExtremeRayBasis` |
| FR-007, FR-008, SC-003 | fixed-seed comparison against the common ancestor | `greedyExtremeRayBasis` |
| FR-010, SC-004 | the three tests, plus a root-cause note | `greedyExtremeRayBasis`, `checkNullspaceBasis` |
| FR-011, FR-012, SC-005, SC-006 | `git merge-base`, conflict-marker grep, `testAll` comparison | — |
| FR-013, SC-007 | the pull request | — |
