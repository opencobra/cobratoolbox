---

description: "Task list for fixing the R2026a fast-mode suite failures"
---

# Tasks: Fix the R2026a fast-mode suite failures

**Input**: Design documents from `specs/20261107-133937-r2026a-test-failures/`

**Prerequisites**: plan.md, spec.md, research.md (R0-R6), data-model.md, contracts/, quickstart.md

**Tests**: every behaviour change carries its narrowest test or, for US4, the documented reproducibility check
(research R6). Run order: narrowest first, then the fast-mode suite.

**Organization**: by user story (US1-US4, spec priorities P1, P1, P2, P3).

**Working rules for every task**: `clear functions; rehash` in the MCP MATLAB session after editing files on the
sbgCloud drive; any fresh start-up runs in a new `matlab -batch` process (the `CBT_INITIALIZED` guard makes a
second call return early); output goes under `results/20261107-r2026a-test-failures/` (gitignored); do NOT stage
the unrelated edit to `src/reconstruction/modelGeneration/stoichConsistency/findStoichConsistentSubset.m`;
`src/analysis/thermo/inchi/**` and `test/verifiedTests/analysis/testReactingMoieties/data/**` are read-only.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1-US4 from spec.md

---

## Phase 1: Setup (baselines before any edit)

**Purpose**: capture the "before" state at commit `cb1fb7394` that SC-001, SC-002 and SC-004 compare against.

- [X] T001 Record before-state outcomes of the six named tests (`testGetMolecularWeight`, `testOptimizeCbModelNLP`, `testFitC13Data`, `testExtractBondSubgraphs`, `testClassifySubgraphIsomorphism`, `testEcosystemToy`), each run through `runScriptFile` after a fresh `initCobraToolbox(false, 'agent')` and after a fresh `initCobraToolbox(false)`, into `results/20261107-r2026a-test-failures/baseline/six-tests-{agent,default}.txt`
- [X] T002 [P] Time five fresh `matlab -batch "initCobraToolbox(false, 'agent')"` runs, parse the seconds from the summary line, and save them with their median to `results/20261107-r2026a-test-failures/baseline/agent-init-times.txt` (SC-002)
- [X] T003 [P] Start the before-state fast-mode `test/testAll.m` runs in the background, one after agent start-up and one after default start-up, logging to `results/20261107-r2026a-test-failures/baseline/testAll-{agent,default}.log` (SC-004; do not wait for them before Phase 3)

---

## Phase 2: Foundational

**Purpose**: close the one open research item and fix the coding-standards checklist before editing.

- [X] T004 Locate how `feasTol` reaches gurobi's `FeasibilityTol` (search `src/base/solvers/` for `FeasibilityTol`, including the gurobi parameter builder that `solveCobraLP.m` calls) and record the file and line in `specs/20261107-133937-r2026a-test-failures/research.md` R5, replacing "is to be confirmed when implementing"
- [X] T005 [P] Load the `matlab-core:matlab-testing` and `matlab-core:matlab-review-code` skills and confirm for this feature: no `evalc`, warnings visible, no new `try/catch` (existing ones keep `ME.stack` in diagnostics), no `nargin` in new code, help text updated (constitution VII-A to VII-E)

**Checkpoint**: the stories below are independent of one another; US1, US3 and US4 all edit `initCobraToolbox.m` or ecosystem files only as listed, and US1/US4 share `initCobraToolbox.m`, so run those two in sequence.

---

## Phase 3: User Story 1 - The test suite reports only real failures after either start-up (P1) MVP

**Goal**: agent start-up reports only solvers that are present and removes the thermochemistry `new/` folders;
`testFitC13Data` reads its solver list correctly.

**Independent Test**: quickstart steps 1-3 after a fresh agent start-up, then the three US1 tests after each
start-up mode.

### Implementation

