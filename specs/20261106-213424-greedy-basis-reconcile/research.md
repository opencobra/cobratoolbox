# Research: greedy-basis reconcile and upstream merge

All facts below were established read-only on 2026-11-07 against the remote-tracking refs from the last
successful fetch (`git fetch` over SSH currently fails with `Permission denied (publickey)`).

| Ref | Commit |
|---|---|
| local `develop` | `2409e7fd5` (worktree `../fork-cobratoolbox-develop`, clean) |
| `origin/develop` | `c8f02f273` |
| `upstream/develop` | `56dcc3064` (Merge PR #2720) |
| merge-base `develop`/`origin/develop` | `467094a5d` |

## R1. Is B already upstream?

- **Decision**: yes. Merge `upstream/develop` only; it brings `origin/develop` with it.
- **Evidence**: `git merge-base --is-ancestor origin/develop upstream/develop` holds; B's commits `37dd5ef4c`,
  `471380a98`, `e1def8983` are all ancestors of `upstream/develop`; `git diff origin/develop upstream/develop`
  is empty for `greedyExtremeRayBasis.m` and `testGreedyExtremeRayBasis.m`. `upstream` is 29 commits ahead of
  `origin`.
- **Consequence**: the spec's assumption "neither A nor B is upstream" was wrong and has been corrected in
  `spec.md`. B's `initialBasis` contract is now a published interface (Principle II): the reconciled function
  MUST be a strict superset of B. A's additions (`checkpointFile`, `checkpointInterval`, `status.checkpointFile`)
  become new optional parameters defaulting to historical behaviour.
- **Alternatives**: merging `origin/develop` then `upstream/develop` (as the spec's US2 wording suggests) —
  rejected as redundant; it produces an extra merge commit with the identical conflict.

## R2. Conflict set

`git merge-tree --write-tree --name-only develop upstream/develop`:

| File | Nature | Resolution |
|---|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | A vs B `initialBasis` | R3 |
| `CLAUDE.md` | upstream lost `<!-- SPECKIT END -->`; plan pointer differs | keep `develop`'s file; pointer → this feature's `plan.md` |
| `.specify/feature.json` | active feature differs | this feature |
| `src/analysis/thermo/reactantContribution/waterGibbsEnergyOfFormation.m` | upstream rewrite (60 lines) vs RunMat `end` (+1) | take upstream, re-add terminator(s) |
| `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m` | upstream 4-line fix vs RunMat `end` | take upstream, re-add terminator |
| `src/analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/setSimulationConstraints.m` | upstream 194-line rewrite vs RunMat `end` | take upstream, re-add terminator(s) |

Upstream touches no `external/` path, no `.gitmodules`, and not the other session's uncommitted
`findStoichConsistentSubset.m`, so the merge can run on the feature branch in the main checkout.

## R3. Reconciliation strategy for `greedyExtremeRayBasis.m`

- **Decision**: take B's file (upstream) as the base; port A's checkpoint machinery and sparse Frobenius norms
  onto it; delete A's seed block, `seedZpos`, `seedMask`, `raysSeeded`; add RunMat `end` terminators to every
  function, including B's new local functions (`partitionInitialBasis`, `keptSupport`,
  `emptyInitialBasisPartition`, `addInitialBasisStatus`, `objectiveFromDirection`, `solveCandidate`).
- **Rationale**: B is published (R1) and carries the larger, specced change (partition, sign retry, test hook,
  verification of kept rows). A's checkpoint is self-contained: setup after the kept basis is placed, a write at
  the loop top, a "largest basis" update on acceptance, a final write after verification, and an `onCleanup`.
- **Porting map**:

| A element | Where it goes in B |
|---|---|
| param defaults `checkpointFile=''`, `checkpointInterval=300` | beside B's `initialBasis` default |
| `checkpointState` map, `onCleanup(finalCheckpoint)`, initial write | after B places `keptBasis` into `Zpos` and sets `nBases=nKept` |
| loop-top dirty write | first statement of the outer `while` |
| largest-basis update on acceptance | inside B's `while true` sign-retry loop, in the `rankB==(nBases+1)` branch before `break` |
| final verified write + `done=true` | after `addInitialBasisStatus`, before the `leftRight` transpose |
| `status.checkpointFile` | on every return path, including B's three early returns |
| `writeCheckpoint`, `finalCheckpoint` | local functions, **with** `end` |
| `norm(X,'fro')` on sparse (2 sites) | same two sites in B's file |

- **Checkpoint orientation (FR-003)**: A wrote `Zpos` in the operative orientation (`nBases x nVar`), so a
  right-mode resume needed `Zpos'`. The reconciled writer stores `Zpos` in the **caller's** orientation (transposed
  in right mode) plus `leftRight`, so `param.initialBasis = C.Zpos` always works. A's format was never published.
- **Restart (FR-004)**: B resets to `keptBasis` on restart; the checkpoint's largest-basis rule compares against
  `size(checkpointState('Zpos'),1)`, initialised to `nKept`, so the checkpoint never drops kept rows.
- **Truncation**: A truncated the seed to `nVar-rankS`; B keeps all kept rows and warns `keptExceedsNullity`. B wins.

## R4. Root causes of the three failing tests on old `develop`

| Test | Root cause | Status |
|---|---|---|
| `testGreedyExtremeRayBasis` | **Confirmed statically**: `checkcode` reports `ENDCT` at lines 1013 and 1029 of `develop`'s `greedyExtremeRayBasis.m`. A's `writeCheckpoint`/`finalCheckpoint` were added without `end` after the RunMat rewrite (`7cc5b6b48`) terminated every other function; MATLAB rejects a file mixing terminated and unterminated functions, so every call errors. Arose in merge `6a391cab3`. | fixed by R3 (all functions terminated) |
| `testGreedyExtremeRayBasisResume` | same parse error | fixed by R3 + test adaptation |
| `testCheckNullspaceBasis` | **Not yet known.** Neither `checkNullspaceBasis.m` nor its test has a Code Analyzer error, and the test does not call `greedyExtremeRayBasis`. Must be diagnosed by running it (task). | diagnose in implementation |

## R5. Where the work happens

- **Decision**: merge `upstream/develop` into the feature branch `20261106-213424-greedy-basis-reconcile` in the
  main checkout, resolve and verify there, then `git merge --ff-only` it into `develop` in
  `../fork-cobratoolbox-develop`.
- **Rationale**: `develop` stays untouched until the result is verified; the fast-forward gives `develop` both
  remotes as ancestors (FR-011) with no extra merge commit.
- **Alternatives**: resolving inside the `develop` worktree — rejected, because a half-resolved merge would sit on
  `develop` through a multi-hour verification.

## R6. Outward actions

Push to `origin` and the upstream PR (FR-013) need (a) a working SSH key or `gh` auth (fetch currently fails) and
(b) explicit user confirmation at that moment. Both are final tasks, after FR-010–FR-012 hold.

## R7. Regression baseline (FR-012)

`testAll` must be run three times: old `develop` (`2409e7fd5`), `upstream/develop` (`56dcc3064`), merged result.
Each takes about 30 min in fast mode and longer in full. Prior local fast-mode baselines are listed in project
memory (R2026a: about 28 min; 7–11 known failures). Comparison is per-test outcome; a regression is a test passing
on both baselines and failing after merge.
