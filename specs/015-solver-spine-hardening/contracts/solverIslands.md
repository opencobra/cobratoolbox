# Contract: Solver Islands List

**Feature**: 015-solver-spine-hardening (Phase 2) | **Artifact**: the documented list of
files that legitimately bypass the solver abstraction, plus the requirement each must meet.

## Purpose

Phase 2 routes every *routable* direct-backend caller through `solveCobra{LP,QP,MILP,MIQP}`.
An **island** is a file that cannot be routed because it depends on a solver-specific
capability the abstraction cannot currently carry. This contract fixes (a) the list format,
(b) where the list lives, and (c) the "graceful requirement" each island must satisfy so it
degrades cleanly when its solver is absent. Canonical membership = research.md R2.2 (11 files).

## List format

The list is a Spec Kit artifact under `specs/015-solver-spine-hardening/` (this contract is its
schema). One row per island:

| field | required | meaning |
|---|---|---|
| `file` | yes | repo-relative path |
| `backend` | yes | native solver whose API is used (e.g. `ibm_cplex`, `gurobi`, `pdco`) |
| `capability` | yes | the specific feature the abstraction cannot carry (closed set below) |
| `fallback` | yes | non-island path if one exists (e.g. `SteadyCom LPonly`), else `none` |
| `note` | no | anything reviewers need (e.g. "fast-path only; LP path is routable") |

Closed set of `capability` values for this feature:
`non-convex QCQP` · `CPLEX solution pool` · `CPLEX conflict refiner/IIS` ·
`CPLEX Java multi-thread FVA` · `CPLEX warm-start reuse` · `nonlinear convex objective (pdco)`.

## The 11 islands (canonical)

| file | backend | capability | fallback |
|---|---|---|---|
| analysis/ICONGEMs/ICONGEMs.m | gurobi | non-convex QCQP | none |
| analysis/gMCS/calculateMCS.m | ibm_cplex | CPLEX solution pool | none |
| analysis/gMCS/calculateGeneMCS.m | ibm_cplex | CPLEX solution pool | none |
| analysis/findMIIS/findMIIS.m | ibm_cplex | CPLEX conflict refiner/IIS | none |
| analysis/FVA/mtFVA.m | ibm_cplex | CPLEX Java multi-thread FVA | none |
| analysis/multiSpecies/SteadyCom/SteadyComFVA.m | ibm_cplex | CPLEX warm-start reuse | SteadyCom LPonly |
| analysis/multiSpecies/SteadyCom/SteadyComPOA.m | ibm_cplex | CPLEX warm-start reuse | SteadyCom LPonly |
| analysis/multiSpecies/SteadyCom/subroutines/SteadyComCplex.m | ibm_cplex | CPLEX warm-start reuse | none |
| analysis/multiSpecies/SteadyCom/subroutines/SteadyComFVAgr.m | ibm_cplex | CPLEX warm-start reuse | none |
| analysis/multiSpecies/SteadyCom/subroutines/SteadyComPOAgr.m | ibm_cplex | CPLEX warm-start reuse | none |
| reconstruction/modelGeneration/stoichConsistency/maxEntConsVector.m | pdco | nonlinear convex objective (pdco) | none |

## Graceful requirement (per island)

Every island MUST, when its required solver is not installed/licensed:
1. Fail with a clear, identified error naming the required solver and capability
   (e.g. "requires IBM CPLEX (solution pool) — install/license CPLEX or use <fallback>"),
   **not** an opaque backend crash, and **not** a silent wrong answer.
2. Where a `fallback` is listed, offer/route to it (e.g. SteadyCom `LPonly`) so a CPLEX-less
   user still gets a correct — if slower/less-featured — result.
3. Keep the solver's diagnostics visible (VII-B): no `evalc`/warning suppression is added while
   touching these files.

Phase 2 does **not** change island behaviour beyond hardening (1)–(3); the compute path stays
solver-specific by design.

## Follow-up (out of scope, recorded)

Routing an island later means teaching the abstraction to carry its capability (indicator
constraints, solution pool, conflict refiner, non-convex QCQP, warm-start reuse, nonlinear
objective). Each is a public-capability addition = a behaviour/interface change outside
FR-011/FR-013, so it belongs to a future feature, not 015.

## Test contract

`test/verifiedTests/base/testSolvers/testSolverAbstractionRouting.m` (Phase 2):
- For each **routed** file: a portability check that it produces an FR-013-equivalent result
  under a non-native configured solver (proving it now goes through the abstraction).
- For each **island**: assert the graceful requirement — with the required solver absent, the
  defined error id is raised (or the listed fallback runs), never a silent/opaque failure.
All `prepareTest`-gated; skip cleanly when a required solver is unavailable.