- [X] T006 [US1] In `initCobraToolbox.m`, add a local function `solverOK = isAgentSolverInstalled(solverName)` at the end of the file (with a help block) implementing the predicates of research R1: glpk `exist('glpkmex', 'file') >= 2`; mosek `exist('mosekopt', 'file') >= 2`; pdco `exist('pdco', 'file') >= 2`; matlab `~isempty(ver('optim')) && license('test', 'Optimization_Toolbox')`; any other name returns false
- [X] T007 [US1] In `initCobraToolbox.m`, agent branch of the solver check (the `for agentSolver = {'glpk', 'pdco', 'mosek', 'matlab'}` loop, about line 616): set `SOLVERS.(sname).installed` and `.working` to `isAgentSolverInstalled(sname)` instead of `true`; update the comment above it; leave the gurobi `which('gurobi')` rule unchanged (depends on T006)
- [X] T008 [US1] In `initCobraToolbox.m`, `elseif agentMode` default-solver block (about line 648): assign `CBT_EP_SOLVER = 'mosek'` and `CBT_CLP_SOLVER = 'mosek'` only if `SOLVERS.mosek.working`, and `CBT_NLP_SOLVER = 'matlab'` only if `SOLVERS.matlab.working`; update the comment that says the flags were "already marked working" (depends on T007)
- [X] T009 [US1] In `initCobraToolbox.m`, the "remove /new thermo folders" block (about line 839): add an `else` branch for agent mode that finds the thermochemistry base folder exactly as the default branch does (`which('initVonBertalanffy')`), splits `path` on `pathsep`, and calls `rmpath` on every entry that starts with that base folder and contains `[filesep 'new']`, with no console output and no disk walk; update the "(skipped in agent mode ...)" comment (research R2)
- [X] T010 [P] [US1] In `test/verifiedTests/dataIntegration/testFitC13Data/testFitC13Data.m` line 20, replace `solverPkgs.LP{1}` with `solvers.LP{1}` (research R3)
- [X] T011 [US1] In `test/verifiedTests/base/testInstall/testInitCobraToolbox.m`, Test 2 (agent mode): assert for each of glpk, pdco, mosek and matlab that `SOLVERS.(s).installed` and `.working` equal the research R1 predicate evaluated in the test; assert `CBT_NLP_SOLVER` is `'matlab'` exactly when the matlab predicate holds; assert that no path entry under the thermochemistry base folder contains `[filesep 'new']`; make the `changeCobraSolver('mosek', 'LP', 0)` assertion (line 103) run only when `exist('mosekopt', 'file') >= 2`; update the header's purpose lines to match (depends on T007-T009)

### Verification

- [X] T012 [US1] Run `checkcode` on `initCobraToolbox.m` and the two edited tests (no new messages); run `testInitCobraToolbox.m`; run quickstart step 1 in a fresh agent start-up; run `testGetMolecularWeight`, `testOptimizeCbModelNLP` and `testFitC13Data` after a fresh agent start-up and after a fresh default start-up; save outputs to `results/20261107-r2026a-test-failures/us1/` (expected: pass or skip with the requirement named; SC-001 part)
- [X] T013 [US1] Repeat T002 on the edited code into `results/20261107-r2026a-test-failures/us1/agent-init-times.txt` and compare medians (SC-002: at most 1 s slower)

**Checkpoint**: US1 complete.

---

## Phase 4: User Story 2 - Error-parity tests survive MATLAB releases (P1)

**Goal**: the parity checks accept only the recorded error or a reviewed, release-annotated equivalent.

**Independent Test**: both tests pass on R2026a and their self-checks reject the deliberately different errors.

### Implementation

- [X] T014 [P] [US2] In `test/verifiedTests/analysis/testReactingMoieties/testExtractBondSubgraphs.m`: add a local function `isRecordedError(ME, recordedIdentifier, recordedMessage)` implementing `contracts/error-parity-check.md`, with an equivalence list holding the single entry from research R4 (`MATLAB:UndefinedFunction` / "Undefined function 'eq' for input arguments of type 'cell'." -> `MATLAB:math:mustBeNumericCharOrLogical` / "Invalid data type. Argument must be numeric, char, or logical.", R2026a); use it in both error comparisons (fallback cases and peeling cases), keeping the existing failure message; add a `%%` self-check section that, for every recorded error case in `fallbackCases` and `peelingCases`, asserts the function rejects an `MException` with a foreign identifier and one with the recorded identifier and a different message; update the header (purpose, and why the list exists)
- [X] T015 [P] [US2] In `test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m`: the same local function and self-check, with the two entries from research R4 for `MATLAB:table:IllegalVarSubscript` / "Table variable names must be strings or character vectors." (-> same identifier with "A table variable name must be a string scalar or a character vector.", R2025a; -> `MATLAB:table:IllegalMultipleVarDotSubscript` with the exact R2026a message recorded in research R4, R2026a); copy the R2026a message character for character from a live run, not from the truncated research table; update the header

### Verification

- [X] T016 [US2] Run both tests on R2026a (expected: pass); confirm the self-checks executed (count of rejected synthetic errors equals 2 x the number of recorded error cases: extract 4 cases -> 8, classify 2 cases -> 4); save output to `results/20261107-r2026a-test-failures/us2/`. R2024b is not installed: record in the receipt that R2024b behaviour rests on the unchanged exact-match branch (US2-4)

**Checkpoint**: US2 complete.

---

## Phase 5: User Story 3 - Ecosystem threshold settled by the maintainer (P2)

**Goal**: the default zero threshold of `ecosystemQualitativeFVA` is the LP solver's `feasTol`
(maintainer decision 2026-11-12); explicit `delta` unchanged.

**Independent Test**: `testEcosystemToy` passes with glpk, gurobi and mosek; the R5 comparison shows 0 flips.

### Implementation

