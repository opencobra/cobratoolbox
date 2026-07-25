# Human Loop State

## Current State
- Status: Bundle 1 in progress — specify done, clarify next, then Gate 1
- Active feature directory: specs/007-ci-coverage-summary
- Last completed bundle: (none yet — Bundle 1 underway)
- Source code modified by this workflow: no (spec artifacts only)

## Core Command Ledger
- constitution:   checked (already read this session; strict implement-gate + receipt ledger)
- specify:        invoked (spec.md + checklists/requirements.md; no NEEDS CLARIFICATION)
- clarify:        pending
- checklist:      pending
- plan:           pending
- tasks:          pending
- analyze:        pending
- implement:      pending (gated on explicit /speckit-implement)

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-14 | (origin) | "make sure a coverage summary + line-by-line link displays in CI" → chose "Route through Spec Kit" | feature 007 started to surface feature-001 coverage in the CI result, fork-PR-safe |

## Approved Implementation Scope
- Approved: no (pending Gate 2)
- Scope: TBD
- Files likely allowed: .github/workflows/testAllCI_step1.yml (job-summary coverage block);
  optionally .github/workflows/testAllCI_step2.yml (PR comment via workflow_run);
  docs single-source note. test/testAll.m only if strictly necessary.
- Files not allowed: coverage computation semantics; feature-001 gate/threshold; skip-baseline.

## Pointers
- Implementation receipt(s): (to be created under agent-runs/ at implement time)
- Implementation review: specs/007-ci-coverage-summary/implementation-review.md

## Open Risks and Ambiguities
- Scope of the PR-comment (US3): run-level job summary (US1/US2) satisfies the core
  ask; the PR comment is optional and needs the privileged workflow_run path. To be
  confirmed at clarify / Gate 2.
- Fork-PR secret/permission model: step1 has no secrets + read-only token → job
  summary is the reliable channel; any PR comment must come from step2.
- Link target: coverage_html artifact (always present when coverage computed) vs
  Codecov file view (only if Codecov live). Default: artifact link always; Codecov
  link additionally. Design detail for plan.
