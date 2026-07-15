# Implementation Receipt

**Feature**: 009-fba-characterization-statusmap
**Run (UTC)**: 20260715T173257Z (resume 2 — Part 2 QP consolidation + closeout)
**Prior run**: 20260715T152500Z (Part 1 net + :911 fix + dqq LP consolidation)

## Prompt

User "resume" after the prior partial commit. User chose (at the MILP/MIQP checkpoint) to
"Stop Part 2 at dqq+QP; close out" — completing the CPLEX QP consolidation, deferring MILP/MIQP,
and closing the feature at the fully-verifiable scope.

## Final response

009 Part 2 closed at the cleanly-verifiable consolidations (dqq LP + cplex QP); MILP/MIQP deferred
to a follow-up. Delivered this session and verified via the MATLAB MCP (R2026a):
- T011: the CPLEX-family QP status if-block (1->1,3->0,2||4->2,5||6->3,else->-1), triplicated across
  the tomlab_cplex/tomlab_cplex_tomRun/ibm_cplex cases of solveCobraQP.m, consolidated to
  mapSolverStatus(solver,'QP',origStat). QP branch added to the helper; exhaustive QP assertions added
  to testMapSolverStatus. Committed 10de820d2.
- Closeout regression (T015): existing testSolveCobraLP (3/3, 0 failed — across dqqMinos, quadMinos,
  glpk, gurobi, mosek, pdco) and testOptimizeCbModel (1/1) PASS after the solveCobraLP.m/solveCobraQP.m
  edits. The dqq consolidation is therefore verified END-TO-END (testSolveCobraLP exercises
  dqqMinos/quadMinos through the rerouted mapSolverStatus call). The cplex QP consolidation is
  unit-test-guarded (ibm_cplex/tomlab_cplex not installed).
- Scope (T016): diff confined to src/base/solvers/** + test/verifiedTests/** + specs/009 +
  .specify/feature.json; solveCobra* signatures/return fields unchanged (FR-011); optimizeCbModel.m /
  buildOptProblemFromModel.m unchanged (FR-007).

Deferred to a follow-up feature: MILP/MIQP status-map consolidation (T012/T013) — heterogeneous
cplex variants + gurobi + glpk + the 106||106 quirk; no MILP/MIQP net; cplex/tomlab not installed.

## Diff summary (this run)

- M `src/base/solvers/solveCobraQP.m` — 3 CPLEX-family status if-blocks -> mapSolverStatus calls.
- M `src/base/solvers/statusMapping/mapSolverStatus.m` — added QP branch (cplex family).
- M `test/verifiedTests/base/testSolvers/testMapSolverStatus.m` — added exhaustive QP assertions.
- M `specs/009-.../{spec.md,tasks.md,human-loop.md}` — closeout records (MILP/MIQP deferral).
(Committed 10de820d2 for the QP src/test; the spec/closeout records committed at closeout.)

Feature 009 total footprint vs develop: 18 files, +1513/-73; all within
src/base/solvers/** + test/verifiedTests/** + specs/009 + .specify/feature.json.

## Tests

Via MATLAB MCP (R2026a):
- testMapSolverStatus (dqq LP + cplex QP, exhaustive) — PASS
- testCharacterizeOptimizeCbModel / testCharacterizeBuildOptProblemFromModel / testCharacterizeSolveCobraLP — PASS
- testSolveCobraLP — 3/3 PASS (all installed solvers incl. dqqMinos/quadMinos through the rerouted path)
- testOptimizeCbModel — 1/1 PASS
- check_matlab_code(mapSolverStatus.m) — clean

## Unresolved issues

- MILP/MIQP consolidation deferred (own follow-up feature) — see spec Clarifications 2026-07-15.
- 106||106 quirk (research R1 D1) — untouched; to preserve verbatim when MILP/MIQP are consolidated.
- Not pushed.
