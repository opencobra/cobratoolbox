# Phase 0 Research: Solver-Spine Consolidation and Abstraction Hardening

**Feature**: 015-solver-spine-hardening | **Date**: 2026-07-20 | **Plan**: [plan.md](./plan.md)

This document is the FR-014 external-solver configuration audit plus the concrete
inventories that ground the three phases. Every claim is file:line-verified against
the sources under `src/base/solvers/` and `src/**` on branch `015-solver-spine-hardening`
(develop-with-009). Line numbers are exact at the time of writing; treat them as the
Phase-1 starting map, re-confirm at edit time.

All non-obvious counts below **supersede the earlier feature-009 estimates** — the
plan's Technical Context "Scale/Scope" numbers are updated to match (see the
reconciliation note at the end).

---

## R1 — Status-map consolidation (Phase 1 / W2)

**Decision**: Extend the feature-009 `src/base/solvers/statusMapping/mapSolverStatus.m`
into the single source of truth for every `(solver, problemType, nativeStatus) -> .stat`
translation the four dispatchers perform inline; delete the duplicated `dqqStatMap` and
the per-dispatcher inline maps; fix the two store-side bugs the consolidation exposes.

**Rationale**: The same native code maps to *different* canonical `.stat` values across
problem types today, which is a correctness hazard and the direct cause of the two
confirmed bugs. A single keyed table makes every divergence explicit and testable.

**Canonical `.stat` value set (FIXED — FR-004, no new value introduced)**:
`{-1, 0, 1, 2, 3}`, meaning (per dispatcher headers `solveCobraLP.m:78-82`,
`solveCobraQP.m:73-77`, `solveCobraMILP.m:85-89`, `solveCobraMIQP.m:64-68`):

| `.stat` | LP/QP meaning | MILP/MIQP meaning |
|---|---|---|
| `1` | optimal | optimal |
| `2` | unbounded | unbounded |
| `0` | infeasible | infeasible |
| `3` | solution exists but with problems (near-optimal / limit) | same |
| `-1` | other (time limit / numerical) | no integer solution exists |

`.origStat` carries the raw native code/string **verbatim** and must be preserved.

### R1.1 Per-dispatcher native → canonical inventory (where inline maps live)

**LP — `solveCobraLP.m`** (defaults `stat=0` @236, `origStat=[]` @237; store @1564-1566):
- dqqMinos @430 and quadMinos @549 already delegate to `mapSolverStatus(solver,'LP',sol.inform)`.
- glpk (via `solveGlpk` @587): map @1628-1636 (`180|5`->1; `182|183|3|110`->0; `184|6`->2; else -1).
- lp_solve @638-646 (`0`->1; `3`->2; `2`->0; else -1).
- mosek @739 via `mosek/parseMskResult.m` (see R1.3).
- mosek_linprog @796-808 (`>0`->1; `<0`->0; `==0`->-1).
- gurobi @852-896, `INF_OR_UNBD` re-solves zero-obj @884-893 (OPTIMAL->2 else 0).
- matlab/linprog @979-1010 (`>0`->1; `<-1`->0; `==-1`->3; else -1).
- tomlab_cplex @1083-1093; cplexlp @1198-1208; ibm_cplex @1266-1336 (dynamic code-4 re-solve @1294-1306); cplex_direct delegates to `cplex/solveCobraLPCPLEX.m:598-619`.
- pdco @1489-1517 (`0`->1; `1|2|3`->0; else -1).

**QP — `solveCobraQP.m`** (default `stat=-99` @103; store @1075-1076):
- tomlab_cplex @222, tomlab_cplex_tomRun @263, ibm_cplex @311 already delegate to `mapSolverStatus(solver,'QP',origStat)`.
- qpng @350-357; mosek @429 via `parseMskResult`; pdco @572-591; gurobi @642-695 (`INF_OR_UNBD` re-solve @682-692).
- **dqqMinos**: inline `dqqStatMap` literal @1010-1024, lookup @1026-1035 (has an `isempty(k)`->`'UNMAPPED'`/`-1` fallback).

**MILP — `solveCobraMILP.m`** (two vars: native `stat` stored as `.origStat`, canonical `solStat` stored as `.stat`; store @526-527):
- glpk @167-184; cplex_direct @227-237; gurobi_mex @292-302; ibm_cplex @320-333; gurobi @399-419 (only place `TIME_LIMIT`->3 is handled, @408); tomlab_cplex @487-497.

**MIQP — `solveCobraMIQP.m`** (store @341-346):
- tomlab_cplex @136-150; gurobi_mex @211-222; gurobi @275-291; ibm_cplex @313-326.

### R1.2 `mapSolverStatus.m` current coverage (the 009 partial mapper)

