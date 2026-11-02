# Human Loop State

## Current State
- Status: Bundle 2 (implementation preparation) complete; at Gate 2
- Active feature directory: specs/20261102-153951-runmat-compat
- Worktree: ../fork-cobratoolbox-runmat (branch `20261102-153951-runmat-compat`, from `develop` @ `467094a5d`), so the
  main checkout and its uncommitted change on `089-large-model-solver-speed` are untouched
- Last completed bundle: 2
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (v1.7.1)
- specify:        done (before_specify hook: branch created by create-new-feature.sh --timestamp)
- clarify:        done (3 questions, 2026-11-02; recorded in spec.md Clarifications)
- checklist:      done (checklists/requirements.md, all items pass)
- plan:           done (plan.md, research.md, quickstart.md)
- tasks:          done (tasks.md, 26 tasks)
- analyze:        done (implementation-review.md; no blocking issues)
- implement:

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

## Approved Implementation Scope
- Approved: yes (2026-11-02), pending the explicit implementation invocation
- Scope: slice: Phases 1–3 + T030
- Tasks approved: T001–T016, T030
- Tasks deferred: T017–T020, T031–T033 (T033 receipt is still written for the slice run)
- Files allowed: src/**/*.m and test/**/*.m outside submodule paths; specs/20261102-153951-runmat-compat/**
- Files not allowed: external/, deprecated/, every submodule path in .gitmodules
- Implementation path: core implementer (/speckit-implement)

## Pointers
- Implementation receipt(s):
- Implementation review: specs/20261102-153951-runmat-compat/implementation-review.md

## Open Risks and Ambiguities
- Mechanical rewrites touch about 1,185 files; the MATLAB before/after test-suite comparison (more than 60 minutes
  per run) is the main evidence of unchanged behaviour.
- Upstream openCOBRA merge friction from a large mechanical diff.
