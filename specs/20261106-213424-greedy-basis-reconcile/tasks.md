# Tasks: Reconcile the two greedyExtremeRayBasis initial-basis features and merge upstream

**Input**: `specs/20261106-213424-greedy-basis-reconcile/` — spec.md, plan.md, research.md, data-model.md,
contracts/greedyExtremeRayBasis.md, quickstart.md

**Tests**: requested by the spec (FR-010, FR-012, SC-001–SC-005); test tasks precede or accompany the behaviour.

**Paths** (repo root = main checkout, branch `20261106-213424-greedy-basis-reconcile`):
- `G` = `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`
- `TG` = `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`
- `TR` = `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasisResume.m`
- `TC` = `test/verifiedTests/analysis/testTopology/testCheckNullspaceBasis.m`
- `R` = `results/20261106-213424-greedy-basis-reconcile/` (gitignored run output)

**MATLAB hygiene for every MATLAB task**: `clear functions; rehash` after any edit on the sbgCloud drive; confirm
`which greedyExtremeRayBasis` resolves into the checkout under test; never use `restoredefaultpath`.

## Phase 1: Setup

- [ ] T001 Confirm preconditions and record them in `R/preconditions.txt`: main checkout on the feature branch with only the other session's files dirty (`findStoichConsistentSubset.m`, `.serena/`, `specs/20261104-134231-runmat-init-exploration/`, `specs/runmat-matlab-dual-compat-prompt.md`), which MUST NOT be staged; `../fork-cobratoolbox-develop` clean at `2409e7fd5`; `upstream/develop` = `56dcc3064`, `origin/develop` = `c8f02f273`; retry `git fetch origin upstream` and, if it now works and either ref moved, STOP and report (research facts would be stale).
- [ ] T002 [P] Create a detached temporary worktree `../fork-cobratoolbox-upstream-baseline` at `upstream/develop` (`git worktree add --detach`), with submodules initialised as `testAll` needs, for the FR-012 baseline.

## Phase 2: Foundational (baselines; run in background, block only T024)

- [ ] T003 [P] Run `testAll` (same mode as T024, recorded in `R/baseline-mode.txt`) in `../fork-cobratoolbox-develop` at `2409e7fd5` with `matlab -batch`; save per-test outcomes as `R/baseline-develop.csv` (`testName,outcome`) and the log as `R/baseline-develop.log`.
- [ ] T004 [P] Run the same `testAll` in `../fork-cobratoolbox-upstream-baseline`; save `R/baseline-upstream.csv` and `R/baseline-upstream.log`.
- [ ] T005 Capture the FR-007 reference: in a MATLAB session on a detached checkout of merge-base `467094a5d` (reuse `../fork-cobratoolbox-upstream-baseline` via `git checkout --detach 467094a5d` after T004 finishes, or a further temporary worktree), run each fixture of `TG` with fixed `rng` and none of the new options, saving `Zpos`, `Z` and the pre-existing status fields to `R/ancestor-reference.mat`. Record the fixture list and seeds in `R/ancestor-reference.txt`.

**Checkpoint**: baselines running or done; the merge can start.

## Phase 3: User Story 2 (part 1) — merge and mechanical conflicts (P1)

**Goal**: the feature branch contains `upstream/develop` (and so `origin/develop`), with every conflict except `G` resolved.

- [ ] T006 [US2] `git merge --no-ff --no-commit upstream/develop` on the feature branch; list conflicts in `R/merge-conflicts.txt` and verify the set equals research R2 (6 files). If it differs, STOP and report.
- [ ] T007 [P] [US2] Resolve `CLAUDE.md`: keep the feature branch's file (with `<!-- SPECKIT END -->` and pointer `specs/20261106-213424-greedy-basis-reconcile/plan.md`); `git add CLAUDE.md`.
- [ ] T008 [P] [US2] Resolve `.specify/feature.json` to name `specs/20261106-213424-greedy-basis-reconcile`; `git add`.
- [ ] T009 [P] [US2] Resolve `src/analysis/thermo/reactantContribution/waterGibbsEnergyOfFormation.m`: take upstream's content, then re-add the RunMat `end` terminator(s) exactly as the `develop` side added them; `checkcode` shows no `ENDCT`/`NOTERM`; `git add`.
- [ ] T010 [P] [US2] Same for `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m`.
- [ ] T011 [P] [US2] Same for `src/analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/setSimulationConstraints.m`.
- [ ] T012 [US2] Check every other `.m` file the merge changed or added for mixed terminators: run `checkcode` on `git diff --name-only --diff-filter=AM 2409e7fd5 -- '*.m'` and list any `ENDCT`/`NOTERM` in `R/terminator-scan.txt`. Fix only files where a RunMat-rewritten file met an upstream change (FR-009); report others without editing.