- Signature @1: `function [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)`.
- Only two live branches: `LP`+`{dqqMinos,quadMinos}` (inline `dqqStatMap` @44-58, lookup @60-61, **no `isempty` guard** — an out-of-table code raises a runtime assignment error) and `QP`+`{tomlab_cplex,tomlab_cplex_tomRun,ibm_cplex}` @74-84.
- Unknown solver -> `error('COBRA:mapSolverStatus:unmappedSolver',…)` @63-65 / @86-88.
- Any problemType other than LP/QP (incl. **MILP/MIQP**) -> `error('COBRA:mapSolverStatus:unmappedProblemType',…)` @91-93. No default-stat return on error paths.

### R1.3 MOSEK parser (shared) — `mosek/parseMskResult.m`

`solsta` string -> `stat`: strict-optimal set -> 1 (@199-200, @259-272); near-optimal -> **3** (@202-206, @275-286); primal-infeas cert -> 0 (@208-209, @289-302); dual-infeas cert -> 2 (@211-212, @305-317); else -1 (@214-215). Default `stat=-1`, `origStat='NO_SOLUTION_STATUS'` @66-67. `.origStat` = `solsta` string + `' & '` + `res.rcodestr` @221-223.

### R1.4 `dqqStatMap` duplication (current, verified)

**Exactly two** literal copies remain and are **byte-identical** (indentation-stripped diff): `mapSolverStatus.m:44-58` and `solveCobraQP.m:1010-1024`. The former LP-dispatcher copy is gone (LP now delegates). The two copies differ only in *lookup* behaviour: the QP copy has an `'UNMAPPED'`/`-1` fallback, the mapper copy does not — consolidation must keep the guarded fallback.

### R1.5 Confirmed store-side bugs (fixed as part of Phase 1)

**Bug A — MIQP gurobi `.stat`/`.origStat` inversion.** `solveCobraMIQP.m:273`
`solStat = resultgurobi.status;` (a native *string*), while @275-291 compute the numeric
canonical into `stat`; store @343 `solution.stat = solStat;` (string into `.stat`) and
@344 `solution.origStat = stat;` (numeric into `.origStat`). Swapped. (The other three
MIQP branches store correctly; gurobi_mex additionally never stores its native `origStat`, @222+@344.)

**Bug B — LP ibm_cplex code 101 left at `stat=0`.** `solveCobraLP.m:236` inits `stat=0`;
the ibm_cplex branch @1332-1336 only `warning('101')` for code `101` and never assigns
`stat`, so it silently returns `.stat=0` (infeasible) for a status that is not infeasible.

### R1.6 Same `(solver, nativeStatus)` -> different `.stat` by problem type (the drift the table eliminates)

- **gurobi `INF_OR_UNBD`**: LP/QP re-solve to 2-or-0; MILP/MIQP hard `0`. **gurobi `TIME_LIMIT`**: MILP -> 3; LP/QP/MIQP fall through to -1.
- **CPLEX code `4`**: LP dynamic 2/0, QP 2, MILP 3, MIQP-tomlab 0, MIQP-ibm 3.
- **CPLEX MIP codes `101/102/103/118/119`**: interpreted by MILP/MIQP; LP/QP send them to -1 (except the LP-101 bug -> 0).
- **GLPK `3`/`4`**: different code namespaces — LP `3`->0 / MILP `3`->-1; LP `4`->-1 / MILP `4`->0.

**Design consequence**: the consolidated table is keyed on `(solver, problemType, nativeStatus)`
so each divergence above is an explicit, tested row — behaviour is *preserved exactly*,
not "unified" (unifying would be a behaviour change and is out of scope per FR-013).

**Alternatives considered**: (a) a `(solver,nativeStatus)`-only 2-key table — rejected,
it cannot represent the by-problem-type divergences without changing behaviour; (b) leaving
the maps inline and only de-duplicating `dqqStatMap` — rejected, does not address W2 or the
two bugs and leaves four drifting copies.

---

## R2 — Abstraction-bypass inventory (Phase 2 / W3)

**Decision**: Route every routable direct-backend caller outside `src/base/solvers/`
through `solveCobra{LP,QP,MILP,MIQP}`; leave a **documented islands list** solver-specific
where the abstraction cannot yet carry the capability.

**Grounded totals (supersede the ~32/23/9 feature-009 estimate)**:
**27 live in-scope bypass files — 16 ROUTABLE, 11 ISLAND.** Scope = `.m` files under `src/`
excluding `src/base/solvers/`, `external/`, `deprecated/`, and excluding false positives
(reading a solver-name global to pass *into* the abstraction; commented/dead calls;
`if 0` debug blocks; substring hits on subroutine names).

### R2.1 ROUTABLE (16) — reroute through `solveCobra*`

