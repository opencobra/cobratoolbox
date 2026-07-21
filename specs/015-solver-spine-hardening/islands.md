# Solver Islands: files that legitimately bypass the solver abstraction

**Feature**: 015-solver-spine-hardening (Phase 2 / W3) | **Date**: 2026-07-20
**Schema**: [contracts/solverIslands.md](./contracts/solverIslands.md) | **Grounding**: [research.md](./research.md) R2.2

## Purpose

Phase 2 routes every *routable* direct-backend caller outside `src/base/solvers/` through
`solveCobra{LP,QP,MILP,MIQP}`. The 11 files below are **not** routed: each depends on a
solver-specific capability the four abstractions cannot currently carry, so it calls its
native backend directly by design. This is the durable, human-readable list Phase 2 refers
to. Membership is fixed by [research.md](./research.md) R2.2 and the canonical table in
[contracts/solverIslands.md](./contracts/solverIslands.md); it is not to be grown or shrunk
without amending those sources.

Paths are relative to `src/`. The `capability` column uses the closed set for this feature:
`non-convex QCQP` · `CPLEX solution pool` · `CPLEX conflict refiner/IIS` ·
`CPLEX Java multi-thread FVA` · `CPLEX warm-start reuse` · `nonlinear convex objective (pdco)`.

## The 11 islands

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

`SteadyComFVA.m` and `SteadyComPOA.m` are island-grade only on their CPLEX warm-start fast
path; each keeps a non-CPLEX route via `SteadyCom(...,'LPonly')`, recorded here as the
`SteadyCom LPonly` fallback. Every other island has no fallback (`none`).

## Graceful requirement (per island)

When its required solver is **not** installed or licensed, each island MUST:

1. **Fail identified, not opaque.** Raise a clear error naming the required solver and the
   capability — e.g. `requires IBM CPLEX (solution pool) — install/license CPLEX or use
   <fallback>` — never an opaque backend crash and never a silent wrong answer.
2. **Route to the fallback where one is listed.** `SteadyComFVA.m` and `SteadyComPOA.m` must
   offer/route to `SteadyCom LPonly` so a CPLEX-less user still gets a correct (if slower,
   less-featured) result. Islands with `fallback = none` stop at requirement (1).
3. **Keep diagnostics visible (VII-B).** No `evalc`/warning suppression is added while
   hardening these files; the solver's own diagnostics stay visible.

Phase 2 does **not** change island behaviour beyond this hardening — the compute path stays
solver-specific by design.

## Additional exceptions found during Phase 2 implementation (2026-07-20)

Two further files that the grounded inventory (R2.1) listed as *routable* were, on close
inspection during routing, left **un-routed** because routing them would change what they
compute (violating FR-013) — the behaviour-preservation mandate requires reporting these
rather than forcing them. They are recorded here so every remaining direct-solver reference
stays traceable (FR-008). They are NOT part of the canonical 11 above.

| file | backend | why not routed | disposition |
|---|---|---|---|
| dataIntegration/metabotools/findMinCardModel.m | ibm_cplex (`solveCobraLPCPLEXcard`) | Uses **L0-cardinality (minimum-nonzero) minimization** (`'zero'` mode), a capability plain `solveCobraLP` cannot perform. | Follow-up: route via `optimizeCardinality`, not `solveCobraLP`. Genuine capability island. |
| analysis/thermo/thermoDirectionality/setThermoReactionDirectionalityiAF1260.m | ibm_cplex (`solveCobraLPCPLEX`) | Caller relies on a CPLEX-specific returned `.A` field (`rmfield(modelD,'A')`); its non-CPLEX branches also carry **pre-existing** bugs (`optimzeCbModel` typo). Routing risks a silent regression on already-broken legacy code. | Follow-up: dedicated fix + route once the legacy bugs are addressed. |

These two are surfaced at Gate 3 (closeout) for a decision: add `findMinCardModel` to a
cardinality island entry, and open a follow-up spec for `setThermo…iAF1260`.

## Follow-up (out of scope)

Routing any island later means teaching the abstraction to carry its capability (non-convex
QCQP, CPLEX solution pool, conflict refiner/IIS, Java multi-thread FVA, warm-start reuse, or
a nonlinear convex objective). Each is a new public capability = a behaviour/interface change
outside FR-011/FR-013, so it belongs to a **future feature**, not 015.

## Cross-references

- Schema, graceful requirement, and test contract: [contracts/solverIslands.md](./contracts/solverIslands.md)
- Grounded inventory with file:line and blocking capability: [research.md](./research.md) R2.2
  (R2 for the routable/island split context)
