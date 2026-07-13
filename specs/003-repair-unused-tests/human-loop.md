# Human Loop State

## Current State
- Status: Bundle 2 complete — awaiting Gate 2 (implementation approval)
- Active feature directory: specs/003-repair-unused-tests
- Last completed bundle: Bundle 2 (plan/tasks/analyze)
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (v1.2.0; reconciliation applied — implement gate + receipt ledger)
- specify:        invoked (spec.md + checklists/requirements.md)
- clarify:        invoked (2 clarifications integrated; both markers resolved)
- checklist:      satisfied by requirements.md (all items pass)
- plan:           invoked (plan.md, research.md w/ per-test triage, quickstart.md)
- tasks:          invoked (tasks.md T001–T017)
- analyze:        invoked (0 critical, 100% FR coverage; 2 low risks)
- plan:           pending
- tasks:          pending
- analyze:        pending
- implement:      not started (blocked on Gate 2 + explicit /speckit-implement)

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-13 | (origin) | route repair through Spec Kit | discovery done read-only; repairs gated |
| 2026-07-13 | Clarify Q1 (DoD) | "Pass-count + accounted-for" | FR-008/SC-005: local pass-count DoD; coverage confirmed in CI |
| 2026-07-13 | Clarify Q2 (scope) | "Also attempt env-dependent" | FR-009/FR-011: widest scope incl. installing free deps |

## Approved Implementation Scope
- Approved: intent yes (Gate 2 = "Approve all tasks", 2026-07-13); edits gated on explicit /speckit-implement
- Scope: all — T001–T017 (US1 code-bug fixes; US2 requirement broadenings; US3 clean-skips/lrs/stray)
- Files allowed (test-only):
  - test/verifiedTests/base/testIO/testUtilities/testGenerateFieldDescriptionFile.m
  - test/verifiedTests/analysis/testFVA/testFVA.m
  - test/verifiedTests/dataIntegration/testMOOMIN/testMoomin.m
  - test/verifiedTests/reconstruction/testComputeMetFormulae/testComputeMetFormulae.m
  - test/verifiedTests/analysis/testMultiSpeciesModelling/testMgPipe.m
  - test/verifiedTests/analysis/testrFBA/testdynamicRFBA.m
  - test/verifiedTests/base/testSolvers/testChangeIBMCplexParams.m
  - test/test_myfunction.m (remove)
- Files not allowed: any src/** function under test (isCompatible.m, TwoSidedBarrier.m,
  sampleCbModel.m, generateFieldDescriptionFile.m, etc.), expected-result .mat fixtures,
  feature 001/002 code. lrs install is a user-run system action, not a repo edit.

## Pointers
- Implementation receipt(s): (none yet — agent-runs/ per constitution)
- Implementation review: specs/003-repair-unused-tests/implementation-review.md (not yet written)

## Open Risks and Ambiguities
- DoD metric: pass-count vs measured line-coverage increase (clarify Q1).
- Target scope: best-effort-all vs code-bug-only (clarify Q2).
- Env-dependent failures (lrs/gcp/cplex): convert-to-clean-skip vs document out-of-scope.
- Discovery baseline came from an existing junit run; local solver set differs, so the
  actual live skip/fail set must be re-measured during plan/verify.
