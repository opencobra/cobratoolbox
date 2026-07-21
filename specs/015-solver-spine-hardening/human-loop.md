# Human Loop State

## Current State
- Status: **Bundle 3 (implementation) COMPLETE + verified → STOPPED AT GATE 3 (closeout).** All 34 tasks done. **SC-006 PASS**: post-fix feature fast testAll = **275: 235 pass / 3 fail** (testFVA, testTrimGdel, testOptEnvelope), IDENTICAL to the clean pre-implementation baseline (272: 232/3) — zero failures introduced by 015; the 3 new tests pass. A mid-run test-hygiene defect (2 new tests leaking solver state → 23 cascade failures) was found via the baseline diff and fixed in-scope (onCleanup save/restore). Receipt COMPLETE at agent-runs/20260720T153321Z-solver-spine-hardening/implementation-receipt.md. NOT committed (awaiting Gate-3 decision).
- Next: human Gate-3 closeout decision. For review: 2 documented non-routed files (islands.md); US3 notes (restore() helper, EP/CLP setParam alignment); 3 pre-existing failures as known-issues; local develop not pushed to origin (SSH).
- Active feature directory: specs/015-solver-spine-hardening
- Last completed bundle: Bundle 2 (implementation preparation) — at Gate 2
- Source code modified by this workflow: no source authored; 009 (a previously-approved, Gate-3-closed feature) integrated into develop via git merge only (pre-Gate-2 for 015)

## Core Command Ledger
- constitution:   checked (v1.4.0; strict implementation gate, agent-runs receipt ledger)
- specify:        invoked (committed 15be829c4)
- clarify:        invoked (4 questions answered; committed 15be829c4)
- checklist:      n/a (requirements quality checklist requirements.md passed 16/16; custom speckit-checklist not requested)
- plan:           invoked — plan.md (updated w/ grounded counts) + research.md + data-model.md + contracts/{mapSolverStatus,cobraSolverState,solverIslands}.md + quickstart.md; agent-context pointer updated; post-design Constitution re-check PASS
- tasks:          invoked — tasks.md, 34 tasks (Setup, Foundational, US1/US2/US3, Polish)
- analyze:        invoked — read-only; 0 CRITICAL/HIGH, 0 constitution violations, 100% req→task coverage; 5 MEDIUM/LOW findings (see implementation-review.md)
- implement:      DONE — agent-assign pipeline (assign/validate/execute); all 34 tasks; SC-006 PASS; receipt at agent-runs/20260720T153321Z-solver-spine-hardening/

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-19 | Scope (pre-gate) | Whole spine, phased (W1+W2+W3+bug) | Feature 015 scoped as one 3-phase feature |
| 2026-07-19 | Clarify Q1 | All three phases must ship | No phase deferred out of this feature |
| 2026-07-19 | Clarify Q2 | All non-island bypasses routed | No prioritized subset for Phase 2 |
| 2026-07-19 | Clarify Q3 | Keep exact current .stat value set | No new canonical status value |
| 2026-07-19 | Clarify Q4 | Status exact + objective within tol | Solution vector not asserted (non-unique optima) |
| 2026-07-19 | Mode | "Human loop it" | Run remaining phases under gated orchestration |
| 2026-07-19 | Plan blocker (009) | Land 009 first, 015 extends | Validate 009 on R2026a → merge 009→develop → rebase 015; 015 reuses 009 net + extends mapSolverStatus to all LP solvers + MILP/MIQP |
| 2026-07-20 | Resume after interruption | Continue Bundle 2 | 009 blocker RESOLVED (8d8301ccc in-branch); complete plan artifacts → tasks → analyze → Gate 2 |
| 2026-07-20 | **Gate 2 — implementation approval** | **Approve ALL tasks (T001–T034), agents in parallel** | Full three-phase implementation authorized; Bundle 3 begins |
| 2026-07-20 | Gate 2 — implementation path | **Agent-assign pipeline** | Run assign → validate → execute in series (constitution-sanctioned invocation) |

## Approved Implementation Scope
- Approved: yes (2026-07-20, Gate 2)
- Scope: all — US1 (T001–T013), US2 (T014–T023), US3 (T024–T029), Polish (T030–T034)
- Implementation path: agent-assign pipeline (assign → validate → execute), agents in parallel
- Tasks approved: T001–T034
- Tasks deferred: none
- Files allowed: src/base/solvers/** (statusMapping, solveCobra{LP,QP,MILP,MIQP}, buildOptProblemFromModel, getSetSolver, param, getCobraSolverParams); the 16 routable bypass files (research.md R2.1); the 11 islands' graceful-requirement hardening only (research.md R2.2); test/verifiedTests/base/testSolvers/**; specs/015-solver-spine-hardening/**
- Files not allowed: external/, deprecated/, vendored subtrees, island compute-path routing

## Pointers
- Spec: specs/015-solver-spine-hardening/spec.md (committed 15be829c4)
- Requirements checklist: specs/015-solver-spine-hardening/checklists/requirements.md
- Implementation receipt(s): (none yet — under agent-runs/ once implemented)
- Implementation review: specs/015-solver-spine-hardening/implementation-review.md (WRITTEN 2026-07-20)
- Plan artifacts: research.md, data-model.md, quickstart.md, contracts/{mapSolverStatus,cobraSolverState,solverIslands}.md, tasks.md (34 tasks)

## Open Risks and Ambiguities
- **RESOLVED (2026-07-20): feature 009 landed.** The 009 merge (8d8301ccc) is now in this
  branch's history; 015's spec+clarify commit (e56fd46bc) sits on top of develop-with-009.
  The 009 FBA/LP characterization net and the partial `mapSolverStatus.m` (LP-dqq + QP-cplex)
  are present in the working tree and serve as 015's behaviour-preservation oracle / extension
  point. Local develop NOT yet pushed to origin (SSH auth fails locally) — track for release,
  not a plan blocker. (Feature 010's entropic-FBA net is a separate net, also on develop.)
- Bypass inventory (Agent B): 32 live in-scope bypassing files — 23 ROUTABLE, 9 ISLAND
  (2 uncertain). SteadyCom entry points + TrimGdel are ROUTABLE; only SteadyCom's 3 CPLEX
  warm-start subroutines are islands. Islands' blockers: CPLEX indicator constraints +
  solution pool (gMCS), conflict refiner (findMIIS), non-convex QCQP (ICONGEMs), CPLEX Java
  FVA (mtFVA), warm-start object reuse (SteadyCom subroutines).
- Status-map drift (Agent A): confirmed same (solver,nativeStatus) → different canonical
  .stat across problem types (gurobi INF_OR_UNBD & TIME_LIMIT; CPLEX 1/2/3/4/20/limits;
  GLPK 3/4); plus two store-side bugs a shared mapper fixes (MIQP gurobi .stat/.origStat
  inversion; LP ibm_cplex code-101 left at stat=0). dqqStatMap duplicated 3× (byte-identical).
- Phase 2 blast radius: ~17-26 files route through the spine; regression risk highest here.
- Phase 3 touches initCobraToolbox + changeCobraSolver (widely depended-on); highest risk.
- Behaviour-preservation oracle leans on the feature-009 characterization net; QP/MILP/MIQP
  coverage may be thinner and need supplementary before/after fixtures.
- 11 R2026a testAll failures exist independently (mostly string/display API drift); must not be
  conflated with this feature's before/after comparisons.
