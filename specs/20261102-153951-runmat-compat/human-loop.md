# Human Loop State

## Current State
- Status: Bundle 3 (approved implementation, slice 1) complete; next is Gate 3
- Active feature directory: specs/20261102-153951-runmat-compat
- Worktree: ../fork-cobratoolbox-runmat (branch `20261102-153951-runmat-compat`, from `develop` @ `467094a5d`), so the
  main checkout and its uncommitted change on `089-large-model-solver-speed` are untouched
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
- implement:      done for slice T001–T016 + T030 (/speckit-implement, 2026-11-02)

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

## Approved Implementation Scope
- Approved: yes (2026-11-02); invoked with `/speckit-implement`
- Scope: slice: Phases 1–3 + T030
- Tasks approved: T001–T016, T030
- Tasks deferred: T017–T020, T031–T033 (T033 receipt is still written for the slice run)
- Files allowed: src/**/*.m and test/**/*.m outside submodule paths; specs/20261102-153951-runmat-compat/**
- Files not allowed: external/, deprecated/, every submodule path in .gitmodules
- Implementation path: core implementer (/speckit-implement)

## Pointers
- Implementation receipt(s): specs/20261102-153951-runmat-compat/agent-runs/20261102T212336Z-runmat-compat-slice1/implementation-receipt.md (deviations listed there)
- Implementation review: specs/20261102-153951-runmat-compat/implementation-review.md

## Open Risks and Ambiguities
- Mechanical rewrites touch about 1,185 files; the MATLAB before/after test-suite comparison (more than 60 minutes
  per run) is the main evidence of unchanged behaviour.
- Upstream openCOBRA merge friction from a large mechanical diff.
- T030 found one behaviour change (testSurfNet, from the name() rewrite); it is fixed and confirmed by a targeted
  testAll run, but the full suite was not rerun after the fix.
