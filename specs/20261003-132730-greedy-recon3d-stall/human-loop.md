# Human Loop State

## Current State
- Status: Gate 2 approved (all); awaiting explicit /speckit-implement
- Active feature directory: specs/20261003-132730-greedy-recon3d-stall
- Last completed bundle: 2 (implementation preparation)
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (read 2026-10-03; Principle VI gate applies)
- specify:        invoked 2026-10-03
- clarify:        not invoked as a skill; 4 clarifications taken interactively and recorded in spec.md "Clarifications / Session 2026-10-03"
- checklist:      checklists/requirements.md written by specify (all pass)
- plan:           invoked 2026-10-03 (research by scratchpad prototype on VK file; SC-003 re-derived)
- tasks:          invoked 2026-10-03 (27 tasks)
- analyze:        invoked 2026-10-03 (0 crit/0 high/3 med/6 low; remediated)
- implement:

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-10-03 | Clarification | Assumptions (10-min bound; fixture) "are correct"; reference call = user snippet on VK file as-is | Recorded in spec Clarifications |
| 2026-10-03 | Clarification | CI fixture: "Use a different model ... small ecoli model" in COBRA.models; VK file loaded via load(...) for development | FR-015 / Assumptions updated |
| 2026-10-03 | Gate 2 | "Approve all tasks (Recommended)"; path "/speckit-implement (Recommended)"; SC-003 re-derivation accepted | Scope T001–T027 recorded; awaiting the user's explicit /speckit-implement invocation (Principle VI) |
| 2026-10-03 | Analyze remediation | "Fix all, then Gate 2 (Recommended)" | U1 A1 C1 C2 I1 I2 I3 fixed in artifacts; U1 measured 1e8-element SVD 8.3 s |
| 2026-10-03 | Gate 1 | "continue using human loop" (continue to implementation-preparation bundle) | Bundle 2 started; per-phase commit hooks deferred to one commit at end of bundle |

## Approved Implementation Scope
- Approved: yes (Gate 2, 2026-10-03) — effective only on the user's explicit /speckit-implement
- Scope: all
- Tasks approved: T001–T027
- Tasks deferred: none
- Implementation path: /speckit-implement (core implementer)
- Files allowed: greedyExtremeRayBasis.m (edit); nullspaceAccuracyTarget.m, checkNullspaceBasis.m (new) in src/analysis/topology/extremeRays/optimalRays/; testGreedyExtremeRayBasis.m (edit); testNullspaceAccuracyTarget.m, testCheckNullspaceBasis.m (new) in test/verifiedTests/analysis/testTopology/; specs/20261003-132730-greedy-recon3d-stall/** (measurements, receipt, state)
- Files not allowed: findExtremePool.m, optimalExtremePoolDriver.m, testFindExtremePathway.m, test/models/**, external/**, deprecated/**, the VK model file

## Pointers
- Implementation receipt(s): (none yet; constitution ledger under agent-runs/)
- Implementation review: specs/20261003-132730-greedy-recon3d-stall/implementation-review.md
- Baseline diagnosis: measurements/20261003-baseline-diagnosis.md

## Open Risks and Ambiguities
- RESOLVED (research R5): plain ecoli_core does not stall; rescaling one conserved row ×2e5 reproduces it (7/11, 1814 accRej) and is the CI regression.
- SC-003 re-derived in planning (10 % of call time → < 15 s); needs confirmation at Gate 2.
- O1 (out of scope): printed "Hit fraction" uses nTry, which excludes accuracy rejections, so it overstates efficiency (baseline printed 1.05). Follow-up candidate.
- test/models/mat/Recon3DModel_301_xomics_input.mat is a corrupt HTML download (COBRA.models submodule) — out of scope; separate follow-up.
