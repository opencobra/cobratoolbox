# Implementation Review

## Summary

Feature 009 adds a characterization net for the LP/FBA solver spine (Part 1) and a
behavior-preserving `mapSolverStatus` consolidation of the duplicated status maps (Part 2),
Part 2 gated behind Part 1 green. This feature EDITS `src/` and `test/` (unlike 008), so the
Principle VI gate and MATLAB standards are load-bearing. Requirements, plan, and tasks are
consistent (100% requirement→task coverage, 0 blocking findings).

## Embedded Core Commands Completed

- constitution: checked (v1.3.0; not regenerated)
- specify: invoked (spec.md + checklists/requirements.md)
- clarify: invoked (1 clarification — both parts in 009, Part 2 gated; Session 2026-07-15)
- checklist: requirements.md 16/16 pass
- plan: invoked (plan.md, research.md, data-model.md, quickstart.md)
- tasks: invoked (tasks.md — 18 tasks, 5 phases, T007 hard gate)
- analyze: invoked (read-only; 0 blocking; F1/F2 should-fix; F3 by-design; F4 low; D1 deferred)

## Cross-Artifact Analysis Summary

- Coverage: 18 requirements (12 FR + 6 SC) → 18 tasks; 100% (FR-012 config audit discharged in
  research R1). No unmapped tasks.
- Clarification consistently reflected: both parts in 009; **T007 is a hard gate** — Part 2
  (T008–T014) MUST NOT start until the Part 1 net is green.
- Findings: **F1** (should-fix) make `testMapSolverStatus` exhaustive over the non-gurobi maps —
  the net only exercises gurobi in CI; **F2** (should-fix) scope T014 style-fixes to flags this
  feature introduces, not pre-existing W17; **F3** (by-design) solveCobraLP is characterized then
  refactored-under-the-net — consistent with the hybrid clarification; **F4** low; **D1** deferred
  (`106||106` typo preserved). **0 blocking.**

## Proposed Implementation Scope

- **Tasks proposed**: T001–T018 (all), in strict order with the T007 gate.
- **First independently testable slice**: **US1 / Part 1 net** (T001–T007) — the MVP; closes the
  coverage gap even if Part 2 slips.
- **Files likely to change**:
  - NEW tests: `test/verifiedTests/analysis/testOptimizeCbModel/…`,
    `test/verifiedTests/base/testSolvers/{testBuildOptProblemFromModel,
    testSolveCobraLP,testMapSolverStatus}.m`
  - NEW helper: `src/base/solvers/statusMapping/mapSolverStatus.m`
  - EDIT (status-map routing only): `src/base/solvers/solveCobra{LP,QP,MILP,MIQP}.m`
  - NEW receipt under `agent-runs/`
- **Files that should NOT change**: `optimizeCbModel.m`/`buildOptProblemFromModel.m` logic,
  `mosek/parseMskResult.m`, the lindo dead block, the `.origStat` post-solve mutation (W16),
  `changeCobraSolver`, any model field, and all W1/W5/W17 targets.

## Tests and Validation Expected (narrowest first)

Via the MATLAB MCP (`run_matlab_test_file`, `check_matlab_code`):
1. `testMapSolverStatus` (unit; solver-independent — guards ALL consolidated maps incl. non-gurobi).
2. `testSolveCobraLP` / `testBuildOptProblemFromModel` (dispatcher/mapping).
3. `testOptimizeCbModel` (full net; perturbation check).
4. Re-run the net + unit after EACH dispatcher reroute (T010–T013) → `.stat`/`.origStat` identical.
5. Existing `testOptimizeCbModel`/`testSolveCobraLP`/`testSolveCobraLPCPLEX` still pass.
6. quickstart V1–V6; diff-scope check.

## Blocking Issues

None.

## Acceptable Risks

- F1 (should-fix): mitigate by making `testMapSolverStatus` exhaustive over research R1's maps —
  the CI net alone (gurobi) does not exercise the non-gurobi solver maps.
- F2 (should-fix): T014 must not touch pre-existing W17 code-analyzer flags in the big dispatchers.
- F3 (by-design): characterize-then-refactor-under-net is sound; solveCobraLP's Part-2 edit is
  behavior-preserving and guarded.
- D1 (deferred): `106||106` typo preserved; follow-up defect feature.

## Human Approval

- Approved: no
- Approved option: (pending Gate 2)
- Approved tasks/scope: (pending)
- Required implementation invocation per constitution: explicit `/speckit-implement` (Principle VI)
  — a Gate 2 menu choice alone does NOT authorize edits. This feature edits `src/` + `test/`.
- Date (UTC): (pending)
