# Human Loop State

## Current State
- Status: Bundle 2 complete; at Gate 2
- Active feature directory: specs/20261104-001324-runmat-init-mode
- Branch: `20261104-001324-runmat-init-mode` (from `089-large-model-solver-speed` @ `87573f1e8`, which contains the
  RunMat-compatibility feature 20261102-153951-runmat-compat)
- Last completed bundle: 2
- Source code modified by this workflow: no
- Not from this workflow: an uncommitted change to
  `src/reconstruction/modelGeneration/stoichConsistency/findStoichConsistentSubset.m` was already in the working tree. It is
  left alone and kept out of this feature's commits.

## Core Command Ledger
- constitution:   amended 1.7.1 -> 1.8.0 (/speckit-constitution, 2026-11-04: VIII-Runtime, IX role map, plan-template check)
- specify:        done (2026-11-04; before_specify hook created the branch)
- clarify:        done (3 questions answered before the spec was written, 2026-11-04; recorded in spec.md)
- checklist:      done (checklists/requirements.md, all items pass)
- plan:           done (plan.md, research.md, data-model.md, contracts/, quickstart.md)
- tasks:          done (25 tasks)
- analyze:        done (implementation-review.md; 0 critical, 2 high should-fix)
- implement:

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-11-04 | Request | "new speckit feature to give initCobraToolbox a new input argument that enables it to run as a runmat compatible script, and acknowledge the debt" | /speckit-specify run |
| 2026-11-04 | Clarify: interface | "New mode 'runmat' (Recommended)" | FR-001: `initCobraToolbox(updateToolbox, 'runmat')` |
| 2026-11-04 | Clarify: scope | "initCobraToolbox + testAll (Recommended)" | FR-006/FR-007: testAll RunMat opt-in |
| 2026-11-04 | Clarify: debt record | "Constitution amendment too" | FR-008–FR-011: marker + register + re-check; companion /speckit-constitution amendment gates the code |
| 2026-11-04 | Workflow | "continue with speckit humanloop" | Bundle 1 closed; Gate 1 |
| 2026-11-04 | Gate 1 | "Amend constitution, then plan (Recommended)" | constitution v1.8.0; then plan, tasks, analyze |
| 2026-11-04 | Planning blocker | "Narrow: mode + debt now (Recommended)" | RunMat v0.6.2 D26–D29 block toolbox functions; SC-001/SC-002 narrowed to the stopping point; research.md R2 |

## Approved Implementation Scope
- Approved: no

## Pointers
- Implementation receipt(s): none yet
- Implementation review: specs/20261104-001324-runmat-init-mode/implementation-review.md
- Predecessor report: specs/20261102-153951-runmat-compat/reports/runmat-compat-report.md

## Open Risks and Ambiguities
- D5 is a compile-time rejection. Reading `PERFORMANCE_REPORT` in testAll probably needs a name-from-text
  construct (`evalin`/`eval`). That construct needs a VII-A/VII-C check and a debt entry.
- RunMat may lack other functions that initCobraToolbox uses (for example `genpath`, `addpath`, `getenv`, `system`).
  This is unknown until planning research.
