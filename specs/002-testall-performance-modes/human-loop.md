# Human Loop State

## Current State
- Status: CLOSED — Gate 3 accepted (2026-07-13)
- Active feature directory: specs/002-testall-performance-modes
- Last completed bundle: Bundle 4 (verification & closeout)
- Source code modified by this workflow: yes (2 new + 7 edited files; verified)

## Core Command Ledger
- constitution:   checked (v1.2.0; reconciliation applied — implement gate + receipt ledger honored)
- specify:        invoked (spec.md + checklists/requirements.md written)
- clarify:        invoked (2 clarifications integrated; both markers resolved)
- checklist:      satisfied by requirements.md quality checklist (all items pass); custom checklist optional
- plan:           invoked (plan.md, research.md, data-model.md, contracts/, quickstart.md)
- tasks:          invoked (tasks.md T001–T020)
- analyze:        invoked (0 critical, 1 high disclosed tradeoff, 4 low; 100% coverage)
- implement:      invoked via /speckit-implement (T001–T020; receipt written)

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-13 | Pre-flight override gate | "Route through Spec Kit" | No direct edit of test/testAll.m; profiling option + speedup folded into this Spec Kit feature |
| 2026-07-13 | Clarify Q1 (CI mode) | "Full in CI, fast local" | FR-012 added; CI keeps 001 coverage-gate baseline |
| 2026-07-13 | Clarify Q2 (coverage tol) | "≤5 pp absolute drop" | FR-003 / SC-002 set to ≤5 percentage-point drop |
| 2026-07-13 | Gate 2 (approval) | "Approve all tasks" | T001–T020 approved; C1 tradeoff accepted |
| 2026-07-13 | (constitution gate) | "/speckit-implement" | edits authorized; Bundle 3 ran |
| 2026-07-13 | Gate 3 (closeout) | "Accept and close" | feature 002 closed; deferrals documented; not merged/pushed |

## Approved Implementation Scope
- Approved: intent yes (Gate 2 = "Approve all tasks", 2026-07-13); edits still gated on explicit /speckit-implement
- Scope: all — T001–T020 (US1 fast mode, US2 full-mode fidelity + docs, US3 profiling report)
- Tasks approved: T001–T020
- Tasks deferred: none
- C1 tradeoff (fast default): accepted at Gate 2 (mitigated by CI=full, ≤5 pp, revert)
- Files allowed:
  - src/base/install/getCobraTestMode.m (new)
  - src/base/install/prepareTest.m
  - test/testAll.m
  - test/verifiedTests/base/testInstall/testGetCobraTestMode.m (new)
  - test/verifiedTests/analysis/testSampling/testGpSampler.m
  - test/verifiedTests/analysis/testMultiSpeciesModelling/testSimulatePairwiseInteractions.m
  - test/verifiedTests/analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList.m
  - test/verifiedTests/base/testIO/testReadSBML.m
  - test/verifiedTests/base/testIO/testWriteSBML.m
  - test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m
  - test/verifiedTests/design/testMultiProductionEnvelopeInorg.m
  - test/verifiedTests/reconstruction/testModelBorgifier/testModelBorgifier.m
  - .gitignore
  - documentation/source/** (contributor note)
- Files not allowed: solver internals, src/ algorithm/analysis code, expected-result
  .mat fixtures, any other test's assertions/expected values

## Pointers
- Implementation receipt(s): specs/002-testall-performance-modes/agent-runs/20260713T170513Z-testall-performance-modes/implementation-receipt.md
- Implementation review: specs/002-testall-performance-modes/implementation-review.md
- Fast-mode edit audit: specs/002-testall-performance-modes/audit/fast-mode-edits.md

## Open Risks and Ambiguities
- CI default mode (fast vs full) vs the 001-ci-coverage-gating coverage gate — clarify Q.
- Acceptable coverage tolerance between fast and full mode — clarify Q.
- Hooks: auto_execute_hooks=true; commits deferred to bundle boundaries (one commit per bundle).
