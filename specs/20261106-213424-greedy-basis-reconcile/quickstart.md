# Quickstart: validating the reconcile and merge

Prerequisites: MATLAB R2026a, gurobi, COBRA initialised from the checkout under test
(`clear functions; rehash` after edits on the sbgCloud drive).

1. **Static form** — `checkcode` on `greedyExtremeRayBasis.m` reports no `ENDCT`/`NOTERM`; every `function` has an `end`.
2. **B's contract** — `runtests('testGreedyExtremeRayBasis')` passes (includes B's 186 added lines of tests).
3. **Checkpoint/resume** — `runtests('testGreedyExtremeRayBasisResume')` passes, adapted to:
   `status.initialBasisKept` instead of `raysSeeded`; checkpoint `Zpos` in caller orientation; a right-mode
   round-trip `param.initialBasis = C.Zpos` with no transpose; an interrupted run (time budget) resumed from its
   checkpoint returns the checkpointed rays as leading rows and reaches the uninterrupted ray count (SC-002).
4. **Inertness (FR-007, SC-003)** — on each fixture of `testGreedyExtremeRayBasis`, with `rng` fixed and none of
   `initialBasis/checkpointFile/checkpointInterval/testHook`, the reconciled output (`Zpos`, `Z`, pre-existing
   status fields) equals the output at merge-base `467094a5d`.
5. **Third test** — `runtests('testCheckNullspaceBasis')` passes; root cause recorded in the receipt.
6. **Merge integrity** — `git grep -n -E '^(<<<<<<<|>>>>>>>)'` empty; `git merge-base --is-ancestor` holds for
   `origin/develop` and `upstream/develop` against `develop`; `git diff 56dcc3064 -- external .gitmodules` empty.
7. **Regression** — `testAll` on the merged tree vs the two baselines (research R7): 0 regressions.
8. **Outward** — only after 1–7, and on explicit user confirmation: push `develop` to `origin`, open the PR to
   `opencobra/cobratoolbox` `develop` with a title and a short summary first (constitution, PR rule).
