# Contract: `CobraSolverState`

**Feature**: 015-solver-spine-hardening (Phase 3) | **New file**:
`src/base/solvers/getSetSolver/CobraSolverState.m` (accessor over the existing globals)

## Purpose

A backward-compatible façade over the 14 solver-state globals (research.md R3) so the
`eval`-built global-name access in the selection/param path becomes struct-field access, and
so `solveCobra*` can be given explicit state. The globals are **deprecated via shim, never
deleted** (Principle II); this accessor is the sanctioned way to read/write them.

## State covered (14 globals)

- Solver selection (7): `CBT_{LP,QP,MILP,MIQP,EP,NLP,CLP}_SOLVER`.
- Solver params (7): `CBT_{LP,QP,MILP,MIQP,EP,NLP,CLP}_PARAMS`.

## API (final shape; keep minimal and MATLAB-idiomatic)

```matlab
state = CobraSolverState.get()                     % snapshot struct (data-model §4)
name  = CobraSolverState.getSolver(problemType)    % '' if unset
        CobraSolverState.setSolver(problemType, name)
p     = CobraSolverState.getParams(solverType)     % struct ([] / struct() if unset)
        CobraSolverState.setParam(solverType, paramName, paramValue)
```

- `problemType` in `{'LP','QP','MILP','MIQP','EP','NLP','CLP'}`; `solverType` same set.
- Implementation reads/writes the corresponding `global CBT_<type>_SOLVER` / `_PARAMS` by a
  **fixed `switch`** on the validated type — **no `eval`** (this is the W1/VII-A/VII-D
  improvement; introducing a new `eval` here would defeat the feature).
- Unknown `problemType`/`solverType` -> defined error id
  `COBRA:CobraSolverState:unknownType` (matches the existing validated-type discipline).

## Backward-compatibility contract (the shim)

1. **Globals stay authoritative.** `setSolver`/`setParam` write the *same global* the old code
   wrote; `get*` read it. Any existing consumer that does `global CBT_LP_SOLVER; …` keeps
   working with no change (research.md lists the read-only consumers — `fluxVariability.m`,
   MOMA/ROOM, gMCS, `generateSystemConfigReport.m`, SteadyCom, demeter).
2. **Round-trip equivalence** (Phase-3 acceptance): for every type,
   `setSolver(t,n)` ⇒ `getSolver(t)==n` **and** the global `CBT_<t>_SOLVER==n`; and setting the
   global directly ⇒ `getSolver(t)` reflects it. Same for params.
3. **No selection/validation behaviour change** (FR-011/FR-013): `changeCobraSolver` performs the
   identical validation, the identical rollback on failure, and the identical printout; only the
   *access mechanism* changes (eval-built name -> `CobraSolverState.*` / field access). The
   dynamic `solveCobra<problemType>` capability-probe dispatch (`changeCobraSolver.m:545,547`) is
   **out of scope** — it is function dispatch, not global access, and is left as-is.

## Call sites migrated (research.md R3.1 — the 10 eval sites)

- `getSetSolver/changeCobraSolver.m`: 259, 260, 348 (reads), 531 (read), 532, 559, 564 (writes)
  -> `CobraSolverState.getSolver/setSolver`.
- `param/parseSolverParameters.m`: 33 (eval global decl), 34 (read) -> `CobraSolverState.getSolver`.
- `param/changeCobraSolverParams.m`: 85 (eval field-write) -> `CobraSolverState.setParam`.
- `getCobraSolverParams.m`: no eval today, but reads `_PARAMS` globals directly (@118-153) ->
  read via `CobraSolverState.getParams` for consistency.

## Explicit-state threading (light touch)

`solveCobra{LP,QP,MILP,MIQP}` gain the ability to receive state explicitly (e.g. an optional
param) so a solve is not forced to depend on process globals. Default behaviour when no explicit
state is supplied = read `CobraSolverState.get()` = today's global-driven behaviour. No public
signature is broken (optional, `exist`/`isempty`-guarded, not `nargin` — VII-D).

## Test contract

`test/verifiedTests/base/testSolvers/testCobraSolverState.m`:
- Round-trip equivalence for all 7 solver types and 7 param types (rule 2).
- Old-style `global CBT_LP_SOLVER` read still sees a value written via `setSolver` (rule 1).
- `changeCobraSolver` before/after: same resulting global state, same validation error on a bogus
  solver, same rollback (rule 3) — run against the project default solvers (gurobi/mosek).
- An explicit-state solve returns a solution equivalent (FR-013: same `.stat`/`.origStat`,
  objective within tol) to the global-driven solve.
All `prepareTest`-gated; justified tolerances; fixed seeds.
