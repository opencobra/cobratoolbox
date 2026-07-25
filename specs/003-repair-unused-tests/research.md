# Research — repair unused / non-contributing tests

## Baseline survey (read-only)

- 264 `test*.m` under `test/`; 261 run via `runTestSuite` (`verifiedTests/**`).
- Outside the suite: `testAll.m`, `testAll_ghActions.m` (runners), and
  `test/test_myfunction.m` — a stray `matlab.unittest` example whose target
  `myfunction` **does not exist anywhere in the repo** (0 hits) → can only error →
  remove (FR-006).
- From the most recent instrumented run: 28 always-skip (missing deps) + 10 fail/error.

## Environment feasibility (this machine) — bounds the env-install scope

Verified live:

| Dependency | Available? | Installable here? | Consequence |
|-----------|------------|-------------------|-------------|
| gurobi, mosek, glpk, pdco, quadMinos, dqqMinos | yes | — | LP/MILP/QP/MIQP covered |
| ibm_cplex, tomlab_cplex | no | no (commercial license) | tests needing them → clean skip |
| Parallel Computing Toolbox (`gcp`) | no (license 0, not installed) | no (license) | `testCreatePanModels` → guard `gcp` → clean skip |
| statistics / bioinformatics / image / gads / optimization toolboxes | no (all license 0) | no (license) | their skip-tests stay clean skips (unless over-strict) |
| **lrs** | not on PATH | **yes** — apt `lrslib` (0.71b) and a bundled `binary/glnxa64/bin/lrs/lrs` | **install/wire lrs → `testExtremePathways`, `testExtremePools`, `testLrsInterface` can run** |
| openbabel (`obabel`) | no | yes — apt `openbabel` (3.1.1) | but `testGenerateChemicalDatabase` also needs `cxcalc` (commercial) → still skips |
| cxcalc (ChemAxon) | no | no (commercial) | `testGenerateChemicalDatabase` → clean skip |

**Net env-install reality**: of the environment-dependent tests, only the **lrs**
trio is genuinely make-runnable here (install `lrslib` via apt, or put the bundled
Linux binary on PATH). Everything else env-dependent lacks a freely-obtainable
dependency and must become (or remain) a **clean skip** — not masked. The `lrs`
install changes system state (`sudo apt install lrslib`) and MUST be surfaced to the
user, not run silently (FR-011).

`testExtremePathways.m` gates on `system('which lrs')` (lines 15/21) + a
`prepareTest('requiredSoftwares', {'lrs'})` (line 19), so putting `lrs` on PATH is
what unblocks it; the lrs interface lives in
`src/analysis/topology/extremeRays/lrs/lrsInterface/`.

## Per-test repair catalogue (failing tests) — triaged

| Test | Root cause | Minimal fix (assertions preserved) | Outcome locally |
|------|-----------|-----------------------------------|-----------------|
| testGenerateFieldDescriptionFile | fopen/fscanf round-trip on a reference file deleted in `c696c3e26`; the function already returns the string | replace the fopen/fscanf lines with `refData_FileString = generateFieldDescriptionFile();` | **error → PASS** |
| testFVA | a cplex-only value assertion (PFK max within 1e-4) runs for gurobi too (block gated `{gurobi,ibm_cplex}` despite "only works on cplex" comment) | guard the value-exact assert(s) with `if strcmp(currentSolver,'ibm_cplex')` — non-emptiness asserts stay unguarded | **fail → PASS** (on gurobi) |
| testdynamicRFBA | `solverPkgs` cell (line 21) overwritten by the `prepareTest` struct (line 25) then indexed `{}`; also requires BOTH cplex variants | assign the gate to a new var: `testSolvers = prepareTest('requireOneSolverOf',{'tomlab_cplex','ibm_cplex'});` (leave the line-21 cell for the loop) | **error → clean SKIP** (cplex-only reference; no cplex locally) |
| testChangeIBMCplexParams | fragile `&` on possibly-empty operands at line 44 | `assert(isempty(sol.full) && isequal(sol.origStat, 11))` (scalar-safe, same meaning) | **hardened**; locally already skips (line-11 cplex req) |
| testIsCompatible | error is inside `isCompatible.m` (`fopen`/`fgetl` when `CBTDIR` unset) — TEST is correct | none in the test; a `fid==-1` guard belongs in `isCompatible.m` (function change → out of scope) | **verify: passes locally** (CBTDIR set + file present) |
| testSampleCbModelRHMC | class-path collision: `papers/2023_BarrierRound/.../TwoSidedBarrier.m` shadows the `src/` class that has `extraHessian` | de-dup/path-exclude the stale `papers/` copies (repo-layout, not a test edit) → out of scope | **clean SKIP locally** (needs statistics_toolbox, unlicensed) |

Verdicts: **repairable-now → PASS**: testGenerateFieldDescriptionFile, testFVA.
**repairable-now → error-to-clean-skip / harden**: testdynamicRFBA, testChangeIBMCplexParams.
**out of scope (function/layout bug)**: testIsCompatible (verify passes), testSampleCbModelRHMC (clean skip; document layout bug for a follow-up).

## Requirement-broadening candidates (skips) — triaged

| Test | Verdict | Action |
|------|---------|--------|
| testMoomin | OVER-STRICT | drop `requiredSolvers {'ibm_cplex'}`; keep `needsMILP` + `excludeSolvers {glpk,gurobi}` → mosek MILP. Validate mosek once. **Local win.** |
| testComputeMetFormulae | OVER-STRICT | fix `requiredSolver`→`requiredSolvers {'gurobi'}` (line 13 typo still enforced via inputParser partial-match); swap the CPLEX cross-check (lines 249-257) to an available 2nd LP solver (mosek/glpk) or guard it. **Local win.** |
| testMgPipe | OVER-STRICT (solver) | `requiredSolvers {'ibm_cplex'}` → `needsLP`; BUT still needs `distrib_computing_toolbox` (absent) → still skips locally. Broaden for correctness; **no local pass**. |
| testMOMA | requirement CORRECT | skip was an environment artifact — gurobi provides QP+LP. Verify `changeCobraSolver('gurobi','QP',0)` locally; **likely already passes**, no change. |
| testFastFVA, testGeneMCS, testMtFVA, testTuneParam, testfindMIIS, testSolveCobraLPCPLEX | GENUINELY-NEEDED (cplex) | leave clean skip — CPLEX-only interfaces (mex/java/conflict-refiner/param-tuning). |
| testOptimizeCbModelNLP, testSolveCobraNLP | GENUINELY-NEEDED (NLP) | leave clean skip — need an NLP backend (matlab/fmincon Optimization Toolbox or tomlab_snopt), none available. |

## Decisions

- **D1 — Categorize, then repair by category** (US1 code-bugs, US2 broadenings,
  US3 clean-skips + install + stray). Each test gets exactly one recorded outcome.
- **D2 — lrs is the only env dependency worth installing here**; do it via a
  user-surfaced `apt install lrslib` (or PATH-wire the bundled binary), then the 3
  lrs tests run. All other env deps → clean skip.
- **D3 — Never loosen assertions**; solver-numeric failures get solver-guards, not
  wider tolerances. Cplex-only assertions run only when cplex is present.
- **D4 — Verify by pass-count** (FR-008): re-run each touched test before/after and
  confirm pass (or clean skip), and that no previously-passing test broke.
