# Quickstart: Validating Solver-Spine Consolidation and Abstraction Hardening

**Feature**: 015-solver-spine-hardening | **Plan**: [plan.md](./plan.md)

This is a **validation/run guide**, not an implementation guide. It lists the runnable
scenarios that prove each phase is behaviour-preserving under the FR-013 equivalence standard
(identical canonical `.stat` **and** raw `.origStat`; optimal objective equal within a justified
tolerance; returned point feasible; solution *vector* not asserted). Implementation detail lives
in `tasks.md` and the contracts.

## Prerequisites

- MATLAB R2024b+ with the COBRA Toolbox initialized: `initCobraToolbox(false)`.
- Project default solvers available: **gurobi** (LP/QP) and **mosek** (everything else); the
  status-map fixture tests are pure and need no solver.
- Run from repo root. Tests run headless (CI parity): no GUI-only calls.
- The **feature-009 characterization net** (`test/verifiedTests/base/testSolvers/testCharacterize*`
  and `testMapSolverStatus.m`) is the behaviour-preservation oracle — capture its output as the
  "before" baseline on the current branch tip *before* any Phase-1 edit.

## Baseline capture (once, before implementation)

```matlab
% From repo root, in MATLAB:
initCobraToolbox(false);
results0 = runtests('test/verifiedTests/base/testSolvers');   % record pass/fail + timings
```

Save the summary; every phase must leave this green (11 unrelated R2026a testAll failures are
tracked separately and must not be conflated — see project memory).

---

## Phase 1 — status consolidation + builder bug

**What to prove**: consolidating the inline maps and `dqqStatMap` into `mapSolverStatus`
changes no `.stat`/`.origStat`, and the two store-side bugs + the `names.con`/`names.var` sizing
are fixed.

1. **Status-map exactness** (pure, no solver):
   ```matlab
   result = runtests('test/verifiedTests/base/testSolvers/testMapSolverStatus.m');
   ```
   Expect: every `(solver, problemType, nativeStatus)` fixture returns the same `.stat` as the
   pre-refactor inline code (contract: mapSolverStatus.md). Fallback code -> `-1` (no throw);
   unknown solver/problemType -> the two defined error ids.

2. **Bug A / Bug B regression guards**:
   - MIQP gurobi solve returns numeric `.stat` and a *string* `.origStat` (not swapped).
   - LP ibm_cplex native `101` no longer yields `.stat==0`.

3. **Builder `names.con`/`names.var`** (new `testBuildOptProblemNamesCon.m`):
   ```matlab
   result = runtests('test/verifiedTests/base/testSolvers/testBuildOptProblemNamesCon.m');
   ```
   Build a model with `model.C` (and separately `model.E`) but **no** `model.ctrs`/`model.evars`,
   call `buildOptProblemFromModel(..., 'debug', true)` under mosek, and assert
   `numel(optProblem.names.con) == size(optProblem.A,1)` and
   `numel(optProblem.names.var) == size(optProblem.A,2)` — no mosek `err_argument_dimension`.

4. **Oracle re-run**: `runtests('test/verifiedTests/base/testSolvers')` stays green vs baseline.

---

## Phase 2 — abstraction bypasses

**What to prove**: each routed file now goes through `solveCobra*` and is portable across
solvers; each island degrades gracefully.

1. **Routing portability** (new `testSolverAbstractionRouting.m`): for a representative routed
   file (e.g. `SWIFTCORE/core.m`, `TrimGdel/gDel_minRN.m`, `QFCA/directionallyCoupled.m`),
   configure a *non-native* solver via `changeCobraSolver` and assert an FR-013-equivalent result
   vs the original backend (same `.stat`, objective within tol).
   ```matlab
   result = runtests('test/verifiedTests/base/testSolvers/testSolverAbstractionRouting.m');
   ```
2. **Island graceful behaviour**: with the island's required solver absent (or simulated absent),
   assert the defined "requires <solver> (<capability>)" error id, or that the listed `fallback`
   runs (SteadyCom `LPonly`). Never a silent/opaque failure (contract: solverIslands.md).
3. **Module smoke**: run the existing verifiedTests for each touched module (e.g.
   `testSWIFTCORE`, `testTrimGdel`, relevant `testFVA`) and confirm no regression vs baseline.

---

## Phase 3 — solver-state encapsulation

**What to prove**: `CobraSolverState` is an equivalent façade over the 14 globals; the
`eval`-built access is gone; `changeCobraSolver` behaves identically.

1. **Round-trip equivalence** (new `testCobraSolverState.m`):
   ```matlab
   result = runtests('test/verifiedTests/base/testSolvers/testCobraSolverState.m');
   ```
   For every solver/param type: `setSolver`/`setParam` via the accessor is visible through the
   corresponding `global`, and vice-versa.
2. **`changeCobraSolver` parity**: before/after the same call, the resulting global state,
   validation error on a bogus solver, and rollback are identical (run with gurobi + mosek).
3. **Explicit-state solve**: a solve given explicit state returns an FR-013-equivalent solution
   to the global-driven solve.
4. **No new `eval` on globals**: confirm the 10 eval sites (research.md R3.1) are replaced and
   no `evalc`/warning suppression was introduced (VII-A/B).

---

## Full-suite gate (end of feature)

```matlab
% Fast-mode local run (~28 min baseline, per project memory):
testAll   % or the project's fast-mode entry point
```

Expect no *new* failures vs the pre-feature baseline; the 11 known R2026a string/display-API
failures remain out of scope. Record results in the implementation receipt.
