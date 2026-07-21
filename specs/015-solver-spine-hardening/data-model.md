# Phase 1 Data Model: Solver-Spine Consolidation and Abstraction Hardening

**Feature**: 015-solver-spine-hardening | **Date**: 2026-07-20 | **Plan**: [plan.md](./plan.md)

The "entities" here are not persisted records — they are the in-memory data structures
and the keyed relation that the refactor introduces or hardens. Field names and value
sets are constrained by the requirements (FR-004 fixed `.stat` set; FR-011 no interface
change; FR-013 equivalence standard) and grounded in [research.md](./research.md).

---

## 1. Canonical solver status (`.stat`) — FIXED value set

The refactor does **not** add or remove any canonical value (FR-004).

| Value | LP/QP semantics | MILP/MIQP semantics |
|---|---|---|
| `1` | optimal | optimal |
| `2` | unbounded | unbounded |
| `0` | infeasible | infeasible |
| `3` | solution returned but with problems (near-optimal / limit) | same |
| `-1` | other (time limit / numerical) | no integer solution exists |

Invariants:
- `.stat` is always a scalar member of `{-1,0,1,2,3}` (never a string — Bug A today
  violates this for MIQP gurobi; Phase 1 restores the invariant).
- `.origStat` carries the raw native code/string **verbatim**; it is orthogonal to `.stat`
  and is never overwritten with the canonical value.
- `.origStatText` (where present) carries a human-readable native label.

## 2. Status-map relation (the consolidated table)

A pure, side-effect-free relation keyed on three inputs:

```
key   = (solver, problemType, nativeStatus)
value = (stat, origStatText)
```

- `solver`: char/string backend id as used in the dispatchers
  (`gurobi`, `ibm_cplex`, `tomlab_cplex`, `tomlab_cplex_tomRun`, `cplexlp`, `cplex_direct`,
  `glpk`, `dqqMinos`, `quadMinos`, `pdco`, `lp_solve`, `mosek`, `mosek_linprog`, `matlab`,
  `qpng`, `gurobi_mex`, `optarrow`).
- `problemType`: one of `{'LP','QP','MILP','MIQP'}`.
- `nativeStatus`: numeric code or native string exactly as the backend returns it
  (e.g. gurobi `'OPTIMAL'`, CPLEX `1`, glpk `180`, MOSEK `solsta` string).
- `stat`: canonical value from §1.
- `origStatText`: native label string (may be `''`).

Relation rules:
- **Total over observed keys**: every `(solver, problemType, nativeStatus)` triple that any
  current dispatcher handles inline MUST resolve to the *same* `stat` the inline code
  produces today (FR-013 exactness) — including the by-problem-type divergences catalogued
  in research.md R1.6 (this is why `problemType` is part of the key, not dropped).
- **Guarded fallback (never silent-optimal)**: an unrecognized `nativeStatus` for a
  *known* `(solver, problemType)` folds into a defined non-optimal `stat` (`-1`), mirroring
  the existing `'UNMAPPED'`/`-1` fallback in `solveCobraQP.m:1026-1035` — it MUST NOT default
  to `1`.
- **Defined error only where the old code also failed**: an unknown `(solver, problemType)`
  raises `COBRA:mapSolverStatus:unmappedSolver` / `:unmappedProblemType`, matching the 009
  mapper's existing identifiers. No new failure surface is introduced.
- **Dynamic re-solve cases stay in the dispatcher**: gurobi/ibm_cplex `INF_OR_UNBD`/code-4
  paths that re-solve a zeroed-objective problem to disambiguate unbounded-vs-infeasible are
  *control flow*, not a table lookup; the table returns the terminal `stat` once the native
  outcome is known, and the re-solve logic remains in the dispatcher. See the mapSolverStatus
  contract for the exact split.

Bugs the relation fixes on adoption (research.md R1.5): **Bug A** (MIQP gurobi
`.stat`/`.origStat` inversion) and **Bug B** (LP ibm_cplex code `101` -> `stat` left at `0`).

## 3. Solver islands list (Phase 2)

A declarative list of files that legitimately bypass the abstraction, each with the
solver-specific capability that keeps it an island. Canonical content = research.md R2.2
(11 files). Format and the "graceful requirement" are specified in
[contracts/solverIslands.md](./contracts/solverIslands.md).

Entity per island entry:

| field | meaning |
|---|---|
| `file` | repo-relative path |
| `backend` | solver whose native API is used |
| `capability` | the specific feature the abstraction cannot carry (e.g. "CPLEX solution pool") |
| `fallback` | non-island path if any (e.g. SteadyCom `LPonly` route), else `none` |

Island capability classes (closed set for this feature): non-convex QCQP; CPLEX solution
pool; CPLEX conflict refiner/IIS; CPLEX Java multi-thread FVA; CPLEX warm-start object reuse;
general convex nonlinear objective (pdco).

## 4. `CobraSolverState` (Phase 3)

A backward-compatible accessor/struct over the 14 existing globals (research.md R3). It does
**not** replace the globals; it is a typed façade so the `eval`-built name access can become
struct-field access, and so `solveCobra*` can receive explicit state.

Conceptual shape (final API fixed in [contracts/cobraSolverState.md](./contracts/cobraSolverState.md)):

```
CobraSolverState
├── solver : struct           % one field per problem type
│   ├── LP   : char           % <- global CBT_LP_SOLVER
│   ├── QP   : char           %    CBT_QP_SOLVER
│   ├── MILP : char           %    CBT_MILP_SOLVER
│   ├── MIQP : char           %    CBT_MIQP_SOLVER
│   ├── EP   : char           %    CBT_EP_SOLVER
│   ├── NLP  : char           %    CBT_NLP_SOLVER
│   └── CLP  : char           %    CBT_CLP_SOLVER
└── params : struct           % one field per solver type
    ├── LP   : struct         % <- global CBT_LP_PARAMS
    ├── QP   : struct         %    CBT_QP_PARAMS
    ├── MILP : struct         %    CBT_MILP_PARAMS
    ├── MIQP : struct         %    CBT_MIQP_PARAMS
    ├── EP   : struct         %    CBT_EP_PARAMS
    ├── NLP  : struct         %    CBT_NLP_PARAMS
    └── CLP  : struct         %    CBT_CLP_PARAMS
```

Invariants:
- **Single source of truth remains the globals**: read/write through the accessor is
  equivalent to reading/writing the corresponding global (so existing read-only consumers —
  `fluxVariability.m`, MOMA/ROOM, gMCS, config report — keep working unchanged).
- **Round-trip equivalence**: `set(problemType, name)` then `get(problemType)` returns `name`,
  and the corresponding global reflects it (and vice-versa) — this is the Phase-3 equivalence
  test (SC / quickstart).
- **No behaviour change to selection/validation**: `changeCobraSolver` still performs the same
  validation and rollback; only the *access mechanism* (eval-built name -> field access) changes.

## Cross-references

- Value/relation rules -> [contracts/mapSolverStatus.md](./contracts/mapSolverStatus.md)
- Accessor API/shim -> [contracts/cobraSolverState.md](./contracts/cobraSolverState.md)
- Islands format/graceful requirement -> [contracts/solverIslands.md](./contracts/solverIslands.md)
- Grounding facts (file:line) -> [research.md](./research.md)
