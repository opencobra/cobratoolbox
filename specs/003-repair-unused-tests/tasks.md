# Tasks: Repair unused / non-contributing tests to enlarge coverage

**Input**: Design documents from `specs/003-repair-unused-tests/`
**Prerequisites**: plan.md, spec.md, research.md (per-test triage), quickstart.md

**Tests**: This feature edits tests; each touched test is re-run before/after via the
MATLAB MCP server and must PASS on available solvers or SKIP cleanly. No assertion is
weakened (FR-002).

**Organization**: by user story — US1 code-bug fixes that yield passes (P1, MVP);
US2 requirement broadenings (P2); US3 clean-skips + env-install + stray removal (P3).

## Implementation status (2026-07-13) — see audit/results.md, audit/out-of-scope.md

Done & verified: T002 (testGenerateFieldDescriptionFile → PASS), T009 (testdynamicRFBA
error→SKIP), T010 (testChangeIBMCplexParams hardened), T012 (test_myfunction removed),
T011 (lrs trio → PASS with bundled binary on PATH; install surfaced), T008/T013 (testMOMA
& testIsCompatible verified PASS; testSampleCbModelRHMC clean SKIP), T014/T015 (results +
static check). **Reverted, no-weakening rule**: T003 (testFVA — solver-specific reference),
T006 (testComputeMetFormulae — cplex TimeLimit assertion), T005/T007 (testMoomin/testMgPipe
broadenings unvalidatable: mosek-MILP not working / PCT absent). T017 receipt written.
SC-005 whole-suite coverage confirmed in CI.

## Path Conventions

MATLAB test files under `test/verifiedTests/**`; one stray file at `test/`.

---

## Phase 1: Setup

- [ ] T001 Record the pre-feature baseline status (passed/skipped/failed) of every test this feature touches, into `specs/003-repair-unused-tests/audit/baseline.md`, by running each via `runScriptFile` in both fast and full modes.

## Phase 2: User Story 1 — repair code-bug failures to PASS (P1) 🎯 MVP

**Goal**: tests broken by their own bugs now pass on available solvers, adding
coverage. **Independent test**: quickstart §1 — status goes fail/error → passed, diff
shows no assertion changed.

- [ ] T002 [P] [US1] `test/verifiedTests/base/testIO/testUtilities/testGenerateFieldDescriptionFile.m`: replace the `generateFieldDescriptionFile();` + `fopen`/`fscanf` reference round-trip with `refData_FileString = generateFieldDescriptionFile();` (the function already returns the canonical string). Keep the single equality assertion. Verify error → passed.
- [ ] T003 [P] [US1] `test/verifiedTests/analysis/testFVA/testFVA.m`: guard the cplex-only value-exact assertion(s) (the PFK-max block ~lines 258–270, and any un-guarded loopless min-norm value asserts ~371–395) with `if strcmp(currentSolver,'ibm_cplex')`; leave the solver-agnostic non-emptiness asserts unguarded. Verify fail → passed on gurobi; assertions intact.
- [ ] T004 [US1] Run T002/T003 tests in BOTH fast and full modes and confirm passed with unchanged assertions (diff review for FR-002).

## Phase 3: User Story 2 — broaden over-strict requirements (P2)

**Goal**: tests that needlessly skip now run on an available solver. **Independent
test**: quickstart §1 — status skipped → passed on an available solver.

- [ ] T005 [P] [US2] `test/verifiedTests/dataIntegration/testMOOMIN/testMoomin.m`: drop the redundant `'requiredSolvers', {'ibm_cplex'}` from the `prepareTest` call; keep `'needsMILP', true, 'excludeSolvers', {'glpk','gurobi'}` so mosek MILP is used. Verify skipped → passed on mosek (validate mosek MILP result once); assertions unchanged.
- [ ] T006 [US2] `test/verifiedTests/reconstruction/testComputeMetFormulae/testComputeMetFormulae.m`: fix the `'requiredSolver'` typo → `'requiredSolvers', {'gurobi'}`; change the CPLEX cross-check block (~lines 249–257) to an available second LP solver (mosek or glpk) OR guard it with `if changeCobraSolver('ibm_cplex','LP',0)`. Verify skipped → passed; cross-solver assertion still runs on an available pair.
- [ ] T007 [P] [US2] `test/verifiedTests/analysis/testMultiSpeciesModelling/testMgPipe.m`: broaden `'requiredSolvers', {'ibm_cplex'}` → `'needsLP', true` (mgPipe uses only generic FBA). Note: still requires `distrib_computing_toolbox` (absent locally) so it remains a clean skip here — this edit is for correctness where PCT exists. Confirm it still skips cleanly locally (on PCT), not errors.
- [ ] T008 [US2] Verify `test/verifiedTests/analysis/testMOMA/testMOMA.m` already passes locally (gurobi provides QP+LP; its skip was an environment artifact). No edit unless it errors; if it does, diagnose (do not weaken).

