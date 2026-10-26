# Human Loop State

## Current State
- Status: Bundle 2 (implementation preparation) in progress
- Active feature directory: specs/20261025-235131-greedy-initial-basis
- Branch: 20261025-235131-greedy-initial-basis (from develop @ 5e8170e12, pulled 2026-10-25)
- Last completed bundle: 1 (requirements preparation)
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (v1.6.0)
- specify:        invoked (2 [NEEDS CLARIFICATION] markers resolved by user 2026-10-26)
- clarify:        invoked (2 questions: kept>nullity -> keep all + warn; LP count -> status.nLPSolves)
- checklist:      invoked (requirements.md 16/16; numerics-compat.md 32/35, 3 deferred to plan: CHK017, CHK032, CHK035)
- plan:
- tasks:
- analyze:
- implement:

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-10-26 | specify Q (FR-013) | Always on (Recommended) | `-g` retry applies with or without initialBasis; recorded as a NOTE; outputs identical unless a dependent/zero-valued `+g` vertex occurs |
| 2026-10-26 | specify Q (FR-012) | Columns, n x k (Recommended) | right-mode initialBasis has the orientation of right-mode Zpos |
| 2026-10-26 | clarify Q1 | Keep all, warn (Recommended) | FR-006a: kept > nullity estimate returns all, outcome complete, warning keptExceedsNullity |
| 2026-10-26 | clarify Q2 | New status.nLPSolves (Recommended) | FR-011/SC-001: LP count observable |
| 2026-10-26 | Gate 1 | Continue to plan (Recommended) | Bundle 2 runs: plan, tasks, analyze, implementation-review; stop at Gate 2 |

## Approved Implementation Scope
- Approved: no
- Scope:
- Tasks approved:
- Tasks deferred:
- Files allowed:
- Files not allowed:

## Pointers
- Feature prompt (authoritative description): feature-prompt.md
- Implementation receipt(s): (none yet) agent-runs/<UTC-timestamp>-<name>/implementation-receipt.md
- Implementation review: specs/20261025-235131-greedy-initial-basis/implementation-review.md

## Open Risks and Ambiguities
- The shared MATLAB MCP session (`matlab-shared`) failed to attach during specification;
  fixture ranks were verified in exact arithmetic (sympy) instead. Verification will need a
  working MATLAB session.
- Fixture 6 route (atom-mapped model for identifyConservedMoieties vs Zpos subset) to be
  settled in plan research.
