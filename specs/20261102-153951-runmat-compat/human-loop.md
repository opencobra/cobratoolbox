# Human Loop State

## Current State
- Status: slice 2 (T017, T018, T020, T031–T033) complete; all tasks done; next is Gate 3
- Active feature directory: specs/20261102-153951-runmat-compat
- Worktree: ../fork-cobratoolbox-runmat (branch `20261102-153951-runmat-compat`) was merged into
  `089-large-model-solver-speed` (6a391cab3) and then removed; slice 2 was done in the main checkout on that branch
- Last completed bundle: 3
- Source code modified by this workflow: yes (973 files under src/ and test/, aa51dcd2a..3c2bbad64)

## Core Command Ledger
- constitution:   checked (v1.7.1)
- specify:        done (before_specify hook: branch created by create-new-feature.sh --timestamp)
- clarify:        done (3 questions, 2026-11-02; recorded in spec.md Clarifications)
- checklist:      done (checklists/requirements.md, all items pass)
- plan:           done (plan.md, research.md, quickstart.md)
- tasks:          done (tasks.md, 26 tasks)
- analyze:        done (implementation-review.md; no blocking issues)
- implement:      done for slice T001–T016 + T030 (/speckit-implement, 2026-11-02); slice 2 T017, T018, T020, T031–T033 (/speckit-implement, 2026-11-03)

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-11-02 | Route | "Spec kit" | Work through Spec Kit in the fork rather than the override phrase. |
| 2026-11-02 | Clarify Q1 (external/) | "Exclude external/" | FR-007: vendored external/ files unchanged. |
| 2026-11-02 | Clarify Q2 (missing RunMat functions) | "Explicit calls only (Recommended)" | FR-008: no RunMat-specific fallbacks. |
| 2026-11-02 | Clarify Q3 (measurement) | "Exclude failing submodules (Recommended)" | FR-014: failing submodule and external/ folders off RunMat's path. |
| 2026-11-02 | Gate 1 | "Continue to planning (Recommended)" | Bundle 2: plan, tasks, analyze; stop at Gate 2. |
| 2026-11-02 | Scope after research | "Bounded mechanical slice (Recommended)" | Spec updated: only machine-verifiable rewrites; testAll under RunMat is measured, not promised. |
| 2026-11-02 | Gate 2 | "Approve first slice (Recommended)"; path "/speckit-implement (Recommended)" | Slice T001–T016 + T030 approved; awaiting the explicit `/speckit-implement` invocation (constitution VI). |
| 2026-11-02 | Implementation invocation | `/speckit-implement` | Slice implemented; receipt written. |
| 2026-11-03 | Merge | "commit fork-cobratoolbox-runmat then merge that with fork-cobratoolbox" | 6a22237af (hyperlink removal in initCobraToolbox.m) and merge 6a391cab3 into 089-large-model-solver-speed. |
| 2026-11-03 | Implementation invocation | `/speckit-implement T017, T018, T020 and T031–T033 as necessary` | Slice 2 implemented (25c3d1fd6 + report); receipt agent-runs/20261103T195258Z-runmat-compat-slice2. |
| 2026-11-02 | After slice 1 | "/speckit-git-commit then actually run testall using runmat in a manner that is reusable in future" | Hook: nothing to commit. T019 done with a reusable runner (tools/runmat_testall.sh, no source change); testAll stops at start-up (reports/runmat-testAll.txt). T017–T018 still need /speckit-implement. |

## Approved Implementation Scope
- Approved: yes (2026-11-02); invoked with `/speckit-implement`
- Scope: slice: Phases 1–3 + T030
- Tasks approved: T001–T016, T030
- Tasks deferred: T017–T020, T031–T033 (T033 receipt is still written for the slice run)
- Files allowed: src/**/*.m and test/**/*.m outside submodule paths; specs/20261102-153951-runmat-compat/**
- Files not allowed: external/, deprecated/, every submodule path in .gitmodules
- Implementation path: core implementer (/speckit-implement)

## Pointers
- Implementation receipt(s): specs/20261102-153951-runmat-compat/agent-runs/20261102T212336Z-runmat-compat-slice1/implementation-receipt.md, specs/20261102-153951-runmat-compat/agent-runs/20261103T195258Z-runmat-compat-slice2/implementation-receipt.md (deviations listed there)
- Report: specs/20261102-153951-runmat-compat/reports/runmat-compat-report.md
- Implementation review: specs/20261102-153951-runmat-compat/implementation-review.md

## Open Risks and Ambiguities
- Mechanical rewrites touch about 1,185 files; the MATLAB before/after test-suite comparison (more than 60 minutes
  per run) is the main evidence of unchanged behaviour.
- Upstream openCOBRA merge friction from a large mechanical diff.
- T030 found one behaviour change (testSurfNet, from the name() rewrite); it is fixed and confirmed by a targeted
  testAll run, but the full suite was not rerun after the fix (nor after 25c3d1fd6).
- SC-004 not met: testAll under RunMat stops at D5 (guarded PERFORMANCE_REPORT read), then D6. Passing D5 inside COBRA
  needs eval (FR-008 forbids) or dropping the PERFORMANCE_REPORT workspace switch: a human decision.
- 6a22237af (desktop hyperlink removed from the initCobraToolbox banner) is outside tasks.md: keep or revert.
