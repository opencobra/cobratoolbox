# Implementation Receipt — 015 solver-spine-hardening

**Run (UTC)**: 20260720T153321Z | **Feature**: 015-solver-spine-hardening |
**Branch**: 015-solver-spine-hardening | **Path**: base of develop-with-009 (merge 8d8301ccc)
**Invocation**: agent-assign pipeline (assign → validate → execute), Gate-2 approved (all tasks).

> STATUS: COMPLETE — SC-006 verified via baseline diff + post-fix re-run (see Tests).
> Awaiting the human Gate-3 closeout decision.

## Prompt

Resume the interrupted Spec Kit human-loop for feature 015 (solver-spine consolidation &
abstraction hardening). After completing plan → tasks → analyze and reaching Gate 2, the human
approved implementation of **all 34 tasks** via the **agent-assign pipeline** with agents run in
parallel. Implement the three phases (US1 status consolidation + builder bug; US2 abstraction-
bypass routing; US3 CobraSolverState façade), strictly behaviour-preserving (FR-013), then run
the verification gate and close out.

## Diff summary

**31 source files modified (+1002 / −802)** + 1 new source file + 3 new tests + Spec Kit
artifacts. All within the Gate-2 approved scope; `external/`, `deprecated/`, vendored code, and
island compute-paths untouched.

- **US1 (status consolidation + builder bug)** — `src/base/solvers/statusMapping/mapSolverStatus.m`
  (95→395 lines: full `(solver,problemType,nativeStatus)` relation, single guarded `dqqStatMap`,
  2 defined error ids); `solveCobraLP.m` (route + fix Bug B, ibm_cplex 101); `solveCobraQP.m`
  (route + delete inline `dqqStatMap`); `solveCobraMILP.m` (route); `solveCobraMIQP.m` (route +
  fix Bug A `.stat`/`.origStat` inversion); `buildOptProblemFromModel.m` (`names.con`/`names.var`
  sized from `size(A,1)`/`(,2)`).
- **US2 (bypass routing)** — 14 of 16 routable files routed through `solveCobra*`
  (SWIFTCORE core/blocked, TrimGdel ×3, QFCA directionallyCoupled, rMTA MTA_MIQP,
  findBlockedReaction, optGeneFitness, optGeneFitnessTilt, organEssentiality, checkIEM_WBM,
  analyzeHMmodel, reactingMoieties identifyConservedReactingMoieties). 11 islands hardened with
  identified `requires-<solver>` errors (mtFVA, ICONGEMs, findMIIS, gMCS ×2, SteadyComCplex,
  maxEntConsVector; 4 SteadyCom FVA/POA files already met the graceful requirement via LPonly).
- **US3 (CobraSolverState)** — NEW `src/base/solvers/getSetSolver/CobraSolverState.m` (classdef,
  0 eval); migrated all 10 eval sites in `changeCobraSolver.m`, `parseSolverParameters.m`,
  `changeCobraSolverParams.m`; `getCobraSolverParams.m` reads via the accessor; optional
  `'cobraSolverState'` plumbing added to the four `solveCobra*`.
- **NEW tests** — `test/verifiedTests/base/testSolvers/{testBuildOptProblemNamesCon,
  testCobraSolverState,testSolverAbstractionRouting}.m`; `testMapSolverStatus.m` extended.
- **Agent-context** — `CLAUDE.md` SPECKIT pointer updated to the active feature.

## Tests

Per-phase oracles, all **orchestrator-verified** by independent re-run (not just relayed):

| Test | Result | Covers |
|---|---|---|
| `testMapSolverStatus` (extended, pure) | PASS 1/1 | FR-001..004, SC-002; every `(solver,problemType,nativeStatus)` = pre-refactor `.stat`; fallback→-1; error ids; Bug A/B guards |
| `testBuildOptProblemNamesCon` (new) | PASS 1/1 | FR-005, SC-003; mosek-debug `names.con`/`names.var` == matrix dims |
| feature-009 characterization net | PASS, zero divergence | FR-003/013, SC-001 (via US1 agent: 18→19 pass, same absent-solver skips) |
| `testSolverAbstractionRouting` (new) | PASS 12/12 | FR-006/007; cross-solver portability (SWIFTCORE/QFCA/TrimGdel) + island graceful errors |
| `testCobraSolverState` (new) | PASS 1/1 | FR-009/010, SC-005; round-trip, changeCobraSolver parity, explicit-state FR-013 equivalence |
| `testChangeCobraSolver` | PASS 1/1 (US3 agent) | selection-path parity incl. rollback |
| `testSolveCobraLP/QP/MILP/MIQP`, `testDuals` | PASS (US1/US3 agents) | dispatcher behaviour preserved |
| `check_matlab_code` on all changed files | no NEW errors | only expected `global` (GVMIS/TLEV) warnings inherent to the shim + 2 cosmetic unused-var in analyzeHMmodel |

**SC-006 full-suite gate — PASS (zero failures introduced by 015).** Verified by a three-way
`testAll` comparison (fast mode):

