# Human Loop State

## Current State
- Status: Bundle 3 PARTIAL increment COMMITTED (Part 1 net + :911 fix + dqq consolidation); Part 2
  QP/MILP/MIQP consolidation PAUSED by user decision. Not pushed.
- Active feature directory: specs/009-fba-characterization-statusmap
- Last completed: Part 1 (T001–T007 + T007b) + Part 2 T008/T009/T010-dqq; receipt written.
- Source modified: solveCobraLP.m (:911 fix + dqq consolidation) + new mapSolverStatus.m + 4 new tests.
  optimizeCbModel.m / buildOptProblemFromModel.m UNCHANGED.
- MATLAB MCP: reachable (R2026a); all delivered tests green; check_matlab_code(mapSolverStatus) clean.
- Receipt: agent-runs/20260715T152500Z-fba-characterization-statusmap/implementation-receipt.md
- To resume: T010 remainder + T011 (QP) + T012 (MILP) + T013 (MIQP) + T014 + T015–T016, then Gate 3.

## Core Command Ledger
- constitution:   checked (v1.3.0; not regenerated)
- specify:        invoked (spec.md + checklists/requirements.md created)
- clarify:        invoked (1 clarification: BOTH Part 1 + Part 2 in 009; see spec Clarifications 2026-07-15)
- checklist:      requirements.md present, 16/16 items pass (unchanged by clarify)
- plan:           invoked (plan.md, research.md, data-model.md, quickstart.md)
- tasks:          invoked (tasks.md — 18 tasks, 5 phases, T007 hard gate: Part 1 green before Part 2)
- analyze:        invoked (read-only; 0 blocking; F1/F2 should-fix; see implementation-review.md)
- implement:      pending (gated on explicit /speckit-implement per Principle VI; edits src/ + test/)

## Constitution Reconciliation Notes
- Implementation gate (Principle VI): a Gate 2 menu choice is NOT sufficient. Edits to
  src/ or test/ require an explicit `/speckit-implement` invocation.
- This feature DOES edit src/ and test/ (unlike 008): characterization tests under
  test/verifiedTests/, and (if in scope) mapSolverStatus + solveCobra* rerouting under
  src/base/solvers/. MATLAB standards (Principle VII) are load-bearing: no evalc shadowing,
  warnings visible, try/catch propagates ME.stack, no nargin, openCOBRA header + camelCase.
- Characterization mode (Principle III, v1.3.0): pin EXISTING behavior; Part 1 tests MUST
  NOT change the functions under test. Part 2 refactor must be behavior-preserving.
- Verification: MATLAB MCP (mcp__matlab__check_matlab_code, run_matlab_test_file,
  run/evaluate) — capture solver status strings + residuals faithfully.
- Receipt: specs/009-.../agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md.

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-15 | Gate 1 | Continue to plan | Proceed to Bundle 2 (plan + tasks + analyze); no source edits |

## Approved Implementation Scope
- Approved: no
- Scope: (undecided — key open question: include Part 2 refactor or net-only?)
- Files allowed (if approved): test/verifiedTests/** (new characterization tests);
  src/base/solvers/** (new mapSolverStatus + solveCobra* rerouting, Part 2 only)
- Files not allowed: optimizeCbModel/buildOptProblemFromModel/solveCobraLP LOGIC changes
  (characterization pins them; only status-map routing changes in Part 2); no interface/
  model-field change; no W1/W5/W16/W17 cleanup

## Pointers
- Implementation receipt(s): (none yet)
- Implementation review: specs/009-fba-characterization-statusmap/implementation-review.md (pending)

## Bundle 3 progress (Part 1 COMPLETE — T007 gate reached)
- MATLAB reachable (R2026a); COBRA initialized; solvers: mosek (active LP+QP), gurobi, glpk.
- :911 latent bug (found by the net) FIXED (user chose fold-into-009): solveCobraLP.m:911
  `param`→`gurobiParam`. Verified under gurobi: unbounded now clean stat==2. Memory:
  [[solvecobralp-gurobi-inf-or-unbd-param-bug]]. Recorded as FR-013 + task T007b.
- Part 1 tests WRITTEN and GREEN under gurobi (via MATLAB MCP):
  - T004 test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/ — PASS
  - T005 test/verifiedTests/base/testSolvers/testCharacterizeBuildOptProblemFromModel.m — PASS
  - T006 test/verifiedTests/base/testSolvers/testCharacterizeSolveCobraLP.m — PASS
- Diff scope verified: solveCobraLP.m = ONLY the :911 one-liner; optimizeCbModel.m /
  buildOptProblemFromModel.m UNCHANGED (FR-007 ✓); + 3 new tests + spec artifacts + feature.json.
- Source code modified by this workflow: YES — solveCobraLP.m (:911 one-liner only) + 3 new tests.
- T007 hard gate PASSED.

## Bundle 3 progress (Part 2 — started, first consolidation done + verified)
- T008 DONE: src/base/solvers/statusMapping/mapSolverStatus.m created (dqq/quadMinos LP map,
  behavior-exact incl. error-on-unmapped-code); check_matlab_code CLEAN.
- T009 DONE: test/verifiedTests/base/testSolvers/testMapSolverStatus.m — exhaustive dqq map
  assertions (all 15 codes × 2 aliases + fail-loud), GREEN.
- T010 PARTIAL: both dqqStatMap duplications in solveCobraLP.m (:419 & :555) consolidated to
  `mapSolverStatus(solver,'LP',sol.inform)` — the flagship W2 duplication removed. Verified:
  net still green under gurobi (testCharacterizeSolveCobraLP + testCharacterizeOptimizeCbModel),
  testMapSolverStatus green. (lp_solve/gurobi-block LP sites NOT consolidated — lp_solve not
  installed; gurobi LP is control-flow not a pure map.)
- REMAINING Part 2 (T010 rest, T011 QP cplex×3, T012 MILP, T013 MIQP, T014): larger grind, mostly
  for NON-installed solvers (cplex/tomlab) → unit-test-guarded only; and MILP/QP/MIQP would want
  their own characterization tests. Checkpoint taken.
- Source modified: solveCobraLP.m (:911 fix + dqq consolidation), + new mapSolverStatus.m + 4 new tests.
  optimizeCbModel.m / buildOptProblemFromModel.m UNCHANGED. Nothing committed.

## Open Risks and Ambiguities
- RESOLVED (clarify 2026-07-15): BOTH Part 1 + Part 2 land in 009 (Part 2 gated behind Part 1 green).
- Capturing stable reference values for infeasible/unbounded/numerical status portably
  across solvers (CI is gurobi-mostly) — plan concern.
- .origStat is mutated post-solve today (solveCobraLP.m:1616); Part 2 must not alter that
  (W16 out of scope).
- Hooks: per-phase git auto-commit disabled; no commits without explicit request.
