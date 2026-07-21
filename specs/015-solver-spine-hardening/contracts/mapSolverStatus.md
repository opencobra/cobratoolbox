# Contract: `mapSolverStatus`

**Feature**: 015-solver-spine-hardening (Phase 1) | **File**:
`src/base/solvers/statusMapping/mapSolverStatus.m` (extend the feature-009 function)

## Purpose

Single source of truth translating a backend solver's native status into the canonical
COBRA `.stat`. Replaces the inline per-dispatcher maps and the duplicated `dqqStatMap`
(research.md R1). Behaviour is preserved **exactly** (FR-013): every triple resolves to the
same `.stat` the inline code produces today.

## Signature (unchanged from 009 — FR-011)

```matlab
function [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)
```

- **Inputs**
  - `solver` (char): backend id (`'gurobi'`, `'ibm_cplex'`, `'tomlab_cplex'`,
    `'tomlab_cplex_tomRun'`, `'cplexlp'`, `'cplex_direct'`, `'glpk'`, `'dqqMinos'`,
    `'quadMinos'`, `'pdco'`, `'lp_solve'`, `'mosek'`, `'mosek_linprog'`, `'matlab'`,
    `'qpng'`, `'gurobi_mex'`, `'optarrow'`).
  - `problemType` (char): one of `'LP' | 'QP' | 'MILP' | 'MIQP'`.
  - `origStat` (numeric scalar or char): raw native status exactly as the backend returns it.
- **Outputs**
  - `stat` (numeric scalar in `{-1,0,1,2,3}`): canonical status (data-model §1).
  - `origStatText` (char): native label; `''` when the backend has no separate label.

The second output name is `origStatText`. Existing LP callers bind it into a variable they
call `origStat` (`solveCobraLP.m:430,549`) — that is the *native label* they then store as
`.origStatText`/`.origStat`; keep that behaviour.

## Behavioural contract

1. **Exactness**: for every `(solver, problemType, origStat)` handled by an inline map today,
   the returned `stat` equals the current inline result — including by-problem-type
   divergences (research.md R1.6): gurobi `INF_OR_UNBD`/`TIME_LIMIT`; CPLEX `4` and MIP codes
   `101/102/103/118/119`; GLPK `3`/`4`.
2. **Guarded fallback**: unrecognized `origStat` for a *known* `(solver, problemType)` returns
   `stat = -1` (never `1`). Restores the QP copy's `'UNMAPPED'`/`-1` fallback
   (`solveCobraQP.m:1026-1035`) that the 009 LP branch dropped.
3. **Defined errors only**: unknown `solver` -> `error('COBRA:mapSolverStatus:unmappedSolver',…)`;
   `problemType` outside the four -> `error('COBRA:mapSolverStatus:unmappedProblemType',…)`.
   Same identifiers the 009 mapper already uses; no new failure surface.
4. **Pure**: no globals, no I/O, no solver calls. O(1)/table lookup (no per-solve overhead).
5. **`.origStat` untouched**: the function returns a *label*; it never mutates the caller's raw
   `.origStat`, which stays verbatim.

## Division of responsibility (what stays in the dispatcher)

The **dynamic re-solve** disambiguation (gurobi/QP `INF_OR_UNBD` and ibm_cplex LP code `4`,
which re-solve a zeroed-objective problem to tell unbounded from infeasible —
`solveCobraLP.m:884-893,1294-1306`, `solveCobraQP.m:682-692`) is control flow and **remains in
the dispatcher**. The mapper is called with the *terminal* native outcome. This keeps the
mapper pure and the contract testable.

## De-duplication required by this contract

- Delete the inline `dqqStatMap` literal in `solveCobraQP.m:1010-1024` (+ lookup `1026-1035`);
  the mapper's copy (now guarded per rule 2) is the only one.
- Delete the remaining inline native->`.stat` maps in all four dispatchers, replacing each
  with a `mapSolverStatus(solver, problemType, nativeStatus)` call. LP dqq/quad (`:430,:549`)
  and the three QP CPLEX branches (`:222,:263,:311`) already delegate; extend to the rest and
  to all of MILP/MIQP.

## Bugs this contract fixes on adoption

- **Bug A** — MIQP gurobi `.stat`/`.origStat` inversion (`solveCobraMIQP.m:273,343,344`):
  after routing through the mapper, `.stat` is the numeric canonical and `.origStat` the native
  string.
- **Bug B** — LP ibm_cplex code `101` left at `stat=0` (`solveCobraLP.m:1332-1336`): the mapper
  returns a defined non-`0` `stat` for `101` (per its CPLEX-LP row), so the warn-only fall-through
  no longer leaves a wrong infeasible.

## Test contract (narrowest-first)

`test/verifiedTests/base/testSolvers/testMapSolverStatus.m` (extend existing):
- A fixture row per `(solver, problemType, nativeStatus)` currently handled inline, asserting the
  exact `stat` — the behaviour-preservation oracle for de-duplication.
- Fallback: an out-of-table code for a known `(solver,problemType)` returns `-1`, no throw.
- Errors: unknown solver / unknown problemType throw the two defined identifiers.
- Regression guards for Bug A (MIQP gurobi returns numeric `.stat`, string `.origStat`) and
  Bug B (LP ibm_cplex `101` not `0`).
All `prepareTest`-gated; pure-function tests need no solver installed.