## Phase 4: User Story 3 — clean skips, env-install, stray (P3)

**Goal**: environmental gaps read as clean skips (not errors), lrs tests run, stray
removed. **Independent test**: quickstart §1/§2.

- [ ] T009 [P] [US3] `test/verifiedTests/analysis/testrFBA/testdynamicRFBA.m`: stop overwriting the `solverPkgs` cell — assign the gate to a new var `testSolvers = prepareTest('requireOneSolverOf', {'tomlab_cplex','ibm_cplex'});`. Verify error → clean SKIP locally (COBRA:RequirementsNotMet); assertions untouched.
- [ ] T010 [P] [US3] `test/verifiedTests/base/testSolvers/testChangeIBMCplexParams.m`: make the line-44 condition scalar-safe: `assert(isempty(sol.full) && isequal(sol.origStat, 11))`. Locally still skips (line-11 cplex req); hardens the cplex-present path without weakening. Confirm clean skip locally.
- [ ] T011 [US3] Enable the lrs tests (FR-011): surface the install command to the user — `! sudo apt-get install -y lrslib` (or add `binary/glnxa64/bin/lrs/` to PATH) — do NOT run sudo silently. After lrs is on PATH, verify `testExtremePathways`, `testExtremePools`, `testLrsInterface` run (pass or, if lrs absent, still skip cleanly).
- [ ] T012 [US3] Remove the stray `test/test_myfunction.m` (target `myfunction` does not exist; FR-006). Confirm the suite still enumerates/runs and no coverage is lost.
- [ ] T013 [US3] Verify `testIsCompatible` passes locally (CBTDIR set + compatMatrix.rst present) and `testSampleCbModelRHMC` skips cleanly (statistics_toolbox unlicensed). Record both function/layout bugs (isCompatible.m `fid==-1`; `papers/…/TwoSidedBarrier.m` class shadowing) as out-of-scope follow-ups in `audit/out-of-scope.md`.

## Phase 5: Polish & cross-cutting

- [ ] T014 Record the post-feature status of the touched set and compute the pass-count delta (FR-008/SC-001): strictly more passed, strictly fewer errored, every identified test accounted for. Write to `audit/results.md`.
- [ ] T015 [P] Run `mcp__matlab__check_matlab_code` on every edited test file; resolve any new warnings (warnings visible; no new issues).
- [ ] T016 Confirm no previously-passing test regressed (SC-003) — run a sample of already-passing neighbours in both modes.
- [ ] T017 Write the implementation receipt under `specs/003-repair-unused-tests/agent-runs/<UTC>-<name>/implementation-receipt.md`; point human-loop.md at it.

## Dependencies & order

- T001 (baseline) first. US1 (T002–T004) is the MVP and independently shippable.
- US2 (T005–T008) and US3 (T009–T013) are independent of US1 and of each other
  (distinct files) — mostly `[P]`.
- Phase 5 after the stories.

## Accounted-for outcomes (every identified non-contributing test)

- **→ PASS**: testGenerateFieldDescriptionFile, testFVA, testMoomin, testComputeMetFormulae, (testMOMA verify), lrs trio (after install).
- **error → clean SKIP**: testdynamicRFBA, testChangeIBMCplexParams(harden; already skips).
- **stays clean SKIP (dep unobtainable)**: testFastFVA, testGeneMCS, testMtFVA, testTuneParam, testfindMIIS, testSolveCobraLPCPLEX, testOptimizeCbModelNLP, testSolveCobraNLP, testGenerateChemicalDatabase (cxcalc), testCreatePanModels (PCT), testMgPipe (PCT), testSampleCbModelRHMC (stats).
- **removed**: test_myfunction.m.
- **out-of-scope follow-up (function/layout bug)**: testIsCompatible, testSampleCbModelRHMC class shadowing.
