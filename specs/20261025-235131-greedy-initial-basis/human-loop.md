# Human Loop State

## Current State
- Status: CLOSED at Gate 3 (2026-10-26); branch pushed, PR to develop opened
- Active feature directory: specs/20261025-235131-greedy-initial-basis
- Branch: 20261025-235131-greedy-initial-basis (from develop @ 5e8170e12, pulled 2026-10-25)
- Last completed bundle: 4 (verification and closeout)
- Source code modified by this workflow: yes (SRC, TST; see receipt)

## Core Command Ledger
- constitution:   checked (v1.6.0)
- specify:        invoked (2 [NEEDS CLARIFICATION] markers resolved by user 2026-10-26)
- clarify:        invoked (2 questions: kept>nullity -> keep all + warn; LP count -> status.nLPSolves)
- checklist:      invoked (requirements.md 16/16; numerics-compat.md 32/35, 3 deferred to plan: CHK017, CHK032, CHK035)
- plan:           invoked (research R1-R9; Constitution Check PASS)
- tasks:          invoked (26 tasks; MVP slice T001-T011)
- analyze:        invoked (0 crit, 0 high, 2 med, 3 low; C1 I1 G1 I2 remediated with approval, U1 accepted)
- implement:      invoked 2026-10-26 via /speckit-implement; 26/26 tasks [X]

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-10-26 | specify Q (FR-013) | Always on (Recommended) | `-g` retry applies with or without initialBasis; recorded as a NOTE; outputs identical unless a dependent/zero-valued `+g` vertex occurs |
| 2026-10-26 | specify Q (FR-012) | Columns, n x k (Recommended) | right-mode initialBasis has the orientation of right-mode Zpos |
| 2026-10-26 | clarify Q1 | Keep all, warn (Recommended) | FR-006a: kept > nullity estimate returns all, outcome complete, warning keptExceedsNullity |
| 2026-10-26 | clarify Q2 | New status.nLPSolves (Recommended) | FR-011/SC-001: LP count observable |
| 2026-10-26 | Gate 1 | Continue to plan (Recommended) | Bundle 2 runs: plan, tasks, analyze, implementation-review; stop at Gate 2 |
| 2026-10-26 | Gate 2 | Approve all T001-T026 (Recommended); path /speckit-implement (Recommended) | implementation authorised on explicit invocation; R1 accepted |
| 2026-10-26 | Gate 3 | Accept, push and open PR | feature closed; branch pushed to origin; PR to develop |
| 2026-10-26 | implement checklist gate | Yes, proceed (Recommended) | Completion Integrity item checked at closeout |
| 2026-10-26 | analyze remediation | Apply C1, I1, G1, I2 (Recommended) | spec SC-004/SC-005/FR-017, tasks T006/T012/T019/T025, research R9, plan amended |

## Approved Implementation Scope
- Approved: yes (Gate 2, 2026-10-26), including research R1 (dependence-only retry trigger)
- Scope: all
- Tasks approved: T001-T026
- Tasks deferred: none
- Implementation path: /speckit-implement (core implementer); awaiting the user's explicit invocation per constitution VI
- Files allowed: src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m; test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m; specs/20261025-235131-greedy-initial-basis/**
- Files not allowed: findExtremePool.m, nullspaceAccuracyTarget.m, checkNullspaceBasis.m, getRankLUSOL, src/base/solvers/**, optimalExtremePoolDriver.m, root .gitignore, external/, deprecated/

## Pointers
- Feature prompt (authoritative description): feature-prompt.md
- Implementation receipt(s): agent-runs/20261026T010205Z-greedy-initial-basis/implementation-receipt.md
- Implementation review: specs/20261025-235131-greedy-initial-basis/implementation-review.md

## Open Risks and Ambiguities
- `matlab-shared` MCP fails to attach; the `matlab` MCP server (R2026a) works and will be used.
  fixture ranks were verified in exact arithmetic (sympy) instead. Verification will need a
  working MATLAB session.
- Fixture 6 route (atom-mapped model for identifyConservedMoieties vs Zpos subset) to be
  settled in plan research.
