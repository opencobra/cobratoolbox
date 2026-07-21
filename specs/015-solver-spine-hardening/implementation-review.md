# Implementation Review

**Feature**: 015-solver-spine-hardening | **Date (UTC)**: 2026-07-20 | **Gate**: 2 (pending)

## Summary

A phased, strictly behaviour-preserving refactor of the LP/QP/MILP/MIQP solver core under
`src/base/solvers`, delivered as three sequenced, independently-testable user stories
(P1 → P2 → P3), all in scope for this feature:

- **US1 / P1 (MVP)** — consolidate every native→canonical status translation into the single
  `mapSolverStatus`, delete the 2 remaining `dqqStatMap` copies + all inline maps, and fix
  three latent bugs (MIQP gurobi `.stat`/`.origStat` inversion; LP ibm_cplex code-101→stat 0;
  `buildOptProblemFromModel` mosek-debug `names.con`/`names.var` sizing).
- **US2 / P2** — route the 16 routable direct-backend callers through `solveCobra*`; document +
  harden the 11 solver islands.
- **US3 / P3** — a backward-compatible `CobraSolverState` façade over the 14 globals, migrating
  the 10 `eval`-built access sites to struct-field access and threading explicit state.

Design artifacts are grounded file:line in [research.md](./research.md); the numbers there
**supersede the spec/plan pre-research estimates** and are the source of the MEDIUM/LOW analyze
findings below (descriptive drift only — no requirement changes).

## Embedded Core Commands Completed

- constitution: checked (v1.4.0 — strict implementation gate, `agent-runs/` receipt ledger)
- specify: invoked (committed e56fd46bc)
- clarify: invoked (4 Qs, committed e56fd46bc)
- checklist: requirements.md passed 16/16
- plan: invoked (plan.md + research.md + data-model.md + contracts/{mapSolverStatus,cobraSolverState,solverIslands}.md + quickstart.md; agent-context pointer updated; post-design Constitution re-check PASS)
- tasks: invoked (tasks.md — 34 tasks)
- analyze: invoked (read-only; report below)

## Cross-Artifact Analysis Summary

**Metrics** — Requirements: 14 FR + 6 SC. Tasks: 34. Requirement→task coverage: 100% (every
FR/SC has ≥1 task or is discharged by a plan-phase artifact). Constitution violations: 0.
CRITICAL: 0. HIGH: 0. Duplication: 0. Ambiguity: 1 (by design).

**Findings** (all MEDIUM/LOW; none blocking):

| ID | Category | Severity | Location | Summary | Recommendation |
|----|----------|----------|----------|---------|----------------|
| I1 | Inconsistency | MEDIUM | spec.md:328-334 vs research.md R2.2 | Spec Assumptions name **TrimGdel** an "expected island"; grounded research classifies all 3 TrimGdel files ROUTABLE (plain gurobi, no island capability) — they are routed in T018. SteadyCom remains an island as spec expected. | Add a one-line spec note that TrimGdel is fully routable; no requirement changes (spec already says "routed through the spine for every problem type the abstraction can carry"). |
| I2 | Inconsistency | MEDIUM | spec.md:342-348 (Traceability) | Test/source paths drift from reality: spec says `test/verifiedTests/base/solvers/`, `src/base/solvers/mapSolverStatus`, `src/base/install/changeCobraSolver`; actual dirs are `test/verifiedTests/base/testSolvers/`, `src/base/solvers/statusMapping/mapSolverStatus.m`, `src/base/solvers/getSetSolver/changeCobraSolver.m`. tasks.md uses the correct paths. | Align the spec Traceability paths (cosmetic; tasks.md is authoritative for implementation). |
| I3 | Inconsistency | LOW | spec.md:137 vs research.md R3 | Spec US3 narrative says "~18 mutable globals"; grounded count is **14** (7 `_SOLVER` + 7 `_PARAMS`). Plan already updated to 14. | Optionally change "~18" → "14" (approximate figure, no requirement impact). |
| C1 | Coverage gap | MEDIUM | FR-011 | Public-signature/diagnostic-preservation is asserted only indirectly via the full `testAll` run (T031). No dedicated signature-assertion task. | Add an explicit public-signature assertion (e.g., fold into T024/T016, or a small guard test) that `changeCobraSolver`/`solveCobra*`/`buildOptProblemFromModel` signatures and solution fields are unchanged. |
| A1 | Ambiguity | LOW | spec FR-006/013 etc. | "within a justified tolerance" is not a single fixed number. | By design (Principle III requires per-test justified tolerances); each test states/justifies its own. No change needed. |