- [X] T017 [US3] In `src/analysis/ecosystem/ecosystemQualitativeFVA.m`: change the `delta` parameter default from `1e-9` to `[]`, allow empty in its validator (`isempty(x) || (isnumeric(x) && isscalar(x) && x >= 0)`), and after parsing set `delta = getCobraSolverParams('LP', 'feasTol')` when it is empty; update the help text for `delta` per `contracts/ecosystemQualitativeFVA-delta.md` (new default, reason, `'delta', 1e-9` for the old behaviour) and add a dated author-line note of the change
- [X] T018 [US3] In `test/verifiedTests/analysis/testEcosystem/testEcosystemToy.m`, inside the solver loop after the main `ecosystemQualitativeFVA` call: assert that a call on a 3-point subset (`'pointIndex'` from `ecoK.qualPointIndex(1:3)`, `'rxnList', {'EX_A_e', 'EX_B_e'}`, `'updateBounds', false`) with no `delta` gives the same `qualVectors` as the same call with `'delta', getCobraSolverParams('LP', 'feasTol')`; also assert that an explicit `'delta', 1e-9` call on that subset runs and returns states in the valid range (explicit value accepted as before); add a comment stating what each assertion proves (depends on T017)

### Verification

- [X] T019 [US3] Run `testEcosystemToy`, `testEcosystemClustering`, `testEcosystemScenarios` and `testConstrainEcosystemPoint` (expected: pass; `testEcosystemToy` now passes for glpk, gurobi and mosek); re-run the research R5 comparison script on the edited code (expected: 0 flips with the default; 28 flips with explicit `'delta', 1e-9` under mosek); save outputs to `results/20261107-r2026a-test-failures/us3/` (FR-006, FR-007, SC-001)

**Checkpoint**: US3 complete.

---

## Phase 6: User Story 4 - Start-up in a linked worktree leaves the repository alone (P3)

**Goal**: default start-up recognises a linked worktree as a git checkout.

**Independent Test**: quickstart step 6.

- [X] T020 [US4] In `initCobraToolbox.m` at the git-tracking check (about line 239), replace `exist([CBTDIR filesep '.git'], 'dir') ~= 7` with a test that is true only when `[CBTDIR filesep '.git']` is neither a folder nor a file (`~isfolder(gitPath) && ~isfile(gitPath)`), with a comment that a linked worktree's `.git` is a file (research R6) (after T009)
- [X] T021 [US4] Run quickstart step 6 (temporary linked worktree under the scratchpad, `.git/config` copied before, fresh default start-up in the worktree, `cmp` after, worktree removed) and the non-repository counter-check (US4-2); save the console output to `results/20261107-r2026a-test-failures/us4/` (SC-005)

**Checkpoint**: all stories complete.

---

## Phase 7: Polish & Cross-Cutting

- [X] T022 Rerun T001 on the edited code into `results/20261107-r2026a-test-failures/after/six-tests-{agent,default}.txt` (SC-001: 6 of 6 pass or skip for a named requirement after each mode)
- [X] T023 Run the fast-mode `test/testAll.m` after agent and after default start-up on the edited code, logging to `results/20261107-r2026a-test-failures/after/testAll-{agent,default}.log`, and compare with the T003 logs: list every test that passed before and fails after (SC-004, FR-010: expected none)
- [X] T024 [P] If a RunMat binary is available, run quickstart step 8; otherwise record "RunMat not available, not verified" in the receipt
- [X] T025 Write the implementation receipt at `specs/20261107-133937-r2026a-test-failures/agent-runs/<UTC-timestamp>-r2026a-test-failures/implementation-receipt.md` with the constitution's sections (Prompt, Final response, Diff summary, Tests, Unresolved issues), and point `specs/20261107-133937-r2026a-test-failures/human-loop.md` at it
- [X] T026 Commit the feature's changes (source, tests, receipt, spec artifacts) on the feature branch, excluding `findStoichConsistentSubset.m`; do not push or open a PR without the maintainer's explicit confirmation

---

## Dependencies & Execution Order

- **Phase 1** (T001-T003) before any edit. T003 runs in the background and is only needed by T023.
- **Phase 2** (T004, T005) before the stories; T004 only affects documentation.
- **US1**: T006 -> T007 -> T008 -> T009 -> T011 -> T012 -> T013; T010 any time.
- **US2**: T014 and T015 in parallel -> T016. Independent of US1.
- **US3**: T017 -> T018 -> T019. Independent of US1 and US2.
- **US4**: T020 after T009 (same file) -> T021.
- **Polish**: T022 and T023 after all stories; T024 any time after T009; T025 after T023; T026 last.

## Parallel Examples

- After Phase 2: T010, T014, T015 and T017 edit different files and can be done together.
- Verification runs that each need a fresh `matlab -batch` process (T012 start-ups, T013, T021, T022, T023) must not
  overlap with each other on the same MATLAB license seat if it is limited; MCP-session runs (T016, T019) can run
  between them.

## Implementation Strategy

1. MVP = US1 (T006-T013): removes the three false failures under agent start-up, which is the maintainer's setup.
2. Add US2 (two test-only edits) and US3 (one approved default change) independently.
3. US4 last (lowest priority, manual check).
4. Close with the full before/after comparison (T022, T023) and the receipt.
