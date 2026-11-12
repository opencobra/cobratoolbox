# Quickstart: validating the R2026a test-failure fixes

**Prerequisites**: MATLAB R2026a; glpk, gurobi and mosek installed; the repository at this branch. In a shared
MATLAB MCP session, run `clear functions; rehash` after editing files on the sbgCloud drive. Run each start-up mode
in a fresh MATLAB process (`matlab -batch`), because the `CBT_INITIALIZED` guard makes a second call in the same
session return early.

## 1. Agent mode: solver flags and path (US1, contract items 1-4)

```matlab
initCobraToolbox(false, 'agent');
global SOLVERS CBT_NLP_SOLVER
[SOLVERS.matlab.installed, SOLVERS.mosek.installed, SOLVERS.glpk.installed, SOLVERS.pdco.installed]
CBT_NLP_SOLVER
p = strsplit(path, pathsep); nnz(contains(p, [filesep 'thermo' filesep]) & contains(p, [filesep 'new']))
```

Expected on this machine (no Optimization Toolbox): `0 1 1 1`; `CBT_NLP_SOLVER` empty; `0` `new/` folders
(6 before the fix).

## 2. The six named tests after each start-up mode (SC-001)

For `mode` in {`'agent'`, `'default'`}, in a fresh process run `initCobraToolbox(false, mode)` and then, with
`runScriptFile` (as `testAll` does): `testGetMolecularWeight`, `testOptimizeCbModelNLP`, `testFitC13Data`,
`testExtractBondSubgraphs`, `testClassifySubgraphIsomorphism`, `testEcosystemToy`.

Expected: each passes or is skipped with the missing requirement named; `testOptimizeCbModelNLP` and
`testFitC13Data` are skipped here for the missing `matlab`/NLP solver. `testEcosystemToy` passes for glpk, gurobi
and mosek.

## 3. Init test (contract)

Run `test/verifiedTests/base/testInstall/testInitCobraToolbox.m`. Expected: passes. It asserts the solver flags
against the predicates, no thermochemistry `new/` folder on the path, and mosek LP only where mosek is present.

## 4. Agent start-up time (SC-002)

Five fresh `matlab -batch` runs of `initCobraToolbox(false, 'agent')` before and after the change; compare the
medians of the time on the summary line. Expected: difference at most 1 s.

## 5. Ecosystem default threshold (US3, FR-007)

- Run `testEcosystemToy`, `testEcosystemClustering`, `testEcosystemScenarios` and `testConstrainEcosystemPoint`
  with glpk and gurobi before and after. Expected: identical outcomes.
- Run the research R5 comparison (gurobi against mosek, default `delta`). Expected: 0 qualitative-state flips.
- With `'delta', 1e-9` given explicitly under mosek, expect the 28 flips again (old behaviour preserved).

## 6. Linked worktree (US4; documented reproducibility check, see research R6)

```bash
git -C <repo> worktree add /tmp/<scratch>/wt HEAD
cp <repo>/.git/config /tmp/<scratch>/config.before
cd /tmp/<scratch>/wt && matlab -batch "initCobraToolbox(false)" 2>&1 | grep -i "git init\|remote add\|not a git repository"
cmp <repo>/.git/config /tmp/<scratch>/config.before
git -C <repo> worktree remove /tmp/<scratch>/wt
```

Expected: no `git init` or `remote add`; `cmp` reports no difference. Also run once in a non-repository copy to
confirm the old behaviour there (US4-2).

## 7. Regression (SC-004, FR-010)

Fast-mode `testAll` after each start-up mode, compared with the `develop` baseline. Expected: no test that passes
on `develop` fails here.

## 8. RunMat (research R1 runtime note)

If a RunMat binary is available, run `initCobraToolbox(false, 'runmat')` and confirm that `ver` and `license` work.
If they do not, record a new RunMat defect; do not work around it in this feature.