**Classification**: I1, I2, C1 = *should-fix* (cosmetic spec alignment + one small test-coverage
add); I3, A1 = *acceptable*. None *blocking*. All *should-fix* items are addressable during
implementation (I1–I3 are spec touch-ups; C1 is an assertion inside already-planned tests) and do
not alter scope or requirements.

## Proposed Implementation Scope

- **Tasks proposed**: T001–T034 (Setup, Foundational, US1, US2, US3, Polish) — see
  [tasks.md](./tasks.md).
- **First independently testable slice (recommended MVP)**: **US1 (T001–T013)** — status
  consolidation + Bug A/Bug B + `names.con`/`names.var` fix. Standalone correctness value,
  fully guarded by the feature-009 oracle, no public-signature change.
- **Files likely to change** (US1 slice): `src/base/solvers/statusMapping/mapSolverStatus.m`,
  `src/base/solvers/solveCobra{LP,QP,MILP,MIQP}.m`, `src/base/solvers/buildOptProblemFromModel.m`,
  and `test/verifiedTests/base/testSolvers/{testMapSolverStatus.m (extend), testBuildOptProblemNamesCon.m (new)}`.
  US2 adds the 16 routable files + `testSolverAbstractionRouting.m` + islands artifact;
  US3 adds `getSetSolver/CobraSolverState.m` + `param/{parseSolverParameters,changeCobraSolverParams}.m`
  + `getCobraSolverParams.m` + `getSetSolver/changeCobraSolver.m` + `testCobraSolverState.m`.
- **Files that should NOT change**: `external/`, `deprecated/`, vendored subtrees, and the 11
  documented islands' compute paths (hardened only, not re-routed) — see
  [contracts/solverIslands.md](./contracts/solverIslands.md).

## Tests and Validation Expected (narrowest first)

1. `testMapSolverStatus.m` (extended, pure) — exact `.stat` per `(solver,problemType,nativeStatus)`; fallback→-1; error ids; Bug A/Bug B guards.
2. `testBuildOptProblemNamesCon.m` (new) — mosek-debug `names.con`/`names.var` == matrix dims.
3. feature-009 characterization net — before/after `.stat`/`.origStat`/objective (FR-013 oracle).
4. `testSolverAbstractionRouting.m` (new) — routed-module portability + island graceful-requirement.
5. `testCobraSolverState.m` (new) — accessor↔global round-trip, `changeCobraSolver` parity, explicit-state solve.
6. `test/testAll.m` fast mode — SC-006 (no new failures; 11 known R2026a failures excluded).

## Blocking Issues

None. (0 CRITICAL, 0 HIGH, 0 constitution violations.)

## Acceptable Risks

- Phase-2 blast radius (~16 routed files) is the highest regression risk; mitigated by the
  per-module portability test and the existing module tests (T023).
- Phase-3 touches the widely-depended-on selection path; mitigated by the backward-compat shim
  (globals stay authoritative) and the parity test (T024).
- QP/MILP/MIQP oracle coverage is thinner than LP/FBA; supplemented by the status-map fixture +
  targeted before/after comparisons (per plan Technical Context / spec Assumptions).
- The 11 known R2026a `testAll` failures are independent and must not be conflated with this
  feature's before/after comparisons (T031 note).

## Human Approval

- Approved: **yes**
- Approved option: **All tasks (T001–T034)**, agents spawned in parallel
- Approved tasks/scope: **all** — US1 (T001–T013), US2 (T014–T023), US3 (T024–T029), Polish (T030–T034)
- Required implementation invocation per constitution: **agent-assign pipeline**
  (`/speckit-agent-assign-assign` → `/speckit-agent-assign-validate` → `/speckit-agent-assign-execute`,
  run in series). Chosen by the human at Gate 2.
- Files allowed: `src/base/solvers/**` (statusMapping, solveCobra{LP,QP,MILP,MIQP}, buildOptProblemFromModel,
  getSetSolver, param, getCobraSolverParams), the 16 routable bypass files (research.md R2.1),
  the 11 islands' graceful-requirement hardening only (research.md R2.2),
  `test/verifiedTests/base/testSolvers/**`, and Spec Kit artifacts under `specs/015-solver-spine-hardening/`.
- Files NOT allowed: `external/`, `deprecated/`, vendored subtrees, island compute paths (routing).
- Date (UTC): 2026-07-20