| File | Backend(s) | Repr. lines |
|---|---|---|
| analysis/QFCA/directionallyCoupled.m | gurobi / linprog | 42, 57 |
| analysis/rMTA/MTA_MIQP.m | Cplex MIQP (already has solveCobraMIQP fallback @130) | 59, 100 |
| analysis/thermo/thermoDirectionality/setThermoReactionDirectionalityiAF1260.m | solveCobraLPCPLEX (legacy) | 89,281,363,… |
| analysis/wholeBody/PSCMToolbox/organEssentiality.m | solveCobraLPCPLEX | 75, 96 |
| analysis/wholeBody/PSCMToolbox/checkIEM_WBM.m | solveCobraLPCPLEX | 158,202,… |
| analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/analyzeHMmodel.m | solveCobraLPCPLEX | 293,317,… |
| analysis/exploration/findBlockedReaction.m | solveCobraLPCPLEX | 52 |
| analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m | intlinprog | 1629 |
| dataIntegration/transcriptomics/SWIFTCORE/core.m | gurobi / linprog / cplexlp | 61,77,91 |
| dataIntegration/transcriptomics/SWIFTCORE/blocked.m | gurobi / linprog / cplexlp | 37,52,65 |
| dataIntegration/metabotools/findMinCardModel.m | solveCobraLPCPLEXcard (legacy) | 38 |
| design/TrimGdel/step2and3.m | gurobi LP/MILP | 71,87,144,194,214 |
| design/TrimGdel/gDel_minRN.m | gurobi LP/MILP | 90,110,162,219,227 |
| design/TrimGdel/GRPRchecker.m | gurobi | 60, 76 |
| design/optGeneFitness.m | solveCobraLPCPLEX | 70, 106 |
| design/optGeneFitnessTilt.m | solveCobraLPCPLEX | 72 |

### R2.2 ISLAND (11) — documented, remain solver-specific

| # | File | Blocking capability |
|---|---|---|
| 1 | analysis/ICONGEMs/ICONGEMs.m | non-convex QCQP (gurobi `NonConvex=2`, `quadcon`) |
| 2 | analysis/gMCS/calculateMCS.m | CPLEX solution pool (`cplex.populate()`) |
| 3 | analysis/gMCS/calculateGeneMCS.m | CPLEX solution pool (`cplex.populate()`) |
| 4 | analysis/findMIIS/findMIIS.m | CPLEX conflict refiner / IIS (`refineConflict()`) |
| 5 | analysis/FVA/mtFVA.m | CPLEX Java multi-thread FVA (compiles/runs `CplexFVA.java`) |
| 6 | analysis/multiSpecies/SteadyCom/SteadyComFVA.m | CPLEX warm-start reuse (readModel/readBasis/readParam) |
| 7 | analysis/multiSpecies/SteadyCom/SteadyComPOA.m | CPLEX warm-start reuse (LP.Start / readBasis) |
| 8 | analysis/multiSpecies/SteadyCom/subroutines/SteadyComCplex.m | CPLEX warm-start reuse |
| 9 | analysis/multiSpecies/SteadyCom/subroutines/SteadyComFVAgr.m | CPLEX warm-start reuse (FVAoptCplex reuse) |
| 10 | analysis/multiSpecies/SteadyCom/subroutines/SteadyComPOAgr.m | CPLEX warm-start reuse |
| 11 | reconstruction/modelGeneration/stoichConsistency/maxEntConsVector.m | general convex *nonlinear* objective via `pdco` (max-entropy) |

**Deviations from the feature-009 inventory** (recorded so the count discrepancy does not
resurface as an analyze finding): (a) the two SteadyCom *entry points* `SteadyComFVA.m`
and `SteadyComPOA.m` contain their own direct `Cplex()` warm-start code, so they are
island-grade on the CPLEX fast path (each retains a non-CPLEX fallback via
`SteadyCom(...,'LPonly')`, so a "routable fallback path" reading is defensible — the CPLEX
path is the island); (b) `maxEntConsVector.m` is a genuine island vs the four LP/QP/MILP/MIQP
abstractions (nonlinear objective) — likely one of the prior "2 uncertain"; (c) removed
false positives: `optimizeCbModel.m:469` (`if 0` dead block), `SteadyCom.m:128` (calls the
*subroutine* not the `Cplex()` constructor), and several `useSolveCobraLPCPLEX`-flag files
with zero actual calls.

**Alternatives considered**: routing the islands too, by extending the abstraction to
carry indicator constraints / solution pool / conflict refiner — rejected for this feature
(large surface, new public capability = a behaviour/interface change, out of FR-011/FR-013
scope); captured as a follow-up in the islands contract.

---