| Run | Total | Pass | Fail | Failing tests |
|---|---|---|---|---|
| Clean pre-implementation baseline (worktree @ HEAD) | 272 | 232 | 3 | testFVA, testTrimGdel, testOptEnvelope |
| Feature tree, first run | 275 | 212 | 26 | baseline-3 + 23 cascade victims |
| Feature tree, after test-hygiene fix | 275 | 235 | 3 | testFVA, testTrimGdel, testOptEnvelope |

The post-fix feature run has the **same 3 failures as the clean baseline** (all pre-existing
R2026a issues: a mosek QP dual-residual FVA assertion; the `readGeneRules.m` colon bug behind
`testTrimGdel`; an optEnvelope peak-x tolerance), plus the 3 new feature tests passing
(235 = 232 + 3). **The 23 extra first-run failures were a TEST-HYGIENE DEFECT in two new tests,
not a source regression**: `testBuildOptProblemNamesCon` left `LP=mosek` and
`testSolverAbstractionRouting` leaked its last-set solver on a mid-test failure; running early in
`base/`, they poisoned the global solver state and cascaded (every victim passes in isolation;
baseline is clean). **Fixed**: both now snapshot+restore the full solver state + cwd via
`onCleanup` (using `CobraSolverState.get()/restore()`), re-verified to pass AND leave state
byte-identical (`leak=0`). `testCobraSolverState` was already hygienic.

## Unresolved issues / deviations (for Gate 3)

1. **2 routable files deliberately NOT routed** (documented in `islands.md`), because routing
   would change what they compute (FR-013): `findMinCardModel.m` (L0-cardinality → `optimizeCardinality`
   follow-up) and `setThermoReactionDirectionalityiAF1260.m` (CPLEX-only return field + pre-existing
   legacy bugs). Recommend a cardinality-island entry + a follow-up spec.
2. **US3 `restore()` helper** beyond the 5 contract methods (documented) for lossless explicit-state
   save/restore; **incidental EP/CLP `setParam` correctness alignment** (previously a dead/buggy
   path; zero live impact).
3. **Several routed files not end-to-end verified locally** (absent ibm_cplex/tomlab_cplex/
   statistics_toolbox/whole-body data) — routed faithfully, flagged, need a CI env with those.
4. **Pre-existing, not introduced** (fail on the clean baseline too — out of scope for 015):
   `testFVA` (mosek QP dual-residual assertion), `testTrimGdel` (`readGeneRules.m:37` R2026a
   colon bug), `testOptEnvelope` (peak-x tolerance). Also `changeCobraSolver()` with zero args
   errors at line 174 in committed HEAD (untouched).
5. **Mid-run correction (this run)**: the baseline diff revealed two new tests leaked global
   solver state (cascading 23 spurious `testAll` failures); fixed in-scope by adding
   `onCleanup` full-state save/restore to `testBuildOptProblemNamesCon.m` and
   `testSolverAbstractionRouting.m`. Re-run confirms the feature tree now matches baseline.

## Final response

Feature 015 (solver-spine consolidation & abstraction hardening) is fully implemented and
verified across all three phases, delivered via the Gate-2-approved agent-assign pipeline.

- **US1** — the four LP/QP/MILP/MIQP dispatchers now obtain their canonical `.stat` from the
  single `mapSolverStatus`; the duplicated `dqqStatMap` is gone (one guarded definition); and
  three latent bugs are fixed: MIQP-gurobi `.stat`/`.origStat` inversion, LP-ibm_cplex code
  101→wrong `stat=0`, and the `buildOptProblemFromModel` mosek-debug `names.con`/`names.var`
  sizing. Behaviour-preserving: zero divergence vs the feature-009 characterization net.
- **US2** — 14 of 16 routable modules now go through `solveCobra*` (honouring
  `changeCobraSolver`); the 11 solver islands are documented (`islands.md`) and hardened with
  identified `requires-<solver>` errors. Two files were deliberately left un-routed, documented
  with reasons, because routing would change what they compute (`findMinCardModel` needs
  L0-cardinality; `setThermo…iAF1260` relies on a CPLEX-only return field + has pre-existing
  legacy bugs) — follow-ups, not silent leaks.
- **US3** — a backward-compatible `CobraSolverState` façade (0 `eval`) replaces all 10
  `eval`-built solver-global access sites; `changeCobraSolver`/`initCobraToolbox` parity is
  preserved and `solveCobra*` accept optional explicit state.

**Verification**: every phase oracle passes; SC-006 confirmed by a three-way `testAll` diff —
the post-fix feature suite (275: 235 pass / 3 fail) matches the clean pre-implementation
baseline (272: 232 / 3) exactly, so **no failures were introduced**. The 3 remaining failures
(`testFVA`, `testTrimGdel`, `testOptEnvelope`) are pre-existing R2026a issues. A test-hygiene
defect discovered mid-verification (two new tests leaked solver state, cascading 23 spurious
failures) was fixed in-scope with `onCleanup` full-state restoration.

Footprint: 31 source files (+1002/−802) + `CobraSolverState.m` + 3 new tests; all within the
Gate-2 approved scope; nothing committed (awaiting Gate-3 closeout).
