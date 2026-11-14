# Implementation Receipt

**Feature**: 20261107-133937-r2026a-test-failures: fix the six R2026a fast-mode test failures and the
linked-worktree start-up finding
**Run (UTC)**: 20261114T051802Z
**Branch**: 20261107-133937-r2026a-test-failures
**MATLAB**: R2026a Update 3, Linux

## Prompt

`/speckit-implement` (no arguments) for the active feature. It executes the Gate 2 approved scope, T001-T026,
through the Spec Kit human loop. The explicit invocation is the Principle VI authorization. Push and PR need
separate confirmation.

## Final response

T001-T026 are done and committed locally on `20261107-133937-r2026a-test-failures`. Nothing was pushed.

**Results (R2026a Update 3, before → after):**
- **The six named tests:** all six now pass or skip with the missing solver named, in both start-up modes.
  - Agent mode: 6 failed before; 4 pass and 2 skip after.
  - Default mode: 3 failed before; 0 fail after.
- **Fast-mode suite:**
  - Agent mode: 600 passed, 6 failed, 24 skipped before; 603 passed, 0 failed, 27 skipped after.
  - Default mode: 601 passed, 3 failed, 26 skipped before; 604 passed, 0 failed, 26 skipped after.
- **No test that passed before fails after.** One test changed from passed to skipped: `testSolveCobraNLP` in
  agent mode, which now matches default mode.
  - Agent mode used to claim the Optimization Toolbox was installed, so the test passed without running an NLP
    solver.
- **Ecosystem threshold:** mosek now gives the same qualitative states as gurobi, with 0 of 656 differing. With
  the old threshold (`'delta', 1e-9`), 28 of 656 differ. That threshold can still be passed explicitly.
- **Agent start-up time:** median 4.1 s, against 5.8 s before. The two trees were on different disks, so the
  speed-up is not attributed to the change.