## Phase 4: User Story 1 — reconciled `greedyExtremeRayBasis` (P1) 🎯 MVP

**Goal**: one `initialBasis` meaning (B), plus A's checkpoint in caller orientation.

**Independent test**: `TG` and adapted `TR` pass; inertness against `R/ancestor-reference.mat`.

### Tests first

- [ ] T013 [US1] Adapt `TR` to the delta contract (contracts/greedyExtremeRayBasis.md): replace `raysSeeded` with `initialBasisKept`; in case 4 assert the corrupted row is `initialBasisRejected` with reason `accuracy`; assert `C.Zpos` is in caller orientation and `C.leftRight` is present; add a right-mode case (`param.leftRight='right'`, `internalStoichiometriMatrixLeftNullspace=0`) whose resume uses `param.initialBasis = C.Zpos` with no transpose; add the SC-002 case: a run stopped by a small `maxTime` after accepting k ≥ 1 rays, then resumed from its checkpoint, returns those k rays bit-for-bit as leading rows and reaches the uninterrupted ray count; keep A's error-path and time-budget checkpoint cases. Update the header (purpose, authors line kept, add this feature).
- [ ] T014 [US1] Add the FR-007/FR-008 inertness check as a script `R/compareToAncestor.m` (not a shipped test): load `R/ancestor-reference.mat`, re-run each fixture on the reconciled function with the same seed, assert `isequal` on `Zpos`, `Z` and each pre-existing status field (B's added fields and `checkpointFile` excluded); report Frobenius norm differences (expected 0).

### Implementation

- [ ] T015 [US1] Resolve `G` by starting from upstream's version (`git checkout --theirs -- G`), then add RunMat `end` terminators to every function in the file (main, and all local functions including B's `partitionInitialBasis`, `keptSupport`, `emptyInitialBasisPartition`, `addInitialBasisStatus`, `objectiveFromDirection`, `solveCandidate`). `checkcode` shows no `ENDCT`/`NOTERM`.
- [ ] T016 [US1] Port A's sparse Frobenius norms into `G`: `norm(Zpos,'fro')` and `norm(model.S,'fro')` in the verification block, and `norm(model.S,'fro')` in `compareSolversAtState` (FR-008).
- [ ] T017 [US1] Port A's checkpoint into `G` per research R3 porting map: defaults beside B's `initialBasis` default; `checkpointState` (`containers.Map`) initialised to `Zpos(1:nKept,:)` after B places `keptBasis`; initial write and `onCleanup(@() finalCheckpoint(...))`; loop-top dirty write as first statement of the outer `while`; largest-basis update in the `rankB==(nBases+1)` branch of B's sign-retry loop before `break`; final verified write with `final=true` and `done=true` after `addInitialBasisStatus`; `status.checkpointFile` on every return path including B's three early returns. Do NOT port A's seed block, `seedZpos`, `seedMask`, `raysSeeded`, or truncation.
- [ ] T018 [US1] Port `writeCheckpoint` and `finalCheckpoint` as local functions with `end`; `writeCheckpoint` transposes `Zpos` to the caller's orientation when `meta.leftRight` is `'right'` and saves `leftRight`; the cleanup's `catch` warns `greedyExtremeRayBasis:checkpointFailed` and does not rethrow (original error must still propagate).
- [ ] T019 [US1] Update `G`'s help text: add `checkpointFile` and `checkpointInterval` under OPTIONAL INPUTS and `checkpointFile` under status, matching the contract; resume recipe `C = load(file); param.initialBasis = C.Zpos;`; extend B's October 2026 change note with one sentence on the checkpoint. No `raysSeeded`.
- [ ] T020 [US1] Run `checkcode` on `G` (no new warnings beyond upstream's), then `runtests` on `TG` and `TR` in MATLAB; save output to `R/us1-tests.log`. Run `R/compareToAncestor.m` (T014); save to `R/us1-inertness.log`. All MUST pass; if inertness fails, STOP and report the differing field.
- [ ] T021 [US1] Review `G` with `matlab-core:matlab-review-code` against the constitution's MATLAB standards (no `evalc`, warnings visible, error stacks preserved, no `nargin`); fix only findings in lines this feature changed.

**Checkpoint**: US1 complete; `git add G TR`.

## Phase 5: User Story 3 — failing tests diagnosed and fixed (P2)

**Independent test**: `TG`, `TR`, `TC` pass on the merged tree; three root causes recorded.

- [ ] T022 [US3] Run `TC` on the merged tree. If it fails, diagnose (run on `2409e7fd5` and on `upstream/develop` too, to see whether the failure is local, upstream, or merge-induced) and record the root cause in `R/root-causes.md` next to the two confirmed ones (research R4: missing `end` on A's `writeCheckpoint`/`finalCheckpoint`, from merge `6a391cab3`). If the fix is small and inside `src/analysis/topology/extremeRays/` or `TC`, apply it; otherwise STOP and report (spec clarification 3).
- [ ] T023 [US3] Re-run `TG`, `TR`, `TC` together; save `R/us3-tests.log`. All MUST pass.

## Phase 6: User Story 2 (part 2) — verify, land on develop, propose upstream (P1)

- [ ] T024 [US2] Conclude the merge commit on the feature branch: confirm `git diff --cached --name-only` contains none of the other session's files; `git grep -n -E '^(<<<<<<<|=======$|>>>>>>>)' -- src test` is empty; `git diff 56dcc3064 --stat -- external deprecated .gitmodules` is empty (FR-014); commit with an openCOBRA-convention message naming upstream PR #2720's head and this feature.
- [ ] T025 [US2] Run `testAll` on the merged feature branch (same mode as T003/T004); save `R/merged.csv`/`R/merged.log`; compare with both baselines into `R/regression.md`: list tests passing on both baselines and failing after merge (MUST be 0, FR-012), plus tests fixed by the merge. If any regression, STOP and report.
- [ ] T026 [US2] In `../fork-cobratoolbox-develop`: `git merge --ff-only 20261106-213424-greedy-basis-reconcile`; verify `git merge-base --is-ancestor origin/develop develop` and `... upstream/develop develop` (SC-006); record in `R/ancestry.txt`.
- [ ] T027 [US2] Write the implementation receipt at `specs/20261106-213424-greedy-basis-reconcile/agent-runs/<UTC>-greedy-reconcile/implementation-receipt.md` (Prompt, Final response, Diff summary, Tests, Unresolved issues) and update `human-loop.md` to point at it; update project memory `develop-sync-blocked-greedy.md` to resolved.
- [ ] T028 [US2] **Outward, confirmation required**: ask the user explicitly before `git push origin develop` (and the feature branch, if wanted). Test auth with `git push --dry-run` first; if SSH still fails, report and stop.
- [ ] T029 [US2] **Outward, confirmation required**: draft the PR title and body (title present tense; body starts with a short summary of what it delivers — A's checkpoint/resume on top of B's initialBasis, the three test fixes — then test results from `R/regression.md`); show it to the user; open `rmtfleming:develop` → `opencobra/cobratoolbox:develop` with `gh pr create` only after explicit approval; record the URL in the receipt (SC-007).

## Phase 7: Polish

- [ ] T030 Remove the temporary worktree `../fork-cobratoolbox-upstream-baseline` (`git worktree remove`) after T025 and T005 no longer need it.

## Dependencies

- T001 → everything. T002 → T004 → T005. T003, T004 run in background from Phase 2 onward; they block only T025.
- T006 → T007–T012 (parallel) and T015. T005 → T014 → T020. T013 with T015–T019 (same story; T013 written first).
- T015 → T016 → T017 → T018 → T019 → T020 → T021 (same file, sequential).
- US1 (T020) → US3 (T022–T023) → T024 → T025 → T026 → T027 → T028 → T029. T030 last.

## Parallel examples

- After T006: T007, T008, T009, T010, T011 together (different files).
- During Phases 3–5: T003 and T004 running in background `matlab -batch` sessions (separate MATLAB processes, not the shared MCP session).

## Implementation strategy

MVP = Phases 1–4 (merge in progress, reconciled function passing `TG`/`TR` and inertness). Then US3, then
verification and landing. Nothing reaches `develop` until T025 shows 0 regressions; nothing leaves the machine
without explicit confirmation at T028/T029.
