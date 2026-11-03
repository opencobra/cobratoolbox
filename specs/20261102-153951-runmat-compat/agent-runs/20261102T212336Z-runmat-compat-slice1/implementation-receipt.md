# Implementation receipt: runmat-compat, slice 1

## Prompt

`/speckit-implement` (no further input), invoked after Gate 2 approved the slice T001–T016 + T030
("Approve first slice (Recommended)", path "/speckit-implement (Recommended)").

## Final response

The approved slice of `20261102-153951-runmat-compat` is implemented: T001–T016 and T030. It is on branch `20261102-153951-runmat-compat` in `../fork-cobratoolbox-runmat` and has not been pushed. Source changes cover 973 files under `src/` and `test/`. Nothing in `external/`, `deprecated/` or any submodule changed.

**What changed (one commit per kind of rewrite):**
- Function terminators: 733 files, plus 46 more found after the other rewrites
- Explicit cell and matrix separators: 141 files
- Empty `catch` added to `try` blocks: 44 files (105 blocks)
- Bare calls written as `name()`: 133 files, 24 names
- One file re-encoded as UTF-8

**MATLAB behaviour (T030).** The full MATLAB `testAll` found one difference from the baseline: `testSurfNet` failed. The `name()` tool had turned `clear surfNet` into `clear surfNet()`, which clears nothing. I fixed the tool and that line (`3c2bbad64`). `testSurfNet` now passes under `testAll`, on both the baseline and the changed branch. The other four failures are the same four that fail on the unchanged code. I did not rerun the full suite after this one-line fix.

**RunMat.** The number of files with test-discovery errors fell from 1,184 to 342. The remaining errors are not mechanical rewrites. Most are RunMat defects (D3–D22, with reproducers in `reports/`) or latent COBRA bugs. `reports/residual.tsv` classifies each one.

**Things to know:**
- `testAll` had to run in full local clones, because `initCobraToolbox` fails inside a git worktree.
- Earlier, a `git config` command in the worktree reset the submodule URLs in the main checkout's shared `.git/config` to the `.gitmodules` values. Any custom URLs that were set there are lost.
- Three classdef files crash RunMat (defect D7), so I set them aside from the discovery measurement.

The receipt is `specs/20261102-153951-runmat-compat/agent-runs/20261102T212336Z-runmat-compat-slice1/implementation-receipt.md`. T017–T020 and T031–T033 are still deferred.

## Extension Hooks

**Optional Hook**: git
Command: `/speckit-git-commit`
Description: Auto-commit after implementation

Prompt: Commit implementation changes?
To execute: `/speckit-git-commit`

Everything is already committed, so this hook has nothing to do.

## Diff summary

Branch `20261102-153951-runmat-compat`, `aa51dcd2a..3c2bbad64`: 973 source files (912 under `src/`, 61 under
`test/`), plus tools, baselines and reports under this feature directory.

| Commit | Tasks | Change | Source files |
|---|---|---|---|
| 9cc2db6dc | T001–T003, T005–T006 | rewrite tools, scope list, analyzer and RunMat discovery baselines | 0 |
| b54fe95fe | T007 | `tutorial_rMTA.m` re-encoded as UTF-8 | 1 |
| 7cc5b6b48 | T008 | explicit function terminators (rejected: surfNet D3, intergrate not valid MATLAB) | 733 |
| 94bbf739c | T009 | explicit cell and matrix separators (6 rejected, 3 lexer skips) | 141 |
| 25cf50634 | T010–T011 | empty `catch` in `try` blocks, 105 blocks (VII-C exception per plan) | 44 |
| f16d1a7d3 | T012 | terminators rerun on files surfaced by earlier rewrites | 46 |
| 934536abd | T013–T014 | bare calls written as `name()`, 24 names (3 classdef self-name rewrites rejected) | 133 |
| 0b548ede1 | T015–T016 | RunMat discovery after US1, residual classification, defect D7 | 0 |
| 21602f2d7 | T004 | MATLAB testAll baseline, comparison tool | 0 |
| 3c2bbad64 | T030 | `clear surfNet` restored; `explicit_calls.py` skips command-syntax arguments | 1 |

Per-file acceptance is in `reports/accepted-*.txt` and `reports/rejected-*.txt`.

## Tests

- Per rewritten file (T008–T014): MATLAB parse tree identical (`strict`), or identical except added CATCH nodes
  (`catch`); `checkcode` gains no message. Rejected files were reverted.
- MATLAB `testAll`, `COBRA_CI=1`, R2026a. Baseline at aa51dcd2a: 537 tests, 497 passed, 4 failed, 36 skipped. After
  at 0b548ede1: 496 passed, 5 failed, 36 skipped. The one difference was `testSurfNet.m` (Passed → Failed), traced
  to 934536abd and fixed in 3c2bbad64. `COBRA_TESTS=testSurfNet testAll` passes on both clones after the fix. The
  full suite was not rerun after the fix (`reports/testAll-after-summary.md`).
- Failing in both runs: testEcosystemToy, testClassifySubgraphIsomorphism, testExtractBondSubgraphs,
  testEntropicFluxBalanceAnalysis.
- RunMat discovery (`runmat test --list`): files with errors 1,184 → 342 (`reports/runmat-discovery-after-us1.txt`,
  `reports/residual.tsv`).

## Unresolved issues

- 342 files still fail RunMat discovery. The classes are in `reports/residual.tsv`: RunMat defects D3–D22 (reproducers
  in `reports/`), 105 "undefined on a path" cases (D5), and 58 out-of-slice cases.
- Three classdef files (D7 panic) are set aside from discovery (`reports/runmat-set-aside.txt`).
- The full testAll was not rerun after the one-line fix in 3c2bbad64.
- Deferred: T017–T020 (US2/US3) and T031–T033.

## Other information

Deviations from the plan:
- The catch and calls categories ran over all in-scope files except `test/testAll.m` and `initCobraToolbox.m`,
  which are left for T017–T018.
- testAll ran in full local clones with submodules, because `initCobraToolbox` fails in a git worktree, where `.git`
  is a file.
- `CMatrixTest.m` was added to the RunMat set-aside list after its new `catch` exposed the D7 panic.
- A `git config` command run in the worktree overwrote the submodule URLs in the main checkout's shared
  `.git/config`. They were restored from the `.gitmodules` values; any custom URLs that were there are lost.