## R3 — Solver-state globals inventory (Phase 3 / W1)

**Decision**: introduce a backward-compatible `CobraSolverState` accessor over the existing
globals and thread explicit state through `solveCobra*`; replace the `eval`-built
global-name access in the selection/param path with struct-field access. The globals are
**deprecated via shim, never deleted** (Principle II).

**Grounded counts (supersede the ~18 estimate)**: **14 distinct globals** — 7 `_SOLVER`
(`CBT_{LP,QP,MILP,MIQP,EP,NLP,CLP}_SOLVER`) + 7 `_PARAMS` (`CBT_{LP,QP,MILP,MIQP,EP,NLP,CLP}_PARAMS`).
**10 `eval` sites** access them, across 3 files.

### R3.1 The 10 eval sites Phase 3 replaces with struct-field access

**`getSetSolver/changeCobraSolver.m` (7):**
- 259 `if ~isempty(eval(varName))` (read; `varName` built @258), 260 `eval(varName)` (read),
  348 `solverUsed = eval(['CBT_' notsupportedProblems{i} '_SOLVER']);` (read),
  531 `eval(['oldval = CBT_', problemType, '_SOLVER;']);` (read),
  532 `eval(['CBT_', problemType, '_SOLVER = solverName;']);` (write),
  559 `eval(['… = oldval;']);` (rollback write), 564 `eval(['… = solverName;']);` (write).
- Not counted (dynamic *function* dispatch, not global access): 545/547 `eval(['solveCobra' problemType …])`.

**`param/parseSolverParameters.m` (2):** 33 `eval(['global CBT_' problemType '_SOLVER;'])`
(eval-built global decl), 34 `eval(['defaultSolver = CBT_' problemType '_SOLVER;']);` (read).

**`param/changeCobraSolverParams.m` (1):** 85
`eval(['CBT_' solverType '_PARAMS.(paramName) = paramValue;']);` (eval-built struct-field write).

`getCobraSolverParams.m` has **zero** eval sites (direct `switch` reads @118-153); it becomes
a `CobraSolverState` reader. Static (non-eval) declarations/sets also exist in
`changeCobraSolver.m:180-186,212-224,252` and `changeCobraSolverParams.m:70-74`.

**Alternatives considered**: (a) delete the globals outright and pass state everywhere —
rejected, breaks the many read-only consumers (`fluxVariability.m`, MOMA/ROOM, gMCS,
demeter, SteadyCom, config report) and violates backward-compat; (b) `containers.Map`
instead of a struct — rejected, no interface advantage and worse for `save`/`load` fixtures.

---

## R4 — Builder bug (Phase 1) — `buildOptProblemFromModel.m`

**Decision**: size `names.con` from the true assembled constraint-row count of the problem
matrix, not from `model.mets` alone.

**Root cause (verified)**: constraint rows are `size(model.S,1) + size(model.C,1)` whenever
`model.C` is present (`optProblem.A` assembled @206 `[S;C]` and @219 `[S E;C D]`). But the
mosek `param.debug` naming block @342-346 sets, when `model.ctrs` is absent,
`optProblem.names.con = model.mets` (length `nMet`) — dropping the `size(model.C,1)` coupling
rows. `ctrs` is never auto-created upstream (`rowFields` @147 omits it; the guard @154-156
forces `rowFieldsToBuild=[]`), so a `model.C`-without-`model.ctrs` model reaches @345 and the
`names.con` length mismatches `size(optProblem.A,1)` by exactly `size(model.C,1)` — the mosek
`err_argument_dimension` failure noted in project memory.

**Correct length**: `names.con` must equal `size(optProblem.A,1)` as assembled @197-226, i.e.
`length(model.mets) + size(model.C,1)` on the C-present branches; append placeholder
identifiers for the coupling rows when `model.ctrs` is absent.

**Parallel finding (recorded, in-scope as the column analogue)**: `names.var` @347-351 has the
same defect for `model.E` without `model.evars` — @350 sets `names.var = model.rxns` (length
`nRxn`) while `size(optProblem.A,2) = nRxn + size(model.E,2)`. Fix symmetrically to keep the
debug path internally consistent.

---

## Reconciliation note for plan.md Technical Context

The grounded numbers differ from the plan's pre-research estimates and take precedence:
- Bypass files: plan says "≈17"; actual **27 (16 routable / 11 island)**.
- Globals: plan says "~18 eval-accessed globals"; actual **14 globals via 10 eval sites**.
- `dqqStatMap`: plan says "duplicated 3×"; actual **2 literal copies remain** (LP already delegates).
- Builder bug: plan scopes `names.con` only; the **`names.var` column analogue** is folded in.

`plan.md` Summary/Scale-Scope and the Phase-2 file list are updated to cite these figures.