- **Linked worktree:** default start-up now leaves `.git` as a file and the main repo's git config unchanged.
- **Not verified:** RunMat (the binary won't start: `libhdf5.so.103` missing) and R2024b (not installed).

**One thing needs your decision.** Your `~/Documents/MATLAB/startup.m` adds mosek to the path *after*
`initCobraToolbox(false,'agent')`. With the fix, agent mode reports mosek as not installed at that point, so
your later `changeCobraSolver('mosek','all',0,0)` does nothing and mosek is no longer your default. Moving the
mosek `addpath` above the init, as you already do for gurobi, fixes it. That file is outside the repo, so I
haven't touched it.

Receipt: `specs/20261107-133937-r2026a-test-failures/agent-runs/20261114T051802Z-r2026a-test-failures/implementation-receipt.md`

## Diff summary

The diff is 259 insertions and 50 deletions across 9 files. The uncommitted edit to
`src/reconstruction/modelGeneration/stoichConsistency/findStoichConsistentSubset.m` is unrelated and was not
committed. No file under `src/analysis/thermo/inchi/**`, `testReactingMoieties/data/**`, `changeCobraSolver.m`,
`getQualitativeFluxStates.m`, `external/`, `deprecated/` or any submodule changed.

- **`initCobraToolbox.m` (+65/-10)**
  - **Agent mode** now probes the solvers cheaply with the new local function `isAgentSolverInstalled`.
    - Probes: `exist` on `glpkmex`, `mosekopt` and `pdco`; for `matlab`, `ver('optim')` and the
      Optimization Toolbox licence.
    - `SOLVERS.<name>.installed` and `.working` are set from the probe. The gurobi rule is unchanged.
    - `CBT_EP_SOLVER`, `CBT_CLP_SOLVER` (mosek) and `CBT_NLP_SOLVER` (matlab) are set only when that solver
      is working.
  - **Thermochemistry**: agent mode now removes the `new/` folders under the `initVonBertalanffy` base from
    the path, as default mode does.
  - **Worktree**: the git check accepts `.git` as a file (a linked worktree), so default start-up no longer
    runs `git init` there.
- **`src/analysis/ecosystem/ecosystemQualitativeFVA.m` (+12/-3)**
  - The default `delta` is now `[]`, resolved at call time to `getCobraSolverParams('LP','feasTol')`.
  - An explicit `'delta', 1e-9` restores the old behaviour. The help text and author line document both.
  - This is the default change the maintainer approved at plan time (spec Clarifications 2026-11-12).
- **`test/verifiedTests/base/testInstall/testInitCobraToolbox.m` (+42/-8)**
  - Agent mode is checked against the same presence predicates: `SOLVERS.installed` and `.working` for
    glpk, pdco, mosek and matlab, and `CBT_NLP_SOLVER`.
  - The test asserts that no thermo `new/` folder is on the path.
  - The mosek `changeCobraSolver` assertion runs only when mosek is present, and the guard is reset before
    the agent start-up.
- **`test/verifiedTests/dataIntegration/testFitC13Data/testFitC13Data.m` (1 line)**: `solverPkgs.LP{1}` is
  now `solvers.LP{1}` (an undefined name).
- **`testExtractBondSubgraphs.m` (+49/-6) and `testClassifySubgraphIsomorphism.m` (+50/-3)**
  - Error parity now goes through a local `isRecordedError` with an explicit per-release equivalence table.
  - Entries:
    - `MATLAB:UndefinedFunction` → `MATLAB:math:mustBeNumericCharOrLogical` (R2026a).
    - `MATLAB:table:IllegalVarSubscript` → its R2025a message, and → `MATLAB:table:IllegalMultipleVarDotSubscript`
      (R2026a).
  - A self-check confirms that a foreign identifier and a changed message are both still rejected.
  - The fixtures under `data/` are unchanged.
- **`test/verifiedTests/analysis/testEcosystem/testEcosystemToy.m` (+14)**: asserts that the default call
  equals an explicit `'delta', feasTol` call, and that the old `'delta', 1e-9` still runs.
- **`specs/20261107-133937-r2026a-test-failures/`**:
  - `tasks.md`: T001-T026 marked done.
  - `research.md` R5: the gurobi `FeasibilityTol` mapping is recorded.
  - `human-loop.md`: updated.
  - This receipt.

## Tests

R2026a Update 3. Each run is a fresh `matlab -batch` process with the main clone removed from the path and
`CBT_INITIALIZED` reset. Results and logs are under `results/20261107-r2026a-test-failures/` (gitignored).

**Static checks**
- `checkcode` reports no new messages: `initCobraToolbox.m` has 51 before and 51 after;
  `ecosystemQualitativeFVA.m` has 0.
- RunMat was not verified: the binary fails to start (`libhdf5.so.103: cannot open shared object file`).

**Six named tests (SC-001)**, before → after:

| Test | Agent mode | Default mode |
|---|---|---|
| testGetMolecularWeight | failed → passed | passed → passed |
| testOptimizeCbModelNLP | failed (`optimoptions` undefined) → skipped ("matlab is a required solver") | skipped → skipped |
| testFitC13Data | failed (`solverPkgs.LP`) → skipped ("requires at least one NLP solver") | skipped → skipped |
| testExtractBondSubgraphs | failed → passed | failed → passed |
| testClassifySubgraphIsomorphism | failed → passed | failed → passed |
| testEcosystemToy | failed → passed | failed → passed |

After the change, all 6 pass or skip with a named requirement in each mode.

**Fast-mode `testAll` (SC-004, FR-010)**
- Agent mode:
  - Before: passed 600, failed 6, skipped 24.
  - After: passed 603, failed 0, skipped 27.
- Default mode:
  - Before: passed 601, failed 3, skipped 26.
  - After: passed 604, failed 0, skipped 26.
- Tests that passed before and fail after: **none** in either mode. Every status change was failed→passed or failed→skipped, apart from the `testSolveCobraNLP` change below.
- `testSolveCobraNLP` in agent mode went from passed to skipped ("requires at least one NLP solver"), which is
  the same as default mode.
  - Agent mode used to report the Optimization Toolbox as installed, and the test then passed with no NLP
    solver actually run. This is the intended effect of US1.

**User stories**
- **US1**:
  - Agent and default start-up report the same solver flags ([matlab mosek glpk pdco] =
    [0 1 1 1] installed and working).
  - `CBT_NLP_SOLVER` is empty in both modes; EP and CLP use mosek, LP uses gurobi.
  - No thermo `new/` folders remain.
  - `testInitCobraToolbox` passes Tests 1-5.
- **SC-002**: agent start-up median is 4.1 s after against 5.8 s before (5 runs each; at most 1 s slower was
  allowed).
  - The before and after trees were on different disks, so the speed-up is not attributed to the change.
- **US2**: both self-checks pass (8 and 4 synthetic errors rejected).
- **US3**:
  - `testEcosystemToy` passes with glpk, gurobi and mosek in 802 s. `testEcosystemClustering`,
    `testEcosystemScenarios` and `testConstrainEcosystemPoint` pass.
  - R5 comparison of qualitative states, gurobi vs mosek: 0 of 656 flip with the new default; 28 of 656 flip
    with an explicit `'delta', 1e-9`.
  - gurobi with the default vs gurobi with 1e-9: 0 flips.
- **US4**:
  - **Linked worktree, default start-up**: `.git` stays a file, the main `.git/config` is byte-identical, and
    the remotes are unchanged.
  - **Non-repo snapshot, default start-up**: a `.git` directory is still created (`git init` plus the origin
    fetch) and the working files are left intact. US4-2 is preserved.

## Unresolved issues

- **Maintainer's `startup.m` (outside the repo).**
  - It runs `initCobraToolbox(false,'agent')` before it adds mosek to the path, then calls
    `changeCobraSolver('mosek','all',0,0)`.
  - Agent mode now reports mosek as not installed at that point, so the later call returns early and mosek
    stops being the default.
  - Fix: add the mosek folder to the path before the init, as is already done for gurobi. Raised at Gate 3;
    the file was not edited.
- **Deviation**: the file-level `prepareTest('requiredSolvers',{'mosek'})` was removed from
  `testInitCobraToolbox`. The mosek assertion inside it is now conditional, so the file-level skip is no longer
  needed.
- **C1**: the three legacy test headers that predate the III-Coverage format were not rewritten. This is a
  follow-up.
- **E1**: agent mode reporting `matlab` installed (Optimization Toolbox present) is not exercised on this
  machine.
- **E2**: the `new/` edge case, where a later default start-up follows an agent start-up in the same session,
  relies on the `CBT_INITIALIZED` guard.
- R2024b parity is argued from the equivalence table, not run (R2024b is not installed).
- **First before-baseline**: it was invalid because `startup.m` initializes the main clone in every
  `matlab -batch` process. Those logs are kept in `results/.../baseline/contaminated/`, and the baseline was
  re-run on a full copy of the tree.
